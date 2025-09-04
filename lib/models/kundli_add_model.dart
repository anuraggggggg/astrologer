// To parse this JSON data, do
//
//     final kundliReceiveModel = kundliReceiveModelFromJson(jsonString);

import 'dart:convert';

KundliReceiveModel kundliReceiveModelFromJson(String str) =>
    KundliReceiveModel.fromJson(json.decode(str));

String kundliReceiveModelToJson(KundliReceiveModel data) =>
    json.encode(data.toJson());

class KundliReceiveModel {
  String message;
  List<RecordList> recordList;
  int status;

  KundliReceiveModel({
    required this.message,
    required this.recordList,
    required this.status,
  });

  factory KundliReceiveModel.fromJson(Map<String, dynamic> json) =>
      KundliReceiveModel(
        message: json["message"],
        recordList: List<RecordList>.from(
            json["recordList"].map((x) => RecordList.fromJson(x))),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "recordList": List<dynamic>.from(recordList.map((x) => x.toJson())),
        "status": status,
      };
}

class RecordList {
  String name;
  String gender;
  DateTime birthDate;
  String birthTime;
  String birthPlace;
  int createdBy;
  int modifiedBy;
  dynamic latitude;
  dynamic longitude;
  dynamic timezone;
  String pdfType;
  DateTime updatedAt;
  DateTime createdAt;
  int id;

  RecordList({
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.createdBy,
    required this.modifiedBy,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.pdfType,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory RecordList.fromJson(Map<String, dynamic> json) => RecordList(
        name: json["name"],
        gender: json["gender"],
        birthDate: DateTime.parse(json["birthDate"]),
        birthTime: json["birthTime"],
        birthPlace: json["birthPlace"],
        createdBy: json["createdBy"],
        modifiedBy: json["modifiedBy"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        timezone: json["timezone"],
        pdfType: json["pdf_type"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "gender": gender,
        "birthDate":
            "${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}",
        "birthTime": birthTime,
        "birthPlace": birthPlace,
        "createdBy": createdBy,
        "modifiedBy": modifiedBy,
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone,
        "pdf_type": pdfType,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "id": id,
      };
}
