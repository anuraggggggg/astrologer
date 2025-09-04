// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

class NotificationModel {
  NotificationModel({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.notificationId,
    this.chatRequestId,
    this.callRequestId,
    this.isActive,
    this.isDelete,
    this.notificationType,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.astrologerName,
    this.astrologerId,
    this.astroprofileImage,
    this.fcmToken,
    this.chatId,
    this.callId,
    this.firebaseChatId,
    this.channelName,
    this.totalMin,
    this.callType,
    this.token,
    this.callStatus,
    this.chatStatus,
  });

  int? id;
  int? userId;
  String? title;
  String? description;
  int? notificationId;
  dynamic chatRequestId;
  int? callRequestId;
  int? isActive;
  int? isDelete;
  int? notificationType;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? createdBy;
  int? modifiedBy;
  String? astrologerName;
  int? astrologerId;
  dynamic astroprofileImage;
  dynamic fcmToken;
  dynamic chatId;
  int? callId;
  dynamic firebaseChatId;
  dynamic channelName;
  String? totalMin;
  int? callType;
  dynamic token;
  String? callStatus;
  String? chatStatus;
//Completed
  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"] ?? 0,
        userId: json["userId"],
        title: json["title"],
        description: json["description"],
        notificationId: json["notificationId"],
        chatRequestId: json["chatRequestId"],
        callRequestId: json["callRequestId"],
        isActive: json["isActive"],
        isDelete: json["isDelete"],
        notificationType: json["notification_type"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        createdBy: json["createdBy"],
        modifiedBy: json["modifiedBy"],
        astrologerName: json["astrologerName"],
        astrologerId: json["astrologerId"],
        astroprofileImage: json["astroprofileImage"],
        fcmToken: json["fcmToken"],
        chatId: json["chatId"],
        callId: json["callId"],
        firebaseChatId: json["firebaseChatId"],
        channelName: json["channelName"],
        totalMin: json["totalMin"],
        callType: json["call_type"],
        token: json["token"],
        callStatus: json["callStatus"],
        chatStatus: json["chatStatus"],
      );

  Map<String, dynamic> toJson() => {
        "chatStatus": chatStatus,
        "callStatus": callStatus,
        "id": id,
        "userId": userId,
        "title": title,
        "description": description,
        "notificationId": notificationId,
        "chatRequestId": chatRequestId,
        "callRequestId": callRequestId,
        "isActive": isActive,
        "isDelete": isDelete,
        "notification_type": notificationType,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "createdBy": createdBy,
        "modifiedBy": modifiedBy,
        "astrologerName": astrologerName,
        "astrologerId": astrologerId,
        "astroprofileImage": astroprofileImage,
        "fcmToken": fcmToken,
        "chatId": chatId,
        "callId": callId,
        "firebaseChatId": firebaseChatId,
        "channelName": channelName,
        "totalMin": totalMin,
        "call_type": callType,
        "token": token,
      };
}
