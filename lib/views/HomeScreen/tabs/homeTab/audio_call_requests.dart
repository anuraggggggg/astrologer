import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/newAudioPage.dart';
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

  // ---- Helpers ---------------------------------------------------------------

  /// Prefer only ASTRO ids here. We do NOT fall back to user_id.
  /// Checks common top-level and nested shapes.
  String _extractAstroId(Map<String, dynamic> req) {
    String pick(dynamic v) => (v ?? '').toString().trim();

    final candidates = <String>[
      pick(req['astrologer_id']),
      pick(req['astro_id']),
      pick(req['astrologerId']),
      pick(req['other_user_id']), // sometimes backend may set this to astro
      // nested maps
      if (req['astrologer'] is Map) ...[
        pick((req['astrologer'] as Map)['astro_id']),
        pick((req['astrologer'] as Map)['id']),
      ],
      if (req['receiver'] is Map) ...[
        pick((req['receiver'] as Map)['astro_id']),
        pick((req['receiver'] as Map)['id']),
      ],
    ];

    for (final v in candidates) {
      if (v.isNotEmpty && v.toLowerCase() != 'null' && !v.contains('user_')) {
        // we strongly avoid picking customer ids like user_xxx here
        debugPrint(
            "🧩 [AudioReq] Extracted astroId='$v' from request id=${req['id']}");
        return v;
      }
    }

    // As a last resort, accept an id that looks like astro even if key unknown
    // (e.g., any non-empty non-'user_' string)
    final allValues = req.values.toList();
    for (final v in allValues) {
      final s = pick(v);
      if (s.isNotEmpty &&
          !s.startsWith('user_') &&
          s.length > 6 &&
          s != 'null') {
        // heuristic: many of your astro ids are UUID-like
        if (_looksLikeUuidOrAstro(s)) {
          debugPrint(
              "🧩 [AudioReq] Heuristic astroId='$s' (request id=${req['id']})");
          return s;
        }
      }
    }

    debugPrint(
        "❌ [AudioReq] Could not find astrologer id in request id=${req['id']}. Payload: $req");
    return '';
  }

  bool _looksLikeUuidOrAstro(String s) {
    // accept UUID-ish or known astro id length
    // Your astro ids look like UUIDs: 36 chars, or the sample '3260671e-...'
    return s.length >= 12 && (s.contains('-') || s.length >= 24);
  }

  /// Try to show a user-friendly name
  String _displayName(Map<String, dynamic> req) {
    String pick(dynamic v) => (v ?? '').toString().trim();

    final candidates = <String>[
      pick(req['user_name']),
      pick(req['name']),
      if (req['user'] is Map) pick((req['user'] as Map)['name']),
      if (req['sender'] is Map) pick((req['sender'] as Map)['name']),
      if (req['receiver'] is Map) pick((req['receiver'] as Map)['name']),
      if (req['astrologer'] is Map) pick((req['astrologer'] as Map)['name']),
    ];

    for (final v in candidates) {
      if (v.isNotEmpty && v.toLowerCase() != 'null' && v != 'string') {
        return v;
      }
    }
    return 'User';
  }

  // ---- Actions ---------------------------------------------------------------

  Future<void> _respondToRequest({
    required Map<String, dynamic> req,
    required String status,
  }) async {
    final requestId = (req['id'] ?? 0) as int;
    final astroId = _extractAstroId(req);

    final success = await FastApiServices().respondToRequest(
      requestId: requestId,
      status: status,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request $status successfully!")),
      );

      // If accepted & audio_call → navigate to AudioCallPage with the ASTRO id
      final isAudio =
          (req['session_type']?.toString() ?? '').toLowerCase() == 'audio_call';
      if (status == 'accepted' && isAudio) {
        if (astroId.isEmpty) {
          debugPrint(
              "🚫 [AudioReq] Invalid astroId='$astroId' (looks like room or empty)");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Missing astrologer ID to start call.")),
          );
        } else {
          debugPrint(
              "➡️ [AudioReq] Navigating to AudioCallPage(otherUserId=$astroId)");
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AudioCallPage(astroId: astroId),
            ),
          );
        }
      }

      setState(_loadRequests); // refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update request.")),
      );
    }
  }

  // ---- UI --------------------------------------------------------------------

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
                Icon(Icons.phone_disabled, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No Audio Requests",
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        final audioRequests = snapshot.data!
            .where((req) =>
                (req['session_type']?.toString() ?? '').toLowerCase() ==
                'audio_call')
            .toList();

        if (audioRequests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_disabled, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No Audio Requests",
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: audioRequests.length,
          itemBuilder: (context, index) {
            final req = audioRequests[index];
            final status = (req['status'] ?? '').toString();
            final showActions = status == 'pending';

            final name = _displayName(req);
            final astroId = _extractAstroId(req); // useful for the Join button

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
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChip(status),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Icon(Icons.phone_in_talk,
                            size: 16, color: Colors.blue.shade600),
                        const SizedBox(width: 6),
                        Text(
                          "Audio Call Session",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),

                    // Actions
                    if (showActions) ...[
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _respondToRequest(
                                  req: req, status: 'declined'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
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
                              onPressed: () => _respondToRequest(
                                  req: req, status: 'accepted'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, size: 18),
                                  SizedBox(width: 6),
                                  Text("Accept"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      if (status == 'accepted')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.call),
                            label: const Text('Join Call'),
                            onPressed: () {
                              if (astroId.isEmpty) {
                                debugPrint(
                                    "🚫 [AudioReq] Join pressed but astroId missing. req=$req");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Missing astrologer ID to start call.")),
                                );
                                return;
                              }
                              debugPrint(
                                  "➡️ [AudioReq] Join -> AudioCallPage(otherUserId=$astroId)");
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        AudioCallPage(astroId: astroId)),
                              );
                            },
                          ),
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
