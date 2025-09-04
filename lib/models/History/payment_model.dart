class Payment {
  int? id;
  String? paymentMode;
  String? paymentReference;
  int? amount;
  int? userId;
  String? paymentStatus;
  dynamic signature;
  String? orderId;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? createdBy;
  int? modifiedBy;

  Payment({
    this.id,
    this.paymentMode,
    this.paymentReference,
    this.amount,
    this.userId,
    this.paymentStatus,
    this.signature,
    this.orderId,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json["id"],
        paymentMode: json["paymentMode"],
        paymentReference: json["paymentReference"],
        amount: json["amount"],
        userId: json["userId"],
        paymentStatus: json["paymentStatus"],
        signature: json["signature"],
        orderId: json["orderId"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        createdBy: json["createdBy"],
        modifiedBy: json["modifiedBy"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "paymentMode": paymentMode,
        "paymentReference": paymentReference,
        "amount": amount,
        "userId": userId,
        "paymentStatus": paymentStatus,
        "signature": signature,
        "orderId": orderId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "createdBy": createdBy,
        "modifiedBy": modifiedBy,
      };
}
