  // lib/views/HomeScreen/tabs/homeTab/ChatRequests.dart

  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  import 'package:astrowaypartner/fastApi/fastApiServices.dart';
  import '../../../chat/chat_history.dart';
import '../../../chat/chat_screen.dart';

  class ChatRequests extends StatefulWidget {
    const ChatRequests({super.key});

    @override
    State<ChatRequests> createState() => _ChatRequestsState();
  }

  class _ChatRequestsState extends State<ChatRequests> {
    Future<List<Map<String, dynamic>>>? _requestsFuture;

    String? _myAstroId;


    String? _myAstroName;
    String? _bearerToken;
    String _chatRate = "0";

    bool _busy = false;

    @override
    void initState() {
      super.initState();
      _bootstrap();
    }




    Future<void> _bootstrap() async {
      final prefs = await SharedPreferences.getInstance();

      _myAstroId = prefs.getString('astro_id') ?? '';
      _myAstroName = prefs.getString('name') ??
          prefs.getString('astro_name') ??
          prefs.getString('full_name') ??
          'Astrologer';

      _bearerToken = prefs.getString('access_token') ?? '';

      _loadRequests();
      setState(() {});
    }

    void _loadRequests() {
      _requestsFuture = FastApiServices().fetchAstrologerRequests();
    }

    Future<void> _refresh() async {
      _loadRequests();
      setState(() {});
    }

    // ------------------- Extractors -------------------
    String _getUserName(Map<String, dynamic> r) {
      try {
        final u = r['user'];
        if (u is Map && u['name'] != null) return u['name'].toString();
        if (r['user_name'] != null) return r['user_name'].toString();
        return 'User';
      } catch (_) {
        return 'User';
      }
    }

    String? _getUserId(Map<String, dynamic> r) {
      return (r['user']?['id'] ??
              r['user_id'] ??
              r['customer_id'] ??
              r['sender']?['id'])
          ?.toString();
    }

    String? _getRoomId(Map<String, dynamic> r) {
      return r['room_id']?.toString();
    }

    String _getStatus(Map<String, dynamic> r) =>
        (r['status'] ?? '').toString().toLowerCase();

    String _extractChatRate(Map<String, dynamic> r) {
      try {
        final dynamic rate = r['chatCharge'] ??
            r['chat_charge'] ??
            r['chat_rate'] ??
            r['rate'] ??
            r['price'] ??
            r['astrologer']?['chatCharge'];

        if (rate != null) return rate.toString();
      } catch (_) {}

      return "0";
    }

    // ------------------- Accept Chat -------------------
    Future<void> _acceptChat(Map<String, dynamic> req) async {
      if (_busy) return;
      setState(() => _busy = true);

      final roomId = _getRoomId(req);
      final userId = _getUserId(req);
      final userName = _getUserName(req);
      final requestId = req['id'];

      // Extract chat rate
      final chatRate = _extractChatRate(req);

      if (roomId == null || userId == null || requestId == null) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid chat data")));
        return;
      }

      // Step 1 → Accept API
      final parsedId =
          requestId is int ? requestId : int.tryParse("$requestId") ?? 0;

      final ok = await FastApiServices().respondToRequest(
        requestId: parsedId,
        status: "accepted",
      );

      if (!ok) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to accept")));
        return;
      }


      final prefs = await SharedPreferences.getInstance();
      final String? userIdOfAstro = prefs.getString("user_id");

      if (userIdOfAstro == null || userIdOfAstro.isEmpty) {
        debugPrint("❌ user_id_of_astro not found in SharedPreferences");
        setState(() => _busy = false);
        return;
      }

      debugPrint("🧠 ASTRO USER ID (from prefs): $userIdOfAstro");

      debugPrint("💬 Request accepted successfully.");

      // Step 2 → Send Notification to CUSTOMER (FULL DATA)
      try {
        await FastApiServices().sendCustomerNotification(
          userId: userId,
          title: "Chat Request Accepted",
          body: "Astrologer has accepted your chat request",
          type: "chat_accept",
          screen: "chatPage",
          data: {
            "roomId": roomId,
            "astrologerUid": userIdOfAstro,
            "myUserId": userId,
            "astro_id": _myAstroId,

            "astrologerName":
                _myAstroName?.isEmpty ?? true ? "Astrologer" : _myAstroName,
            "chatRate": "0",
            // "token": _bearerToken,
          },
        );








        // _myAstroId    userId

        debugPrint("📨 Customer notified with full payload.");
      } catch (e) {
        debugPrint("⚠️ Notification failed: $e");
      }

      // Step 3 → Open Astrologer chat instantly
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AstrologerChatPage(
            roomId: roomId,
            myUserId: _myAstroId!,
            receiverId: userId,
            receiverName: userName,
          ),
        ),
      ).then((_) => _refresh());

      setState(() => _busy = false);
    }

    // ------------------- UI -------------------
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

          final chats = snapshot.data!
              .where((r) => (r['session_type'] ?? '') == 'chat')
              .toList();

          if (chats.isEmpty) return const _EmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              return _buildChatCard(chats[index]);
            },
          );
        },
      );
    }




    Widget _buildChatCard(Map<String, dynamic> req) {
      final userName = _getUserName(req);
      final status = _getStatus(req);

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
                          Text(
                            "User",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  _statusChip(status),
                ],
              ),

              const SizedBox(height: 16),

              // SESSION TYPE
              Row(
                children: [
                  Icon(Icons.chat,
                      size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 6),
                  Text(
                    "Chat Session",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ACTIONS
              if (status == "pending") ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () async {
                          await FastApiServices().respondToRequest(
                            requestId: req['id'],
                            status: "declined",
                          );
                          _refresh();
                        },
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
                        onPressed: _busy ? null : () => _acceptChat(req),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Accept & Chat"),
                      ),
                    ),
                  ],
                ),
              ]

    else if (status == "accepted") ...[
    Align(
    alignment: Alignment.centerRight,
    child: IconButton(
    tooltip: "View Chat History",
    icon: const Icon(Icons.history, color: Colors.orange),
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (_) => AstrologerChatHistoryPage(
    otherUserId: _getUserId(req)!,
    userName: _getUserName(req),
    ),
    ),
    );
    },
    ),
    ),
    ]
    else ...[
                Text(
                  "This request is $status.",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }


    Widget _buildCard(Map<String, dynamic> req) {
      final name = _getUserName(req);
      final status = _getStatus(req);

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 22, color: Colors.blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(name,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600)),
                  ),
                  _statusChip(status),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              if (status == "pending")
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () async {
                                await FastApiServices().respondToRequest(
                                  requestId: req['id'],
                                  status: "declined",
                                );
                                _refresh();
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                        ),
                        child: const Text("Reject"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _busy ? null : () => _acceptChat(req),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                        child: const Text("Accept & Chat"),
                      ),
                    ),
                  ],
                )
              else
                Center(
                  child: Text(
                    status == "accepted" ? "Session Active" : "Session Closed",
                    style: TextStyle(
                        color: status == "accepted" ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    Widget _statusChip(String s) {
      Color c = {
            "pending": Colors.orange,
            "accepted": Colors.green,
            "declined": Colors.red,
          }[s] ??
          Colors.grey;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: c.withOpacity(.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          s.toUpperCase(),
          style: TextStyle(
            color: c,
            fontWeight: FontWeight.bold,
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
          Text("No Chat Requests",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ));
    }
  }
