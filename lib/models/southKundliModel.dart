// To parse this JSON data, do
//
//     final southKundaliMatchingModel = southKundaliMatchingModelFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

SouthKundaliMatchingModel southKundaliMatchingModelFromJson(String str) =>
    SouthKundaliMatchingModel.fromJson(json.decode(str));

String southKundaliMatchingModelToJson(SouthKundaliMatchingModel data) =>
    json.encode(data.toJson());

class SouthKundaliMatchingModel {
  String? message;
  RecordList? recordList;
  LikRpt? girlMangalikRpt;
  LikRpt? boyManaglikRpt;
  int? status;

  SouthKundaliMatchingModel({
    this.message,
    this.recordList,
    this.girlMangalikRpt,
    this.boyManaglikRpt,
    this.status,
  });

  factory SouthKundaliMatchingModel.fromJson(Map<String, dynamic> json) =>
      SouthKundaliMatchingModel(
        message: json["message"],
        recordList: json["recordList"] == null
            ? null
            : RecordList.fromJson(json["recordList"]),
        girlMangalikRpt: json["girlMangalikRpt"] == null
            ? null
            : LikRpt.fromJson(json["girlMangalikRpt"]),
        boyManaglikRpt: json["boyManaglikRpt"] == null
            ? null
            : LikRpt.fromJson(json["boyManaglikRpt"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "recordList": recordList?.toJson(),
        "girlMangalikRpt": girlMangalikRpt?.toJson(),
        "boyManaglikRpt": boyManaglikRpt?.toJson(),
        "status": status,
      };
}

class LikRpt {
  int? status;
  BoyManaglikRptResponse? response;

  LikRpt({
    this.status,
    this.response,
  });

  factory LikRpt.fromJson(Map<String, dynamic> json) => LikRpt(
        status: json["status"],
        response: json["response"] == null
            ? null
            : BoyManaglikRptResponse.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "response": response?.toJson(),
      };
}

class BoyManaglikRptResponse {
  bool? manglikByMars;
  List<String>? factors;
  String? botResponse;
  bool? manglikBySaturn;
  bool? manglikByRahuketu;
  List<String>? aspects;
  double? score;

  BoyManaglikRptResponse({
    this.manglikByMars,
    this.factors,
    this.botResponse,
    this.manglikBySaturn,
    this.manglikByRahuketu,
    this.aspects,
    this.score,
  });

  factory BoyManaglikRptResponse.fromJson(Map<String, dynamic> json) =>
      BoyManaglikRptResponse(
        manglikByMars: json["manglik_by_mars"],
        factors: json["factors"] == null
            ? []
            : List<String>.from(json["factors"]!.map((x) => x)),
        botResponse: json["bot_response"],
        manglikBySaturn: json["manglik_by_saturn"],
        manglikByRahuketu: json["manglik_by_rahuketu"],
        aspects: json["aspects"] == null
            ? []
            : List<String>.from(json["aspects"]!.map((x) => x)),
        score: json["score"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "manglik_by_mars": manglikByMars,
        "factors":
            factors == null ? [] : List<dynamic>.from(factors!.map((x) => x)),
        "bot_response": botResponse,
        "manglik_by_saturn": manglikBySaturn,
        "manglik_by_rahuketu": manglikByRahuketu,
        "aspects":
            aspects == null ? [] : List<dynamic>.from(aspects!.map((x) => x)),
        "score": score,
      };
}

class RecordList {
  int? status;
  RecordListResponse? response;

  RecordList({
    this.status,
    this.response,
  });

  factory RecordList.fromJson(Map<String, dynamic> json) => RecordList(
        status: json["status"],
        response: json["response"] == null
            ? null
            : RecordListResponse.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "response": response?.toJson(),
      };
}

class RecordListResponse {
  Dina? dina;
  Gana? gana;
  Dina? mahendra;
  Dina? sthree;
  Yoni? yoni;
  Rasi? rasi;
  Rasiathi? rasiathi;
  Rasi? vasya;
  Rajju? rajju;
  Dina? vedha;
  double? score;
  String? botResponse;

  RecordListResponse({
    this.dina,
    this.gana,
    this.mahendra,
    this.sthree,
    this.yoni,
    this.rasi,
    this.rasiathi,
    this.vasya,
    this.rajju,
    this.vedha,
    this.score,
    this.botResponse,
  });

  factory RecordListResponse.fromJson(Map<String, dynamic> json) =>
      RecordListResponse(
        dina: json["dina"] == null ? null : Dina.fromJson(json["dina"]),
        gana: json["gana"] == null ? null : Gana.fromJson(json["gana"]),
        mahendra:
            json["mahendra"] == null ? null : Dina.fromJson(json["mahendra"]),
        sthree: json["sthree"] == null ? null : Dina.fromJson(json["sthree"]),
        yoni: json["yoni"] == null ? null : Yoni.fromJson(json["yoni"]),
        rasi: json["rasi"] == null ? null : Rasi.fromJson(json["rasi"]),
        rasiathi: json["rasiathi"] == null
            ? null
            : Rasiathi.fromJson(json["rasiathi"]),
        vasya: json["vasya"] == null ? null : Rasi.fromJson(json["vasya"]),
        rajju: json["rajju"] == null ? null : Rajju.fromJson(json["rajju"]),
        vedha: json["vedha"] == null ? null : Dina.fromJson(json["vedha"]),
        score: json["score"]?.toDouble(),
        botResponse: json["bot_response"],
      );

  Map<String, dynamic> toJson() => {
        "dina": dina?.toJson(),
        "gana": gana?.toJson(),
        "mahendra": mahendra?.toJson(),
        "sthree": sthree?.toJson(),
        "yoni": yoni?.toJson(),
        "rasi": rasi?.toJson(),
        "rasiathi": rasiathi?.toJson(),
        "vasya": vasya?.toJson(),
        "rajju": rajju?.toJson(),
        "vedha": vedha?.toJson(),
        "score": score,
        "bot_response": botResponse,
      };
}

class Dina {
  String? boyStar;
  String? girlStar;
  double? dina;
  String? description;
  String? name;
  dynamic fullScore;
  dynamic mahendra;
  dynamic sthree;
  dynamic vedha;

  Dina({
    this.boyStar,
    this.girlStar,
    this.dina,
    this.description,
    this.name,
    this.fullScore,
    this.mahendra,
    this.sthree,
    this.vedha,
  });

  factory Dina.fromJson(Map<String, dynamic> json) => Dina(
        boyStar: json["boy_star"],
        girlStar: json["girl_star"],
        dina: json["dina"]?.toDouble(),
        description: json["description"],
        name: json["name"],
        fullScore: json["full_score"],
        mahendra: json["mahendra"],
        sthree: json["sthree"],
        vedha: json["vedha"],
      );

  Map<String, dynamic> toJson() => {
        "boy_star": boyStar,
        "girl_star": girlStar,
        "dina": dina,
        "description": description,
        "name": name,
        "full_score": fullScore,
        "mahendra": mahendra,
        "sthree": sthree,
        "vedha": vedha,
      };
}

class Gana {
  String? boyGana;
  String? girlGana;
  dynamic gana;
  String? description;
  String? name;
  dynamic fullScore;

  Gana({
    this.boyGana,
    this.girlGana,
    this.gana,
    this.description,
    this.name,
    this.fullScore,
  });

  factory Gana.fromJson(Map<String, dynamic> json) => Gana(
        boyGana: json["boy_gana"],
        girlGana: json["girl_gana"],
        gana: json["gana"],
        description: json["description"],
        name: json["name"],
        fullScore: json["full_score"],
      );

  Map<String, dynamic> toJson() => {
        "boy_gana": boyGana,
        "girl_gana": girlGana,
        "gana": gana,
        "description": description,
        "name": name,
        "full_score": fullScore,
      };
}

class Rajju {
  String? boyRajju;
  String? girlRajju;
  int? rajju;
  String? description;
  String? name;
  dynamic fullScore;

  Rajju({
    this.boyRajju,
    this.girlRajju,
    this.rajju,
    this.description,
    this.name,
    this.fullScore,
  });

  factory Rajju.fromJson(Map<String, dynamic> json) => Rajju(
        boyRajju: json["boy_rajju"],
        girlRajju: json["girl_rajju"],
        rajju: json["rajju"],
        description: json["description"],
        name: json["name"],
        fullScore: json["full_score"],
      );

  Map<String, dynamic> toJson() => {
        "boy_rajju": boyRajju,
        "girl_rajju": girlRajju,
        "rajju": rajju,
        "description": description,
        "name": name,
        "full_score": fullScore,
      };
}

class Rasi {
  String? boyRasi;
  String? girlRasi;
  dynamic rasi;
  String? description;
  String? name;
  dynamic fullScore;
  dynamic vasya;

  Rasi({
    this.boyRasi,
    this.girlRasi,
    this.rasi,
    this.description,
    this.name,
    this.fullScore,
    this.vasya,
  });

  factory Rasi.fromJson(Map<String, dynamic> json) => Rasi(
        boyRasi: json["boy_rasi"],
        girlRasi: json["girl_rasi"],
        rasi: json["rasi"],
        description: json["description"],
        name: json["name"],
        fullScore: json["full_score"],
        vasya: json["vasya"],
      );

  Map<String, dynamic> toJson() => {
        "boy_rasi": boyRasi,
        "girl_rasi": girlRasi,
        "rasi": rasi,
        "description": description,
        "name": name,
        "full_score": fullScore,
        "vasya": vasya,
      };
}

class Rasiathi {
  String? boyLord;
  String? girlLord;
  dynamic rasiathi;
  String? description;
  String? name;
  dynamic fullScore;

  Rasiathi({
    this.boyLord,
    this.girlLord,
    this.rasiathi,
    this.description,
    this.name,
    this.fullScore,
  });

  factory Rasiathi.fromJson(Map<String, dynamic> json) => Rasiathi(
        boyLord: json["boy_lord"],
        girlLord: json["girl_lord"],
        rasiathi: json["rasiathi"],
        description: json["description"],
        name: json["name"],
        fullScore: json["full_score"],
      );

  Map<String, dynamic> toJson() => {
        "boy_lord": boyLord,
        "girl_lord": girlLord,
        "rasiathi": rasiathi,
        "description": description,
        "name": name,
        "full_score": fullScore,
      };
}

class Yoni {
  String? boyYoni;
  String? girlYoni;
  dynamic yoni;
  String? description;
  String? name;
  dynamic fullScore;

  Yoni({
    this.boyYoni,
    this.girlYoni,
    this.yoni,
    this.description,
    this.name,
    this.fullScore,
  });

  factory Yoni.fromJson(Map<String, dynamic> json) => Yoni(
        boyYoni: json["boy_yoni"],
        girlYoni: json["girl_yoni"],
        yoni: json["yoni"],
        description: json["description"],
        name: json["name"],
        fullScore: json["full_score"],
      );

  Map<String, dynamic> toJson() => {
        "boy_yoni": boyYoni,
        "girl_yoni": girlYoni,
        "yoni": yoni,
        "description": description,
        "name": name,
        "full_score": fullScore,
      };
}
