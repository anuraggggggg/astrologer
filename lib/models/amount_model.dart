class AmountModel {
  AmountModel({
    this.id,
    this.amount,
    this.createdAt,
    this.updatedAt,
    this.cashback,
  });

  int? id;
  int? amount;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? cashback = 0;

  factory AmountModel.fromJson(Map<String, dynamic> json) => AmountModel(
        id: json["id"],
        amount: json["amount"],
        cashback: json['cashback'],
        createdAt: DateTime.parse(json["created_at"] ?? DateTime.now()),
        updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "cashback": cashback,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}
