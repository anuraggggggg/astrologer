// lib/views/HomeScreen/tabs/homeTab/AudioCallRequests.dart
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/newAudioPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:astrowaypartner/fastApi/agora_service.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';

class AudioCallRequests extends StatefulWidget {
  const AudioCallRequests({super.key});

  @override
  State<AudioCallRequests> createState() => _AudioCallRequestsState();
}

class _AudioCallRequestsState extends State<AudioCallRequests> {
  Future<List<Map<String, dynamic>>>? _requestsFuture;
  bool _actBusy = false;

  String _selfAstroId = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _selfAstroId = (prefs.getString("astro_id") ?? "").trim();

    if (_selfAstroId.isEmpty) {
      debugPrint("⚠️ [AudioReq] No astro_id found in storage.");
    } else {
      debugPrint("🔐 [AudioReq] Using astroId = $_selfAstroId");
    }

    _loadRequests();
    if (mounted) setState(() {});
  }

  void _loadRequests() {
    _requestsFuture = FastApiServices().fetchAstrologerRequests();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _pick(dynamic v) => (v ?? "").toString().trim();

  String _extractUserId(Map<String, dynamic> req) {
    final c = <String>[
      _pick(req['user_id']),
      _pick(req['customer_id']),
      _pick(req['userid']),
      if (req['user'] is Map) _pick(req['user']['id']),
      if (req['receiver'] is Map) _pick(req['receiver']['user_id']),
    ]..removeWhere((e) => e.isEmpty);

    for (final id in c) {
      if (id.startsWith("user_") || id.length >= 16) return id;
    }

    return "";
  }

  String _extractAstroId(Map<String, dynamic> req) {
    final c = <String>[
      _pick(req['astro_id']),
      _pick(req['astrologer_id']),
      _pick(req['astroId']),
    ]..removeWhere((e) => e.isEmpty);

    return c.isNotEmpty ? c.first : _selfAstroId;
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  Future<void> _goToCall({
    required String overrideRoomId,
    required String overrideToken,
    required String overrideAccount,
    required String overrideAppId,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AudioCallPage(
          astroId: _selfAstroId,
          isAstrologer: true,
          overrideRoomId: overrideRoomId,
          overrideToken: overrideToken,
          overrideAccount: overrideAccount,
          overrideAppId: overrideAppId,
        ),
      ),
    );

    if (mounted) setState(_loadRequests);
  }

  // ---------------------------------------------------------------------------
  // Handle Accept / Reject
  // ---------------------------------------------------------------------------

  Future<void> _respond({
    required Map<String, dynamic> req,
    required String status,
  }) async {
    if (_actBusy) return;
    setState(() => _actBusy = true);

    try {
      final requestId = int.tryParse(_pick(req['id'])) ?? 0;

      debugPrint("📨 [AudioReq] Updating request $requestId → $status");

      final resp = await FastApiServices().respondToRequest(
        requestId: requestId,
        status: status,
      );

      if (!mounted) return;

      if (resp != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update request")),
        );
        return;
      }

      // ---------------- ACCEPTED ----------------
      if (status == "accepted") {
        await _joinCall(req);
        return;
      }

      // ---------------- DECLINED ----------------
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request $status")),
      );
    } catch (e, st) {
      debugPrint("🔥 [AudioReq] ERROR: $e\n$st");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _actBusy = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Join / Rejoin Call
  // ---------------------------------------------------------------------------

  Future<void> _joinCall(Map<String, dynamic> req) async {
    try {
      final userId = _extractUserId(req);
      final astroId = _extractAstroId(req);

      debugPrint("📌 JOIN CALL → USER=$userId ASTRO=$astroId");

      final auth = await AgoraService.getTokens(astroId);

      final astroJoin = AgoraService.buildJoinParams(
        auth: auth,
        isAstrologer: true,
      );

      final customerJoin = AgoraService.buildJoinParams(
        auth: auth,
        isAstrologer: false,
      );

      /// notify customer again (rejoin safe)
      await FastApiServices().sendCustomerNotification(
        userId: userId,
        title: "Audio Call Ready",
        body: "Astrologer joined the call",
        type: "audio_accept",
        screen: "AudioCallPage",
        data: {
          "session_type": "audio_call",
          "astro_id": astroId,
          "agora_channel": customerJoin.channel,
          "agora_token": customerJoin.token,
          "agora_account": customerJoin.account,
          "app_id": auth.appId,
          "expireIn": auth.expireIn,
        },
      );

      await _goToCall(
        overrideRoomId: astroJoin.channel,
        overrideToken: astroJoin.token,
        overrideAccount: astroJoin.account,
        overrideAppId: auth.appId,
      );
    } catch (e) {
      debugPrint("❌ Join call error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Join failed: $e")));
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const _EmptyState();
        }

        final audioRequests = snapshot.data!
            .where((req) =>
                (_pick(req['session_type'])).toLowerCase() == 'audio_call')
            .toList();

        if (audioRequests.isEmpty) return const _EmptyState();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: audioRequests.length,
          itemBuilder: (context, index) {
            final req = audioRequests[index];
            final status = (_pick(req['status'])).toLowerCase();

            final userName = req['user'] is Map
                ? (_pick((req['user'] as Map)['name']).isEmpty
                    ? 'Unknown User'
                    : _pick((req['user'] as Map)['name']))
                : (_pick(req['user_name']).isEmpty
                    ? 'Unknown User'
                    : _pick(req['user_name']));

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
                    // HEADER
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
                        _chip(status),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // TYPE
                    Row(
                      children: [
                        Icon(Icons.call,
                            size: 16, color: Colors.orange.shade700),
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

                    const SizedBox(height: 12),

                    // ACTIONS
                    if (status == 'pending') ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _actBusy
                                  ? null
                                  : () => _respond(
                                        req: req,
                                        status: "declined",
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
                                  : () => _respond(
                                        req: req,
                                        status: "accepted",
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
                    ]

                    // ---------- ACCEPTED → JOIN AGAIN ----------
                    else if (status == 'accepted') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _actBusy ? null : () => _joinCall(req),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Join Again"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
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

  Widget _chip(String status) {
    Color c;
    switch (status.toLowerCase()) {
      case "accepted":
        c = Colors.green;
        break;
      case "declined":
        c = Colors.red;
        break;
      default:
        c = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: c)),
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
          Icon(Icons.call_missed, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text("No Audio Requests"),
        ],
      ),
    );
  }
}
