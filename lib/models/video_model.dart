// To parse this JSON data, do
//
//     final videoModel = videoModelFromJson(jsonString);

import 'dart:convert';

VideoModel videoModelFromJson(String str) =>
    VideoModel.fromJson(json.decode(str));

String videoModelToJson(VideoModel data) => json.encode(data.toJson());

class VideoModel {
  String? message;
  RecordList? recordList;
  int? status;

  VideoModel({
    this.message,
    this.recordList,
    this.status,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
        message: json["message"],
        recordList: json["recordList"] == null
            ? null
            : RecordList.fromJson(json["recordList"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "recordList": recordList?.toJson(),
        "status": status,
      };
}

class RecordList {
  String? astrologerId;
  String? media;
  String? mediaType;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? id;

  RecordList({
    this.astrologerId,
    this.media,
    this.mediaType,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  factory RecordList.fromJson(Map<String, dynamic> json) => RecordList(
        astrologerId: json["astrologerId"],
        media: json["media"],
        mediaType: json["mediaType"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "astrologerId": astrologerId,
        "media": media,
        "mediaType": mediaType,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "id": id,
      };
}
