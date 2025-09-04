// To parse this JSON data, do
//
//     final storyTextModel = storyTextModelFromJson(jsonString);

import 'dart:convert';

StoryTextModel storyTextModelFromJson(String str) => StoryTextModel.fromJson(json.decode(str));

String storyTextModelToJson(StoryTextModel data) => json.encode(data.toJson());

class StoryTextModel {
  String? message;
  RecordList? recordList;
  int? status;

  StoryTextModel({
    this.message,
    this.recordList,
    this.status,
  });

  StoryTextModel copyWith({
    String? message,
    RecordList? recordList,
    int? status,
  }) =>
      StoryTextModel(
        message: message ?? this.message,
        recordList: recordList ?? this.recordList,
        status: status ?? this.status,
      );

  factory StoryTextModel.fromJson(Map<String, dynamic> json) => StoryTextModel(
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

  RecordList copyWith({
    String? astrologerId,
    String? media,
    String? mediaType,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
  }) =>
      RecordList(
        astrologerId: astrologerId ?? this.astrologerId,
        media: media ?? this.media,
        mediaType: mediaType ?? this.mediaType,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
      );

  factory RecordList.fromJson(Map<String, dynamic> json) => RecordList(
    astrologerId: json["astrologerId"],
    media: json["media"],
    mediaType: json["mediaType"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
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
