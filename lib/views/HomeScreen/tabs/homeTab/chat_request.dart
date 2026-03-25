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

  String? _astroId;
  String? _astroName;
  bool _busy = false;

  /// cache session timer responses
  final Map<int, bool> _sessionActiveCache = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    _astroId = prefs.getString("astro_id");
    _astroName = prefs.getString("name") ?? "Astrologer";

    _loadRequests();
    setState(() {});
  }

  void _loadRequests() {
    if (_astroId == null || _astroId!.isEmpty) return;
    _requestsFuture = FastApiServices().fetchAstrologerRequests();
  }

  Future<void> _refresh() async {
    _sessionActiveCache.clear();
    _loadRequests();
    setState(() {});
  }

  // ---------------- HELPERS ----------------

  String _name(Map<String, dynamic> r) =>
      r["user"]?["name"]?.toString() ?? "User";

  String? _userId(Map<String, dynamic> r) => r["user"]?["id"]?.toString();

  String? _room(Map<String, dynamic> r) => r["room_id"]?.toString();

  String _status(Map<String, dynamic> r) =>
      (r["status"] ?? "").toString().toLowerCase();

  // ---------------- ACCEPT CHAT ----------------

  Future<void> _accept(Map<String, dynamic> req) async {
    if (_busy) return;
    setState(() => _busy = true);

    final roomId = _room(req);
    final userId = _userId(req);
    final name = _name(req);
    final requestId = req["id"];

    if (roomId == null || userId == null || requestId == null) {
      setState(() => _busy = false);
      return;
    }

    /// STEP 1 → ACCEPT REQUEST
    final ok = await FastApiServices().respondToRequest(
      requestId: requestId,
      status: "accepted",
    );

    if (!ok) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to accept request")),
      );
      return;
    }

    /// STEP 2 → GET ASTRO USER ID
    final prefs = await SharedPreferences.getInstance();
    final myId = prefs.getString("user_id");

    if (myId == null) {
      setState(() => _busy = false);
      return;
    }

    /// STEP 3 → NOTIFY CUSTOMER
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
          "astro_id": _astroId,
          "astrologerName": _astroName ?? "Astrologer",
        },
      );
    } catch (e) {
      debugPrint("Notification error: $e");
    }

    /// STEP 4 → OPEN CHAT
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AstrologerChatPage(
          roomId: roomId,
          myUserId: myId,
          receiverId: userId,
          receiverName: name,
          requestId: requestId,
        ),
      ),
    ).then((_) => _refresh());

    setState(() => _busy = false);
  }

  // ---------------- SESSION TIMER CHECK ----------------

  Future<bool> _isActive(int id) async {
    if (_sessionActiveCache.containsKey(id)) {
      return _sessionActiveCache[id]!;
    }

    final res = await FastApiServices().checkSessionTimer(id);

    final active = res != null && res["is_expired"] == false;

    _sessionActiveCache[id] = active;
    return active;
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _requestsFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(child: Text("Error: ${snap.error}"));
        }

        if (!snap.hasData || snap.data!.isEmpty) {
          return const _Empty();
        }

        final list = snap.data!
            .where((e) => e["session_type"] == "chat")
            .toList()
          ..sort((a, b) => DateTime.parse(b["created_at"])
              .compareTo(DateTime.parse(a["created_at"])));

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) => _card(list[i]),
          ),
        );
      },
    );
  }

  // ---------------- CARD ----------------

  Widget _card(Map<String, dynamic> r) {
    final name = _name(r);
    final status = _status(r);
    final id = r["id"];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
              ),
              _chip(status)
            ],
          ),

          const SizedBox(height: 18),

          /// BUTTON STATES

          if (status == "pending")
            _pendingButtons(r)
          else if (status == "accepted")
            _acceptedButton(r, id)
          else
            Text("This request is $status",
                style: const TextStyle(color: Colors.grey))
        ],
      ),
    );
  }

  // ---------------- PENDING BUTTONS ----------------

  Widget _pendingButtons(Map<String, dynamic> r) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              await FastApiServices().respondToRequest(
                requestId: r["id"],
                status: "rejected",
              );
              _refresh();
            },
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Reject"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _busy ? null : () => _accept(r),
            child: const Text("Accept & Chat"),
          ),
        ),
      ],
    );
  }

  // ---------------- ACCEPTED BUTTON ----------------

  Widget _acceptedButton(Map<String, dynamic> r, int id) {
    return FutureBuilder<bool>(
      future: _isActive(id),
      builder: (_, s) {
        if (!s.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!s.data!) {
          return const Text("Session expired",
              style: TextStyle(color: Colors.grey));
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.chat),
            label: const Text("Open Chat"),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final myId = prefs.getString("user_id");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AstrologerChatPage(
                    roomId: _room(r)!,
                    myUserId: myId!,
                    receiverId: _userId(r)!,
                    receiverName: _name(r),
                    requestId: id,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ---------------- STATUS CHIP ----------------

  Widget _chip(String s) {
    Color c = {
          "pending": Colors.orange,
          "accepted": Colors.green,
          "declined": Colors.red,
          "completed": Colors.grey
        }[s] ??
        Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        s.toUpperCase(),
        style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ---------------- EMPTY STATE ----------------

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 70, color: Colors.grey),
          SizedBox(height: 12),
          Text("No Chat Requests",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
