// lib/views/HomeScreen/tabs/homeTab/ChatRequests.dart

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
  Future<List<Map<String, dynamic>>>? _requestsFuture;

  String? _myAstroId;
  String? _myAstroName;
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

  // ================= HELPERS =================

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
    final dynamic rate = r['chatCharge'] ??
        r['chat_charge'] ??
        r['chat_rate'] ??
        r['rate'] ??
        r['price'] ??
        r['astrologer']?['chatCharge'];

    return rate?.toString() ?? "0";
  }

  // ================= ACCEPT CHAT =================

  Future<void> _acceptChat(Map<String, dynamic> req) async {
    if (_busy) return;
    setState(() => _busy = true);

    final roomId = _getRoomId(req);
    final userId = _getUserId(req);
    final userName = _getUserName(req);
    final requestId = req['id'];
    final chatRate = _extractChatRate(req);

    if (roomId == null || userId == null || requestId == null) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid chat data")));
      return;
    }

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
    final myId = prefs.getString("user_id");

    if (myId == null || myId.isEmpty) {
      setState(() => _busy = false);
      return;
    }

    /// notify customer
    try {
      await FastApiServices().sendCustomerNotification(
        userId: userId,
        title: "Chat Request Accepted",
        body: "Astrologer has accepted your chat request",
        type: "chat_accept",
        screen: "chatPage",
        data: {
          "roomId": roomId,
          "astrologerUid": myId,
          "myUserId": userId,
          "astro_id": _myAstroId,
          "astrologerName": _myAstroName ?? "Astrologer",
          "chatRate": chatRate,
        },
      );
    } catch (_) {}

    /// open chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AstrologerChatPage(
          roomId: roomId,
          myUserId: myId,
          receiverId: userId,
          receiverName: userName,
        ),
      ),
    ).then((_) => _refresh());

    setState(() => _busy = false);
  }

  // ================= UI =================

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
            .toList()
          ..sort((a, b) {
            final aTime = DateTime.tryParse(a["created_at"] ?? "");
            final bTime = DateTime.tryParse(b["created_at"] ?? "");
            return (bTime ?? DateTime.now()).compareTo(aTime ?? DateTime.now());
          });

        if (chats.isEmpty) return const _EmptyState();

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (_, i) => _buildChatCard(chats[i]),
          ),
        );
      },
    );
  }

  // ================= CARD =================

  Widget _buildChatCard(Map<String, dynamic> req) {
    final userName = _getUserName(req);
    final status = _getStatus(req);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 16, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 6),
                        Text("User",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(userName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                _statusChip(status),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.chat, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 6),
                const Text("Chat Session"),
              ],
            ),

            const SizedBox(height: 14),

            /// ACTION BUTTONS
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
                          foregroundColor: Colors.white),
                      child: const Text("Accept & Chat"),
                    ),
                  ),
                ],
              ),
            ] else if (status == "accepted") ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: const Text("Open Chat"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final myId = prefs.getString("user_id");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AstrologerChatPage(
                          roomId: _getRoomId(req)!,
                          myUserId: myId!,
                          receiverId: _getUserId(req)!,
                          receiverName: _getUserName(req),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Text("This request is $status.",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
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
      child: Text(s.toUpperCase(),
          style:
              TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 12)),
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
      ),
    );
  }
}
