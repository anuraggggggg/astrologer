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
  String? _astroName;

  /// cache session timer responses for video calls with full details
  final Map<int, Map<String, dynamic>> _sessionCache = {};

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _selfAstroId = (prefs.getString('astro_id') ?? '').trim();
    _astroName = prefs.getString('name') ?? "Astrologer";

    if (_selfAstroId.isEmpty) {
      debugPrint("⚠️ [VideoReq] No astro_id found in storage.");
    } else {
      debugPrint("🔐 [VideoReq] Using astroId = $_selfAstroId");
    }

    _loadRequests();
    if (mounted) setState(() {});
  }

  void _loadRequests() {
    _requestsFuture = FastApiServices().fetchAstrologerRequests();
  }

  Future<void> _refresh() async {
    _sessionCache.clear();
    _loadRequests();
    if (mounted) setState(() {});
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
  // Get Profile Image
  // ---------------------------------------------------
  String? _getProfileImage(Map<String, dynamic> req) {
    try {
      if (req['user'] is Map) {
        final user = req['user'] as Map;
        if (user['profile'] is Map) {
          final profile = user['profile'] as Map;
          return profile['profileImage']?.toString();
        }
      }
    } catch (e) {
      debugPrint("Error getting profile image: $e");
    }
    return null;
  }

  // ---------------------------------------------------
  // SESSION TIMER CHECK WITH DETAILS
  // ---------------------------------------------------
  Future<Map<String, dynamic>?> _getSessionDetails(int requestId) async {
    if (_sessionCache.containsKey(requestId)) {
      return _sessionCache[requestId];
    }

    debugPrint("⏱ [VideoReq] Checking session timer for request: $requestId");
    final res = await FastApiServices().checkSessionTimer(requestId);

    if (res != null) {
      debugPrint(
          "⏱ [VideoReq] Session $requestId: expired=${res['is_expired']}, remaining=${res['remaining_seconds']}s");
      _sessionCache[requestId] = res;
    }

    return res;
  }

  Future<bool> _isSessionActive(int requestId) async {
    final details = await _getSessionDetails(requestId);
    return details != null && details["is_expired"] == false;
  }

  String _getRemainingTimeText(Map<String, dynamic>? details) {
    if (details == null || details['remaining_seconds'] == null) return '';

    final seconds = details['remaining_seconds'];
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '$minutes min ${remainingSeconds}s';
    } else {
      return '$remainingSeconds sec';
    }
  }

  Color _getTimerColor(Map<String, dynamic>? details) {
    if (details == null) return Colors.grey;
    final seconds = details['remaining_seconds'] ?? 0;
    if (seconds < 60) return Colors.red; // Less than 1 minute
    if (seconds < 180) return Colors.orange; // Less than 3 minutes
    return Colors.green;
  }

  // ---------------------------------------------------
  // Navigate to Call Page
  // ---------------------------------------------------
  Future<void> _goToCall({
    required String room,
    required String token,
    required String account,
    required String appId,
    required int requestId,
  }) async {
    if (!mounted) return;

    // Check session again before navigating
    final isActive = await _isSessionActive(requestId);
    if (!isActive) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session has expired"),
            backgroundColor: Colors.red,
          ),
        );
        _refresh();
      }
      return;
    }

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
          requestId: requestId,
        ),
      ),
    );

    if (mounted) {
      _refresh();
    }
  }

  // ---------------------------------------------------
  // Send Reconnection Notification to Customer
  // ---------------------------------------------------
  Future<void> _sendReconnectionNotification({
    required String userId,
    required String astroId,
    required String channel,
    required String token,
    required String account,
    required String appId,
    required int expireIn,
    required int requestId,
  }) async {
    try {
      debugPrint(
          "📱 [VideoReq] Sending reconnection notification to user: $userId for request: $requestId");

      await FastApiServices().sendCustomerNotification(
        userId: userId,
        title: "Video Call Reconnected",
        body: "$_astroName has rejoined the video call",
        type: "video_rejoin",
        screen: "VideoCallPage",
        data: {
          "session_type": "video_call",
          "astro_id": astroId,
          "astrologerName": _astroName ?? "Astrologer",
          "agora_channel": channel,
          "agora_token": token,
          "agora_account": account,
          "app_id": appId,
          "expireIn": expireIn, // This is correct - passed from auth.expireIn
          "request_id": requestId,
          "isRejoin": true,
        },
      );

      debugPrint(
          "✅ [VideoReq] Reconnection notification sent for request: $requestId");
    } catch (e) {
      debugPrint("❌ [VideoReq] Failed to send reconnection notification: $e");
    }
  }

  // ---------------------------------------------------
  // ACCEPT / DECLINE
  // ---------------------------------------------------
  Future<void> _respondToRequest(
      int requestId, String status, Map<String, dynamic> req) async {
    if (_actBusy) return;
    setState(() => _actBusy = true);

    try {
      debugPrint("📨 [VideoReq] Updating request $requestId → $status");

      final resp = await FastApiServices().respondToRequest(
        requestId: requestId,
        status: status,
      );

      if (!mounted) return;

      if (resp == null || resp == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update request')),
        );
        return;
      }

      if (status == "accepted") {
        // Check if session is still valid before joining
        final isActive = await _isSessionActive(requestId);
        if (!isActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Session has already expired"),
              backgroundColor: Colors.red,
            ),
          );
          _refresh();
          return;
        }

        final userId = _extractUserId(req);
        final astroId = _extractAstroId(req);

        final auth = await AgoraService.getTokens(astroId);

        final astroJoin =
            AgoraService.buildJoinParams(auth: auth, isAstrologer: true);
        final custJoin =
            AgoraService.buildJoinParams(auth: auth, isAstrologer: false);

        // Send acceptance notification
        await FastApiServices().sendCustomerNotification(
          userId: userId,
          title: "Video Call Accepted",
          body: "$_astroName has accepted your video call request",
          type: "video_accept",
          screen: "VideoCallPage",
          data: {
            "session_type": "video_call",
            "astro_id": astroId,
            "astrologerName": _astroName ?? "Astrologer",
            "agora_channel": custJoin.channel,
            "agora_token": custJoin.token,
            "agora_account": custJoin.account,
            "app_id": auth.appId,
            "expireIn": auth.expireIn,
            "request_id": requestId,
          },
        );

        await _goToCall(
          room: astroJoin.channel,
          token: astroJoin.token,
          account: astroJoin.account,
          appId: auth.appId,
          requestId: requestId,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Request $status"),
            backgroundColor: status == "declined" ? Colors.red : Colors.grey,
          ),
        );
        _refresh();
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _actBusy = false);
    }
  }

  // ---------------------------------------------------
  // REJOIN CALL WITH NOTIFICATION
  // ---------------------------------------------------
  Future<void> _rejoinCall(Map<String, dynamic> req) async {
    if (_actBusy) return;
    setState(() => _actBusy = true);

    try {
      // Safely parse requestId
      final requestId = int.tryParse(_pick(req['id']));

      if (requestId == null) {
        debugPrint("❌ [VideoReq] Invalid request ID in rejoin");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid request ID"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userId = _extractUserId(req);
      final astroId = _extractAstroId(req);

      // Check if session is still active
      final isActive = await _isSessionActive(requestId);
      if (!isActive) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session has expired"),
            backgroundColor: Colors.red,
          ),
        );
        _refresh();
        return;
      }

      debugPrint(
          "📌 [VideoReq] REJOIN CALL → USER=$userId ASTRO=$astroId REQUEST=$requestId");

      final auth = await AgoraService.getTokens(astroId);

      final astroJoin =
          AgoraService.buildJoinParams(auth: auth, isAstrologer: true);
      final custJoin =
          AgoraService.buildJoinParams(auth: auth, isAstrologer: false);

      // Send reconnection notification to customer
      await _sendReconnectionNotification(
        userId: userId,
        astroId: astroId,
        channel: custJoin.channel,
        token: custJoin.token,
        account: custJoin.account,
        appId: auth.appId,
        expireIn: auth.expireIn ?? 600, // This is correct - auth has expireIn
        requestId: requestId,
      );

      await _goToCall(
        room: astroJoin.channel,
        token: astroJoin.token,
        account: astroJoin.account,
        appId: auth.appId,
        requestId: requestId,
      );
    } catch (e) {
      debugPrint("❌ [VideoReq] Rejoin error: $e");
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
    IconData? icon;

    switch (status.toLowerCase()) {
      case "accepted":
      case "active":
      case "ongoing":
        c = Colors.green;
        icon = Icons.check_circle;
        break;
      case "declined":
        c = Colors.red;
        icon = Icons.cancel;
        break;
      case "completed":
        c = Colors.grey;
        icon = Icons.done_all;
        break;
      default:
        c = Colors.orange;
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: c, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: c,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const _EmptyState();
        }

        final videoRequests = snapshot.data!
            .where(
                (e) => _pick(e['session_type']).toLowerCase() == "video_call")
            .toList()
          ..sort((a, b) {
            final dateA =
                DateTime.tryParse(_pick(a['created_at'])) ?? DateTime.now();
            final dateB =
                DateTime.tryParse(_pick(b['created_at'])) ?? DateTime.now();
            return dateB.compareTo(dateA);
          });

        if (videoRequests.isEmpty) return const _EmptyState();

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videoRequests.length,
            itemBuilder: (_, i) => _buildRequestCard(videoRequests[i]),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------
  // REQUEST CARD
  // ---------------------------------------------------
  Widget _buildRequestCard(Map<String, dynamic> req) {
    final status = _pick(req['status']).toLowerCase();
    final requestId = int.tryParse(_pick(req['id'])) ?? 0;
    final name = req['user']?['name'] ?? "Unknown User";
    final profileImage = _getProfileImage(req);

    final canJoin =
        status == "accepted" || status == "active" || status == "ongoing";

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
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage:
                      profileImage != null ? NetworkImage(profileImage) : null,
                  child: profileImage == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (canJoin)
                        FutureBuilder<Map<String, dynamic>?>(
                          future: _getSessionDetails(requestId),
                          builder: (context, snap) {
                            if (!snap.hasData) return const SizedBox();
                            final timeText = _getRemainingTimeText(snap.data);
                            final timerColor = _getTimerColor(snap.data);
                            return Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 14,
                                  color: timerColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: timerColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
                _chip(status),
              ],
            ),

            const SizedBox(height: 16),

            // TYPE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 6),
                  Text(
                    "Video Call Session",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // BUTTON STATES
            if (status == "pending") ...[
              _pendingButtons(req, requestId)
            ] else if (canJoin) ...[
              _acceptedButton(req, requestId)
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      status == "declined" ? Icons.cancel : Icons.info,
                      color: status == "declined" ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "This request was $status",
                      style: TextStyle(
                        color: status == "declined" ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // PENDING BUTTONS
  // ---------------------------------------------------
  Widget _pendingButtons(Map<String, dynamic> req, int requestId) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _actBusy
                ? null
                : () => _respondToRequest(
                      requestId,
                      "declined",
                      req,
                    ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
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
                      requestId,
                      "accepted",
                      req,
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _actBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("Accept & Join"),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------
  // ACCEPTED BUTTON WITH TIMER
  // ---------------------------------------------------
  Widget _acceptedButton(Map<String, dynamic> req, int requestId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getSessionDetails(requestId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isExpired = snapshot.data?['is_expired'] == true;
        final remainingSeconds = snapshot.data?['remaining_seconds'] ?? 0;
        final isLowTime = remainingSeconds < 60; // Less than 1 minute

        if (isExpired) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_off, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Session expired",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "This video session is no longer available",
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _actBusy ? null : () => _rejoinCall(req),
            icon: Icon(
              Icons.videocam,
              color: isLowTime ? Colors.orange : Colors.white,
            ),
            label: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Join Video Call"),
                if (remainingSeconds > 0)
                  Text(
                    '${(remainingSeconds / 60).floor()}:${(remainingSeconds % 60).toString().padLeft(2, '0')} left',
                    style: TextStyle(
                      fontSize: 10,
                      color: isLowTime ? Colors.orange : Colors.white70,
                    ),
                  ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLowTime ? Colors.orange : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------
// EMPTY STATE
// ---------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, size: 70, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "No Video Call Requests",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            "New video call requests will appear here",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
