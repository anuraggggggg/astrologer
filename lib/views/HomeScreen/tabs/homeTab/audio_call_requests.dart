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
  // Navigation → EXACT SAME AS VIDEO CALL
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
  // Handle "Accept" / "Reject"
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

      // Accepted → Join & Notify customer
      if (status == "accepted") {
        final userId = _extractUserId(req);
        final astroId = _extractAstroId(req);

        debugPrint("📌 USER = $userId | ASTRO = $astroId");

        // Fetch unified Agora token
        final auth = await AgoraService.getTokens(astroId);

        final astroJoin = AgoraService.buildJoinParams(
          auth: auth,
          isAstrologer: true,
        );

        final customerJoin = AgoraService.buildJoinParams(
          auth: auth,
          isAstrologer: false,
        );

        // SEND FCM to customer
        await FastApiServices().sendCustomerNotification(
          userId: userId,
          title: "Audio Call Accepted",
          body: "Your audio call request has been accepted",
          type: "audio_accept",
          screen: "AudioCallPage",
          data: {
            "request_id": requestId,
            "session_type": "audio_call",
            "astro_id": astroId,

            // Customer JOIN data
            "agora_channel": customerJoin.channel,
            "agora_token": customerJoin.token,
            "agora_account": customerJoin.account,
            "app_id": auth.appId,
            "expireIn": auth.expireIn,
          },
        );

        // Navigate astrologer into call
        return await _goToCall(
          overrideRoomId: astroJoin.channel,
          overrideToken: astroJoin.token,
          overrideAccount: astroJoin.account,
          overrideAppId: auth.appId,
        );
      }

      // Declined
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
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _requestsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snap.hasData || snap.data!.isEmpty) {
          return const _EmptyState();
        }

        final audioList = snap.data!
            .where(
                (e) => _pick(e['session_type']).toLowerCase() == "audio_call")
            .toList();

        if (audioList.isEmpty) return const _EmptyState();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: audioList.length,
          itemBuilder: (_, i) {
            final req = audioList[i];
            final status = _pick(req['status']);
            final userName = (req['user'] is Map)
                ? _pick(req['user']['name'])
                : _pick(req['user_name']);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(userName.isEmpty ? "User" : userName,
                            style: const TextStyle(fontSize: 18)),
                        _chip(status),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(children: const [
                      Icon(Icons.call, size: 18),
                      SizedBox(width: 6),
                      Text("Audio Call Session")
                    ]),

                    const SizedBox(height: 12),

                    if (status == "pending")
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _respond(req: req, status: "declined"),
                              child: const Text("Reject"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _respond(req: req, status: "accepted"),
                              child: const Text("Accept & Join"),
                            ),
                          ),
                        ],
                      )
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
