import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  WebSocket? _socket;
  bool _connected = false;
  bool _loading = true;

  final List<Map<String, dynamic>> _messages = [];

  late String _roomId;
  late String _myUserId;
  late String _token;

  @override
  void initState() {
    super.initState();
    _init();
  }

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    _roomId = widget.roomId.trim();
    _myUserId = widget.myUserId.trim();
    _token = widget.authToken ?? prefs.getString('access_token') ?? '';

    // await _loadHistory();
    if (!mounted) return;

    setState(() => _loading = false);
    _connectWebSocket();
  }

  // ---------------------------------------------------------------------------
  // HISTORY
  // ---------------------------------------------------------------------------

  Future<void> _loadHistory() async {
    try {
      final resp = await _api.getChatHistoryForAstrologerSelf(
        otherUserId: widget.receiverId,
        page: 1,
        size: 50,
      );



      final items = (resp['messages'] as List? ?? []).reversed.toList();

      setState(() {
        _messages
          ..clear()
          ..addAll(items.map((m) => {
            'sender_id': m['sender_user_id']?.toString(),
            'message': m['content']?.toString() ?? '',
            'created_at': m['created_at'],
          }));
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ History error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // WEBSOCKET
  // ---------------------------------------------------------------------------

  Future<void> _connectWebSocket() async {
    final uri = Uri(
      scheme: 'wss',
      host: 'fastapi.jyotishionline.com',
      path: '/chat/ws/$_roomId',
      queryParameters: {'token': _token},
    );

    _socket = await WebSocket.connect(uri.toString());
    _socket!.pingInterval = const Duration(seconds: 20);

    setState(() => _connected = true);

    _socket!.listen(_onMessage);
  }

  void _onMessage(dynamic data) async {
    try {
      final raw = data is String ? data : utf8.decode(data);
      final parsed = jsonDecode(raw);

      if (parsed is! Map || parsed['type'] != 'message') return;

      final msg = parsed['message'];
      if (msg is! Map) return;

      final String senderId = msg['sender_user_id']?.toString() ?? '';

      // 🔥 get user_id from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String useridforastro = prefs.getString('user_id') ?? '';

      // 🔥 ignore self WS echo (duplicate prevention)
      if (senderId == useridforastro) return;

      setState(() {
        _messages.add({
          'sender_id': senderId,
          'message': msg['content']?.toString() ?? '',
          'created_at': msg['created_at'],
        });
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ WS onMessage error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // SEND MESSAGE
  // ---------------------------------------------------------------------------

  void _sendMessage() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || !_connected || _socket == null) return;

    // Optimistic UI
    setState(() {
      _messages.add({
        'sender_id': _myUserId,
        'message': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    _socket!.add(jsonEncode({'content': text}));

    _textCtrl.clear();
    _scrollToBottom();
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _socket?.close();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 1,
        title: Text(
          widget.receiverName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final isMine =
                    msg['sender_id'] == _myUserId;

                return _ChatBubble(
                  message: msg['message'],
                  isMine: isMine,
                  time: msg['created_at'],
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textCtrl,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type a message…',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CHAT BUBBLE
// ---------------------------------------------------------------------------

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isMine;
  final String? time;

  const _ChatBubble({
    required this.message,
    required this.isMine,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
            isMine ? const Radius.circular(16) : Radius.zero,
            bottomRight:
            isMine ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: isMine ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(time),
              style: TextStyle(
                fontSize: 10,
                color:
                isMine ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
