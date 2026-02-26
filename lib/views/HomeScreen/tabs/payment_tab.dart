// payment_history_tab.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../fastApi/fastApiServices.dart';
import '../../../fastApi/fastApiEndPoints.dart';

class PaymentHistoryTab extends StatefulWidget {
  const PaymentHistoryTab({super.key});

  @override
  State<PaymentHistoryTab> createState() => _PaymentHistoryTabState();
}

class _PaymentHistoryTabState extends State<PaymentHistoryTab> {
  // ✅ VARIABLES
  List<PaymentRecord> _paymentHistory = [];
  String _selectedFilter = "all";
  bool _isLoading = false;
  double _availableBalance = 0.0;

  // profile info & availability flags
  bool _hasUpi = false;
  bool _hasBank = false;
  String? _upiId;
  String? _bankName;
  String? _accountNumber;
  String? _ifscCode;
  String? _accountHolderName;

  @override
  void initState() {
    super.initState();
    print('📱 PaymentHistoryTab: initState called');
    _loadProfileAndData();
  }

  Future<void> _loadProfileAndData() async {
    print('🔄 PaymentHistoryTab: _loadProfileAndData started');
    setState(() => _isLoading = true);
    try {
      try {
        print('👤 PaymentHistoryTab: Fetching astrologer profile');
        final profile = await FastApiServices().getAstrologerById();
        print('✅ PaymentHistoryTab: Profile fetched: $profile');
        _extractBankAndUpiFromProfile(profile);
      } catch (e, stackTrace) {
        print('❌ PaymentHistoryTab: Failed to fetch profile: $e');
        print('📚 Stack trace: $stackTrace');
      }

      print(
          '🔄 PaymentHistoryTab: Fetching transaction history and wallet amount');
      await Future.wait([_fetchTransactionHistory(), _fetchWalletAmount()]);
    } catch (e, stackTrace) {
      print('❌ PaymentHistoryTab: Error in _loadProfileAndData: $e');
      print('📚 Stack trace: $stackTrace');
    } finally {
      print('✅ PaymentHistoryTab: _loadProfileAndData completed');
      setState(() => _isLoading = false);
    }
  }

  void _extractBankAndUpiFromProfile(Map<String, dynamic>? profile) {
    print('🔍 PaymentHistoryTab: Extracting bank and UPI from profile');
    if (profile == null) {
      print('⚠️ PaymentHistoryTab: Profile is null');
      _hasUpi = false;
      _hasBank = false;
      return;
    }

    try {
      String? upi =
          (profile['upiId'] ?? profile['upi_id'] ?? profile['upi'])?.toString();
      String? bank =
          (profile['bankName'] ?? profile['bank_name'] ?? profile['bank'])
              ?.toString();
      String? acct = (profile['accountNumber'] ??
              profile['account_number'] ??
              profile['accountNo'])
          ?.toString();
      String? ifsc =
          (profile['ifscCode'] ?? profile['ifsc_code'] ?? profile['ifsc'])
              ?.toString();
      String? holder =
          (profile['account_holder_name'] ?? profile['accountHolder'])
              ?.toString();

      upi = (upi == null || upi.trim().isEmpty) ? null : upi.trim();
      bank = (bank == null || bank.trim().isEmpty) ? null : bank.trim();
      acct = (acct == null || acct.trim().isEmpty) ? null : acct.trim();
      ifsc = (ifsc == null || ifsc.trim().isEmpty) ? null : ifsc.trim();
      holder = (holder == null || holder.trim().isEmpty) ? null : holder.trim();

      setState(() {
        _upiId = upi;
        _bankName = bank;
        _accountNumber = acct;
        _ifscCode = ifsc;
        _accountHolderName = holder;
        _hasUpi = _upiId != null;
        _hasBank =
            (_bankName != null && _accountNumber != null && _ifscCode != null);
      });

      print(
          '✅ PaymentHistoryTab: Extracted - UPI: $_upiId, Bank: $_bankName, HasBank: $_hasBank');
    } catch (e, stackTrace) {
      print('❌ PaymentHistoryTab: Error extracting profile data: $e');
      print('📚 Stack trace: $stackTrace');
    }
  }

  Future<void> _fetchTransactionHistory() async {
    print('🔄 PaymentHistoryTab: Fetching transaction history');
    try {
      final transactions = await FastApiServices.transactionHistory();
      print(
          '📊 PaymentHistoryTab: Received ${transactions.length} transactions');

      final fetchedList = transactions.map((t) {
        return PaymentRecord(
          amount: (t.amount ?? 0).toDouble(),
          date: DateTime.tryParse(t.date ?? '') ?? DateTime.now(),
          type: _mapType(t.type ?? ''),
          status: _mapStatus(t.status ?? ''),
          duration: t.duration ?? '',
          clientName: t.userName ?? '',
        );
      }).toList();

      setState(() => _paymentHistory = fetchedList);
      print('✅ PaymentHistoryTab: Transaction history fetched successfully');
    } catch (e, stackTrace) {
      print("❌ PaymentHistoryTab: Error fetching transaction history: $e");
      print('📚 Stack trace: $stackTrace');
    }
  }

  Future<double> _fetchWalletAmount() async {
    print('💰 PaymentHistoryTab: Fetching wallet amount');
    try {
      final prefs = await SharedPreferences.getInstance();
      final astroId = prefs.getString("astro_id");
      print('📱 PaymentHistoryTab: Astro ID: $astroId');

      if (astroId != null && astroId.isNotEmpty) {
        final data = await FastApiServices().balanceAmountAstro(astroId);
        print('📊 PaymentHistoryTab: Balance data: $data');
        if (data != null) {
          final amount = double.tryParse(data['amount'].toString()) ?? 0.0;
          setState(() => _availableBalance = amount);
          print("💰 PaymentHistoryTab: Wallet Amount: ₹$amount");
          return amount;
        }
      }
    } catch (e, stackTrace) {
      print("❌ PaymentHistoryTab: Error fetching wallet amount: $e");
      print('📚 Stack trace: $stackTrace');
    }
    return 0.0;
  }

  PaymentType _mapType(String type) {
    switch (type.toLowerCase()) {
      case 'audio_call':
      case 'audio':
        return PaymentType.audioCall;
      case 'video_call':
      case 'video':
        return PaymentType.videoCall;
      default:
        return PaymentType.chat;
    }
  }

  PaymentStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return PaymentStatus.completed;
      case 'pending':
        return PaymentStatus.pending;
      case 'failed':
      case 'declined':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }

  List<PaymentRecord> get _filteredPayments {
    if (_selectedFilter == "all") return _paymentHistory;
    return _paymentHistory
        .where((payment) => payment.status.name == _selectedFilter)
        .toList();
  }

  Future<void> _refreshData() async {
    print('🔄 PaymentHistoryTab: Refreshing data');
    setState(() => _isLoading = true);
    await Future.wait([_fetchTransactionHistory(), _fetchWalletAmount()]);
    setState(() => _isLoading = false);
    print('✅ PaymentHistoryTab: Data refresh complete');
  }

  void _showWithdrawalDialog() {
    print('💳 PaymentHistoryTab: _showWithdrawalDialog called');
    print(
        '📊 Balance: $_availableBalance, HasUPI: $_hasUpi, HasBank: $_hasBank');

    if (!_hasUpi && !_hasBank) {
      print('⚠️ PaymentHistoryTab: No payment methods available');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please add UPI or Bank details in your profile before withdrawing.')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          print('✅ PaymentHistoryTab: Building WithdrawalDialog');
          return WithdrawalDialog(
            availableBalance: _availableBalance,
            onWithdraw: (amount, method, {breakdown}) async {
              print(
                  '💳 PaymentHistoryTab: onWithdraw called - Amount: $amount, Method: $method');
              print('📊 Breakdown: $breakdown');
              await _submitWithdrawal(amount, method, breakdown: breakdown);
            },
            hasUpi: _hasUpi,
            hasBank: _hasBank,
            upiId: _upiId,
            bankName: _bankName,
            accountNumber: _accountNumber,
            ifscCode: _ifscCode,
            accountHolderName: _accountHolderName,
          );
        },
      );
      print('✅ PaymentHistoryTab: showDialog called successfully');
    } catch (e, stackTrace) {
      print('❌ PaymentHistoryTab: Error showing dialog: $e');
      print('📚 Stack trace: $stackTrace');
    }
  }

  Future<void> _submitWithdrawal(double amount, String method,
      {Map<String, dynamic>? breakdown}) async {
    print('🚀 PaymentHistoryTab: _submitWithdrawal started');
    print('📊 Amount: $amount, Method: $method');

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      print('🔑 Token present: ${token.isNotEmpty}');

      if (token.isEmpty) {
        print('❌ PaymentHistoryTab: No authentication token');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Not authenticated. Please login again.')),
        );
        return;
      }

      final uri = Uri.parse(
          '${FastApiEndpoints.fastApiBaseUrl}/api/v1/astro/wallet/request');
      print('🌐 API URL: $uri');

      final bodyJson = {'amount': amount % 1 == 0 ? amount.toInt() : amount};
      print('📦 Request body: $bodyJson');

      final resp = await http.post(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyJson),
      );

      print('📡 Response status: ${resp.statusCode}');
      print('📡 Response body: ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        String message = 'Request sent to Admin for approval.';
        String withdrawalId = '';
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map) {
            if (decoded.containsKey('message'))
              message = decoded['message'].toString();
            if (decoded.containsKey('withdrawal_id'))
              withdrawalId = decoded['withdrawal_id'].toString();
          }
        } catch (e) {
          print('⚠️ Error parsing response: $e');
        }

        setState(() => _availableBalance =
            (_availableBalance - amount).clamp(0.0, double.infinity));

        print('✅ Withdrawal successful, showing success message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade600,
            content: Text(
                '$message ${withdrawalId.isNotEmpty ? "(ID: $withdrawalId)" : ""}'),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 300));
        await _refreshData();
      } else {
        String err = 'Withdrawal request failed.';
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map) {
            if (decoded.containsKey('detail'))
              err = decoded['detail'].toString();
            else if (decoded.containsKey('message'))
              err = decoded['message'].toString();
          } else {
            err = resp.body;
          }
        } catch (e) {
          err = resp.body;
        }
        print('❌ Withdrawal failed: $err');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      }
    } catch (e, stackTrace) {
      print('❌ PaymentHistoryTab: Exception in _submitWithdrawal: $e');
      print('📚 Stack trace: $stackTrace');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Request failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.purple.shade50],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Available Balance",
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${_availableBalance.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 28,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade100, shape: BoxShape.circle),
                    child: Icon(Icons.account_balance_wallet,
                        size: 30, color: Colors.blue.shade800),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.currency_rupee, size: 20),
                  label: const Text("Withdraw Funds"),
                  onPressed:
                      _availableBalance >= 500 ? _showWithdrawalDialog : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter["value"];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(filter["label"]!),
              onSelected: (_) =>
                  setState(() => _selectedFilter = filter["value"]!),
              selectedColor: Colors.yellow.shade700,
              backgroundColor: Colors.grey.shade100,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentItem(PaymentRecord payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: _getPaymentTypeColor(payment.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getPaymentTypeIcon(payment.type),
              color: _getPaymentTypeColor(payment.type),
              size: 22,
            ),
          ),
          title: Text(
            payment.clientName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                DateFormat('MMM dd, yyyy').format(payment.date),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(payment.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  payment.status.name.toUpperCase(),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(payment.status)),
                ),
              ),
            ],
          ),
          trailing: Text(
            "₹${payment.amount.toStringAsFixed(2)}",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(payment.status)),
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
    print('🏗️ PaymentHistoryTab: Building UI');
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.purple.shade600],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, color: Colors.white, size: 26),
                    const SizedBox(width: 10),
                    const Text(
                      "Payment History",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildBalanceCard(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Transaction History",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800),
                      ),
                      const Spacer(),
                      Text(
                        "${_filteredPayments.length} transactions",
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredPayments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.payments_outlined,
                                        size: 60, color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    Text(
                                      "No payments found",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _refreshData,
                                child: ListView.builder(
                                  itemCount: _filteredPayments.length,
                                  itemBuilder: (context, index) =>
                                      _buildPaymentItem(
                                          _filteredPayments[index]),
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

// ---------------- Withdrawal Dialog ----------------
class WithdrawalDialog extends StatefulWidget {
  final double availableBalance;
  final Future<void> Function(double amount, String method,
      {Map<String, dynamic>? breakdown}) onWithdraw;
  final bool hasUpi;
  final bool hasBank;
  final String? upiId;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? accountHolderName;

  const WithdrawalDialog({
    required this.availableBalance,
    required this.onWithdraw,
    required this.hasUpi,
    required this.hasBank,
    this.upiId,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.accountHolderName,
  });

  @override
  State<WithdrawalDialog> createState() => _WithdrawalDialogState();
}

class _WithdrawalDialogState extends State<WithdrawalDialog> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedMethod = '';
  bool _submitting = false;
  double? _calculatedPayout;

  @override
  void initState() {
    super.initState();
    print('💬 WithdrawalDialog: initState called');
    print('📊 Available balance: ${widget.availableBalance}');
    print('📊 HasUPI: ${widget.hasUpi}, HasBank: ${widget.hasBank}');

    if (widget.hasUpi) {
      _selectedMethod = 'upi';
      print('✅ Selected method: UPI');
    } else if (widget.hasBank) {
      _selectedMethod = 'bank_transfer';
      print('✅ Selected method: Bank Transfer');
    }
  }

  void _calculatePayout() {
    if (_amountController.text.isEmpty) {
      setState(() => _calculatedPayout = null);
      return;
    }

    try {
      final amount = double.parse(_amountController.text.trim());
      print('💰 Calculating payout for amount: $amount');

      if (amount >= 500 && amount <= widget.availableBalance) {
        final afterPlatformFee = amount * 0.70; // After 30% fee
        final payout = afterPlatformFee * 0.90; // After 10% TDS
        setState(() => _calculatedPayout = payout);
        print('✅ Calculated payout: $payout');
      } else {
        print('⚠️ Amount invalid or out of range');
        setState(() => _calculatedPayout = null);
      }
    } catch (e) {
      print('❌ Error calculating payout: $e');
      setState(() => _calculatedPayout = null);
    }
  }

  String? _validateAmount(String value) {
    print('🔍 Validating amount: $value');

    if (value.isEmpty) {
      print('❌ Amount is empty');
      return 'Please enter an amount';
    }

    double? amount;
    try {
      amount = double.parse(value);
      print('✅ Parsed amount: $amount');
    } catch (e) {
      print('❌ Invalid number format: $e');
      return 'Please enter a valid number';
    }

    if (amount < 500) {
      print('❌ Amount below minimum: $amount < 500');
      return 'Minimum withdrawal amount is ₹500';
    }

    if (amount > widget.availableBalance) {
      print('❌ Amount exceeds balance: $amount > ${widget.availableBalance}');
      return 'Insufficient balance';
    }

    print('✅ Amount validation passed');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ WithdrawalDialog: Building UI');

    final methodItems = <DropdownMenuItem<String>>[];
    if (widget.hasUpi) {
      methodItems.add(const DropdownMenuItem(value: 'upi', child: Text('UPI')));
    }
    if (widget.hasBank) {
      methodItems.add(const DropdownMenuItem(
          value: 'bank_transfer', child: Text('Bank Transfer')));
    }

    if (methodItems.isEmpty) {
      print('⚠️ WithdrawalDialog: No payment methods available');
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.warning, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('No payout method available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Please add UPI or bank details in your profile before withdrawing.'),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  print('👋 Closing dialog - no methods');
                  Navigator.pop(context);
                },
                child: const Text('OK'))
          ]),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet,
                      color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  const Text(
                    "Withdraw Funds",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Available Balance: ₹${widget.availableBalance.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Amount Input
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculatePayout(),
                      decoration: InputDecoration(
                        labelText: 'Amount (Min: ₹500)',
                        prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),

                    // Payout Info - Always shown when valid amount entered
                    if (_calculatedPayout != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'You will receive:',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${_calculatedPayout!.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Platform Fee (30%)',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600),
                                  ),
                                ),
                                Text(
                                  '-₹${(double.parse(_amountController.text) * 0.30).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.red),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'TDS (10% on remaining)',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600),
                                  ),
                                ),
                                Text(
                                  '-₹${(double.parse(_amountController.text) * 0.70 * 0.10).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.orange),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Withdrawal Method
                    Text(
                      'Withdrawal Method',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedMethod,
                      items: methodItems,
                      onChanged: (value) {
                        print('📋 Method changed to: $value');
                        setState(() => _selectedMethod = value!);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Method Details
                    if (_selectedMethod == 'upi' && widget.upiId != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.payment,
                                size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(widget.upiId!,
                                    style: TextStyle(
                                        color: Colors.blue.shade800))),
                          ],
                        ),
                      ),
                    ],
                    if (_selectedMethod == 'bank_transfer' &&
                        widget.hasBank) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.accountHolderName != null) ...[
                              _buildDetailRow(Icons.person, 'Name',
                                  widget.accountHolderName!),
                              const SizedBox(height: 6),
                            ],
                            _buildDetailRow(Icons.account_balance, 'Bank',
                                widget.bankName!),
                            const SizedBox(height: 6),
                            _buildDetailRow(
                                Icons.numbers, 'A/C', widget.accountNumber!),
                            const SizedBox(height: 6),
                            _buildDetailRow(
                                Icons.code, 'IFSC', widget.ifscCode!),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () {
                              print('👋 Cancel button pressed');
                              Navigator.pop(context);
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting
                          ? null
                          : () async {
                              print('💳 Withdraw button pressed');
                              final val = _amountController.text.trim();
                              final err = _validateAmount(val);
                              if (err != null) {
                                print('❌ Validation failed: $err');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(err),
                                      behavior: SnackBarBehavior.floating),
                                );
                                return;
                              }

                              final amount = double.parse(val);
                              print('✅ Amount validated: $amount');

                              final platformFee = amount * 0.30;
                              final afterPlatformFee = amount - platformFee;
                              final tds = afterPlatformFee * 0.10;
                              final finalPayout = afterPlatformFee - tds;

                              print('📊 Platform Fee: $platformFee');
                              print('📊 TDS: $tds');
                              print('📊 Final Payout: $finalPayout');

                              setState(() => _submitting = true);
                              try {
                                print('🚀 Calling onWithdraw callback');
                                await widget.onWithdraw(
                                  amount,
                                  _selectedMethod,
                                  breakdown: {
                                    'platformFee': platformFee,
                                    'tds': tds,
                                    'finalPayout': finalPayout,
                                  },
                                );
                                print('✅ onWithdraw completed successfully');
                                if (mounted) {
                                  print('👋 Closing dialog after success');
                                  Navigator.pop(context);
                                }
                              } catch (e, stackTrace) {
                                print('❌ onWithdraw failed: $e');
                                print('📚 Stack trace: $stackTrace');
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Withdrawal failed: $e'),
                                        behavior: SnackBarBehavior.floating),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  print('🔄 Setting submitting to false');
                                  setState(() => _submitting = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Withdraw'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.purple.shade700),
        const SizedBox(width: 6),
        Text('$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    print('💬 WithdrawalDialog: Disposing');
    _amountController.dispose();
    super.dispose();
  }
}

// ---------------- DATA MODELS ----------------
enum PaymentType { audioCall, videoCall, chat }

enum PaymentStatus { completed, pending, failed }

class PaymentRecord {
  final double amount;
  final DateTime date;
  final PaymentType type;
  final PaymentStatus status;
  final String duration;
  final String clientName;

  PaymentRecord({
    required this.amount,
    required this.date,
    required this.type,
    required this.status,
    required this.duration,
    required this.clientName,
  });
}
