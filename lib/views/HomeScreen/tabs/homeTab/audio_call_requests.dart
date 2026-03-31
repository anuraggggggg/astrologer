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

  /// cache session timer responses for audio calls with full details
  final Map<int, Map<String, dynamic>> _sessionCache = {};

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

  Future<void> _refresh() async {
    _sessionCache.clear();
    _loadRequests();
    if (mounted) setState(() {});
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

  // ---------------- SESSION TIMER CHECK WITH DETAILS ----------------

  Future<Map<String, dynamic>?> _getSessionDetails(int requestId) async {
    if (_sessionCache.containsKey(requestId)) {
      return _sessionCache[requestId];
    }

    debugPrint("⏱ [AudioReq] Checking session timer for request: $requestId");
    final res = await FastApiServices().checkSessionTimer(requestId);

    if (res != null) {
      debugPrint(
          "⏱ [AudioReq] Session $requestId: expired=${res['is_expired']}, remaining=${res['remaining_seconds']}s");
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

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  Future<void> _goToCall({
    required String overrideRoomId,
    required String overrideToken,
    required String overrideAccount,
    required String overrideAppId,
    required int requestId,
  }) async {
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
        builder: (_) => AudioCallPage(
          astroId: _selfAstroId,
          isAstrologer: true,
          overrideRoomId: overrideRoomId,
          overrideToken: overrideToken,
          overrideAccount: overrideAccount,
          overrideAppId: overrideAppId,
          requestId: requestId,
        ),
      ),
    );

    if (mounted) {
      _refresh(); // Refresh after returning from call
    }
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
        await _joinCall(req);
        return;
      }

      // ---------------- DECLINED ----------------
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Request $status"),
          backgroundColor: status == "rejected" ? Colors.red : Colors.green,
        ),
      );

      _refresh(); // Refresh after decline
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
      final requestId = int.tryParse(_pick(req['id'])) ?? 0;

      debugPrint(
          "📌 JOIN CALL → USER=$userId ASTRO=$astroId REQUEST=$requestId");

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
          "request_id": requestId,
        },
      );

      await _goToCall(
        overrideRoomId: astroJoin.channel,
        overrideToken: astroJoin.token,
        overrideAccount: astroJoin.account,
        overrideAppId: auth.appId,
        requestId: requestId,
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
            .toList()
          ..sort((a, b) {
            final dateA =
                DateTime.tryParse(_pick(a['created_at'])) ?? DateTime.now();
            final dateB =
                DateTime.tryParse(_pick(b['created_at'])) ?? DateTime.now();
            return dateB.compareTo(dateA);
          });

        if (audioRequests.isEmpty) return const _EmptyState();

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: audioRequests.length,
            itemBuilder: (context, index) {
              final req = audioRequests[index];
              return _buildRequestCard(req);
            },
          ),
        );
      },
    );
  }

  // ---------------- REQUEST CARD ----------------

  Widget _buildRequestCard(Map<String, dynamic> req) {
    final status = (_pick(req['status'])).toLowerCase();
    final requestId = int.tryParse(_pick(req['id'])) ?? 0;
    final profileImage = _getProfileImage(req);

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
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage:
                      profileImage != null ? NetworkImage(profileImage) : null,
                  child: profileImage == null
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
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
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (status == "accepted")
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
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Text(
                    "Audio Call Session",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ACTIONS WITH SESSION TIMER CHECK
            if (status == 'pending') ...[
              _pendingButtons(req)
            ] else if (status == 'accepted') ...[
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
                      status == "rejected" ? Icons.cancel : Icons.info,
                      color: status == "rejected" ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "This request was $status",
                      style: TextStyle(
                        color: status == "rejected" ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------- PENDING BUTTONS ----------------

  Widget _pendingButtons(Map<String, dynamic> req) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _actBusy
                ? null
                : () => _respond(
                      req: req,
                      status: "rejected",
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
                : () => _respond(
                      req: req,
                      status: "accepted",
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

  // ---------------- ACCEPTED BUTTON WITH TIMER CHECK ----------------

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
                        "This call session is no longer available",
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
            onPressed: _actBusy ? null : () => _joinCall(req),
            icon: Icon(
              Icons.call,
              color: isLowTime ? Colors.orange : Colors.white,
            ),
            label: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Join Call"),
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

  // ---------------- STATUS CHIP ----------------

  Widget _chip(String status) {
    Color c;
    IconData? icon;

    switch (status.toLowerCase()) {
      case "accepted":
        c = Colors.green;
        icon = Icons.check_circle;
        break;
      case "rejected":
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
}

// ---------------- EMPTY STATE ----------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.call_missed, size: 70, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "No Audio Call Requests",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            "New audio call requests will appear here",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
