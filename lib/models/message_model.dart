class MessageModel {
  int? id;
  String? message;
  String? userName;
  bool? isMe;
  String? profile;
  String? gift;
  DateTime? createdAt;
  bool? isFromWeb;

  MessageModel({
    this.id,
    this.message,
    this.userName,
    this.isMe,
    this.profile,
    this.gift,
    this.isFromWeb = false,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MessageModel();

    return MessageModel(
      id: json['id'],
      message: json['message'],
      userName: json['userName'],
      isMe: json['isMe'],
      profile: json['profile'],
      gift: json['gift'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      isFromWeb: json['isFromWeb'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'userName': userName,
      'isMe': isMe,
      'profile': profile,
      'gift': gift,
      'createdAt': createdAt?.toIso8601String(),
      'isFromWeb': isFromWeb,
    };
  }
}
