import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';

// =================================================================
// 0. MOCK CONFIGS (Replace in Production)
// =========================
//
//
// ========================================

const String _mockServerBaseUrl = '10.0.2.2:8000'; // FastAPI local host (Android Emulator)
const String _mockMyAstrologerId = 'fea423d4-3f23-43a9-9ecb-a5cd4d0d5247';
const String _mockAstrologerToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJqaW5jeXRAZXhhbXBsZS5jb20iLCJleHAiOjE3NjQyMjM0NDR9.DPPuDztA5DL3SGNalsG4C6EHSDAkxjcw2UBOSQd7c1k';
const Color _primaryColor = Color(0xFF6A1B9A); // Deep Purple

// Mock Message Model
class ChatMessage {
  final int id;
  final String fromId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final bool isSender;

  ChatMessage({
    required this.id,
    required this.fromId,
    required this.message,
    required this.timestamp,
    required this.isRead,
  }) : isSender = (fromId == _mockMyAstrologerId);

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      fromId: json['from_id'].toString(),
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']).toLocal(),
      isRead: json['is_read'] ?? false,
    );
  }
}

// Mock Chat Service
class MockPanditChatService {
  Future<Map<String, dynamic>> getOrCreateRoomId(String customerId, String token) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final userList = [_mockMyAstrologerId, customerId]..sort();
    return {'room_id': userList.join('_')};
  }

  Future<List<Map<String, dynamic>>> chatHistory(String roomId, String token) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        'id': 1,
        'from_id': 'CUSTOMER_USER_123',
        'message': 'Hi Pandit ji!',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 4)).toIso8601String(),
        'is_read': true
      },
      {
        'id': 2,
        'from_id': _mockMyAstrologerId,
        'message': 'Namaste beta 🙏',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 3)).toIso8601String(),
        'is_read': true
      },
    ];
  }

  Future<void> markChatAsRead(String roomId, String token) async {
    await Future.delayed(const Duration(milliseconds: 150));
    print("✅ MOCK: Astrologer marked $roomId as read");
  }
}

// =================================================================
// 1. ASTROLOGER CHAT SCREEN
// =================================================================

class AstrologerChatPage extends StatefulWidget {
  final String customerUid;
  const AstrologerChatPage({Key? key, required this.customerUid}) : super(key: key);

  @override
  State<AstrologerChatPage> createState() => _AstrologerChatPageState();
}

class _AstrologerChatPageState extends State<AstrologerChatPage> {
  final MockPanditChatService _chatService = MockPanditChatService();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isLoading = true;
  String? _roomId= 'room_6d741b397f134892a04aab155a000d5a';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final roomResponse = await _chatService.getOrCreateRoomId(widget.customerUid, _mockAstrologerToken);
      _roomId = roomResponse['room_id'];
      await _loadChatHistory();
      _connectWebSocket();
      await _chatService.markChatAsRead(_roomId!, _mockAstrologerToken);
    } catch (e) {
      print("Error: $e");
    }
    setState(() => _isLoading = false);
  }

  void _connectWebSocket() {
    if (_roomId == null) return;

    // 👇 Must match your working HTML test client
    final uri = Uri.parse(
      'wss://fastapi.jyotishionline.com/chat/ws/$_roomId',
    );

    print("🔗 Connecting to: $uri");

    try {
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      _channel!.stream.listen(
            (data) {
          print("📩 Received: $data");
          final json = jsonDecode(data);

          // Server sends: { "type": "message", "message": { ... } }
          if (json['type'] == 'message' && json['message'] != null) {
            final msg = ChatMessage.fromJson(json['message']);
            setState(() => _messages.insert(0, msg));
          } else if (json['type'] == 'read_update') {
            print("📖 Read update: ${json['user_id']} marked ${json['marked']}");
          } else {
            print("🌀 Unknown message: $json");
          }
        },
        onError: (e) {
          print("⚠️ WS Error: $e");
          setState(() => _isConnected = false);
        },
        onDone: () {
          print("❌ WebSocket Closed");
          setState(() => _isConnected = false);
        },
      );
    } catch (e) {
      print("❌ WebSocket connection failed: $e");
    }
  }



  Future<void> _loadChatHistory() async {
    final history = await _chatService.chatHistory(_roomId!, _mockAstrologerToken);
    setState(() {
      _messages.clear();
      _messages.addAll(history.map((e) => ChatMessage.fromJson(e)).toList().reversed);
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || !_isConnected) return;

    final payload = jsonEncode({
      "action": "send",
      "sender_id": _mockMyAstrologerId,
      "receiver_id": widget.customerUid,
      "content": text,
    });

    _channel!.sink.add(payload);

    final myMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      fromId: _mockMyAstrologerId,
      message: text,
      timestamp: DateTime.now(),
      isRead: true,
    );

    setState(() => _messages.insert(0, myMsg));
    _controller.clear();
  }


  @override
  void dispose() {
    _channel?.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.customerUid}"),
        backgroundColor: _primaryColor,
        actions: [
          Icon(_isConnected ? Icons.circle : Icons.circle_outlined,
              color: _isConnected ? Colors.greenAccent : Colors.white70)
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isMe = m.isSender;
                return Align(
                  alignment:
                  isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? _primaryColor.withOpacity(0.9)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.message,
                          style: TextStyle(
                            color:
                            isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          DateFormat('hh:mm a').format(m.timestamp),
                          style: TextStyle(
                              fontSize: 10,
                              color: isMe
                                  ? Colors.white70
                                  : Colors.black45),
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
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: _isConnected ? _primaryColor : Colors.grey,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: _isConnected ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }
}
