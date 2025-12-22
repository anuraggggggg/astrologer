import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:intl/intl.dart';

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

  final List<Map<String, dynamic>> _messages = [];

  late String _roomId;
  late String _myUserId;
  late String _token;
  late String _myUserIdFromPrefs;

  // 🔥 Pagination state
  int _historyPage = 1;
  bool _hasMoreHistory = true;
  bool _loadingHistory = false;
  static const int _pageSize = 50;

  static const Color appYellow = Color(0xFFFFC31F);
  static const Color appDark = Color(0xFF1A1A1A);
  static const Color appLight = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _init();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent &&
          !_loadingHistory &&
          _hasMoreHistory) {
        _loadOlderMessages();
      }
    });
  }

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    _roomId = widget.roomId.trim();
    _myUserId = widget.myUserId.trim(); // keep if needed elsewhere
    _token = widget.authToken ?? prefs.getString('access_token') ?? '';

    // ✅ THIS IS THE IMPORTANT LINE
    _myUserIdFromPrefs = prefs.getString('user_id') ?? '';

    debugPrint("🧠 MY USER ID (ASTRO): $_myUserIdFromPrefs");

    await _loadFullChatHistory();
    if (!mounted) return;

    setState(() => _isLoading = false);
    _scrollToBottom(force: true);
    _connectWebSocket();
  }

  // ---------------------------------------------------------------------------
  // HISTORY - FULL LOAD WITH PAGINATION
  // ---------------------------------------------------------------------------

  Future<void> _loadFullChatHistory() async {
    final List<Map<String, dynamic>> all = [];
    int page = 1;
    bool hasMore = true;

    while (hasMore) {
      try {
        final resp = await _api.getChatHistoryForAstrologerSelf(
          otherUserId: widget.receiverId,
          page: page,
          size: _pageSize,
        );

        final items = (resp['messages'] as List? ?? []);

        if (items.isEmpty) {
          hasMore = false;
        } else {
          for (final m in items) {
            all.add({
              'sender_id': m['sender_user_id']?.toString(),
              'message': m['content']?.toString() ?? '',
              'created_at': m['created_at'],
            });
          }
          page++;
        }
      } catch (e) {
        debugPrint('❌ History error: $e');
        hasMore = false;
      }
    }

    _historyPage = page - 1;
    setState(() {
      _messages.clear();
      _messages.addAll(all);
    });
  }

  Future<void> _loadOlderMessages() async {
    if (_loadingHistory || !_hasMoreHistory) return;
    _loadingHistory = true;

    try {
      final resp = await _api.getChatHistoryForAstrologerSelf(
        otherUserId: widget.receiverId,
        page: _historyPage + 1,
        size: _pageSize,
      );

      final items = (resp['messages'] as List? ?? []);

      if (items.isEmpty) {
        _hasMoreHistory = false;
      } else {
        _historyPage++;
        setState(() {
          _messages.insertAll(
            0,
            items.map((m) => {
              'sender_id': m['sender_user_id']?.toString(),
              'message': m['content']?.toString() ?? '',
              'created_at': m['created_at'],
            }),
          );
        });
      }
    } catch (e) {
      debugPrint('❌ Older messages error: $e');
    }
    _loadingHistory = false;
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

    try {
      _socket = await WebSocket.connect(uri.toString());
      _socket!.pingInterval = const Duration(seconds: 20);

      setState(() => _isConnected = true);

      _socket!.listen(_onMessage);
    } catch (e) {
      debugPrint('❌ WebSocket connection error: $e');
    }
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
    final text = _controller.text.trim();
    if (text.isEmpty || !_isConnected || _socket == null) return;

    setState(() {
      _messages.add({
        'sender_id': _myUserIdFromPrefs, // ✅ FIX
        'message': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    _socket!.add(jsonEncode({'content': text}));

    _controller.clear();
    _scrollToBottom(force: true);
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  void _scrollToBottom({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (force) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      } else {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      return DateFormat('h:mm a').format(DateTime.parse(iso));
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    _socket?.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI (EXACT SAME AS CUSTOMER CHAT)
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appLight,
      appBar: AppBar(
        backgroundColor: appDark,
        elevation: 3,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.receiverName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: appYellow),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isMine = m['sender_id'] == _myUserIdFromPrefs;
                return _buildMessageBubble(m, isMine);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> m, bool isMine) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMine ? appYellow : Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                m['message'],
                style: TextStyle(
                  color: isMine ? appDark : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(m['created_at']),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: appLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: const CircleAvatar(
              backgroundColor: appYellow,
              child: Icon(Icons.send, color: appDark),
            ),
          ),
        ],
      ),
    );
  }
}