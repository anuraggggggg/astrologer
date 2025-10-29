import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';

class AstrologerChatPage extends StatefulWidget {
  final String roomId;
  final String myUserId;   // must be exact, no spaces
  final String receiverId; // must be exact, no spaces
  final String? authToken; // optional: if your backend needs it via query/header

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

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  bool _isConnected = false;
  bool _isManuallyClosed = false;

  final List<Map<String, dynamic>> _messages = [];
  final List<String> _outbox = []; // queue while reconnecting

  Timer? _pingTimer;
  int _reconnectAttempt = 0;
  static const int _maxBackoffSeconds = 30;

  String get _cleanMyId => widget.myUserId.trim();
  String get _cleanReceiverId => widget.receiverId.trim();

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _isManuallyClosed = true;
    _cancelPing();
    _subscription?.cancel();
    _channel?.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Uri _buildUri() {
    // If your FastAPI expects token/ids in query, add here
    final qp = <String, String>{
      'room_id': widget.roomId,
      // 'token': widget.authToken ?? '',
      // 'user_id': _cleanMyId,
    }..removeWhere((k, v) => v.isEmpty);

    return Uri.parse('wss://fastapi.jyotishionline.com/chat/ws/${widget.roomId}')
        .replace(queryParameters: qp.isEmpty ? null : qp);
  }

  void _connectWebSocket() {
    final uri = _buildUri();
    print("🔗 Connecting to WebSocket: $uri");

    try {
      _channel = WebSocketChannel.connect(uri);
      print("✅ WebSocket connection object created");

      _subscription = _channel!.stream.listen(
            (event) {
          print("📩 Received message: $event");
          _handleIncoming(event);
        },

        onError: (error) {
          print("⚠️ WebSocket error: $error");
          _handleError(error);
        },
        cancelOnError: true,
      );

      setState(() => _isConnected = true);
      print("✅ Connection state set to true");

      _reconnectAttempt = 0;
      _startPing();
      print("📡 Started ping timer");

      _sendRaw({
        "action": "join",
        "room_id": widget.roomId,
        "sender_id": _cleanMyId,
        "receiver_id": _cleanReceiverId,
      });
      print("📨 Sent join message");

      _flushOutbox();
      print("📬 Outbox flushed");
    } catch (e, st) {
      print("🚫 Connection failed: $e\n$st");
      setState(() => _isConnected = false);
      _scheduleReconnect();
    }
  }


  void _handleIncoming(dynamic event) {
    // print("📩 Received: $event");
    Map<String, dynamic>? data;
    try {
      data = event is String ? jsonDecode(event) : Map<String, dynamic>.from(event);
    } catch (_) {
      return; // ignore non-JSON frames
    }

    if (data == null) return;

    // Handle pong/ack quietly
    if (data['type'] == 'pong' || data['action'] == 'pong') return;

    // Normalize message payloads
    final msg = data['message'] ?? data;

    if ((data['type'] == 'message' || msg['content'] != null) && mounted) {
      setState(() {
        _messages.insert(0, {
          "from": msg["sender_id"] ?? "",
          "text": msg["content"] ?? "",
          "time": (msg["created_at"] ??
              msg["timestamp"] ??
              DateTime.now().toIso8601String()),
        });
      });
    }
  }

  void _handleDone() {
    // print("❌ WebSocket closed");
    setState(() => _isConnected = false);
    _cancelPing();
    if (!_isManuallyClosed) {
      _scheduleReconnect();
    }
  }

  void _handleError(Object error, [StackTrace? _]) {
    // print("⚠️ WebSocket error: $error");
    setState(() => _isConnected = false);
    _cancelPing();
    _scheduleReconnect();
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
    // Send a ping every 20s; many proxies close idle sockets ~30s
    _pingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _sendRaw({"action": "ping", "ts": DateTime.now().toIso8601String()});
    });
  }

  void _cancelPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _flushOutbox() {
    if (!_isConnected) return;
    for (final payload in _outbox) {
      _channel?.sink.add(payload);
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

    final frame = {
      "action": "send",
      "sender_id": _cleanMyId,
      "receiver_id": _cleanReceiverId,
      "room_id": widget.roomId,
      "content": text,
    };

    _sendRaw(frame);

    setState(() {
      _messages.insert(0, {
        "from": _cleanMyId,
        "text": text,
        "time": DateTime.now().toIso8601String(),
      });
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WebSocket Chat"),
        backgroundColor: Colors.deepPurple,
        actions: [
          Icon(
            _isConnected ? Icons.circle : Icons.circle_outlined,
            color: _isConnected ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
              child: Text(
                "No messages yet...",
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              reverse: true,
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
                        vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.deepPurple.withOpacity(0.8)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg["text"] ?? "",
                          style: TextStyle(
                            color:
                            isMe ? Colors.white : Colors.black,
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
                            color: isMe
                                ? Colors.white70
                                : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.deepPurple,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
