// lib/views/HomeScreen/tabs/homeTab/VideoCallRequests.dart
import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/videoCallPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Import the actual call page (this is where the navigation goes)
class VideoCallRequests extends StatefulWidget {
  const VideoCallRequests({super.key});

  @override
  State<VideoCallRequests> createState() => _VideoCallRequestsState();
}

class _VideoCallRequestsState extends State<VideoCallRequests> {
  late Future<List<Map<String, dynamic>>> _requestsFuture;
  bool _actBusy = false;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    _requestsFuture = FastApiServices().fetchAstrologerRequests();
  }

  Future<void> _goToCall() async {
    final prefs = await SharedPreferences.getInstance();
    final astroId = prefs.getString('astro_id') ?? '';

    if (astroId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Astrologer ID missing — please login again.')),
      );
      return;
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallPage(
          astroId: astroId,
          isAstrologer: true, // astrologer app
        ),
      ),
    );

    if (mounted) setState(_loadRequests);
  }

  Future<void> _respondToRequest(
    int requestId,
    String status,
    Map<String, dynamic> req,
  ) async {
    if (_actBusy) return;
    setState(() => _actBusy = true);

    try {
      final success = await FastApiServices().respondToRequest(
        requestId: requestId,
        status: status,
      );

      if (!mounted) return;

      if (success) {
        if (status.toLowerCase() == 'accepted') {
          // ✅ Navigate to the call screen on accept
          // release busy state before navigating so buttons don't stay disabled on back
          setState(() => _actBusy = false);
          await _goToCall();
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request $status successfully.")),
        );
        setState(_loadRequests);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update request.')),
        );
      }
    } finally {
      if (mounted) setState(() => _actBusy = false);
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
          return const _EmptyState();
        }

        final videoRequests = snapshot.data!
            .where((req) =>
                (req['session_type']?.toString() ?? '').toLowerCase() ==
                'video_call')
            .toList();

        if (videoRequests.isEmpty) {
          return const _EmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: videoRequests.length,
          itemBuilder: (context, index) {
            final req = videoRequests[index];
            final status = (req['status'] ?? '').toString().toLowerCase();
            final userName = req['user'] is Map
                ? (req['user']['name']?.toString() ?? 'Unknown User')
                : (req['user_name']?.toString() ?? 'Unknown User');

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person,
                                    size: 16,
                                    color: Theme.of(context).primaryColor),
                                const SizedBox(width: 6),
                                Text("User",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        _buildStatusChip(status),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Icon(Icons.videocam,
                            size: 16, color: Colors.purple.shade600),
                        const SizedBox(width: 6),
                        Text(
                          "Video Call Session",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ✅ Buttons/Status
                    if (status == 'pending') ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _actBusy
                                  ? null
                                  : () => _respondToRequest(
                                        req['id'],
                                        'declined',
                                        req,
                                      ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text("Reject"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _actBusy
                                  ? null
                                  : () => _respondToRequest(
                                        req['id'],
                                        'accepted',
                                        req,
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Accept & Join"),
                            ),
                          ),
                        ],
                      ),
                    ] else if (status == 'accepted') ...[
                      // ✅ Show Join button for already-accepted sessions
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: ElevatedButton.icon(
                      //     onPressed: _actBusy ? null : _goToCall,
                      //     icon: const Icon(Icons.play_arrow),
                      //     label: const Text('Join Call'),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.indigo,
                      //       foregroundColor: Colors.white,
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: null, // disabled
                          icon: const Icon(Icons.lock),
                          label: const Text('Session over'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      )
                    ] else ...[
                      Text(
                        "This request is $status.",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text("No Video Requests",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
