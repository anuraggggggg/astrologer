import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Your API service that returns paged history for the astrologer
import 'package:astrowaypartner/fastApi/fastApiServices.dart';

class AstrologerChatPage extends StatefulWidget {
  final String roomId;
  final String myUserId; // astrologer (me)
  final String receiverId; // customer (other)
  final String? authToken;

  const AstrologerChatPage({
    super.key,
    required this.roomId,
    required this.myUserId,
    required this.receiverId,
    this.authToken,
  });

  @override
  State<AstrologerChatPage> createState() => _AstrologerChatPageState();
}

class _AstrologerChatPageState extends State<AstrologerChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FastApiServices _api = FastApiServices();

  WebSocket? _socket;
  bool _connected = false;
  bool _joined = false;
  bool _manuallyClosed = false;
  String? _token; // resolved token (widget.authToken or prefs)
  String? _lastError; // for UI banner

  final List<Map<String, dynamic>> _messages =
      []; // {from,text,time,id?,optimistic_id?}
  final Set<String> _seenIds = {}; // server ids
  final Set<String> _seenKeys = {}; // content-only key: "sender|content"

  // history paging
  int _page = 1;
  final int _size = 20;
  bool _histLoading = false;
  bool _histHasMore = true;

  // timers
  Timer? _reconnectTimer;
  Timer? _pollTimer;
  DateTime _lastFrameAt = DateTime.fromMillisecondsSinceEpoch(0);
  int _retries = 0;

  // optimistic
  int _optCounter = 0;
  DateTime? _lastSentAt; // pause polling briefly after send

  String get _me => widget.myUserId.trim(); // astrologer (self)
  String get _other => widget.receiverId.trim(); // customer

  @override
  void initState() {
    super.initState();
    debugPrint(
        '🧭 [AstroChat] init room=${widget.roomId} me=$_me other=$_other tokenProvided=${widget.authToken != null}');
    _bootstrap();
    _scroll.addListener(() {
      if (_scroll.position.pixels <= _scroll.position.minScrollExtent + 24) {
        _loadHistory();
      }
    });
  }

  Future<void> _bootstrap() async {
    // Resolve token (use same storage key as your working app)
    final prefs = await SharedPreferences.getInstance();
    _token = widget.authToken ??
        prefs.getString('accessToken') ??
        prefs.getString('access_token');
    debugPrint(
        '🧭 [AstroChat] token resolved? ${_token != null && _token!.isNotEmpty}');

    // Load initial history — 🔑 pass ASTRO ID (self), not customer
    await _loadHistory(initial: true);

    if (!mounted) return;
    _connectWS();
  }

  @override
  void dispose() {
    _manuallyClosed = true;
    _pollTimer?.cancel();
    try {
      _socket?.close();
    } catch (_) {}
    _reconnectTimer?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ---------- Reconcile helper (optimistic -> server copy) ----------
  bool _tryReconcileOptimistic({
    required String sender,
    required String text,
    required String ts,
    required String id,
  }) {
    // Only reconcile "my" messages
    if (sender != _me) return false;

    for (int i = _messages.length - 1; i >= 0; i--) {
      final m = _messages[i];
      final hasOpt = (m['optimistic_id'] ?? '').toString().isNotEmpty;
      final isMe = (m['from'] ?? '') == _me;
      if (!hasOpt || !isMe) continue;

      final sameText = (m['text'] ?? '').toString().trim() == text.trim();
      if (sameText) {
        setState(() {
          _messages[i] = {
            "from": _me,
            "text": text,
            "time": ts,
            if (id.isNotEmpty) "id": id,
          };
        });
        // Remember we have this content so later frames with different ts won't add again
        _seenKeys.add('$_me|${text.trim()}');
        if (id.isNotEmpty) _seenIds.add(id);
        return true;
      }
    }
    return false;
  }

  // -------------------- History --------------------
  Future<void> _loadHistory({bool initial = false}) async {
    if (_histLoading || !_histHasMore) return;
    setState(() => _histLoading = true);

    try {
      // 🔁 Use astrologer id (self) for history
      debugPrint(
          '🧭 [AstroChat] history: selfAstroId=$_me page=$_page size=$_size');
      final resp = await _api.getChatHistoryForAstrologerSelf(
        otherUserId: _me, // ✅ backend expects astrologer/self id here
        page: _page,
        size: _size,
      );

      final items = (resp['messages'] as List?) ?? const [];
      debugPrint('🧭 [AstroChat] history got ${items.length} items');

      if (items.isEmpty) {
        setState(() {
          _histHasMore = false;
          _histLoading = false;
        });
        return;
      }

      final List<Map<String, dynamic>> batch = [];
      for (final raw in items) {
        final m = Map<String, dynamic>.from(raw as Map);
        final id = (m['id'] ?? '').toString();
        final sender = (m['sender_id'] ?? '').toString();
        final text = (m['content'] ?? m['message'] ?? '').toString();
        final ts =
            (m['created_at'] ?? DateTime.now().toIso8601String()).toString();

        if (text.isEmpty) continue;

        if (id.isNotEmpty && _seenIds.contains(id)) continue;
        if (id.isNotEmpty) _seenIds.add(id);

        // 👇 De-dupe by content-only key (timestamps differ between optimistic/server)
        final key = '$sender|${text.trim()}';
        if (_seenKeys.contains(key)) continue;
        _seenKeys.add(key);

        batch.add({"from": sender, "text": text, "time": ts, "id": id});
      }

      batch.sort((a, b) =>
          DateTime.parse(a['time']).compareTo(DateTime.parse(b['time'])));

      if (initial) {
        setState(() {
          _messages
            ..clear()
            ..addAll(batch);
          _page++;
        });
        _scrollToBottom(immediate: true);
      } else {
        final oldMax = _scroll.position.maxScrollExtent;
        setState(() {
          _messages.insertAll(0, batch);
          _page++;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final newMax = _scroll.position.maxScrollExtent;
          _scroll.jumpTo(_scroll.offset + (newMax - oldMax));
        });
      }
    } catch (e, st) {
      debugPrint('💥 [AstroChat] history error: $e\n$st');
      setState(() => _lastError = 'History error: $e');
    } finally {
      if (mounted) setState(() => _histLoading = false);
    }
  }

  // -------------------- WebSocket --------------------
  Uri _buildWsUri() {
    final qp = <String, String>{
      'user_id': _me,
      'role': 'astrologer',
      if ((_token ?? '').isNotEmpty) 'token': _token!,
    };
    final uri = Uri(
      scheme: 'wss',
      host: 'fastapi.jyotishionline.com',
      path: '/chat/ws/${widget.roomId}',
      queryParameters: qp,
    );
    debugPrint('🌐 [AstroChat] WS URI: $uri');
    return uri;
  }

  Future<void> _connectWS() async {
    if (_socket != null) return;

    final uri = _buildWsUri();
    try {
      debugPrint('🧭 [AstroChat] connecting...');
      final s = await WebSocket.connect(uri.toString());

      if (!mounted) {
        try {
          s.close();
        } catch (_) {}
        return;
      }

      _socket = s;
      _socket!.pingInterval = const Duration(seconds: 20);
      _connected = true;
      _retries = 0;
      _lastError = null;
      debugPrint('✅ [AstroChat] connected');
      setState(() {});

      _listenSocket();
      _sendJoin();
      _startPolling();
    } catch (e, st) {
      debugPrint('💥 [AstroChat] connect failed: $e\n$st');
      setState(() {
        _connected = false;
        _lastError = 'WS connect failed: $e';
      });
      _scheduleReconnect();
    }
  }

  void _listenSocket() {
    _socket?.listen(
      (data) {
        _lastFrameAt = DateTime.now();
        try {
          final raw = data is String ? data : utf8.decode(data as List<int>);
          debugPrint('⬅️ [AstroChat] FRAME $raw');
        } catch (_) {}
        _onIncoming(data);
      },
      onDone: () {
        debugPrint('⚠️ [AstroChat] onDone');
        _handleDisconnect('Socket closed');
      },
      onError: (err, st) {
        debugPrint('⚠️ [AstroChat] onError: $err');
        _handleDisconnect('WS error: $err');
      },
      cancelOnError: false,
    );
  }

  void _handleDisconnect(String reason) {
    setState(() {
      _connected = false;
      _joined = false;
      _lastError = reason;
    });
    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;
    _pollTimer?.cancel();
    if (!_manuallyClosed) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_manuallyClosed) return;
    _reconnectTimer?.cancel();
    _retries++;
    final backoff = [2, 5, 10, 20, 30][_retries.clamp(0, 4)];
    debugPrint('🔁 [AstroChat] reconnect in ${backoff}s (attempt $_retries)');
    _reconnectTimer = Timer(Duration(seconds: backoff), _connectWS);
  }

  void _sendJoin() {
    if (!_connected || _socket == null) return;

    final join = {
      "action": "join",
      "type": "join",
      "event": "subscribe",
      "room": widget.roomId,
      "room_id": widget.roomId,
      "user_id": _me,
      "sender_id": _me,
      "receiver_id": _other,
      "role": "astrologer",
      if ((_token ?? '').isNotEmpty) "token": _token,
    };
    _sendRaw(join);
    _joined = true;
  }

  void _onIncoming(dynamic data) {
    Map<String, dynamic>? root;
    try {
      final raw = data is String ? data : utf8.decode(data as List<int>);
      if (raw.trim().isEmpty) return;

      if (raw.trim().startsWith('[')) {
        final list = jsonDecode(raw) as List;
        for (final item in list) {
          _onIncoming(item);
        }
        return;
      }
      root = data is String
          ? jsonDecode(data) as Map<String, dynamic>
          : Map<String, dynamic>.from(data as Map);
    } catch (_) {
      return;
    }
    if (root == null) return;

    final type = (root['type'] ?? root['action'])?.toString();
    if (type == 'ping' || type == 'pong' || type == 'joined' || type == 'join')
      return;

    // unwrap typical containers
    Map<String, dynamic> msg;
    if (root['message'] is Map) {
      msg = Map<String, dynamic>.from(root['message']);
    } else if (root['data'] is Map) {
      msg = Map<String, dynamic>.from(root['data']);
    } else {
      msg = root;
    }

    final serverId = (msg['id'] ?? '').toString();
    final content = (msg['content'] ?? msg['message'] ?? msg['text'] ?? '')
        .toString()
        .trim();
    if (content.isEmpty) return;

    final sender =
        (msg['sender_id'] ?? msg['user_id'] ?? msg['from'] ?? '').toString();
    final ts = (msg['created_at'] ??
            msg['timestamp'] ??
            msg['time'] ??
            DateTime.now().toIso8601String())
        .toString();

    // if my echo arrives with an ID, reconcile optimistic bubble
    if (sender == _me && serverId.isNotEmpty) {
      _seenIds.add(serverId);
      if (_tryReconcileOptimistic(
          sender: sender, text: content, ts: ts, id: serverId)) {
        return;
      }
      // fallback: add if no optimistic bubble found
      setState(() {
        _messages
            .add({"from": _me, "text": content, "time": ts, "id": serverId});
      });
      _seenKeys.add('$_me|${content.trim()}');
      _scrollToBottom();
      return;
    }

    // normal incoming
    if (serverId.isNotEmpty && _seenIds.contains(serverId)) return;
    if (serverId.isNotEmpty) _seenIds.add(serverId);

    // ✅ Try reconcile (in case server marks echo without sender==_me for some reason)
    if (_tryReconcileOptimistic(
        sender: sender, text: content, ts: ts, id: serverId)) {
      return;
    }

    // content-only de-dupe (timestamps differ)
    final key = '$sender|${content.trim()}';
    if (_seenKeys.contains(key)) return;
    _seenKeys.add(key);

    setState(() {
      _messages
          .add({"from": sender, "text": content, "time": ts, "id": serverId});
    });
    _scrollToBottom();
  }

  // -------------------- Polling fallback (3s) --------------------
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!_connected || !_joined) return;

      // Don't poll if we've received a frame recently OR just sent a message
      if (DateTime.now().difference(_lastFrameAt) < const Duration(seconds: 2))
        return;
      if (_lastSentAt != null &&
          DateTime.now().difference(_lastSentAt!) < const Duration(seconds: 4))
        return;

      try {
        // 🔁 Poll with ASTRO ID (self)
        final resp = await _api.getChatHistoryForAstrologerSelf(
          otherUserId: _me, // ✅ self id
          page: 1,
          size: 10,
        );

        final items = (resp['messages'] as List?) ?? const [];
        for (final raw in items.reversed) {
          final m = Map<String, dynamic>.from(raw as Map);
          final id = (m['id'] ?? '').toString();
          final sender = (m['sender_id'] ?? '').toString();
          final text = (m['content'] ?? m['message'] ?? '').toString();
          final ts = (m['created_at'] ?? '').toString();

          if (text.isEmpty || ts.isEmpty) continue;
          if (id.isNotEmpty && _seenIds.contains(id)) continue;

          // ✅ Reconcile with optimistic bubble first
          if (_tryReconcileOptimistic(
              sender: sender, text: text, ts: ts, id: id)) {
            continue;
          }

          // Secondary de-dupe by content
          final key = '$sender|${text.trim()}';
          if (_seenKeys.contains(key)) continue;

          if (id.isNotEmpty) _seenIds.add(id);
          _seenKeys.add(key);

          if (!mounted) return;

          setState(() {
            _messages.add({"from": sender, "text": text, "time": ts, "id": id});
          });
          _scrollToBottom();
        }
      } catch (_) {
        // ignore; retry next tick
      }
    });
  }

  // -------------------- Send --------------------
  void _sendRaw(Map<String, dynamic> map) {
    if (!_connected || _socket == null) {
      debugPrint('🚫 [AstroChat] send while disconnected');
      setState(() => _lastError = 'Sending while disconnected');
      return;
    }
    try {
      final payload = jsonEncode(map);
      debugPrint('➡️ [AstroChat] SEND $payload');
      _socket!.add(payload);
    } catch (e, st) {
      debugPrint('💥 [AstroChat] send failed: $e\n$st');
      setState(() => _lastError = 'Send failed: $e');
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (!_joined) _sendJoin();

    _optCounter++;
    final optId =
        'opt_${_me}_${DateTime.now().millisecondsSinceEpoch}_$_optCounter';

    final frame = {
      "action": "send",
      "type": "message",
      "event": "message",
      "room": widget.roomId,
      "room_id": widget.roomId,
      "sender_id": _me,
      "user_id": _me,
      "receiver_id": _other,
      "role": "astrologer",
      "content": text,
      "message": text, // some servers require both
      if ((_token ?? '').isNotEmpty) "token": _token,
      "message_obj": {
        "room_id": widget.roomId,
        "sender_id": _me,
        "receiver_id": _other,
        "role": "astrologer",
        "content": text,
        "created_at": DateTime.now().toIso8601String(),
        "token": _token,
      }
    };

    // optimistic UI
    final ts = DateTime.now().toIso8601String();
    setState(() {
      _messages
          .add({"from": _me, "text": text, "time": ts, "optimistic_id": optId});
      _lastError = null;
    });
    _controller.clear();
    _scrollToBottom();

    // mark last sent to pause polling briefly
    _lastSentAt = DateTime.now();

    _sendRaw(frame);
  }

  // -------------------- UI helpers --------------------
  void _scrollToBottom({bool immediate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: Duration(milliseconds: immediate ? 1 : 200),
        curve: Curves.easeOut,
      );
    });
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    final canSend = _connected;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _connected ? Colors.greenAccent : Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
            const Text('Chat (Astrologer)'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_histLoading) const LinearProgressIndicator(minHeight: 2),
          if (_lastError != null)
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '⚠️ ${_lastError!}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('No messages yet...',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    controller: _scroll,
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      final isMe = (m['from'] ?? '') == _me;
                      final isOpt =
                          (m['optimistic_id'] ?? '').toString().isNotEmpty;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isMe
                                ? (isOpt
                                    ? Colors.deepPurple.withOpacity(0.6)
                                    : Colors.deepPurple.withOpacity(0.85))
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: Radius.circular(isMe ? 12 : 2),
                              bottomRight: Radius.circular(isMe ? 2 : 12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                (m['text'] ?? '').toString(),
                                style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black87,
                                    height: 1.25),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isOpt)
                                    const Icon(Icons.access_time,
                                        size: 10, color: Colors.white70),
                                  Text(
                                    DateFormat('hh:mm a').format(
                                      DateTime.tryParse(m['time'] ?? '') ??
                                          DateTime.now(),
                                    ),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe
                                          ? Colors.white70
                                          : Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildInput(canSend: canSend),
        ],
      ),
    );
  }

  Widget _buildInput({required bool canSend}) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: canSend,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: canSend ? 'Type a message...' : 'Connecting…',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: canSend ? _sendMessage : null,
              icon: const Icon(Icons.send),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (!canSend) return Colors.grey.shade300;
                  return Colors.deepPurple;
                }),
                foregroundColor: WidgetStateProperty.all(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
