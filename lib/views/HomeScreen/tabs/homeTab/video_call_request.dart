// lib/views/HomeScreen/tabs/homeTab/VideoCallRequests.dart

import 'package:astrowaypartner/fastApi/agora_service.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/videoCallPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoCallRequests extends StatefulWidget {
  const VideoCallRequests({super.key});

  @override
  State<VideoCallRequests> createState() => _VideoCallRequestsState();
}

class _VideoCallRequestsState extends State<VideoCallRequests> {
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
    _selfAstroId = (prefs.getString('astro_id') ?? '').trim();
    _loadRequests();
    if (mounted) setState(() {});
  }

  void _loadRequests() {
    _requestsFuture = FastApiServices().fetchAstrologerRequests();
  }

  String _pick(dynamic v) => (v ?? '').toString().trim();

  // ---------------------------------------------------
  // Extract USER ID
  // ---------------------------------------------------
  String _extractUserId(Map<String, dynamic> req) {
    final candidates = <String>[
      _pick(req['user_id']),
      _pick(req['customer_id']),
      _pick(req['userId']),
      if (req['user'] is Map) _pick(req['user']['id']),
      if (req['receiver'] is Map) _pick(req['receiver']['user_id']),
    ]..removeWhere((e) => e.isEmpty);

    for (final id in candidates) {
      if (id.startsWith("user_") || id.length >= 16) return id;
    }
    return "";
  }

  // ---------------------------------------------------
  // Extract ASTRO ID
  // ---------------------------------------------------
  String _extractAstroId(Map<String, dynamic> req) {
    final candidates = <String>[
      _pick(req['astro_id']),
      _pick(req['astrologer_id']),
      _pick(req['astroId']),
    ]..removeWhere((e) => e.isEmpty);

    return candidates.isNotEmpty ? candidates.first : _selfAstroId;
  }

  // ---------------------------------------------------
  // Navigate to Call Page
  // ---------------------------------------------------
  Future<void> _goToCall({
    required String room,
    required String token,
    required String account,
    required String appId,
  }) async {
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallPage(
          astroId: _selfAstroId,
          isAstrologer: true,
          overrideRoomId: room,
          overrideToken: token,
          overrideAccount: account,
          overrideAppId: appId,
        ),
      ),
    );

    if (mounted) setState(_loadRequests);
  }

  // ---------------------------------------------------
  // ACCEPT / DECLINE
  // ---------------------------------------------------
  Future<void> _respondToRequest(
      int requestId, String status, Map<String, dynamic> req) async {
    if (_actBusy) return;
    setState(() => _actBusy = true);

    try {
      final resp = await FastApiServices().respondToRequest(
        requestId: requestId,
        status: status,
      );

      if (resp == null || resp == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update request')),
        );
        return;
      }

      if (status == "accepted") {
        final userId = _extractUserId(req);
        final astroId = _extractAstroId(req);

        final auth = await AgoraService.getTokens(astroId);

        final astroJoin =
            AgoraService.buildJoinParams(auth: auth, isAstrologer: true);
        final custJoin =
            AgoraService.buildJoinParams(auth: auth, isAstrologer: false);

        await FastApiServices().sendCustomerNotification(
          userId: userId,
          title: "Video Call Accepted",
          body: "Your video call request has been accepted.",
          type: "video_accept",
          screen: "VideoCallPage",
          data: {
            "session_type": "video_call",
            "astro_id": astroId,
            "agora_channel": custJoin.channel,
            "agora_token": custJoin.token,
            "agora_account": custJoin.account,
            "app_id": auth.appId,
            "expireIn": auth.expireIn,
          },
        );

        await _goToCall(
          room: astroJoin.channel,
          token: astroJoin.token,
          account: astroJoin.account,
          appId: auth.appId,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _actBusy = false);
    }
  }

  // ---------------------------------------------------
  // REJOIN CALL
  // ---------------------------------------------------
  Future<void> _rejoinCall(Map<String, dynamic> req) async {
    if (_actBusy) return;
    setState(() => _actBusy = true);

    try {
      final userId = _extractUserId(req);
      final astroId = _extractAstroId(req);

      final auth = await AgoraService.getTokens(astroId);

      final astroJoin =
          AgoraService.buildJoinParams(auth: auth, isAstrologer: true);
      final custJoin =
          AgoraService.buildJoinParams(auth: auth, isAstrologer: false);

      await FastApiServices().sendCustomerNotification(
        userId: userId,
        title: "Video Call Reconnected",
        body: "Astrologer joined again",
        type: "video_rejoin",
        screen: "VideoCallPage",
        data: {
          "session_type": "video_call",
          "astro_id": astroId,
          "agora_channel": custJoin.channel,
          "agora_token": custJoin.token,
          "agora_account": custJoin.account,
          "app_id": auth.appId,
          "expireIn": auth.expireIn,
        },
      );

      await _goToCall(
        room: astroJoin.channel,
        token: astroJoin.token,
        account: astroJoin.account,
        appId: auth.appId,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Rejoin failed: $e")));
    } finally {
      if (mounted) setState(() => _actBusy = false);
    }
  }

  // ---------------------------------------------------
  // STATUS CHIP
  // ---------------------------------------------------
  Widget _chip(String status) {
    Color c;
    switch (status) {
      case "accepted":
      case "active":
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

  // ---------------------------------------------------
  // UI
  // ---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Video Requests"));
        }

        final videoRequests = snapshot.data!
            .where(
                (e) => _pick(e['session_type']).toLowerCase() == "video_call")
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: videoRequests.length,
          itemBuilder: (_, i) {
            final req = videoRequests[i];
            final status = _pick(req['status']).toLowerCase();
            final name = req['user']?['name'] ?? "Unknown User";

            final canJoin = status == "accepted" ||
                status == "active" ||
                status == "ongoing";

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        _chip(status),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // BUTTON STATES
                    if (status == "pending") ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _actBusy
                                  ? null
                                  : () => _respondToRequest(
                                      int.parse(req['id'].toString()),
                                      "declined",
                                      req),
                              child: const Text("Reject"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _actBusy
                                  ? null
                                  : () => _respondToRequest(
                                      int.parse(req['id'].toString()),
                                      "accepted",
                                      req),
                              child: const Text("Accept & Join"),
                            ),
                          ),
                        ],
                      )
                    ] else if (canJoin) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _actBusy ? null : () => _rejoinCall(req),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Join Again"),
                        ),
                      )
                    ] else ...[
                      Text("Request is $status")
                    ]
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
