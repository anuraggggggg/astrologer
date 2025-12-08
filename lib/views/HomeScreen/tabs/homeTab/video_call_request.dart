// lib/views/HomeScreen/tabs/homeTab/VideoCallRequests.dart
import 'package:astrowaypartner/fastApi/agora_service.dart';
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
  Future<List<Map<String, dynamic>>>? _requestsFuture;
  bool _actBusy = false;

  /// fallback astro id retrieved from SharedPreferences (used for navigation/join)
  String _selfAstroId = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _selfAstroId = (prefs.getString('astro_id') ?? '').trim();
    if (_selfAstroId.isEmpty) {
      debugPrint("⚠️ [VideoReq] No astro_id in SharedPreferences. Login required.");
    } else {
      debugPrint("🔐 [VideoReq] Using self astro_id fallback: $_selfAstroId");
    }
    _loadRequests();
    if (mounted) setState(() {});
  }

  void _loadRequests() {
    _requestsFuture = FastApiServices().fetchAstrologerRequests();
  }

  String _pick(dynamic v) => (v ?? '').toString().trim();

  /// Robust extraction of the customer/user id from various payload shapes.
  /// Tries: top-level user_id, user.id, user.user_id, customer_id, receiver.user_id, etc.
  String _extractUserId(Map<String, dynamic> req) {
    String clean(String v) => v.trim();
    final candidates = <String>[
      clean(_pick(req['user_id'])),
      clean(_pick(req['customer_id'])),
      clean(_pick(req['customerId'])),
      clean(_pick(req['userid'])),
      if (req['user'] is Map)
        clean(_pick((req['user'] as Map)['id'] ??
            (req['user'] as Map)['user_id'] ??
            (req['user'] as Map)['userId'])),
      if (req['receiver'] is Map)
        clean(_pick((req['receiver'] as Map)['user_id'] ??
            (req['receiver'] as Map)['id'])),
      if (req['sender'] is Map)
        clean(_pick((req['sender'] as Map)['user_id'] ??
            (req['sender'] as Map)['id'])),
      if (req['customer'] is Map)
        clean(_pick((req['customer'] as Map)['id'] ??
            (req['customer'] as Map)['user_id'])),
      clean(_pick(req['userId'])),
    ]..removeWhere((e) => e.isEmpty);

    bool looksLikeUserId(String s) {
      if (s.isEmpty) return false;
      final lower = s.toLowerCase();
      if (lower.startsWith('user_')) return true;
      return s.length >= 16; // long-ish fallback
    }

    for (final c in candidates) {
      if (looksLikeUserId(c)) {
        debugPrint("🧩 [VideoReq] Extracted userId='$c' (req id=${req['id']})");
        return c;
      }
    }

    // last resort: top-level 'id' if it isn't numeric (avoid picking request numeric id)
    final topId = _pick(req['id']);
    if (topId.isNotEmpty && !RegExp(r'^\d+$').hasMatch(topId)) {
      if (looksLikeUserId(topId)) {
        debugPrint("🧩 [VideoReq] Using top-level id as userId='$topId'");
        return topId;
      }
    }

    debugPrint("⚠️ [VideoReq] No user id found in request payload: $req");
    return '';
  }

  /// Try to extract an astrologer id from the payload.
  /// Common keys checked: astro_id, astrologer_id, astroId, sender/receiver nested fields, createdBy/created_by.
  String _extractAstroId(Map<String, dynamic> req) {
    String pick(dynamic v) => (v ?? '').toString().trim();

    final candidates = <String>[
      pick(req['astro_id']),
      pick(req['astrologer_id']),
      pick(req['astroId']),
      if (req['sender'] is Map) pick((req['sender'] as Map)['astro_id'] ?? (req['sender'] as Map)['astrologer_id'] ?? (req['sender'] as Map)['id']),
      if (req['receiver'] is Map) pick((req['receiver'] as Map)['astro_id'] ?? (req['receiver'] as Map)['astrologer_id'] ?? (req['receiver'] as Map)['id']),
      pick(req['created_by']),
      pick(req['createdBy']),
      pick(req['owner']),
    ]..removeWhere((s) => s.isEmpty);

    if (candidates.isNotEmpty) {
      debugPrint("🧭 [VideoReq] Extracted astroId candidates: $candidates (req id=${req['id']})");
      return candidates.first;
    }
    return '';
  }

 Future<void> _goToCall({
  String? overrideRoomId,
  String? overrideToken,
  String? overrideAccount,
  String? overrideAppId,
}) async {
  final astroId = _selfAstroId;
  if (astroId.isEmpty) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Astrologer ID missing — please login again.')),
    );
    return;
  }

  if (!mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => VideoCallPage(
        astroId: astroId,
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

Future<void> _respondToRequest(
  int requestId,
  String status,
  Map<String, dynamic> req,
) async {
  if (_actBusy) return;
  setState(() => _actBusy = true);

  try {
    debugPrint("📨 [VideoReq] respondToRequest(id=$requestId, status=$status)");

    // Call the service. It might return bool (old) or Map<String,dynamic> (new).
    final dynamic svcResp = await FastApiServices().respondToRequest(
      requestId: requestId,
      status: status,
    );

    if (!mounted) return;

    // Normalize to session map if possible
    Map<String, dynamic>? session;
    if (svcResp == null) {
      // failure
      debugPrint("💥 [VideoReq] respondToRequest returned null/failed for id=$requestId");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update request.')),
      );
      return;
    } else if (svcResp is bool) {
      if (svcResp == false) {
        debugPrint("💥 [VideoReq] respondToRequest returned false for id=$requestId");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update request.')),
        );
        return;
      }
      // svcResp == true -> we don't have server session object, but proceed with what we know.
      session = {
        'id': requestId,
        'room_id': null,
        'session_type': 'video_call',
        'status': status,
      };
      debugPrint("ℹ️ [VideoReq] respondToRequest returned true (no session body). Using fallback session={id:$requestId}");
    } else if (svcResp is Map<String, dynamic>) {
      session = svcResp;
      debugPrint("✅ [VideoReq] respondToRequest returned session: $session");
    } else {
      // unexpected type
      debugPrint("⚠️ [VideoReq] respondToRequest returned unexpected type: ${svcResp.runtimeType}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update request (unexpected response).')),
      );
      return;
    }

    // At this point we have a session Map (maybe partial)
    if (status.toLowerCase() == 'accepted') {
      final userId = _extractUserId(req);

      if (userId.isNotEmpty) {
        final astroIdToSend = (_selfAstroId.isNotEmpty) ? _selfAstroId : _extractAstroId(req);
        debugPrint("📨 [VideoReq] Preparing to send notification to USER: $userId (astro_id=$astroIdToSend)");

        try {
          // Get Agora tokens/channel from server (authoritative)
          final auth = await AgoraService.getVideoTokens(astroIdToSend);

          // Build join params for astro and customer
          final astroJoin = AgoraService.buildJoinParams(auth: auth, isAstrologer: true);
          final custJoin = AgoraService.buildJoinParams(auth: auth, isAstrologer: false);

          final String channel = custJoin.channel;
          final String custToken = custJoin.token;
          final String custAccount = custJoin.account;
          final String astroToken = astroJoin.token;
          final String astroAccount = astroJoin.account;
          final String appId = auth.appId;
          final int? expireIn = auth.expireIn;

          // Prepare data payload to send in FCM — include agora details so the customer can join directly
          final dataPayload = <String, dynamic>{
            "request_id": session['id']?.toString() ?? requestId.toString(),
            "session_type": session['session_type'] ?? 'video_call',
            "astro_id": astroIdToSend,
            if (session['room_id'] != null) "room_id": session['room_id'].toString(),
            "agora_channel": channel,
            "agora_token": custToken,
            "agora_account": custAccount,
            "app_id": appId,
            if (expireIn != null) "expireIn": expireIn,
          };

          debugPrint("📨 [VideoReq] Sending notification to USER: $userId with data: $dataPayload");

          final notifSuccess = await FastApiServices().sendCustomerNotification(
            userId: userId,
            title: "Video Call Accepted",
            body: "Your video call request has been accepted.",
            type: "video_accept",
            screen: "VideoCallPage",
            data: dataPayload,
          );

          debugPrint("📨 [VideoReq] Notification send result: $notifSuccess");

          // Navigate the astrologer into the call and pass astro's join params as overrides
          setState(() => _actBusy = false);
          await _goToCall(
            overrideRoomId: astroJoin.channel,
            overrideToken: astroToken,
            overrideAccount: astroAccount,
          );
          return;
        } catch (e, st) {
          debugPrint("💥 [VideoReq] Failed to fetch Agora tokens or send notification: $e\n$st");
          // fallback: still navigate astrologer; customer may not get channel info
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Accepted but failed to notify customer / fetch Agora info: $e")),
            );
          }
          setState(() => _actBusy = false);
          await _goToCall();
          return;
        }
      } else {
        debugPrint("⚠️ [VideoReq] No valid user_id found in request. Notification skipped. Payload: $req");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Accepted — customer id missing, notification skipped.")),
          );
        }
        setState(() => _actBusy = false);
        await _goToCall();
        return;
      }
    }

    // Handle non-accepted statuses (declined, etc.)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request $status successfully.")),
      );
    }
    setState(_loadRequests);
  } catch (e, st) {
    debugPrint("🔥 [VideoReq] Unexpected error: $e\n$st");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
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
            .where((req) => (_pick(req['session_type'])).toLowerCase() == 'video_call')
            .toList();

        if (videoRequests.isEmpty) {
          return const _EmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: videoRequests.length,
          itemBuilder: (context, index) {
            final req = videoRequests[index];
            final status = (_pick(req['status'])).toLowerCase();
            final userName = req['user'] is Map
                ? (_pick((req['user'] as Map)['name']) == '' ? 'Unknown User' : _pick((req['user'] as Map)['name']))
                : (_pick(req['user_name']) == '' ? 'Unknown User' : _pick(req['user_name']));

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
                                req['id'] is int ? req['id'] : int.tryParse(_pick(req['id'])) ?? 0,
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
                                req['id'] is int ? req['id'] : int.tryParse(_pick(req['id'])) ?? 0,
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
