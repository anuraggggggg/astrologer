import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';

// history only
import 'package:astrowaypartner/fastApi/fastApiServices.dart';

class AstrologerChatPage extends StatefulWidget {
  final String roomId;
  final String myUserId; // astrologer id (me)
  final String receiverId; // customer id (other)
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
  final ScrollController _scrollController = ScrollController();
  final FastApiServices _api = FastApiServices();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  bool _isConnected = false;
  bool _isManuallyClosed = false;
  bool _joined = false;

  final List<Map<String, dynamic>> _messages = []; // {from,text,time}

  // pagination for history
  int _page = 1;
  final int _size = 20;
  bool _isLoadingHistory = false;
  bool _hasMore = true;

  // queued while reconnecting
  final List<String> _outbox = [];

  // ping + reconnect + polling
  Timer? _pingTimer;
  Timer? _pollTimer;
  DateTime _lastFrameAt = DateTime.fromMillisecondsSinceEpoch(0);
  int _reconnectAttempt = 0;
  static const int _maxBackoffSeconds = 30;

  // de-dup (server ids & simple content-time rule)
  final Set<String> _seenIds = {};
  final Set<String> _seenKeys = {};

  // FIX: Use a monotonic counter for the client-side key for maximum stability
  int _optimisticMessageCounter = 0;
  String? _lastOptimisticKey; // Stores the key of the last message sent

  // suppress my own immediate echo
  // NOTE: Kept for reference but the primary suppression is via _seenKeys
  String _lastSentText = '';
  DateTime _lastSentAt = DateTime.fromMillisecondsSinceEpoch(0);
  // static const Duration _echoWindow = Duration(seconds: 2); // Unused now

  String get _cleanMyId => widget.myUserId.trim();
  String get _cleanReceiverId => widget.receiverId.trim();

  @override
  void initState() {
    super.initState();
    _loadHistory(initial: true).then((_) {
      if (!mounted) return;
      _connectWebSocket();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 24) {
        _loadHistory();
      }
    });
  }

  @override
  void dispose() {
    _isManuallyClosed = true;
    _cancelPing();
    _stopPolling();
    _subscription?.cancel();
    _channel?.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------- helpers ----------

  String _mkKey(Map<String, dynamic> m) {
    // 1. Server ID (highest priority)
    final id = (m['id'] ?? '').toString();
    if (id.isNotEmpty) return 'id:$id';

    // 2. Optimistic ID (next priority - for self-echo suppression)
    final optimisticId = (m['optimistic_id'] ?? '').toString();
    if (optimisticId.isNotEmpty) return 'opt:$optimisticId';

    // 3. Fallback (Content-Time-Sender rule for history/polling)
    final s = (m['sender_id'] ?? m['from'] ?? '').toString();
    // Normalize content: trim and lowercase, then take a stable prefix
    final c = (m['content'] ?? m['message'] ?? m['text'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final t = (m['created_at'] ?? m['time'] ?? '').toString();

    // We only use the first 50 characters of content to keep the key stable
    final cShort = c.length > 50 ? c.substring(0, 50) : c;

    return 's:$s|t:${t.length > 19 ? t.substring(0, 19) : t}|c:$cShort'; // Trim ISO timestamp to seconds precision
  }

  // ---------- history (initial & scrollback only) ----------

  Future<void> _loadHistory({bool initial = false}) async {
    if (_isLoadingHistory || !_hasMore) return;
    setState(() => _isLoadingHistory = true);

    try {
      // NOTE: Using _cleanMyId as 'otherUserId' is a documented backend quirk.
      final resp = await _api.getChatHistoryForAstrologerSelf(
        otherUserId: _cleanMyId,
        page: _page,
        size: _size,
      );

      final List<dynamic> items = (resp['messages'] as List?) ?? const [];
      if (items.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoadingHistory = false;
        });
        return;
      }

      final List<Map<String, dynamic>> batch = [];
      for (final raw in items) {
        final m = Map<String, dynamic>.from(raw as Map);
        final id = (m['id'] ?? '').toString();
        if (id.isNotEmpty && _seenIds.contains(id)) continue;

        final sender = (m['sender_id'] ?? '').toString();
        final text = (m['content'] ?? m['message'] ?? '').toString();
        final ts =
            (m['created_at'] ?? DateTime.now().toIso8601String()).toString();

        if (id.isNotEmpty) _seenIds.add(id);
        final uniq = _mkKey(
            {'id': id, 'sender_id': sender, 'content': text, 'created_at': ts});

        // If an optimistic key was used for this exact message, treat this history item as seen.
        if (_seenKeys.contains(uniq)) continue;
        _seenKeys.add(uniq);

        batch.add({"from": sender, "text": text, "time": ts});
      }

      // newest->oldest => oldest->newest
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
        final oldMax = _scrollController.position.maxScrollExtent;
        setState(() {
          _messages.insertAll(0, batch);
          _page++;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final newMax = _scrollController.position.maxScrollExtent;
          // Maintain scroll position after prepending messages
          _scrollController
              .jumpTo(_scrollController.offset + (newMax - oldMax));
        });
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  // ---------- websocket ----------

  Uri _buildUri() {
    final qp = <String, String>{
      'user_id': _cleanMyId,
      if ((widget.authToken ?? '').isNotEmpty) 'token': widget.authToken!,
    };
    return Uri.parse(
            'wss://fastapi.jyotishionline.com/chat/ws/${widget.roomId}')
        .replace(queryParameters: qp);
  }

  void _connectWebSocket() {
    final uri = _buildUri();
    try {
      _channel = WebSocketChannel.connect(uri);
      _subscription = _channel!.stream.listen(
        _handleIncoming,
        onDone: _handleDone,
        onError: _handleError,
        cancelOnError: false,
      );

      setState(() {
        _isConnected = true;
        _joined = false;
      });

      _reconnectAttempt = 0;
      _startPing();
      _sendJoin();
      _flushOutbox();
      _startPolling();
    } catch (_) {
      setState(() => _isConnected = false);
      _scheduleReconnect();
    }
  }

  void _sendJoin() {
    if (!_isConnected || _channel == null) return;

    final joinPayload = {
      "action": "join",
      "room_id": widget.roomId,
      "user_id": _cleanMyId,
      "sender_id": _cleanMyId,
      "receiver_id": _cleanReceiverId,
    };
    _sendRaw(joinPayload);
    _joined = true;
  }

  void _handleIncoming(dynamic event) {
    _lastFrameAt = DateTime.now();
    Map<String, dynamic>? data;
    try {
      if (event is String) {
        if (event.trim().isEmpty) return;
        if (event.trim().startsWith('[')) {
          final List arr = jsonDecode(event);
          for (final e in arr) {
            _handleIncoming(e);
          }
          return;
        }
        data = jsonDecode(event);
      } else if (event is Map) {
        data = Map<String, dynamic>.from(event);
      }
    } catch (_) {
      return;
    }
    if (data == null) return;

    final type = (data['type'] ?? data['action'])?.toString();
    if (type == 'pong') return;

    // normalize payload
    final Map<String, dynamic> msg = (data['message'] is Map)
        ? Map<String, dynamic>.from(data['message'])
        : data;

    // Extract fields
    final String id = (msg['id'] ?? '').toString();
    final String content =
        (msg['content'] ?? msg['message'] ?? msg['text'] ?? '')
            .toString()
            .trim();
    if (content.isEmpty) return;
    final String sender = (msg['sender_id'] ?? msg['from'] ?? '').toString();
    final String ts = (msg['created_at'] ??
            msg['timestamp'] ??
            msg['time'] ??
            DateTime.now().toIso8601String())
        .toString();

    // Check for server ID duplication (highest priority)
    if (id.isNotEmpty && _seenIds.contains(id)) return;
    if (id.isNotEmpty) _seenIds.add(id);

    // Check for custom key duplication (to block optimistic echo)
    // NOTE: We manually add the last sent optimistic key to the incoming message
    // data here if it matches the sender and content, as a final attempt to match.
    // However, the _mkKey logic should handle this.
    final Map<String, dynamic> keyData = {
      'id': id,
      'sender_id': sender,
      'content': content,
      'created_at': ts
    };

    // Check if this is the immediate echo of the last sent message.
    // If it is, and we have the optimistic key, use it for de-duplication.
    if (sender == _cleanMyId && _lastOptimisticKey != null) {
      // The content check is simplified but necessary to prevent blocking the wrong message
      final sentContent = _lastSentText.trim().toLowerCase();
      final incomingContent = content.trim().toLowerCase();
      if (incomingContent.startsWith(sentContent)) {
        keyData['optimistic_id'] = _lastOptimisticKey;
      }
    }

    final uniq = _mkKey(keyData);
    if (_seenKeys.contains(uniq)) return;
    _seenKeys.add(uniq);

    // Clear the optimistic key if we successfully received its echo/server message
    if (uniq == _lastOptimisticKey) {
      _lastOptimisticKey = null;
    }

    if (!mounted) return;
    setState(() {
      _messages.add({"from": sender, "text": content, "time": ts});
    });
    _scrollToBottom();
  }

  void _handleDone() {
    setState(() {
      _isConnected = false;
      _joined = false;
    });
    _cancelPing();
    _stopPolling();
    if (!_isManuallyClosed) _scheduleReconnect();
  }

  void _handleError(Object error, [StackTrace? _]) {
    setState(() {
      _isConnected = false;
      _joined = false;
    });
    _cancelPing();
    _stopPolling();
    if (!_isManuallyClosed) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isManuallyClosed) return;
    _reconnectAttempt++;
    final backoff = (_reconnectAttempt * 2).clamp(1, _maxBackoffSeconds);
    Future.delayed(Duration(seconds: backoff), () {
      if (!mounted || _isManuallyClosed) return;
      _connectWebSocket();
    });
  }

  void _startPing() {
    _cancelPing();
    _pingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _sendRaw({"action": "ping", "ts": DateTime.now().toIso8601String()});
    });
  }

  void _cancelPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  // ---------- POLLING FALLBACK (2s) ----------

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!_isConnected || !_joined) return;
      // only poll if socket has been quiet for a moment
      if (DateTime.now().difference(_lastFrameAt) < const Duration(seconds: 1))
        return;

      try {
        final resp = await _api.getChatHistoryForAstrologerSelf(
          otherUserId: _cleanMyId,
          page: 1,
          size: 10,
        );
        final List<dynamic> items = (resp['messages'] as List?) ?? const [];

        // merge oldest->newest to maintain order
        for (final raw in items.reversed) {
          final m = Map<String, dynamic>.from(raw as Map);
          final id = (m['id'] ?? '').toString();
          if (id.isNotEmpty && _seenIds.contains(id)) continue;

          final sender = (m['sender_id'] ?? '').toString();
          final text = (m['content'] ?? m['message'] ?? '').toString();
          final ts = (m['created_at'] ?? '').toString();
          if (text.isEmpty || ts.isEmpty) continue;

          final uniq = _mkKey({
            'id': id,
            'sender_id': sender,
            'content': text,
            'created_at': ts
          });
          if (_seenKeys.contains(uniq)) continue;

          if (!mounted) return;
          setState(() {
            _messages.add({"from": sender, "text": text, "time": ts});
            if (id.isNotEmpty) _seenIds.add(id);
            _seenKeys.add(uniq);
          });
          _scrollToBottom();
        }
      } catch (_) {
        // ignore; try next tick
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ---------- send ----------

  void _flushOutbox() {
    if (!_isConnected || _channel == null) return;
    for (final payload in _outbox) {
      _channel!.sink.add(payload);
    }
    _outbox.clear();
  }

  void _sendRaw(Map<String, dynamic> map) {
    final payload = jsonEncode(map);
    if (_isConnected && _channel != null) {
      _channel!.sink.add(payload);
    } else {
      _outbox.add(payload);
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (!_joined) _sendJoin();

    // 1. Generate a client-side ID for the optimistic update
    _optimisticMessageCounter++;
    final optimisticId = "${_cleanMyId}:${_optimisticMessageCounter}";

    // 2. Prepare the frame to send (contains the message content)
    final frame = {
      "action": "send",
      "room_id": widget.roomId,
      "sender_id": _cleanMyId,
      "receiver_id": _cleanReceiverId,
      "content": text,
      // Optional: If your backend supports echoing a 'client_id' or 'correlation_id',
      // you could add it here as well, e.g., "client_id": optimisticId
    };

    _sendRaw(frame);

    // 3. Optimistic UI update and key generation
    final ts = DateTime.now().toIso8601String();

    // Key used to block the server echo. We use the custom optimistic ID
    // which has the highest priority in _mkKey.
    final optimisticKey = _mkKey({
      "optimistic_id": optimisticId,
      "sender_id": _cleanMyId,
      "content": text,
      "created_at": ts,
    });

    // Store the last key and content to help with echo matching in _handleIncoming
    _lastOptimisticKey = optimisticKey;
    _lastSentText = text;
    _lastSentAt = DateTime.now();

    // Only add if the key is new (should always be, but safe check)
    if (!_seenKeys.contains(optimisticKey)) {
      setState(() {
        // Add the optimistic_id to the message object to confirm it's the optimistic one
        _messages.add({
          "from": _cleanMyId,
          "text": text,
          "time": ts,
          "optimistic_id": optimisticId
        });
        _seenKeys.add(optimisticKey);
      });
    }

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom({bool immediate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: immediate ? 1 : 200),
        curve: Curves.easeOut,
      );
    });
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final canSend = _isConnected;

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
                color: _isConnected ? Colors.greenAccent : Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
            const Text("Chat"),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isLoadingHistory) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      "No messages yet...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = (msg["from"] ?? "") == _cleanMyId;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.deepPurple.withOpacity(0.85)
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
                                (msg["text"] ?? "").toString(),
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('hh:mm a').format(
                                  DateTime.tryParse(msg["time"] ?? "") ??
                                      DateTime.now(),
                                ),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _buildInputArea(canSend: canSend),
        ],
      ),
    );
  }

  Widget _buildInputArea({required bool canSend}) {
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
                  hintText: canSend ? "Type a message..." : "Connecting…",
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
