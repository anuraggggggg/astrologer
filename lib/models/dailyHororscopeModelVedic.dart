// ignore_for_file: file_names, constant_identifier_names

import 'dart:convert';

DailyHororscopeModelVedic dailyHororscopeModelVedicFromJson(String str) =>
    DailyHororscopeModelVedic.fromJson(json.decode(str));

String dailyHororscopeModelVedicToJson(DailyHororscopeModelVedic data) =>
    json.encode(data.toJson());

class DailyHororscopeModelVedic {
  String? message;
  int? astroApiCallType;
  VedicList? vedicList;
  int? status;

  DailyHororscopeModelVedic({
    this.message,
    this.astroApiCallType,
    this.vedicList,
    this.status,
  });

  factory DailyHororscopeModelVedic.fromJson(Map<String, dynamic> json) =>
      DailyHororscopeModelVedic(
        message: json["message"],
        astroApiCallType: json["astroApiCallType"],
        vedicList: json["vedicList"] == null
            ? null
            : VedicList.fromJson(json["vedicList"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "astroApiCallType": astroApiCallType,
        "vedicList": vedicList?.toJson(),
        "status": status,
      };
}

class VedicList {
  List<Scope>? todayHoroscope;
  List<Scope>? weeklyHoroScope;
  List<Scope>? yearlyHoroScope;

  VedicList({
    this.todayHoroscope,
    this.weeklyHoroScope,
    this.yearlyHoroScope,
  });

  factory VedicList.fromJson(Map<String, dynamic> json) => VedicList(
        todayHoroscope: json["todayHoroscope"] == null
            ? []
            : List<Scope>.from(
                json["todayHoroscope"]!.map((x) => Scope.fromJson(x))),
        weeklyHoroScope: json["weeklyHoroScope"] == null
            ? []
            : List<Scope>.from(
                json["weeklyHoroScope"]!.map((x) => Scope.fromJson(x))),
        yearlyHoroScope: json["yearlyHoroScope"] == null
            ? []
            : List<Scope>.from(
                json["yearlyHoroScope"]!.map((x) => Scope.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "todayHoroscope": todayHoroscope == null
            ? []
            : List<dynamic>.from(todayHoroscope!.map((x) => x.toJson())),
        "weeklyHoroScope": weeklyHoroScope == null
            ? []
            : List<dynamic>.from(weeklyHoroScope!.map((x) => x.toJson())),
        "yearlyHoroScope": yearlyHoroScope == null
            ? []
            : List<dynamic>.from(yearlyHoroScope!.map((x) => x.toJson())),
      };
}

class Scope {
  int? id;
  String? zodiac;
  int? totalScore;
  String? luckyColor;
  String? luckyColorCode;
  String? luckyNumber;
  int? physique;
  int? status;
  int? finances;
  int? relationship;
  int? career;
  int? travel;
  int? family;
  int? friends;
  int? health;
  String? botResponse;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? date;
  int? type;
  DateTime? startDate;
  DateTime? endDate;
  String? healthRemark;
  String? careerRemark;
  String? relationshipRemark;
  String? travelRemark;
  String? familyRemark;
  String? friendsRemark;
  String? financesRemark;
  String? statusRemark;
  String? colorCode;

  Scope({
    this.id,
    this.zodiac,
    this.totalScore,
    this.luckyColor,
    this.luckyColorCode,
    this.luckyNumber,
    this.physique,
    this.status,
    this.finances,
    this.relationship,
    this.career,
    this.travel,
    this.family,
    this.friends,
    this.health,
    this.botResponse,
    this.createdAt,
    this.updatedAt,
    this.date,
    this.type,
    this.startDate,
    this.endDate,
    this.healthRemark,
    this.careerRemark,
    this.relationshipRemark,
    this.travelRemark,
    this.familyRemark,
    this.friendsRemark,
    this.financesRemark,
    this.statusRemark,
    this.colorCode,
  });

  factory Scope.fromJson(Map<String, dynamic> json) => Scope(
        id: json["id"],
        zodiac: json["zodiac"],
        totalScore: json["total_score"],
        luckyColor: json["lucky_color"],
        luckyColorCode: json["lucky_color_code"],
        luckyNumber: json["lucky_number"],
        physique: json["physique"],
        status: json["status"],
        finances: json["finances"],
        relationship: json["relationship"],
        career: json["career"],
        travel: json["travel"],
        family: json["family"],
        friends: json["friends"],
        health: json["health"],
        botResponse: json["bot_response"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        type: json["type"],
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"]),
        endDate:
            json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        healthRemark: json["health_remark"],
        careerRemark: json["career_remark"],
        relationshipRemark: json["relationship_remark"],
        travelRemark: json["travel_remark"],
        familyRemark: json["family_remark"],
        friendsRemark: json["friends_remark"],
        financesRemark: json["finances_remark"],
        statusRemark: json["status_remark"],
        colorCode: json["color_code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "zodiac": zodiac,
        "total_score": totalScore,
        "lucky_color": luckyColor,
        "lucky_color_code": luckyColorCode,
        "lucky_number": luckyNumber,
        "physique": physique,
        "status": status,
        "finances": finances,
        "relationship": relationship,
        "career": career,
        "travel": travel,
        "family": family,
        "friends": friends,
        "health": health,
        "bot_response": botResponse,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "type": type,
        "start_date":
            "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "end_date":
            "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        "health_remark": healthRemark,
        "career_remark": careerRemark,
        "relationship_remark": relationshipRemark,
        "travel_remark": travelRemark,
        "family_remark": familyRemark,
        "friends_remark": friendsRemark,
        "finances_remark": financesRemark,
        "status_remark": statusRemark,
        "color_code": colorCode,
      };
}

enum LuckyColorCode { EMPTY, THE_8_A0303, THE_993300 }

final luckyColorCodeValues = EnumValues({
  "": LuckyColorCode.EMPTY,
  "#008200": LuckyColorCode.THE_993300,
  "#993300": LuckyColorCode.THE_993300
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
