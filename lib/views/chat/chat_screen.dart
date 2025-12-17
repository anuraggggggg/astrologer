import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';

class AstrologerChatPage extends StatefulWidget {
  final String roomId;
  final String myUserId; // ASTRO ID
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
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  WebSocket? _socket;
  bool _connected = false;
  bool _loading = true;

  final List<Map<String, dynamic>> _messages = [];

  late String _roomId;
  late String _myUserId;
  late String _token;

  int _page = 1;
  final int _pageSize = 20;
  int _total = 0;
  bool _isFetchingMore = false;
  bool _hasMore = true;

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 ChatPage initState');

    _scrollCtrl.addListener(() {
      debugPrint(
          '📜 Scroll offset=${_scrollCtrl.position.pixels.toStringAsFixed(1)}');

      if (_scrollCtrl.position.pixels <= 100 &&
          !_isFetchingMore &&
          _hasMore &&
          !_loading) {
        debugPrint('⬆️ TOP reached → triggering pagination');
        _loadHistory(loadMore: true);
      }
    });

    _init();
  }

  Future<void> _init() async {

    debugPrint('🧠 [_init] START');
    debugPrint('🧠 [_init] ROOM ID = ${widget.roomId}');
    debugPrint('🧠 [_init] ASTRO ID = ${widget.myUserId}');
    debugPrint('🧠 [_init] RECEIVER ID = ${widget.receiverId}');
    debugPrint('🧠 [_init] Loading SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();

    _roomId = widget.roomId.trim();
    _myUserId = widget.myUserId.trim();
    _token = widget.authToken ?? prefs.getString('access_token') ?? '';

    debugPrint('🧠 [_init] roomId=$_roomId');
    debugPrint('🧠 [_init] astroId=$_myUserId');
    debugPrint('🧠 [_init] token=${_token.isNotEmpty ? "FOUND" : "MISSING"}');

    if (_roomId.isEmpty || _myUserId.isEmpty || _token.isEmpty) {
      debugPrint('❌ [_init] Missing required chat params');
      return;
    }

    await _loadHistory();
    if (!mounted) return;

    setState(() => _loading = false);
    debugPrint('🟢 [_init] History loaded → connecting WebSocket');
    _connectWebSocket();
  }

  // ---------------------------------------------------------------------------
  // HISTORY (PAGINATION)
  // ---------------------------------------------------------------------------

  Future<void> _loadHistory({bool loadMore = false}) async {
    if (_isFetchingMore) {
      debugPrint('⏸️ [_loadHistory] Already fetching, skipping');
      return;
    }

    _isFetchingMore = true;

    debugPrint(
        '📜 [_loadHistory] START page=$_page size=$_pageSize loadMore=$loadMore');

    try {
      final resp = await _api.getChatHistoryForAstrologerSelf(
        otherUserId: widget.receiverId,
        page: _page,
        size: _pageSize,
      );

      final items = resp['messages'] as List? ?? [];
      _total = resp['total'] ?? 0;

      debugPrint(
          '📜 [_loadHistory] received=${items.length} total=$_total');

      if (items.isEmpty) {
        debugPrint('📜 [_loadHistory] No more messages');
        _hasMore = false;
        return;
      }

      final newMessages = items.map((m) {
        debugPrint(
            '📦 API MSG → sender=${m['sender_user_id']} content="${m['content']}"');

        return {
          'sender_id': m['sender_user_id'], // 🔥 IMPORTANT
          'message': m['content'],
          'created_at': m['created_at'],
        };
      }).toList();

      if (loadMore) {
        final oldOffset = _scrollCtrl.offset;
        final oldMax = _scrollCtrl.position.maxScrollExtent;

        setState(() {
          _messages.insertAll(0, newMessages);
          _page++;
          if (_messages.length >= _total) _hasMore = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final newMax = _scrollCtrl.position.maxScrollExtent;
          _scrollCtrl.jumpTo(newMax - oldMax + oldOffset);
          debugPrint('📜 Pagination scroll position preserved');
        });
      } else {
        setState(() {
          _messages.clear();
          _messages.addAll(newMessages);
          _page = 2;
          _hasMore = _messages.length < _total;
        });

        debugPrint('📜 Initial history loaded (${_messages.length})');
        _scrollToBottom();
      }
    } catch (e, st) {
      debugPrint('❌ [_loadHistory] Error: $e');
      debugPrint(st.toString());
    } finally {
      _isFetchingMore = false;
      debugPrint('📜 [_loadHistory] END');
    }
  }

  // ---------------------------------------------------------------------------
  // WEBSOCKET
  // ---------------------------------------------------------------------------

  Future<void> _connectWebSocket() async {
    if (_socket != null) {
      debugPrint('⚠️ [_connectWebSocket] Socket already active');
      return;
      // debugPrint('🌐 [_connectWebSocket] ROOM ID = $_roomId');
      // debugPrint('🌐 [_connectWebSocket] FULL URL = $uri');

    }

    final uri = Uri(
      scheme: 'wss',
      host: 'fastapi.jyotishionline.com',
      path: '/chat/ws/$_roomId',
      queryParameters: {'token': _token},
    );

    debugPrint('🌐 [_connectWebSocket] Connecting → $uri');

    try {
      final ws = await WebSocket.connect(uri.toString());
      _socket = ws;
      _socket!.pingInterval = const Duration(seconds: 20);

      setState(() => _connected = true);
      debugPrint('✅ [_connectWebSocket] CONNECTED');

      _socket!.listen(
        _onMessage,
        onDone: _onDisconnect,
        onError: (e) {
          debugPrint('🔥 WS ERROR: $e');
          _onDisconnect();
        },
      );
    } catch (e, st) {
      debugPrint('❌ WS CONNECT FAILED: $e');
      debugPrint(st.toString());
    }
  }

  void _onMessage(dynamic data) {
    debugPrint('⬅️ WS FRAME: $data');

    try {
      final parsed = jsonDecode(data);
      if (parsed['type'] != 'message') {
        debugPrint('ℹ️ WS non-message ignored');
        return;
      }

      final msg = parsed['message'];
      debugPrint(
          '📩 WS MSG room=${msg['room_id']} sender=${msg['sender_user_id']}'
      );
      final sender = msg['sender_user_id'];

      debugPrint(
          '📩 WS MESSAGE sender=$sender isMine=${sender == _myUserId}');

      setState(() {
        _messages.add({
          'sender_id': sender,
          'message': msg['content'],
          'created_at': msg['created_at'],
        });
      });

      _scrollToBottom();
    } catch (e, st) {
      debugPrint('❌ WS PARSE ERROR: $e');
      debugPrint(st.toString());
    }
  }

  void _onDisconnect() {
    debugPrint('🔴 WS DISCONNECTED');
    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;
    setState(() => _connected = false);
  }

  // ---------------------------------------------------------------------------
  // SEND MESSAGE
  // ---------------------------------------------------------------------------

  void _sendMessage() {
    final text = _textCtrl.text.trim();
    debugPrint('➡️ SEND pressed text="$text" connected=$_connected');

    if (text.isEmpty || !_connected || _socket == null) {
      debugPrint('⚠️ SEND blocked (empty / disconnected)');
      return;
    }

    final payload = {"content": text, "metadata": {}};
    debugPrint('➡️ WS SEND PAYLOAD: ${jsonEncode(payload)}');

    _socket!.add(jsonEncode(payload));

    setState(() {
      _messages.add({
        'sender_id': _myUserId,
        'message': text,
        'created_at': DateTime.now().toIso8601String(),
      });
      _textCtrl.clear();
    });

    _scrollToBottom();
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        debugPrint('⬇️ Auto-scroll to bottom');
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    debugPrint('🧹 ChatPage dispose');
    try {
      _socket?.close();
    } catch (_) {}
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    debugPrint('🖼️ build() connected=$_connected messages=${_messages.length}');

    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              itemCount: _messages.length +
                  (_isFetchingMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isFetchingMore && i == 0) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2)),
                  );
                }

                final msg =
                _messages[_isFetchingMore ? i - 1 : i];
                final isMine =
                    msg['sender_id'] == _myUserId;

                debugPrint(
                    '🧩 Render msg sender=${msg['sender_id']} isMine=$isMine');

                return Align(
                  alignment: isMine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMine
                          ? Colors.orange
                          : Colors.grey.shade200,
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: Text(msg['message']),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textCtrl,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'Type message',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed:
                _connected ? _sendMessage : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
