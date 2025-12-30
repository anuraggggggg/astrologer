import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fastApi/fastApiServices.dart';

class AstrologerChatHistoryPage extends StatefulWidget {
  final String otherUserId;
  final String userName;

  const AstrologerChatHistoryPage({
    super.key,
    required this.otherUserId,
    required this.userName,
  });



  @override
  State<AstrologerChatHistoryPage> createState() =>
      _AstrologerChatHistoryPageState();
}

class _AstrologerChatHistoryPageState
    extends State<AstrologerChatHistoryPage> {
  final FastApiServices _api = FastApiServices();
  final ScrollController _scrollController = ScrollController();
  Duration _sessionDuration = Duration.zero;
  final List<Map<String, dynamic>> _messages = [];

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  int _page = 1;
  static const int _pageSize = 50;

  String _myUserId = '';

  @override
  void initState() {
    super.initState();
    _init();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _myUserId = prefs.getString('user_id') ?? '';
    await _loadHistory();
    setState(() => _loading = false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent &&
        !_loadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  String _formatMessageTime(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return TimeOfDay.fromDateTime(dt).format(context);
    } catch (e) {
      return '';
    }
  }


  Future<void> _loadHistory() async {
    final resp = await _api.getChatHistoryForAstrologerSelf(
      otherUserId: widget.otherUserId,
      page: _page,
      size: _pageSize,
    );

    final items = (resp['messages'] as List? ?? []);

    if (items.isEmpty) {
      _hasMore = false;
    } else {
      final mapped = items.map((m) => {
        'sender_id': m['sender_user_id']?.toString(),
        'message': m['content']?.toString() ?? '',
        'created_at': m['created_at'],
      }).toList();

      _messages.addAll(mapped);
      _page++;

      // ✅ CALCULATE TIMER ONLY ON FIRST LOAD
      if (_page == 2 && _messages.length >= 2) {
        _calculateSessionDuration();
      }
    }
  }


  void _calculateSessionDuration() {
    try {
      final first = DateTime.parse(_messages.first['created_at']);
      final last = DateTime.parse(_messages.last['created_at']);

      setState(() {
        _sessionDuration = last.difference(first);
      });
    } catch (e) {
      debugPrint("❌ Timer parse error: $e");
    }
  }


  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }


  Future<void> _loadMore() async {
    _loadingMore = true;
    await _loadHistory();
    setState(() {});
    _loadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.userName}"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (_, i) {
          final m = _messages[i];
          final isMine = m['sender_id'] == _myUserId;
          return _bubble(m, isMine);
        },
      ),
    );
  }

  Widget _bubble(Map<String, dynamic> m, bool isMine) {
    final time = _formatMessageTime(m['created_at']);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMine ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            /// MESSAGE TEXT
            Text(
              m['message'],
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 4),

            /// CREATED AT
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
