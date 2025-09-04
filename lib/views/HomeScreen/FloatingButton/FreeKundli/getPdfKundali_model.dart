// To parse this JSON data, do
//
//     final getPdfKundaliModel = getPdfKundaliModelFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

GetPdfKundaliModel getPdfKundaliModelFromJson(String str) => GetPdfKundaliModel.fromJson(json.decode(str));

String getPdfKundaliModelToJson(GetPdfKundaliModel data) => json.encode(data.toJson());

class GetPdfKundaliModel {
  String? message;
  RecordList? recordList;
  int? status;

  GetPdfKundaliModel({
    this.message,
    this.recordList,
    this.status,
  });

  factory GetPdfKundaliModel.fromJson(Map<String, dynamic> json) => GetPdfKundaliModel(
    message: json["message"],
    recordList: json["recordList"] == null ? null : RecordList.fromJson(json["recordList"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "recordList": recordList?.toJson(),
    "status": status,
  };
}

class RecordList {
  int? status;
  String? response;

  RecordList({
    this.status,
    this.response,
  });

  factory RecordList.fromJson(Map<String, dynamic> json) => RecordList(
    status: json["status"],
    response: json["response"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "response": response,
  };
}
