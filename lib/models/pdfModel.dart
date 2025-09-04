// To parse this JSON data, do
//
//     final pdfModel = pdfModelFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

PdfModel pdfModelFromJson(String str) => PdfModel.fromJson(json.decode(str));

String pdfModelToJson(PdfModel data) => json.encode(data.toJson());

class PdfModel {
  String message;
  RecordList recordList;
  int status;

  PdfModel({
    required this.message,
    required this.recordList,
    required this.status,
  });

  factory PdfModel.fromJson(Map<String, dynamic> json) => PdfModel(
        message: json["message"],
        recordList: RecordList.fromJson(json["recordList"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "recordList": recordList.toJson(),
        "status": status,
      };
}

class RecordList {
  int status;
  String response;

  RecordList({
    required this.status,
    required this.response,
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
