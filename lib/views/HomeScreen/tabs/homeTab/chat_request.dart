import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import '../../../chat/chat_screen.dart';

class ChatRequests extends StatefulWidget {
  const ChatRequests({super.key});

  @override
  State<ChatRequests> createState() => _ChatRequestsState();
}

class _ChatRequestsState extends State<ChatRequests> {
  /// Make it nullable to avoid LateInitializationError during hot reload / early reads
  Future<List<Map<String, dynamic>>>? _requestsFuture;

  /// Fallback for missing astrologer_id in API items
  String? _myAstroId;

  /// Prevents double actions
  bool _actBusy = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadIdentity();
    _loadRequests();
    if (mounted) setState(() {});
  }

  Future<void> _loadIdentity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _myAstroId = prefs.getString('astro_id');
      debugPrint('🔑 [IDENTITY] astro_id=$_myAstroId');
    } catch (e) {
      debugPrint('⚠️ Failed to load astro_id from SharedPreferences: $e');
    }
  }

  void _loadRequests() {
    debugPrint('📥 [LOAD] fetching astrologer requests…');
    _requestsFuture = FastApiServices().fetchAstrologerRequests();
  }

  Future<void> _refresh() async {
    _loadRequests();
    if (mounted) setState(() {});
  }

  Future<void> _respondToRequest(dynamic requestIdRaw, String status) async {
    final int? requestId = (requestIdRaw is int)
        ? requestIdRaw
        : int.tryParse(requestIdRaw?.toString() ?? '');

    debugPrint('📤 [RESPOND] id=$requestId status=$status');

    if (requestId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid request id')),
      );
      return;
    }

    final success = await FastApiServices().respondToRequest(
      requestId: requestId,
      status: status,
    );

    if (!mounted) return;

    if (success) {
      final locked = status.toLowerCase() == 'accepted';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(locked
                ? 'Request accepted. Session locked.'
                : 'Request $status successfully!')),
      );
      await _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update request.')),
      );
    }
  }

  // ---------- Robust extractors + logs ----------

  String _extractUserName(Map<String, dynamic> req) {
    try {
      // Prefer nested user map -> name
      final user = req['user'];
      if (user is Map) {
        final name = user['name'] ?? user['full_name'] ?? user['username'];
        if (name != null && name.toString().trim().isNotEmpty) {
          return name.toString();
        }
      } else if (user is String && user.trim().isNotEmpty) {
        return user;
      }

      // Fallback keys
      final userName = req['user_name'];
      if (userName != null && userName.toString().trim().isNotEmpty) {
        return userName.toString();
      }

      final sender = req['sender'];
      if (sender is Map) {
        final sname =
            sender['name'] ?? sender['full_name'] ?? sender['username'];
        if (sname != null && sname.toString().trim().isNotEmpty) {
          return sname.toString();
        }
      }
    } catch (e) {
      debugPrint('⚠️ _extractUserName error: $e\nRAW=${jsonEncode(req)}');
    }
    return 'Unknown User';
  }

  String? _extractRoomId(Map<String, dynamic> req) {
    final rid = req['room_id']?.toString();
    if (rid != null && rid.trim().isNotEmpty) return rid;
    final room = req['room'];
    if (room is Map && room['id'] != null) return room['id'].toString();
    return null;
  }

  String? _extractUserId(Map<String, dynamic> req) {
    // Prefer explicit user_id, else nested user.id / user.user_id, else sender.id
    final userId = req['user_id'] ??
        (req['user'] is Map
            ? (req['user']['id'] ?? req['user']['user_id'])
            : null) ??
        (req['sender'] is Map ? req['sender']['id'] : null) ??
        req['customer_id'] ??
        (req['customer'] is Map ? req['customer']['id'] : null);
    return (userId == null) ? null : userId.toString();
  }

  String? _extractAstrologerId(Map<String, dynamic> req) {
    // Prefer astrologer_id, else nested astrologer.id / astrologer.astro_id,
    // else receiver.id, else fallback to myAstroId (from SharedPrefs)
    final astroId = req['astrologer_id'] ??
        (req['astrologer'] is Map
            ? (req['astrologer']['id'] ?? req['astrologer']['astro_id'])
            : null) ??
        (req['receiver'] is Map ? req['receiver']['id'] : null) ??
        _myAstroId;
    return (astroId == null) ? null : astroId.toString();
  }

  String _extractSessionType(Map<String, dynamic> req) {
    final t = (req['session_type'] ??
        req['type'] ??
        req['mode'] ??
        (req['session'] is Map ? req['session']['type'] : null))
        ?.toString()
        .toLowerCase();
    return t ?? 'chat';
  }

  void _debugRequest(Map<String, dynamic> req, {String label = 'REQ'}) {
    try {
      final name = _extractUserName(req);
      final room = _extractRoomId(req);
      final uid = _extractUserId(req);
      final aid = _extractAstrologerId(req);
      final st = (req['status'] ?? '').toString();
      final tp = _extractSessionType(req);
      final keys = req.keys.toList();
      debugPrint(
          '[$label] name="$name" room="$room" userId="$uid" astroId="$aid" status="$st" type="$tp" keys=$keys');
    } catch (e) {
      debugPrint('⚠️ _debugRequest error: $e\nRAW=${jsonEncode(req)}');
    }
  }

  // ---------- Actions ----------

  Future<void> _acceptAndStartChat(Map<String, dynamic> request) async {
    if (_actBusy) return;
    setState(() => _actBusy = true);

    _debugRequest(request, label: 'ACCEPT_BEFORE');

    final int? requestId = (request['id'] is int)
        ? request['id']
        : int.tryParse(request['id']?.toString() ?? '');

    if (requestId == null) {
      if (!mounted) return;
      setState(() => _actBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid request id')),
      );
      return;
    }

    final success = await FastApiServices().respondToRequest(
      requestId: requestId,
      status: 'accepted',
    );

    if (!mounted) {
      setState(() => _actBusy = false);
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted successfully!')),
      );

      final roomId = _extractRoomId(request);
      final userId = _extractUserId(request);
      final astrologerId = _extractAstrologerId(request); // now has fallback
      final userName = _extractUserName(request); // Extract user name

      if (roomId == null || userId == null || astrologerId == null) {
        setState(() => _actBusy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Missing required data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        _debugRequest(request, label: 'ACCEPT_MISSING');
        return;
      }

      // prepare additional fields to send in notification data
      String astroName = 'Astrologer';
      String token = '';
      String chatRate = '0';

      try {
        final prefs = await SharedPreferences.getInstance();
        astroName = prefs.getString('name') ??
            prefs.getString('astro_name') ??
            prefs.getString('full_name') ??
            astroName;
        token = prefs.getString('access_token') ?? prefs.getString('token') ?? '';
      } catch (e) {
        debugPrint('⚠️ Could not read astroName/token from prefs: $e');
      }

      // try various keys from the request payload for chat rate
      try {
        final dynamic rateCandidates = request['chatCharge'] ??
            request['chat_charge'] ??
            request['chat_rate'] ??
            request['charge'] ??
            request['rate'] ??
            request['price'];
        if (rateCandidates != null) {
          chatRate = rateCandidates.toString();
        } else {
          // sometimes nested in session or astrologer objects
          if (request['session'] is Map && request['session']['chatCharge'] != null) {
            chatRate = request['session']['chatCharge'].toString();
          } else if (request['astrologer'] is Map && request['astrologer']['chatCharge'] != null) {
            chatRate = request['astrologer']['chatCharge'].toString();
          }
        }
      } catch (_) {
        chatRate = '0';
      }

      final customerId = userId; // customer's id used as "myUserId" in payload per your request

      // Try sending notification to the customer before navigating.
      // This is non-blocking (errors will be shown but we still navigate).
      try {
        debugPrint(
            '📨 [CHAT_REQ] Sending notification to userId=$userId for request=$requestId with astroId=$astrologerId');

        final notifResult = await FastApiServices().sendCustomerNotification(
          userId: userId,
          title: 'Chat Accepted',
          body: 'The astrologer accepted your chat request!',
          type: 'chat_accept',
          screen: 'chatPage',
          data: {
            'astrologerUid': astrologerId,
            'roomId': roomId,
            'myUserId': customerId,
            'astrologerName': astroName,
            'token': token,
            'chatRate': chatRate.toString(),
          },
        );

        debugPrint('📨 [CHAT_REQ] Notification send result: $notifResult');
        if (notifResult != true) {
          // Service returned falsy — show an info snack but don't block navigation
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Accepted but failed to notify customer.')),
            );
          }
        }
      } catch (e, st) {
        debugPrint('💥 [CHAT_REQ] Exception while sending notification: $e\n$st');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Accepted but notification failed: $e')),
          );
        }
      }

      // Navigate to chat as astrologer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AstrologerChatPage(
            roomId: roomId,
            myUserId: astrologerId, // astrologer (you)
            receiverId: userId,
            receiverName: userName, // Pass the user name here
          ),
        ),
      ).then((_) {
        _refresh();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept request.')),
        );
      }
    }

    if (mounted) setState(() => _actBusy = false);
  }

  void _openChat(Map<String, dynamic> request) {
    // This path will no longer be presented for accepted items (UI removed).
    _debugRequest(request, label: 'OPEN_CHAT');
    final roomId = _extractRoomId(request);
    final userId = _extractUserId(request);
    final astrologerId = _extractAstrologerId(request);
    final userName = _extractUserName(request); // Extract user name

    if (roomId == null || userId == null || astrologerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing required data. Cannot open chat.'),
          backgroundColor: Colors.red,
        ),
      );
      _debugRequest(request, label: 'OPEN_CHAT_MISSING');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AstrologerChatPage(
          roomId: roomId,
          myUserId: astrologerId,
          receiverId: userId,
          receiverName: userName, // Pass the user name here
        ),
      ),
    ).then((_) => _refresh());
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    // Guard against null (during first build or hot reload)
    if (_requestsFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(children: const [
              SizedBox(height: 240),
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 240),
            ]);
          } else if (snapshot.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 80),
                Center(child: Text('Error: ${snapshot.error}')),
              ],
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const _EmptyState();
          }

          // Filter only chat requests
          final chatRequests = snapshot.data!
              .where((req) => _extractSessionType(req) == 'chat')
              .toList();

          if (chatRequests.isEmpty) {
            return const _EmptyState();
          }

          // One-time debug of items
          for (final r in chatRequests) {
            _debugRequest(r, label: 'LIST_ITEM');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chatRequests.length,
            itemBuilder: (context, index) {
              final req = chatRequests[index];
              final status = (req['status'] ?? '').toString();
              final showActions = status == 'pending';
              final isAccepted = status == 'accepted';

              final displayName = _extractUserName(req);

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
                                    Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'User',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusChip(status),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Session type info
                      Row(
                        children: [
                          Icon(
                            Icons.chat,
                            size: 16,
                            color: Colors.orange.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Chat Session',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      if (showActions)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _actBusy
                                    ? null
                                    : () =>
                                    _respondToRequest(req['id'], 'declined'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.close, size: 18),
                                    SizedBox(width: 6),
                                    Text('Reject'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                _actBusy ? null : () => _acceptAndStartChat(req),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chat, size: 18),
                                    SizedBox(width: 6),
                                    Text('Accept & Chat'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (isAccepted)
                      // 🔒 Accepted: no re-open allowed → show disabled "Session over"
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
                      else
                        const SizedBox(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch ((status).toLowerCase()) {
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No Chat Requests',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
