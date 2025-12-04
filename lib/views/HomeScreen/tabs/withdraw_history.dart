import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../fastApi/fastApiServices.dart';

class WithdrawItem {
  final String id;
  final double amount;
  final double payableAmount;
  final double? tdsPercent;
  final String status; // normalized to lowercase
  final DateTime createdAt;
  final String? remarks;

  WithdrawItem({
    required this.id,
    required this.amount,
    required this.payableAmount,
    required this.status,
    required this.createdAt,
    this.tdsPercent,
    this.remarks,
  });

  factory WithdrawItem.fromJson(Map<String, dynamic> json) {
    // helper to parse double safely
    double _parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    DateTime _parseDate(dynamic v) {
      try {
        if (v is DateTime) return v;
        if (v is String && v.isNotEmpty) return DateTime.parse(v);
      } catch (_) {}
      // fallback to now (so UI still shows something)
      return DateTime.now();
    }

    return WithdrawItem(
      id: json['id']?.toString() ?? json['withdraw_id']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
      payableAmount: _parseDouble(json['payable_amount'] ?? json['payableAmount'] ?? json['payable']),
      tdsPercent: json['tds_percent'] != null ? _parseDouble(json['tds_percent']) : null,
      status: (json['status'] ?? '').toString().toLowerCase(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt'] ?? json['date']),
      remarks: json['remarks']?.toString(),
    );
  }
}

class WithdrawHistoryPage extends StatefulWidget {
  const WithdrawHistoryPage({super.key});

  @override
  State<WithdrawHistoryPage> createState() => _WithdrawHistoryPageState();
}

class _WithdrawHistoryPageState extends State<WithdrawHistoryPage> {
  bool _loading = true;
  String? _error;
  List<WithdrawItem> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final svc = FastApiServices();
      final raw = await svc.getWithdrawHistory();

      debugPrint('WithdrawHistory: raw=${raw?.length ?? 0}');

      if (raw == null) {
        setState(() {
          _loading = false;
          _error = "Failed to fetch history (check network / token)";
        });
        return;
      }

      try {
        final items = raw.map((m) => WithdrawItem.fromJson(m)).toList();
        // Sort by createdAt descending (most recent first)
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        setState(() {
          _items = items;
          _loading = false;
        });
      } catch (e, st) {
        debugPrint('Parsing withdraw items error: $e\n$st');
        setState(() {
          _loading = false;
          _error = "Parsing error";
        });
      }
    } catch (e, st) {
      debugPrint('Exception in _fetch withdraw history: $e\n$st');
      setState(() {
        _loading = false;
        _error = "Unexpected error";
      });
    }
  }

  Map<String, List<WithdrawItem>> _groupByStatus(List<WithdrawItem> items) {
    final map = <String, List<WithdrawItem>>{};
    for (final it in items) {
      final key = (it.status.isEmpty) ? 'unknown' : it.status;
      map.putIfAbsent(key, () => []);
      map[key]!.add(it);
    }
    return map;
  }

  String _formatDate(DateTime dt) {
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dt.toIso8601String();
    }
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('success') || s.contains('received') || s.contains('approved') || s.contains('completed')) {
      return Colors.green;
    } else if (s.contains('pending') || s.contains('processing')) {
      return Colors.orange;
    } else if (s.contains('failed') || s.contains('rejected')) {
      return Colors.red;
    }
    return Colors.blueGrey;
  }

  Widget _buildTile(WithdrawItem it) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      title: Text(
        "₹${it.amount.toStringAsFixed(2)}",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(_formatDate(it.createdAt)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (it.tdsPercent != null)
                Text("TDS Charge: ${it.tdsPercent!.toStringAsFixed(0)}%  •  "),
              Text("Payable: ₹${it.payableAmount.toStringAsFixed(2)}"),
            ],
          ),
          if (it.remarks != null && it.remarks!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(it.remarks!, style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            it.status.toUpperCase(),
            style: TextStyle(
              color: _statusColor(it.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      onTap: () {
        // Optionally show detail dialog/page
        showModalBottomSheet(
          context: context,
          builder: (_) => _buildDetailSheet(it),
        );
      },
    );
  }

  Widget _buildDetailSheet(WithdrawItem it) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        children: [
          Text("Withdraw Details", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ListTile(
            title: const Text("Amount"),
            subtitle: Text("₹${it.amount.toStringAsFixed(2)}"),
          ),
          ListTile(
            title: const Text("Payable Amount"),
            subtitle: Text("₹${it.payableAmount.toStringAsFixed(2)}"),
          ),
          if (it.tdsPercent != null)
            ListTile(
              title: const Text("TDS Percent"),
              subtitle: Text("${it.tdsPercent!.toStringAsFixed(0)}%"),
            ),
          ListTile(
            title: const Text("Status"),
            subtitle: Text(it.status),
          ),
          ListTile(
            title: const Text("Requested On"),
            subtitle: Text(_formatDate(it.createdAt)),
          ),
          if (it.remarks != null)
            ListTile(
              title: const Text("Remarks"),
              subtitle: Text(it.remarks!),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _approvedInfoBanner() {
    return Container(
      width: double.infinity,
      color: Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Your amount will be credited within 3-4 working bank days.",
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByStatus(_items);

    // Choose ordering: pending first then success/received then others
    final List<String> order = [
      'pending',
      'processing',
      'approved',
      'success',
      'received',
      'completed',
      'failed',
      'rejected',
      'unknown'
    ];
    final keys = [
      ...order.where((k) => grouped.containsKey(k)),
      ...grouped.keys.where((k) => !order.contains(k))
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Withdraw History"),
        actions: [
          // IconButton(
          //   onPressed: _fetch,
          //   icon: const Icon(Icons.refresh),
          //   tooltip: "Refresh",
          // )
          //
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null)
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 80),
            Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
          ],
        )
            : (_items.isEmpty)
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            Center(child: Text("No withdraw history found")),
          ],
        )
            : ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: keys.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final key = keys[index];
            final list = grouped[key]!;
            final title = key[0].toUpperCase() + key.substring(1); // Capitalize

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$title (${list.length})",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "Total: ₹${list.fold(0.0, (p, e) => p + e.amount).toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                // If this is the 'approved' section, show the info banner
                if (key == 'approved') _approvedInfoBanner(),

                ...list.map((it) => _buildTile(it)).toList(),
              ],
            );
          },
        ),
      ),
    );
  }
}
