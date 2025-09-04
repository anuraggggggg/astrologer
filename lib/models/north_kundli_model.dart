// To parse this JSON data, do
//
//     final northKundaliMatchingModel = northKundaliMatchingModelFromJson(jsonString);

import 'dart:convert';

NorthKundaliMatchingModel northKundaliMatchingModelFromJson(String str) =>
    NorthKundaliMatchingModel.fromJson(json.decode(str));

String northKundaliMatchingModelToJson(NorthKundaliMatchingModel data) =>
    json.encode(data.toJson());

class NorthKundaliMatchingModel {
  String? message;
  RecordList? recordList;
  LikRpt? girlMangalikRpt;
  LikRpt? boyManaglikRpt;
  int? status;

  NorthKundaliMatchingModel({
    this.message,
    this.recordList,
    this.girlMangalikRpt,
    this.boyManaglikRpt,
    this.status,
  });

  factory NorthKundaliMatchingModel.fromJson(Map<String, dynamic> json) =>
      NorthKundaliMatchingModel(
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
  dynamic score;

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
  Tara? tara;
  Gana? gana;
  Yoni? yoni;
  Bhakoot? bhakoot;
  Grahamaitri? grahamaitri;
  Vasya? vasya;
  Nadi? nadi;
  Varna? varna;
  dynamic score;
  String? botResponse;

  RecordListResponse({
    this.tara,
    this.gana,
    this.yoni,
    this.bhakoot,
    this.grahamaitri,
    this.vasya,
    this.nadi,
    this.varna,
    this.score,
    this.botResponse,
  });

  factory RecordListResponse.fromJson(Map<String, dynamic> json) =>
      RecordListResponse(
        tara: json["tara"] == null ? null : Tara.fromJson(json["tara"]),
        gana: json["gana"] == null ? null : Gana.fromJson(json["gana"]),
        yoni: json["yoni"] == null ? null : Yoni.fromJson(json["yoni"]),
        bhakoot:
            json["bhakoot"] == null ? null : Bhakoot.fromJson(json["bhakoot"]),
        grahamaitri: json["grahamaitri"] == null
            ? null
            : Grahamaitri.fromJson(json["grahamaitri"]),
        vasya: json["vasya"] == null ? null : Vasya.fromJson(json["vasya"]),
        nadi: json["nadi"] == null ? null : Nadi.fromJson(json["nadi"]),
        varna: json["varna"] == null ? null : Varna.fromJson(json["varna"]),
        score: json["score"]?.toDouble(),
        botResponse: json["bot_response"],
      );

  Map<String, dynamic> toJson() => {
        "tara": tara?.toJson(),
        "gana": gana?.toJson(),
        "yoni": yoni?.toJson(),
        "bhakoot": bhakoot?.toJson(),
        "grahamaitri": grahamaitri?.toJson(),
        "vasya": vasya?.toJson(),
        "nadi": nadi?.toJson(),
        "varna": varna?.toJson(),
        "score": score,
        "bot_response": botResponse,
      };
}

class Bhakoot {
  int? boyRasi;
  int? girlRasi;
  String? boyRasiName;
  String? girlRasiName;
  int? bhakoot;
  String? description;
  String? name;
  dynamic fullScore;

  Bhakoot({
    this.boyRasi,
    this.girlRasi,
    this.boyRasiName,
    this.girlRasiName,
    this.bhakoot,
    this.description,
    this.name,
    this.fullScore,
  });

  factory Bhakoot.fromJson(Map<String, dynamic> json) => Bhakoot(
        boyRasi: json["boy_rasi"],
        girlRasi: json["girl_rasi"],
        boyRasiName: json["boy_rasi_name"],
        girlRasiName: json["girl_rasi_name"],
        bhakoot: json["bhakoot"],
        description: json["description"],
        name: json["name"],
        fullScore: json["full_score"],
      );

  Map<String, dynamic> toJson() => {
        "boy_rasi": boyRasi,
        "girl_rasi": girlRasi,
        "boy_rasi_name": boyRasiName,
        "girl_rasi_name": girlRasiName,
        "bhakoot": bhakoot,
        "description": description,
        "name": name,
        "full_score": fullScore,
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

class Grahamaitri {
  String? boyLord;
  String? girlLord;
  dynamic grahamaitri;
  String? description;
  String? name;
  dynamic fullScore;

  Grahamaitri({
    this.boyLord,
    this.girlLord,
    this.grahamaitri,
    this.description,
    this.name,
    this.fullScore,
  });

  factory Grahamaitri.fromJson(Map<String, dynamic> json) => Grahamaitri(
        boyLord: json["boy_lord"],
        girlLord: json["girl_lord"],
        grahamaitri: json["grahamaitri"],
        description: json["description"],
        name: json["name"],
        fullScore: json["full_score"],
      );

  Map<String, dynamic> toJson() => {
        "boy_lord": boyLord,
        "girl_lord": girlLord,
        "grahamaitri": grahamaitri,
        "description": description,
        "name": name,
        "full_score": fullScore,
      };
}

class Nadi {
  String? boyNadi;
  String? girlNadi;
  dynamic nadi;
  String? description;
  String? name;
  dynamic fullScore;

  Nadi({
    this.boyNadi,
    this.girlNadi,
    this.nadi,
    this.description,
    this.name,
    this.fullScore,
  });

  factory Nadi.fromJson(Map<String, dynamic> json) => Nadi(
        boyNadi: json["boy_nadi"],
        girlNadi: json["girl_nadi"],
        nadi: json["nadi"],
        description: json["description"],
        name: json["name"],
        fullScore: json["full_score"],
      );

  Map<String, dynamic> toJson() => {
        "boy_nadi": boyNadi,
        "girl_nadi": girlNadi,
        "nadi": nadi,
        "description": description,
        "name": name,
        "full_score": fullScore,
      };
}

class Tara {
  String? boyTara;
  String? girlTara;
  dynamic tara;
  String? description;
  String? name;
  dynamic fullScore;

  Tara({
    this.boyTara,
    this.girlTara,
    this.tara,
    this.description,
    this.name,
    this.fullScore,
  });

  factory Tara.fromJson(Map<String, dynamic> json) => Tara(
        boyTara: json["boy_tara"],
        girlTara: json["girl_tara"],
        tara: json["tara"]?.toDouble(),
        description: json["description"],
        name: json["name"],
        fullScore: json["full_score"],
      );

  Map<String, dynamic> toJson() => {
        "boy_tara": boyTara,
        "girl_tara": girlTara,
        "tara": tara,
        "description": description,
        "name": name,
        "full_score": fullScore,
      };
}

class Varna {
  String? boyVarna;
  String? girlVarna;
  int? varna;
  String? description;
  String? name;
  int? fullScore;

  Varna({
    this.boyVarna,
    this.girlVarna,
    this.varna,
    this.description,
    this.name,
    this.fullScore,
  });

  factory Varna.fromJson(Map<String, dynamic> json) => Varna(
        boyVarna: json["boy_varna"],
        girlVarna: json["girl_varna"],
        varna: json["varna"],
        description: json["description"],
        name: json["name"],
        fullScore: json["full_score"],
      );

  Map<String, dynamic> toJson() => {
        "boy_varna": boyVarna,
        "girl_varna": girlVarna,
        "varna": varna,
        "description": description,
        "name": name,
        "full_score": fullScore,
      };
}

class Vasya {
  String? boyVasya;
  String? girlVasya;
  int? vasya;
  String? description;
  String? name;
  int? fullScore;

  Vasya({
    this.boyVasya,
    this.girlVasya,
    this.vasya,
    this.description,
    this.name,
    this.fullScore,
  });

  factory Vasya.fromJson(Map<String, dynamic> json) => Vasya(
        boyVasya: json["boy_vasya"],
        girlVasya: json["girl_vasya"],
        vasya: json["vasya"],
        description: json["description"],
        name: json["name"],
        fullScore: json["full_score"],
      );

  Map<String, dynamic> toJson() => {
        "boy_vasya": boyVasya,
        "girl_vasya": girlVasya,
        "vasya": vasya,
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
