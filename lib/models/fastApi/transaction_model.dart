class TransactionModel {
  final String date;
  final double amount;
  final String type;
  final String status;
  final String duration;
  final String userName;

  TransactionModel({
    required this.date,
    required this.amount,
    required this.type,
    required this.status,
    required this.duration,
    required this.userName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      date: json['date'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      duration: json['duration'] ?? '',
      userName: json['userName'] ?? 'Unknown',
    );
  }
}
