// To parse this JSON data, do
//
//     final getPdfPrice = getPdfPriceFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

GetPdfPrice getPdfPriceFromJson(String str) =>
    GetPdfPrice.fromJson(json.decode(str));

String getPdfPriceToJson(GetPdfPrice data) => json.encode(data.toJson());

class GetPdfPrice {
  RecordList? recordList;
  bool? isFreeSession;
  int? status;

  GetPdfPrice({
    this.recordList,
    this.isFreeSession,
    this.status,
  });

  factory GetPdfPrice.fromJson(Map<String, dynamic> json) => GetPdfPrice(
        recordList: json["recordList"] == null
            ? null
            : RecordList.fromJson(json["recordList"]),
        isFreeSession: json["isFreeSession"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "recordList": recordList?.toJson(),
        "isFreeSession": isFreeSession,
        "status": status,
      };
}

class RecordList {
  int? small;
  int? medium;
  int? large;

  RecordList({
    this.small,
    this.medium,
    this.large,
  });

  factory RecordList.fromJson(Map<String, dynamic> json) => RecordList(
        small: json["SMALL"],
        medium: json["MEDIUM"],
        large: json["LARGE"],
      );

  Map<String, dynamic> toJson() => {
        "SMALL": small,
        "MEDIUM": medium,
        "LARGE": large,
      };
}
