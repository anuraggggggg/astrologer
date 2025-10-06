import 'package:flutter/material.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';

class ChatRequests extends StatefulWidget {
  const ChatRequests({super.key});

  @override
  State<ChatRequests> createState() => _ChatRequestsState();
}

class _ChatRequestsState extends State<ChatRequests> {
  late Future<List<Map<String, dynamic>>> _requestsFuture;

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
          return const Center(child: Text("No chat requests"));
        }

        // Filter requests for chat
        final chatRequests = snapshot.data!
            .where((req) => req['session_type'] == 'chat')
            .toList();

        if (chatRequests.isEmpty) {
          return const Center(child: Text("No chat requests"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chatRequests.length,
          itemBuilder: (context, index) {
            final req = chatRequests[index];
            final status = req['status'] as String;

            // Determine if action buttons should be shown
            final showActions = status == 'pending';

            // Status color
            Color statusColor;
            if (status == 'accepted') {
              statusColor = Colors.green;
            } else if (status == 'declined') {
              statusColor = Colors.red;
            } else {
              statusColor = Colors.black87;
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: ListTile(
                leading: const Icon(Icons.chat, color: Colors.orange),
                title: Text("User: ${req['user_id']}"),
                subtitle: Text(
                  "Status: $status",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: showActions
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () =>
                                _respondToRequest(req['id'], 'accepted'),
                            child: const Text("Accept"),
                          ),
                          TextButton(
                            onPressed: () =>
                                _respondToRequest(req['id'], 'declined'),
                            child: const Text("Reject"),
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
