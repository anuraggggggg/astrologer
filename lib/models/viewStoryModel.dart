

// ignore_for_file: file_names

class ViewStories {
  int? id;
  int? astrologerId;
  String? mediaType;
  String? media;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? storyViewCount;
  bool? storyView;

  ViewStories({
    this.id,
    this.astrologerId,
    this.mediaType,
    this.media,
    this.createdAt,
    this.updatedAt,
    this.storyViewCount,
    this.storyView,
  });

  ViewStories copyWith({
    int? id,
    int? astrologerId,
    String? mediaType,
    String? media,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? storyViewCount,
    bool? storyView,
  }) =>
      ViewStories(
        id: id ?? this.id,
        astrologerId: astrologerId ?? this.astrologerId,
        mediaType: mediaType ?? this.mediaType,
        media: media ?? this.media,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        storyViewCount: storyViewCount ?? this.storyViewCount,
        storyView: storyView ?? this.storyView,
      );

  factory ViewStories.fromJson(Map<String, dynamic> json) => ViewStories(
    id: json["id"],
    astrologerId: json["astrologerId"],
    mediaType: json["mediaType"],
    media: json["media"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    storyViewCount: json["StoryViewCount"],
    storyView: json["storyView"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "astrologerId": astrologerId,
    "mediaType": mediaType,
    "media": media,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "StoryViewCount": storyViewCount,
    "storyView": storyView,
  };
}
