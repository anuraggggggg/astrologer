import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';

class AstrologerChatPage extends StatefulWidget {
  final String roomId;
  final String myUserId;
  final String receiverId;
  final String receiverName;
  final String? authToken;

  const AstrologerChatPage({
    super.key,
    required this.roomId,
    required this.myUserId,
    required this.receiverId,
    required this.receiverName,
    this.authToken,
  });

  @override
  State<AstrologerChatPage> createState() => _AstrologerChatPageState();
}

class _AstrologerChatPageState extends State<AstrologerChatPage> {
  final FastApiServices _api = FastApiServices();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  WebSocket? _socket;
  bool _isConnected = false;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _messages = <Map<String, dynamic>>[];

  static const int _pageSize = 20;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasMore = true;

  Timer? _reconnectTimer;
  Timer? _pollTimer;
  bool _isPolling = false;
  int _retries = 0;
  int _seq = 0;

  final Set<String> _clientSeqSeen = <String>{};
  final Map<String, int> _clientSeqIndex = {};
  final Set<String> _historyIdsSeen = <String>{};

  late String _myUserId;
  late String _roomId;
  String? _token;
  DateTime? _latestSeenAt;

  int _wsFrameCount = 0;
  String _lastWsRaw = '';
  DateTime _lastWsAt = DateTime.fromMillisecondsSinceEpoch(0);

  // Theme colors - same as customer chat
  final Color _primaryColor = const Color(0xFFFFC31F); // App yellow
  final Color _backgroundColor = Colors.white;
  final Color _cardColor = Colors.grey.shade50;
  final Color _textColor = Colors.black87;
  final Color _hintColor = Colors.grey.shade600;
  final Color _onlineColor = Colors.green;
  final Color _offlineColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _initializeUserData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
              _scrollController.position.minScrollExtent + 100 &&
          !_isFetchingMore &&
          _hasMore) {
        debugPrint('⬆️ Reached top — loading older messages...');
        _loadChatHistory(loadMore: true);
      }
    });
  }

  Future<void> _initializeUserData() async {
    debugPrint('🧠 Loading stored user data / wiring params...');
    final prefs = await SharedPreferences.getInstance();

    _myUserId = widget.myUserId.trim();
    _roomId = widget.roomId.trim();
    _token = widget.authToken ?? prefs.getString('accessToken');

    if (_myUserId.isEmpty || _roomId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Missing session details. Please try again.')),
        );
      }
      return;
    }

    await _loadChatHistory();
    if (!mounted) return;

    setState(() => _isLoading = false);
    _connectWebSocket();
    _startPolling();
  }

  // ---------------------------------------------------------------------------
  // History & Polling
  // ---------------------------------------------------------------------------

  Future<void> _loadChatHistory({bool loadMore = false}) async {
    if (_isFetchingMore || (!_hasMore && loadMore)) return;
    _isFetchingMore = true;

    try {
      final resp = await _api.getChatHistoryForAstrologerSelf(
        otherUserId: _myUserId,
        page: _currentPage,
        size: _pageSize,
      );

      final items = (resp['messages'] as List?) ?? const [];
      if (items.isEmpty) {
        setState(() => _hasMore = false);
        return;
      }

      final formatted = items
          .map((msg) {
            final raw = Map<String, dynamic>.from(msg as Map);
            final id = (raw['id'] ?? '').toString();
            final sender = (raw['sender_id'] ?? '').toString();
            final text = (raw['content'] ?? raw['message'] ?? '').toString();
            final ts = (raw['created_at'] ?? DateTime.now().toIso8601String())
                .toString();
            final room = (raw['room_id'] ?? '').toString();

            return <String, dynamic>{
              'sender_id': sender,
              'message': text,
              'created_at': ts,
              if (id.isNotEmpty) 'server_id': id,
              if (room.isNotEmpty) 'room_id': room,
            };
          })
          .where((m) => (m['room_id'] == null) || (m['room_id'] == _roomId))
          .toList();

      if (loadMore) {
        final oldOffset = _scrollController.offset;
        final oldMax = _scrollController.position.maxScrollExtent;

        setState(() {
          for (final m in formatted) {
            _addMessageIfNew(m);
          }
          _messages.sort((a, b) =>
              (DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0))
                  .compareTo(
                      DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0)));
          _currentPage++;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final newMax = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(newMax - oldMax + oldOffset);
        });
      } else {
        final fresh = <Map<String, dynamic>>[];
        for (final m in formatted) {
          if (_addMessageIfNew(m)) fresh.add(m);
        }
        setState(() {
          _messages
            ..clear()
            ..addAll(fresh);
        });
        _maybeScrollToBottom(force: true);
      }

      if (formatted.length < _pageSize) {
        setState(() => _hasMore = false);
      }
    } catch (e, st) {
      debugPrint('❌ Error loading chat history: $e\n$st');
    } finally {
      _isFetchingMore = false;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _pollForUpdates());
  }

  Future<void> _pollForUpdates() async {
    if (_isPolling) return;
    _isPolling = true;

    try {
      final resp = await _api.getChatHistoryForAstrologerSelf(
        otherUserId: _myUserId,
        page: 1,
        size: 10,
      );

      final items = (resp['messages'] as List?) ?? [];
      if (items.isEmpty) return;

      final candidates = items
          .map((msg) {
            final raw = Map<String, dynamic>.from(msg as Map);
            final id = (raw['id'] ?? '').toString();
            final roomId = (raw['room_id'] ?? '').toString();
            if (roomId.isNotEmpty && roomId != _roomId)
              return <String, dynamic>{};
            if (id.isNotEmpty && _historyIdsSeen.contains(id))
              return <String, dynamic>{};

            return <String, dynamic>{
              'sender_id': (raw['sender_id'] ?? '').toString(),
              'message': (raw['content'] ?? raw['message'] ?? '').toString(),
              'created_at':
                  (raw['created_at'] ?? DateTime.now().toIso8601String())
                      .toString(),
              if (id.isNotEmpty) 'server_id': id,
              if (roomId.isNotEmpty) 'room_id': roomId,
            };
          })
          .where((m) => m.isNotEmpty)
          .toList();

      candidates.sort((a, b) {
        final ta = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0);
        final tb = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0);
        return ta.compareTo(tb);
      });

      bool added = false;
      for (final m in candidates) {
        if (_addMessageIfNew(m)) added = true;
      }

      if (added && mounted) {
        setState(() {});
        _maybeScrollToBottom();
      }
    } catch (e, st) {
      debugPrint('⚠️ Poll failed: $e\n$st');
    } finally {
      _isPolling = false;
    }
  }

  // ---------------------------------------------------------------------------
  // WebSocket
  // ---------------------------------------------------------------------------

  Future<void> _connectWebSocket() async {
    if (_socket != null) return;

    final prefs = await SharedPreferences.getInstance();
    _token = _token ?? prefs.getString('accessToken');

    final wsUrl = Uri(
      scheme: 'wss',
      host: 'fastapi.jyotishionline.com',
      path: '/chat/ws/$_roomId',
      queryParameters: {
        if (_token != null && _token!.isNotEmpty) 'token': _token!,
        'user_id': _myUserId,
        'role': 'astrologer',
      },
    );

    debugPrint('🌐 Connecting WS: $wsUrl');

    try {
      final socket = await WebSocket.connect(wsUrl.toString());
      if (!mounted) {
        socket.close();
        return;
      }
      _socket = socket;
      _socket!.pingInterval = const Duration(seconds: 20);

      _retries = 0;
      setState(() => _isConnected = true);
      debugPrint('✅ WebSocket connected');

      _sendRaw({
        "action": "join",
        "type": "join",
        "event": "subscribe",
        "room": _roomId,
        "room_id": _roomId,
        "user_id": _myUserId,
        "sender_id": _myUserId,
        "receiver_id": widget.receiverId,
        "role": "astrologer",
        "token": _token,
      });

      _socket!.listen(
        (data) {
          _lastWsAt = DateTime.now();
          try {
            _wsFrameCount++;
            _lastWsRaw = data is String ? data : utf8.decode(data as List<int>);
            debugPrint('⬅️ WS #$_wsFrameCount: $_lastWsRaw');
          } catch (_) {}
          _handleIncomingMessage(data);
        },
        onDone: _handleDisconnect,
        onError: (error, st) {
          debugPrint('⚠️ WebSocket error: $error');
          _handleDisconnect();
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('❌ WS connect failed: $e');
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    debugPrint('❌ WS disconnected');
    if (mounted) setState(() => _isConnected = false);
    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!mounted) return;
    if (_reconnectTimer?.isActive ?? false) return;
    final delaySecs = [2, 5, 10, 20, 30][_retries.clamp(0, 4)];
    debugPrint('🔁 Reconnect in $delaySecs s (attempt ${_retries + 1})…');
    _reconnectTimer = Timer(Duration(seconds: delaySecs), () {
      _retries++;
      _connectWebSocket();
    });
  }

  // ---------------------------------------------------------------------------
  // Message handling
  // ---------------------------------------------------------------------------

  String? _extractClientSeqId(Map<String, dynamic> map) {
    for (final k in const [
      'client_sequence_id',
      'client_seq',
      'cid',
      'clientId',
      'client_id'
    ]) {
      final v = map[k];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    for (final k in const ['message_obj', 'data', 'payload']) {
      final v = map[k];
      if (v is Map) {
        final nested = _extractClientSeqId(Map<String, dynamic>.from(v));
        if (nested != null) return nested;
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractMessage(dynamic node) {
    if (node == null) return null;
    if (node is String) return null;

    if (node is List) {
      for (final item in node) {
        final found = _extractMessage(item);
        if (found != null) return found;
      }
      return null;
    }

    if (node is Map) {
      final map = Map<String, dynamic>.from(node);

      for (final k in const [
        'message',
        'data',
        'payload',
        'detail',
        'result',
        'message_obj',
        'event',
        'record',
        'value'
      ]) {
        if (map.containsKey(k) && map[k] is Map) {
          final found = _extractMessage(map[k]);
          if (found != null) return found;
        }
      }

      final content =
          (map['content'] ?? map['message'] ?? map['text'] ?? map['body']);
      if (content != null && content.toString().trim().isNotEmpty) {
        final created = (map['created_at'] ??
                map['timestamp'] ??
                map['time'] ??
                DateTime.now().toIso8601String())
            .toString();
        final out = <String, dynamic>{
          'sender_id': (map['sender_id'] ?? map['user_id'] ?? map['from'] ?? '')
              .toString(),
          'message': content.toString(),
          'created_at': created,
        };
        if (map['id'] != null) out['server_id'] = map['id'].toString();
        if (map['room_id'] != null) out['room_id'] = map['room_id'].toString();
        final cid = _extractClientSeqId(map);
        if (cid != null) out['client_sequence_id'] = cid;
        return out;
      }
    }
    return null;
  }

  void _handleIncomingMessage(dynamic data) {
    try {
      final raw = data is String ? data : utf8.decode(data as List<int>);
      final parsed = jsonDecode(raw);

      final msg = _extractMessage(parsed);
      if (msg == null) {
        if (parsed is Map &&
            (parsed['type'] == 'pong' ||
                parsed['type'] == 'ping' ||
                parsed['action'] == 'join' ||
                parsed['event'] == 'joined')) {
          return;
        }
        debugPrint('ℹ️ WS frame had no message content, ignored.');
        return;
      }

      final room = (msg['room_id'] ?? '').toString();
      if (room.isNotEmpty && room != _roomId) {
        debugPrint('↩️ Ignored message for other room: $room');
        return;
      }

      if (_addMessageIfNew(msg) && mounted) {
        setState(() {});
        _maybeScrollToBottom();
      }
    } catch (e, st) {
      debugPrint('❌ Failed to decode WS message: $e\n$st\ndata=$data');
    }
  }

  bool _addMessageIfNew(Map<String, dynamic> m) {
    final cid = (m['client_sequence_id'] ?? '').toString();
    final sid = (m['server_id'] ?? '').toString();

    if (cid.isNotEmpty) {
      if (_clientSeqSeen.contains(cid)) {
        final idx = _clientSeqIndex[cid];
        if (idx != null && idx >= 0 && idx < _messages.length) {
          _messages[idx]['created_at'] =
              m['created_at'] ?? _messages[idx]['created_at'];
          if (sid.isNotEmpty) _messages[idx]['server_id'] = sid;
          return false;
        }
        return false;
      }
    }

    if (sid.isNotEmpty && _historyIdsSeen.contains(sid)) {
      return false;
    }

    final s = (m['sender_id'] ?? '').toString();
    final c = (m['message'] ?? '').toString().trim();
    final t =
        DateTime.tryParse((m['created_at'] ?? '').toString()) ?? DateTime.now();

    for (var i = _messages.length - 1;
        i >= 0 && i >= _messages.length - 20;
        i--) {
      final mm = _messages[i];
      final ms = (mm['sender_id'] ?? '').toString();
      final mc = (mm['message'] ?? '').toString().trim();
      final mt =
          DateTime.tryParse((mm['created_at'] ?? '').toString()) ?? DateTime(0);
      if (ms == s &&
          mc == c &&
          (t.difference(mt).inMilliseconds).abs() <= 2000) {
        return false;
      }
    }

    final addedIndex = _messages.length;
    _messages.add(m);

    if (cid.isNotEmpty) {
      _clientSeqSeen.add(cid);
      _clientSeqIndex[cid] = addedIndex;
    }
    if (sid.isNotEmpty) {
      _historyIdsSeen.add(sid);
    }

    _updateLatestSeenAt(m['created_at']);
    return true;
  }

  void _updateLatestSeenAt(String? iso) {
    if (iso == null) return;
    final dt = DateTime.tryParse(iso);
    if (dt == null) return;
    if (_latestSeenAt == null || dt.isAfter(_latestSeenAt!)) {
      _latestSeenAt = dt;
    }
  }

  // ---------------------------------------------------------------------------
  // Send
  // ---------------------------------------------------------------------------

  void _sendRaw(Map<String, dynamic> map) {
    if (_socket == null) {
      debugPrint('🚫 _sendRaw while socket=null');
      return;
    }
    try {
      _socket!.add(jsonEncode(Map<String, dynamic>.from(map)));
    } catch (e, st) {
      debugPrint('❌ _sendRaw failed: $e\n$st\npayload=$map');
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (!_isConnected || _socket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecting… please wait')),
      );
      _connectWebSocket();
      return;
    }

    final clientId =
        'c:${_myUserId}:${DateTime.now().millisecondsSinceEpoch}:${_seq++}';
    final nowIso = DateTime.now().toIso8601String();

    final payload = {
      "action": "send",
      "type": "message",
      "event": "message",
      "room": _roomId,
      "room_id": _roomId,
      "sender_id": _myUserId,
      "user_id": _myUserId,
      "receiver_id": widget.receiverId,
      "role": "astrologer",
      "content": text,
      "message": text,
      "client_sequence_id": clientId,
      "message_obj": {
        "room_id": _roomId,
        "sender_id": _myUserId,
        "receiver_id": widget.receiverId,
        "role": "astrologer",
        "content": text,
        "client_sequence_id": clientId,
        "created_at": nowIso,
        "token": _token,
      }
    };

    debugPrint('➡️ WS SEND: ${jsonEncode(payload)}');
    _sendRaw(payload);

    final local = <String, dynamic>{
      "sender_id": _myUserId,
      "message": text,
      "created_at": nowIso,
      "client_sequence_id": clientId,
      "room_id": _roomId,
    };
    _addMessageIfNew(local);

    setState(() {
      _controller.clear();
    });
    _maybeScrollToBottom(force: true);
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  void _maybeScrollToBottom({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final atBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 80;
      if (force || atBottom) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    try {
      _socket?.close();
    } catch (_) {}
    _reconnectTimer?.cancel();
    _pollTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Enhanced UI - Same as customer chat
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final canSend = _isConnected && _socket != null;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 2,
        shadowColor: _primaryColor.withOpacity(0.3),
        title: Row(
          children: [
            // Profile avatar circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                    color: _primaryColor.withOpacity(0.5), width: 1.5),
              ),
              child: Icon(
                Icons.person,
                color: _primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isConnected ? _onlineColor : _offlineColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isConnected ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _backgroundColor,
                          _cardColor.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: _buildMessageList(),
                  ),
                ),
                _buildInputBox(canSend: canSend),
              ],
            ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading chat...',
            style: TextStyle(
              color: _textColor.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Stack(
      children: [
        // Background pattern
        Opacity(
          opacity: 0.03,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('assets/pattern.png'), // Add your pattern asset
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
        ),

        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _messages.length + (_isFetchingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (_isFetchingMore && index == 0) {
              return _buildLoadingMoreIndicator();
            }

            final msg = _messages[_isFetchingMore ? index - 1 : index];
            final isMine = msg['sender_id']?.toString() == _myUserId;

            return _buildMessageBubble(msg, isMine);
          },
        ),
      ],
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Loading older messages...',
                style: TextStyle(
                  color: _textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMine) {
    final messageTime = DateTime.tryParse(msg['created_at'] ?? '');
    final timeString = messageTime != null
        ? '${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}'
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: _primaryColor,
                size: 16,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMine ? _primaryColor : _cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMine
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isMine
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (msg['message'] ?? '').toString(),
                    style: TextStyle(
                      color: isMine ? Colors.white : _textColor,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeString,
                    style: TextStyle(
                      color:
                          isMine ? Colors.white.withOpacity(0.7) : _hintColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMine)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: _primaryColor,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBox({required bool canSend}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: _hintColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (_) {
                  if (canSend) {
                    _sendMessage();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: canSend ? _primaryColor : _primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
              boxShadow: canSend
                  ? [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
              onPressed: canSend ? _sendMessage : null,
              tooltip: canSend ? 'Send message' : 'Connecting...',
            ),
          ),
        ],
      ),
    );
  }
}
