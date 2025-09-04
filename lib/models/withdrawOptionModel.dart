// To parse this JSON data, do
//
//     final withdrawOptionModel = withdrawOptionModelFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

WithdrawOptionModel withdrawOptionModelFromJson(String str) =>
    WithdrawOptionModel.fromJson(json.decode(str));

String withdrawOptionModelToJson(WithdrawOptionModel data) =>
    json.encode(data.toJson());

class WithdrawOptionModel {
  String? message;
  int? status;
  List<RecordList>? recordList;

  WithdrawOptionModel({
    this.message,
    this.status,
    this.recordList,
  });

  factory WithdrawOptionModel.fromJson(Map<String, dynamic> json) =>
      WithdrawOptionModel(
        message: json["message"],
        status: json["status"],
        recordList: json["recordList"] == null
            ? []
            : List<RecordList>.from(
                json["recordList"]!.map((x) => RecordList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "recordList": recordList == null
            ? []
            : List<dynamic>.from(recordList!.map((x) => x.toJson())),
      };
}

class RecordList {
  int? id;
  String? methodName;
  int? methodId;
  int? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  RecordList({
    this.id,
    this.methodName,
    this.methodId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory RecordList.fromJson(Map<String, dynamic> json) => RecordList(
        id: json["id"],
        methodName: json["method_name"],
        methodId: json["method_id"],
        isActive: json["isActive"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "method_name": methodName,
        "method_id": methodId,
        "isActive": isActive,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
