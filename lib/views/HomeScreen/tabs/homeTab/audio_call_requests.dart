// lib/views/HomeScreen/tabs/homeTab/AudioCallRequests.dart
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/newAudioPage.dart';
import 'package:flutter/material.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';

// ✅ Import your audio call page (astrologer side)

class AudioCallRequests extends StatefulWidget {
  const AudioCallRequests({super.key});

  @override
  State<AudioCallRequests> createState() => _AudioCallRequestsState();
}

class _AudioCallRequestsState extends State<AudioCallRequests> {
  late Future<List<Map<String, dynamic>>> _requestsFuture;

  /// Saved/self astrologer id from SharedPreferences (fallback when list items don’t include it)
  String _selfAstroId = '';

  bool _actBusy = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Load self astro id first (for reliable fallback)
    final saved = await FastApiServices.getAstroId();
    _selfAstroId = (saved ?? '').trim();
    if (_selfAstroId.isEmpty) {
      debugPrint(
          "⚠️ [AudioReq] No astro_id in SharedPreferences. Login required.");
    } else {
      debugPrint("🔐 [AudioReq] Using self astro_id fallback: $_selfAstroId");
    }
    _loadRequests();
    if (mounted) setState(() {});
  }

  void _loadRequests() {
    _requestsFuture = FastApiServices().fetchAstrologerRequests();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────────────────

  String _pick(dynamic v) => (v ?? '').toString().trim();

  /// Extract a friendly display name. Avoids 'string'/'null'.
  String _displayName(Map<String, dynamic> req) {
    final candidates = <String>[
      _pick(req['user_name']),
      _pick(req['name']),
      if (req['user'] is Map) _pick((req['user'] as Map)['name']),
      if (req['sender'] is Map) _pick((req['sender'] as Map)['name']),
      if (req['receiver'] is Map) _pick((req['receiver'] as Map)['name']),
      if (req['astrologer'] is Map) _pick((req['astrologer'] as Map)['name']),
    ];

    for (final v in candidates) {
      final s = v.toLowerCase();
      if (v.isNotEmpty && s != 'null' && v != 'string') return v;
    }
    return 'User';
  }

  /// Extract strictly an ASTROLOGER ID (UUID-like). Never returns room_id or user_*
  String _extractAstroId(Map<String, dynamic> req) {
    bool looksLikeAstroId(String s) {
      if (s.isEmpty) return false;
      final lower = s.toLowerCase();
      if (lower.startsWith('room_')) return false; // reject room ids
      if (lower.startsWith('user_')) return false; // reject customer ids
      // UUID-ish: dashes OR long enough random-ish id (>= 24)
      return s.contains('-') || s.length >= 24;
    }

    String clean(String v) => v.trim();

    // Preferred top-level keys
    final candidates = <String>[
      clean(_pick(req['astrologer_id'])),
      clean(_pick(req['astro_id'])),
      clean(_pick(req['astrologerId'])),
      clean(_pick(req['other_user_id'])), // backend might put astro id here
    ]..removeWhere((e) => e.isEmpty);

    // Nested possibilities
    if (req['astrologer'] is Map) {
      final m = (req['astrologer'] as Map);
      candidates.addAll([
        clean(_pick(m['astro_id'])),
        clean(_pick(m['id'])),
      ]);
    }
    if (req['receiver'] is Map) {
      final m = (req['receiver'] as Map);
      candidates.addAll([
        clean(_pick(m['astro_id'])),
        clean(_pick(m['id'])),
      ]);
    }

    // Validate
    for (final v in candidates) {
      if (looksLikeAstroId(v)) {
        debugPrint(
            "🧩 [AudioReq] Extracted astroId='$v' (req id=${req['id']})");
        return v;
      }
    }

    // Fallback to our own saved astro id (reliable)
    if (_selfAstroId.isNotEmpty) {
      debugPrint(
          "🧷 [AudioReq] Falling back to self astro_id='$_selfAstroId' (req id=${req['id']})");
      return _selfAstroId;
    }

    debugPrint(
        "❌ [AudioReq] No valid astroId for req id=${req['id']}. Payload: $req");
    return '';
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Navigation
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _goToAudioCall() async {
    // We join as the astrologer, so use self astro id
    final astroId = _selfAstroId;
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
        builder: (_) => AudioCallPage(astroId: astroId),
      ),
    );

    if (mounted) setState(_loadRequests);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Actions
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _respondToRequest({
    required Map<String, dynamic> req,
    required String status,
  }) async {
    if (_actBusy) return;
    setState(() => _actBusy = true);

    try {
      final requestIdDynamic = req['id'];
      final int requestId = (requestIdDynamic is int)
          ? requestIdDynamic
          : int.tryParse(_pick(requestIdDynamic)) ?? 0;

      // We still compute astroId for logging (not used for navigation here)
      final astroIdForLog = _extractAstroId(req);

      debugPrint(
          "📨 [AudioReq] respondToRequest(id=$requestId, status=$status, astroId='$astroIdForLog')");

      final success = await FastApiServices().respondToRequest(
        requestId: requestId,
        status: status,
      );

      if (!mounted) return;

      if (success) {
        if (status.toLowerCase() == 'accepted') {
          // ✅ Navigate to AudioCallPage on Accept
          setState(() => _actBusy = false);
          await _goToAudioCall();
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request $status successfully!")),
        );
        setState(_loadRequests);
      } else {
        debugPrint(
            "💥 [AudioReq] respondToRequest failed for id=$requestId, status=$status");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update request.")),
        );
      }
    } finally {
      if (mounted) setState(() => _actBusy = false);
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // UI
  // ────────────────────────────────────────────────────────────────────────────

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

        final audioRequests = snapshot.data!
            .where((req) =>
                _pick(req['session_type']).toLowerCase() == 'audio_call')
            .toList();

        if (audioRequests.isEmpty) {
          return const _EmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: audioRequests.length,
          itemBuilder: (context, index) {
            final req = audioRequests[index];
            final status = _pick(req['status']).toLowerCase();
            final name = _displayName(req);

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
                        const Text("Audio Call Session",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (status == 'pending') ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _actBusy
                                  ? null
                                  : () => _respondToRequest(
                                      req: req, status: 'declined'),
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
                                      req: req, status: 'accepted'),
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
                      // ✅ After accepted, allow joining any time.
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: ElevatedButton.icon(
                      //     onPressed: _actBusy ? null : _goToAudioCall,
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
          Icon(Icons.phone_disabled, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text("No Audio Requests",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
