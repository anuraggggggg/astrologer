import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../fastApi/fastApiServices.dart';
import 'package:shimmer/shimmer.dart';


class PaymentHistoryTab extends StatefulWidget {
  const PaymentHistoryTab({super.key});

  @override
  State<PaymentHistoryTab> createState() => _PaymentHistoryTabState();
}

class _PaymentHistoryTabState extends State<PaymentHistoryTab> {
  final List<PaymentRecord> _paymentHistory = [
    PaymentRecord(
      id: "PAY-001",
      amount: 1500.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: PaymentType.audioCall,
      status: PaymentStatus.completed,
      duration: "30 mins",
      clientName: "Rajesh Kumar",
    ),
    PaymentRecord(
      id: "PAY-002",
      amount: 2500.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: PaymentType.videoCall,
      status: PaymentStatus.completed,
      duration: "45 mins",
      clientName: "Priya Sharma",
    ),
    PaymentRecord(
      id: "PAY-003",
      amount: 800.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: PaymentType.chat,
      status: PaymentStatus.pending,
      duration: "Chat Session",
      clientName: "Amit Patel",
    ),
    PaymentRecord(
      id: "PAY-004",
      amount: 1200.00,
      date: DateTime.now().subtract(const Duration(days: 7)),
      type: PaymentType.audioCall,
      status: PaymentStatus.completed,
      duration: "25 mins",
      clientName: "Sneha Gupta",
    ),
    PaymentRecord(
      id: "PAY-005",
      amount: 3000.00,
      date: DateTime.now().subtract(const Duration(days: 10)),
      type: PaymentType.videoCall,
      status: PaymentStatus.failed,
      duration: "60 mins",
      clientName: "Vikram Singh",
    ),
    PaymentRecord(
      id: "PAY-006",
      amount: 600.00,
      date: DateTime.now().subtract(const Duration(days: 12)),
      type: PaymentType.chat,
      status: PaymentStatus.completed,
      duration: "Chat Session",
      clientName: "Neha Joshi",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _availableBalance = 0;
    _fetchWalletAmount();
  }



  Future<double> _fetchWalletAmount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final astroId = prefs.getString("astro_id");

      if (astroId != null) {
        final data = await FastApiServices().balanceAmountAstro(astroId);
        if (data != null) {
          final amount = (data['amount'] as num).toDouble();
          print("💰 Wallet Amount (real-time): $amount");
          return amount;
        }
      }
    } catch (e) {
      print("Error fetching wallet amount: $e");
    }
    return 0.0;
  }


  String _selectedFilter = "all";
  bool _isLoading = false;
  late double _availableBalance;


  List<PaymentRecord> get _filteredPayments {
    if (_selectedFilter == "all") return _paymentHistory;
    return _paymentHistory
        .where((payment) => payment.status.name == _selectedFilter)
        .toList();
  }

  // double get _totalEarnings {
  //   return _paymentHistory
  //       .where((payment) => payment.status == PaymentStatus.completed)
  //       .fold(0, (sum, payment) => sum + payment.amount);
  // }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  void _showWithdrawalDialog() {
    showDialog(
      context: context,
      builder: (context) => WithdrawalDialog(
        availableBalance: _availableBalance,
        onWithdraw: (amount) {
          // Handle withdrawal logic
          _processWithdrawal(amount);
        },
      ),
    );
  }

  void _processWithdrawal(double amount) {
    // Simulate withdrawal processing
    setState(() {
      _availableBalance -= amount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade600,
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(
                'Withdrawal request of ₹${amount.toStringAsFixed(2)} submitted!'),
          ],
        ),
      ),
    );

    Navigator.pop(context);
  }

  Widget _buildBalanceCard() {
    return FutureBuilder<double>(
      future: _fetchWalletAmount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Shimmer Placeholder
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Error fetching balance"));
        } else {
          final balance = snapshot.data ?? 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.purple.shade50],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Balance Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Available Balance",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.5, // half of screen width
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "₹${balance.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),


                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            size: 30,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Stats Row
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: _buildBalanceStatItem(
                    //         "₹${_totalEarnings.toStringAsFixed(2)}",
                    //         "Total Earnings",
                    //         Colors.green.shade700,
                    //       ),
                    //     ),
                    //     Expanded(
                    //       child: _buildBalanceStatItem(
                    //         "₹${_pendingAmount.toStringAsFixed(2)}",
                    //         "Pending",
                    //         Colors.orange.shade700,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 16),
                    // Withdraw Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.currency_rupee, size: 20),
                        label: Text("Withdraw Funds"),
                        onPressed: balance > 0 ? _showWithdrawalDialog : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildBalanceStatItem(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {"value": "all", "label": "All"},
      {"value": "completed", "label": "Completed"},
      {"value": "pending", "label": "Pending"},
      {"value": "failed", "label": "Failed"},
    ];

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter["value"];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(filter["label"]!),
              onSelected: (_) =>
                  setState(() => _selectedFilter = filter["value"]!),
              checkmarkColor: Colors.white,
              selectedColor: Colors.yellow.shade700,
              backgroundColor: Colors.grey.shade100,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentItem(PaymentRecord payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getPaymentTypeColor(payment.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPaymentTypeIcon(payment.type),
              color: _getPaymentTypeColor(payment.type),
              size: 24,
            ),
          ),
          title: Text(
            payment.clientName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                "${payment.duration} • ${DateFormat('MMM dd, yyyy').format(payment.date)}",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(payment.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  payment.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(payment.status),
                  ),
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${payment.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(payment.status),
                ),
              ),
              Text(
                payment.id,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPaymentTypeColor(PaymentType type) {
    switch (type) {
      case PaymentType.audioCall:
        return Colors.blue.shade700;
      case PaymentType.videoCall:
        return Colors.purple.shade700;
      case PaymentType.chat:
        return Colors.green.shade700;
    }
  }

  IconData _getPaymentTypeIcon(PaymentType type) {
    switch (type) {
      case PaymentType.audioCall:
        return Icons.mic;
      case PaymentType.videoCall:
        return Icons.videocam;
      case PaymentType.chat:
        return Icons.chat;
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Colors.green.shade600;
      case PaymentStatus.pending:
        return Colors.orange.shade600;
      case PaymentStatus.failed:
        return Colors.red.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade600,
                  Colors.purple.shade600,
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      "Payment History",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildBalanceCard(),
              ],
            ),
          ),

          // Filter and List Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Transaction History",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "${_filteredPayments.length} transactions",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFilterChips(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.yellow.shade700),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Loading payments...",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _filteredPayments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.payments_outlined,
                                      size: 80,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No payments found",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                backgroundColor: Colors.white,
                                color: Colors.yellow.shade700,
                                onRefresh: _refreshData,
                                child: ListView.builder(
                                  itemCount: _filteredPayments.length,
                                  itemBuilder: (context, index) {
                                    return _buildPaymentItem(
                                        _filteredPayments[index]);
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WithdrawalDialog extends StatefulWidget {
  final double availableBalance;
  final Function(double) onWithdraw;

  const WithdrawalDialog({
    required this.availableBalance,
    required this.onWithdraw,
  });

  @override
  State<WithdrawalDialog> createState() => _WithdrawalDialogState();
}

class _WithdrawalDialogState extends State<WithdrawalDialog> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'bank_transfer';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                const Text(
                  "Withdraw Funds",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Available Balance: ₹${widget.availableBalance.toInt().toStringAsFixed(2)}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount to withdraw",
                prefixIcon: Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Withdrawal Method",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              items: [
                DropdownMenuItem(
                  value: 'bank_transfer',
                  child: Row(
                    children: [
                      Icon(Icons.account_balance, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text('Bank Transfer'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'upi',
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text('UPI'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _selectedMethod = value!),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final amount =
                          double.tryParse(_amountController.text) ?? 0;
                      if (amount > 0 && amount <= widget.availableBalance) {
                        widget.onWithdraw(amount);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Withdraw"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum PaymentType { audioCall, videoCall, chat }

enum PaymentStatus { completed, pending, failed }

class PaymentRecord {
  final String id;
  final double amount;
  final DateTime date;
  final PaymentType type;
  final PaymentStatus status;
  final String duration;
  final String clientName;

  PaymentRecord({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.status,
    required this.duration,
    required this.clientName,
  });
}
