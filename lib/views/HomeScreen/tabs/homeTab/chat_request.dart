import 'package:flutter/material.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import '../../../chat/chat_screen.dart';

class ChatRequests extends StatefulWidget {
  const ChatRequests({super.key});

  @override
  State<ChatRequests> createState() => _ChatRequestsState();
}

class _ChatRequestsState extends State<ChatRequests> {
  late Future<List<Map<String, dynamic>>> _requestsFuture;


// Optional token if your WS checks auth on connect via query/header



  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    _requestsFuture = FastApiServices().fetchAstrologerRequests();
  }

  Future<void> _respondToRequest(int requestId, String status) async {
    final success = await FastApiServices().respondToRequest(
      requestId: requestId,
      status: status,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request $status successfully!")),
      );
      setState(() {
        _loadRequests(); // refresh list
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update request.")),
      );
    }
  }

  Future<void> _acceptAndStartChat(Map<String, dynamic> request) async {
    // First accept the request
    final success = await FastApiServices().respondToRequest(
      requestId: request['id'],
      status: 'accepted',
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request accepted successfully!")),
      );

      // Then navigate to chat screen
      // Use actual user ID from the request data
      final customerId = request['user_id']?.toString() ??
          request['customer_uid']?.toString() ??
          'user_779b09b9560f490e92889c35f5ff8de5'; // fallback

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AstrologerChatPage(
            roomId: 'room_05cd5625d56e45719056a060499bacdf',
            myUserId: '79952e41-dc8f-4366-b4d1-678b6f49d78a',
            receiverId: '6bc25288-2b38-469e-9fc2-ac30ccbc155a',
          ),
        ),
      ).then((_) {
        // Refresh requests when returning from chat
        setState(() {
          _loadRequests();
        });
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to accept request.")),
      );
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'accepted':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        statusText = 'Accepted';
        break;
      case 'declined':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        statusText = 'Declined';
        break;
      case 'pending':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        statusText = 'Pending';
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        statusText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No Chat Requests",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Filter requests for chat
        final chatRequests = snapshot.data!
            .where((req) => req['session_type'] == 'chat')
            .toList();

        if (chatRequests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No Chat Requests",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chatRequests.length,
          itemBuilder: (context, index) {
            final req = chatRequests[index];
            final status = req['status'] as String;
            final showActions = status == 'pending';
            final isAccepted = status == 'accepted';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with user info and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "User",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                req['user_name']?.toString() ?? 'Unknown User',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChip(status),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Session type info
                    Row(
                      children: [
                        Icon(
                          Icons.chat,
                          size: 16,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Chat Session",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Show action buttons for pending requests OR chat button for accepted requests
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    if (showActions)
                    // Pending request - show Accept/Reject buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _respondToRequest(req['id'], 'declined'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.close, size: 18),
                                  SizedBox(width: 6),
                                  Text("Reject"),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _acceptAndStartChat(req),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat, size: 18),
                                  SizedBox(width: 6),
                                  Text("Accept & Chat"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (isAccepted)
                    // Accepted request - show Chat button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final customerId = req['user_id']?.toString() ??
                                req['customer_uid']?.toString() ??
                                'user_779b09b9560f490e92889c35f5ff8de5';

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AstrologerChatPage(
                                  roomId: 'room_05cd5625d56e45719056a060499bacdf',
                                  myUserId: '79952e41-dc8f-4366-b4d1-678b6f49d78a',   //user_id
                                  receiverId: '6bc25288-2b38-469e-9fc2-ac30ccbc155a',  //id
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat, size: 18),
                              SizedBox(width: 6),
                              Text("Start Chat"),
                            ],
                          ),
                        ),
                      )
                    else
                    // Declined request - no actions
                      const SizedBox(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}