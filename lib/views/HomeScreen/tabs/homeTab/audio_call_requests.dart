import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:flutter/material.dart';

class AudioCallRequests extends StatefulWidget {
  const AudioCallRequests({super.key});

  @override
  State<AudioCallRequests> createState() => _AudioCallRequestsState();
}

class _AudioCallRequestsState extends State<AudioCallRequests> {
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
          return const Center(child: Text("No audio requests"));
        }

        // Filter requests for audio_call
        final audioRequests = snapshot.data!
            .where((req) => req['session_type'] == 'audio_call')
            .toList();

        if (audioRequests.isEmpty) {
          return const Center(child: Text("No audio requests"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: audioRequests.length,
          itemBuilder: (context, index) {
            final req = audioRequests[index];
            final status = req['status'] as String;

            // Determine if buttons should be shown
            final showActions = status == 'pending';

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
                title: Text("User: ${req['user_id']}"),
                subtitle: Text(
                  "Status: $status",
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
                trailing: showActions
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _respondToRequest(req['id'], 'accepted'),
                            child: const Text("Accept"),
                          ),
                          TextButton(
                            onPressed: () => _respondToRequest(req['id'], 'declined'),
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
