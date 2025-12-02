// payment_history_tab.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../fastApi/fastApiServices.dart';
import '../../../fastApi/fastApiEndPoints.dart';
import 'package:shimmer/shimmer.dart';

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
  Map<String, dynamic>? _astroProfile;
  bool _hasUpi = false;
  bool _hasBank = false;
  String? _upiId;
  String? _bankName;
  String? _accountNumber;
  String? _ifscCode;
  String? _accountHolderName;

  // ✅ INIT
  @override
  void initState() {
    super.initState();
    _loadProfileAndData();
  }

  Future<void> _loadProfileAndData() async {
    setState(() => _isLoading = true);
    try {
      // fetch profile
      try {
        final profile = await FastApiServices().getAstrologerById();
        _astroProfile = profile;
        _extractBankAndUpiFromProfile(profile);
      } catch (e) {
        // log but continue — we will still try to fetch balance/transactions
        print('⚠️ Failed to fetch profile: $e');
      }

      await Future.wait([_fetchTransactionHistory(), _fetchWalletAmount()]);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _extractBankAndUpiFromProfile(Map<String, dynamic>? profile) {
    if (profile == null) {
      _hasUpi = false;
      _hasBank = false;
      return;
    }

    // Check common field names — adjust if your API uses different keys
    String? upi = (profile['upiId'] ?? profile['upi_id'] ?? profile['upi'] ?? profile['upiIdString'])?.toString();
    String? bank = (profile['bankName'] ?? profile['bank_name'] ?? profile['bank'] ?? profile['bankNameString'])?.toString();
    String? acct = (profile['accountNumber'] ?? profile['account_number'] ?? profile['accountNo'] ?? profile['account'])?.toString();
    String? ifsc = (profile['ifscCode'] ?? profile['ifsc_code'] ?? profile['ifsc'] ?? profile['ifscCodeString'])?.toString();
    String? holder = (profile['accountHolderName'] ?? profile['account_holder_name'] ?? profile['accountName'] ?? profile['accountHolder'] ?? profile['nameOnAccount'])?.toString();

    // Normalize empties
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
      // require bank name, account number and ifsc at minimum; holder name optional but preferred
      _hasBank = (_bankName != null && _accountNumber != null && _ifscCode != null);
    });

    print('🔎 Profile payment info: upi=$_upiId hasUpi=$_hasUpi hasBank=$_hasBank bank=$_bankName acct=$_accountNumber ifsc=$_ifscCode holder=$_accountHolderName');
  }

  // ---------------- FETCH TRANSACTIONS ----------------
  Future<void> _fetchTransactionHistory() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await FastApiServices.transactionHistory();
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

      setState(() {
        _paymentHistory = fetchedList;
      });
    } catch (e) {
      print("❌ Error fetching transaction history: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ---------------- FETCH BALANCE ----------------
  Future<double> _fetchWalletAmount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final astroId = prefs.getString("astro_id");

      if (astroId != null && astroId.isNotEmpty) {
        final data = await FastApiServices().balanceAmountAstro(astroId);
        if (data != null) {
          final amount = double.tryParse(data['amount'].toString()) ?? 0.0;
          setState(() => _availableBalance = amount);
          print("💰 Wallet Amount: $amount");
          return amount;
        }
      }
    } catch (e) {
      print("❌ Error fetching wallet amount: $e");
    }
    return 0.0;
  }

  // ---------------- HELPERS ----------------
  PaymentType _mapType(String type) {
    switch (type.toLowerCase()) {
      case 'audio_call':
      case 'audio':
        return PaymentType.audioCall;
      case 'video_call':
      case 'video':
        return PaymentType.videoCall;
      case 'chat':
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
    setState(() => _isLoading = true);
    await Future.wait([_fetchTransactionHistory(), _fetchWalletAmount()]);
    setState(() => _isLoading = false);
  }

  // ---------------- SHOW DIALOG ----------------
  void _showWithdrawalDialog() {
    // if no payment methods available, inform user
    if (!_hasUpi && !_hasBank) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please add UPI or Bank details in your profile before withdrawing.'),
      ));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WithdrawalDialog(
        availableBalance: _availableBalance,
        onWithdraw: (amount, method) async {
          // call API and wait
          await _submitWithdrawal(amount, method);
        },
        hasUpi: _hasUpi,
        hasBank: _hasBank,
        upiId: _upiId,
        bankName: _bankName,
        accountNumber: _accountNumber,
        ifscCode: _ifscCode,
        accountHolderName: _accountHolderName,
      ),
    );
  }

  // ---------------- SUBMIT WITHDRAWAL (network) ----------------
  Future<void> _submitWithdrawal(double amount, String method) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      if (token.isEmpty) {
        final snack = const SnackBar(content: Text('Not authenticated. Please login again.'));
        ScaffoldMessenger.of(context).showSnackBar(snack);
        return;
      }

      final uri = Uri.parse('${FastApiEndpoints.fastApiBaseUrl}/api/v1/astro/wallet/request');

      // Body: API example expects { "amount": 1050 }
      final bodyJson = {'amount': amount % 1 == 0 ? amount.toInt() : amount};

      print('📤 POST $uri');
      print('📤 Headers: Authorization: Bearer <token>, Content-Type: application/json');
      print('📤 Body: ${jsonEncode(bodyJson)}');

      final resp = await http.post(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyJson),
      );

      print('📡 withdraw response: status=${resp.statusCode} body=${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        String message = 'Request sent to Admin for approval.';
        String withdrawalId = '';
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map) {
            if (decoded.containsKey('message')) message = decoded['message'].toString();
            if (decoded.containsKey('withdrawal_id')) withdrawalId = decoded['withdrawal_id'].toString();
          }
        } catch (_) {}

        setState(() => _availableBalance = (_availableBalance - amount).clamp(0.0, double.infinity));

        final snack = SnackBar(
          backgroundColor: Colors.green.shade600,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('$message ${withdrawalId.isNotEmpty ? "(ID: $withdrawalId)" : ""}')),
            ],
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snack);

        await Future.delayed(const Duration(milliseconds: 300));
        await _refreshData();
      } else {
        String err = 'Withdrawal request failed.';
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map) {
            if (decoded.containsKey('detail')) err = decoded['detail'].toString();
            else if (decoded.containsKey('message')) err = decoded['message'].toString();
          } else {
            err = resp.body;
          }
        } catch (_) {
          err = resp.body;
        }
        final snack = SnackBar(content: Text(err));
        ScaffoldMessenger.of(context).showSnackBar(snack);
      }
    } catch (e, st) {
      print('🚨 _submitWithdrawal exception: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request failed: $e')));
    } finally {
      setState(() => _isLoading = false);
      if (Navigator.canPop(context)) Navigator.of(context).pop();
    }
  }

  // ---------------- UI BUILDERS ----------------
  Widget _buildBalanceCard() {
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
                          maxWidth: MediaQuery.of(context).size.width * 0.5,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "₹${_availableBalance.toStringAsFixed(2)}",
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.currency_rupee, size: 20),
                  label: const Text("Withdraw Funds"),
                  onPressed: _availableBalance > 0 ? _showWithdrawalDialog : null,
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
              onSelected: (_) => setState(() => _selectedFilter = filter["value"]!),
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
                DateFormat('MMM dd, yyyy').format(payment.date),
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

  // ---------------- BUILD ----------------
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
                      const Spacer(),
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
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
                          return _buildPaymentItem(_filteredPayments[index]);
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

// ---------------- Withdrawal Dialog ----------------
class WithdrawalDialog extends StatefulWidget {
  final double availableBalance;
  final Future<void> Function(double amount, String method) onWithdraw;

  // availability flags + details
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
  final _amountController = TextEditingController();
  String _selectedMethod = 'bank_transfer';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // choose default available method
    if (widget.hasUpi) {
      _selectedMethod = 'upi';
    } else if (widget.hasBank) {
      _selectedMethod = 'bank_transfer';
    } else {
      _selectedMethod = 'none';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _validateAmount(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Enter amount';
    final n = double.tryParse(v);
    if (n == null || n <= 0) return 'Enter valid amount';
    if (n > widget.availableBalance) return 'Amount exceeds available balance';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // build available methods list based on flags
    final List<DropdownMenuItem<String>> methodItems = [];
    if (widget.hasUpi) {
      methodItems.add(const DropdownMenuItem(value: 'upi', child: Text('UPI')));
    }
    if (widget.hasBank) {
      methodItems.add(const DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')));
    }

    // if none available show message
    if (methodItems.isEmpty) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.warning, size: 48, color: Colors.orange),
            const SizedBox(height: 12),
            const Text('No payout method available', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Please add UPI or bank details in your profile before withdrawing.'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
          ]),
        ),
      );
    }

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
              "Available Balance: ₹${widget.availableBalance.toStringAsFixed(2)}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              value: methodItems.any((mi) => mi.value == _selectedMethod) ? _selectedMethod : methodItems.first.value,
              items: methodItems,
              onChanged: (value) => setState(() => _selectedMethod = value ?? methodItems.first.value!),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // show summary details for the selected method (read-only) so user sees which UPI/account will be used
            if (_selectedMethod == 'upi' && widget.upiId != null) ...[
              Text('Using UPI: ${widget.upiId}', style: TextStyle(color: Colors.grey.shade800)),
              const SizedBox(height: 12),
            ],
            if (_selectedMethod == 'bank_transfer' && widget.hasBank) ...[
              Text('Bank: ${widget.bankName ?? '-'}', style: TextStyle(color: Colors.grey.shade800)),
              const SizedBox(height: 4),
              Text('A/C: ${widget.accountNumber ?? '-'}', style: TextStyle(color: Colors.grey.shade800)),
              const SizedBox(height: 4),
              Text('IFSC: ${widget.ifscCode ?? '-'}', style: TextStyle(color: Colors.grey.shade800)),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitting
                        ? null
                        : () async {
                      final val = _amountController.text.trim();
                      final err = _validateAmount(val);
                      if (err != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                        return;
                      }
                      final amount = double.parse(val);

                      // ensure chosen method is allowed
                      if (_selectedMethod == 'upi' && !widget.hasUpi) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please first add your UPI ID in profile.')));
                        return;
                      }
                      if (_selectedMethod == 'bank_transfer' && !widget.hasBank) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please first add your bank details (name, account number, IFSC).')));
                        return;
                      }

                      setState(() => _submitting = true);
                      try {
                        await widget.onWithdraw(amount, _selectedMethod);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Withdrawal failed: $e')));
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: _submitting
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("Withdraw"),
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
