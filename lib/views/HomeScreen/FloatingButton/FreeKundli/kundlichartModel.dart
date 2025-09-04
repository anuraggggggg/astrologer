// To parse this JSON data, do
//
//     final kundliChartModel = kundliChartModelFromJson(jsonString);

// ignore_for_file: constant_identifier_names, file_names

import 'dart:convert';

KundliChartModel kundliChartModelFromJson(String str) =>
    KundliChartModel.fromJson(json.decode(str));

String kundliChartModelToJson(KundliChartModel data) =>
    json.encode(data.toJson());

class KundliChartModel {
  String? message;
  List<RecordList>? recordList;
  KundaliChart? kundaliChart;
  PlanetDetails? planetDetails;
  Ashtakvarga? ashtakvarga;
  PersonalCharacteristics? personalCharacteristics;
  int? status;

  KundliChartModel({
    this.message,
    this.recordList,
    this.kundaliChart,
    this.planetDetails,
    this.ashtakvarga,
    this.personalCharacteristics,
    this.status,
  });

  factory KundliChartModel.fromJson(Map<String, dynamic> json) =>
      KundliChartModel(
        message: json["message"],
        recordList: json["recordList"] == null
            ? []
            : List<RecordList>.from(
                json["recordList"]!.map((x) => RecordList.fromJson(x))),
        kundaliChart: json["kundaliChart"] == null
            ? null
            : KundaliChart.fromJson(json["kundaliChart"]),
        planetDetails: json["planetDetails"] == null
            ? null
            : PlanetDetails.fromJson(json["planetDetails"]),
        ashtakvarga: json["ashtakvarga"] == null
            ? null
            : Ashtakvarga.fromJson(json["ashtakvarga"]),
        personalCharacteristics: json["personalCharacteristics"] == null
            ? null
            : PersonalCharacteristics.fromJson(json["personalCharacteristics"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "recordList": recordList == null
            ? []
            : List<dynamic>.from(recordList!.map((x) => x.toJson())),
        "kundaliChart": kundaliChart?.toJson(),
        "planetDetails": planetDetails?.toJson(),
        "ashtakvarga": ashtakvarga?.toJson(),
        "personalCharacteristics": personalCharacteristics?.toJson(),
        "status": status,
      };
}

class Ashtakvarga {
  int? status;
  AshtakvargaResponse? response;

  Ashtakvarga({
    this.status,
    this.response,
  });

  factory Ashtakvarga.fromJson(Map<String, dynamic> json) => Ashtakvarga(
        status: json["status"],
        response: json["response"] == null
            ? null
            : AshtakvargaResponse.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "response": response?.toJson(),
      };
}

class AshtakvargaResponse {
  List<String>? ashtakvargaOrder;
  List<List<int>>? ashtakvargaPoints;
  List<int>? ashtakvargaTotal;

  AshtakvargaResponse({
    this.ashtakvargaOrder,
    this.ashtakvargaPoints,
    this.ashtakvargaTotal,
  });

  factory AshtakvargaResponse.fromJson(Map<String, dynamic> json) =>
      AshtakvargaResponse(
        ashtakvargaOrder: json["ashtakvarga_order"] == null
            ? []
            : List<String>.from(json["ashtakvarga_order"]!.map((x) => x)),
        ashtakvargaPoints: json["ashtakvarga_points"] == null
            ? []
            : List<List<int>>.from(json["ashtakvarga_points"]!
                .map((x) => List<int>.from(x.map((x) => x)))),
        ashtakvargaTotal: json["ashtakvarga_total"] == null
            ? []
            : List<int>.from(json["ashtakvarga_total"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "ashtakvarga_order": ashtakvargaOrder == null
            ? []
            : List<dynamic>.from(ashtakvargaOrder!.map((x) => x)),
        "ashtakvarga_points": ashtakvargaPoints == null
            ? []
            : List<dynamic>.from(ashtakvargaPoints!
                .map((x) => List<dynamic>.from(x.map((x) => x)))),
        "ashtakvarga_total": ashtakvargaTotal == null
            ? []
            : List<dynamic>.from(ashtakvargaTotal!.map((x) => x)),
      };
}

class KundaliChart {
  String? d1;
  String? d2;
  String? d3;
  String? d3S;
  String? d4;
  String? d5;
  String? d7;
  String? d8;
  String? d9;
  String? d10;
  String? d10R;
  String? d12;
  String? d16;
  String? d20;
  String? d24;
  String? d24R;
  String? d27;
  String? d40;
  String? d45;
  String? d60;
  String? d30;
  String? chalit;
  String? sun;
  String? moon;
  String? kpChalit;

  KundaliChart({
    this.d1,
    this.d2,
    this.d3,
    this.d3S,
    this.d4,
    this.d5,
    this.d7,
    this.d8,
    this.d9,
    this.d10,
    this.d10R,
    this.d12,
    this.d16,
    this.d20,
    this.d24,
    this.d24R,
    this.d27,
    this.d40,
    this.d45,
    this.d60,
    this.d30,
    this.chalit,
    this.sun,
    this.moon,
    this.kpChalit,
  });

  factory KundaliChart.fromJson(Map<String, dynamic> json) => KundaliChart(
        d1: json["D1"],
        d2: json["D2"],
        d3: json["D3"],
        d3S: json["D3-s"],
        d4: json["D4"],
        d5: json["D5"],
        d7: json["D7"],
        d8: json["D8"],
        d9: json["D9"],
        d10: json["D10"],
        d10R: json["D10-R"],
        d12: json["D12"],
        d16: json["D16"],
        d20: json["D20"],
        d24: json["D24"],
        d24R: json["D24-R"],
        d27: json["D27"],
        d40: json["D40"],
        d45: json["D45"],
        d60: json["D60"],
        d30: json["D30"],
        chalit: json["chalit"],
        sun: json["sun"],
        moon: json["moon"],
        kpChalit: json["kp_chalit"],
      );

  Map<String, dynamic> toJson() => {
        "D1": d1,
        "D2": d2,
        "D3": d3,
        "D3-s": d3S,
        "D4": d4,
        "D5": d5,
        "D7": d7,
        "D8": d8,
        "D9": d9,
        "D10": d10,
        "D10-R": d10R,
        "D12": d12,
        "D16": d16,
        "D20": d20,
        "D24": d24,
        "D24-R": d24R,
        "D27": d27,
        "D40": d40,
        "D45": d45,
        "D60": d60,
        "D30": d30,
        "chalit": chalit,
        "sun": sun,
        "moon": moon,
        "kp_chalit": kpChalit,
      };
}

class PersonalCharacteristics {
  int? status;
  List<ResponseElement>? response;

  PersonalCharacteristics({
    this.status,
    this.response,
  });

  factory PersonalCharacteristics.fromJson(Map<String, dynamic> json) =>
      PersonalCharacteristics(
        status: json["status"],
        response: json["response"] == null
            ? []
            : List<ResponseElement>.from(
                json["response"]!.map((x) => ResponseElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "response": response == null
            ? []
            : List<dynamic>.from(response!.map((x) => x.toJson())),
      };
}

class ResponseElement {
  int? currentHouse;
  String? verbalLocation;
  String? currentZodiac;
  String? lordOfZodiac;
  String? lordZodiacLocation;
  int? lordHouseLocation;
  String? personalisedPrediction;
  LordStrength? lordStrength;

  ResponseElement({
    this.currentHouse,
    this.verbalLocation,
    this.currentZodiac,
    this.lordOfZodiac,
    this.lordZodiacLocation,
    this.lordHouseLocation,
    this.personalisedPrediction,
    this.lordStrength,
  });

  factory ResponseElement.fromJson(Map<String, dynamic> json) =>
      ResponseElement(
        currentHouse: json["current_house"],
        verbalLocation: json["verbal_location"],
        currentZodiac: json["current_zodiac"],
        lordOfZodiac: json["lord_of_zodiac"],
        lordZodiacLocation: json["lord_zodiac_location"],
        lordHouseLocation: json["lord_house_location"],
        personalisedPrediction: json["personalised_prediction"],
        lordStrength: lordStrengthValues.map[json["lord_strength"]],
      );

  Map<String, dynamic> toJson() => {
        "current_house": currentHouse,
        "verbal_location": verbalLocation,
        "current_zodiac": currentZodiac,
        "lord_of_zodiac": lordOfZodiac,
        "lord_zodiac_location": lordZodiacLocation,
        "lord_house_location": lordHouseLocation,
        "personalised_prediction": personalisedPrediction,
        "lord_strength": lordStrengthValues.reverse[lordStrength],
      };
}

enum LordStrength { DEBILITATED, NEUTRAL }

final lordStrengthValues = EnumValues(
    {"Debilitated": LordStrength.DEBILITATED, "Neutral": LordStrength.NEUTRAL});

class PlanetDetails {
  int? status;
  PlanetDetailsResponse? response;

  PlanetDetails({
    this.status,
    this.response,
  });

  factory PlanetDetails.fromJson(Map<String, dynamic> json) => PlanetDetails(
        status: json["status"],
        response: json["response"] == null
            ? null
            : PlanetDetailsResponse.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "response": response?.toJson(),
      };
}

class PlanetDetailsResponse {
  The0? the0;
  The0? the1;
  The0? the2;
  The0? the3;
  The0? the4;
  The0? the5;
  The0? the6;
  The0? the7;
  The0? the8;
  The0? the9;
  String? birthDasa;
  String? currentDasa;
  String? birthDasaTime;
  String? currentDasaTime;
  List<String>? luckyGem;
  List<int>? luckyNum;
  List<String>? luckyColors;
  List<String>? luckyLetters;
  List<String>? luckyNameStart;
  String? rasi;
  String? nakshatra;
  int? nakshatraPada;
  Panchang? panchang;
  GhatkaChakra? ghatkaChakra;

  PlanetDetailsResponse({
    this.the0,
    this.the1,
    this.the2,
    this.the3,
    this.the4,
    this.the5,
    this.the6,
    this.the7,
    this.the8,
    this.the9,
    this.birthDasa,
    this.currentDasa,
    this.birthDasaTime,
    this.currentDasaTime,
    this.luckyGem,
    this.luckyNum,
    this.luckyColors,
    this.luckyLetters,
    this.luckyNameStart,
    this.rasi,
    this.nakshatra,
    this.nakshatraPada,
    this.panchang,
    this.ghatkaChakra,
  });

  factory PlanetDetailsResponse.fromJson(Map<String, dynamic> json) =>
      PlanetDetailsResponse(
        the0: json["0"] == null ? null : The0.fromJson(json["0"]),
        the1: json["1"] == null ? null : The0.fromJson(json["1"]),
        the2: json["2"] == null ? null : The0.fromJson(json["2"]),
        the3: json["3"] == null ? null : The0.fromJson(json["3"]),
        the4: json["4"] == null ? null : The0.fromJson(json["4"]),
        the5: json["5"] == null ? null : The0.fromJson(json["5"]),
        the6: json["6"] == null ? null : The0.fromJson(json["6"]),
        the7: json["7"] == null ? null : The0.fromJson(json["7"]),
        the8: json["8"] == null ? null : The0.fromJson(json["8"]),
        the9: json["9"] == null ? null : The0.fromJson(json["9"]),
        birthDasa: json["birth_dasa"],
        currentDasa: json["current_dasa"],
        birthDasaTime: json["birth_dasa_time"],
        currentDasaTime: json["current_dasa_time"],
        luckyGem: json["lucky_gem"] == null
            ? []
            : List<String>.from(json["lucky_gem"]!.map((x) => x)),
        luckyNum: json["lucky_num"] == null
            ? []
            : List<int>.from(json["lucky_num"]!.map((x) => x)),
        luckyColors: json["lucky_colors"] == null
            ? []
            : List<String>.from(json["lucky_colors"]!.map((x) => x)),
        luckyLetters: json["lucky_letters"] == null
            ? []
            : List<String>.from(json["lucky_letters"]!.map((x) => x)),
        luckyNameStart: json["lucky_name_start"] == null
            ? []
            : List<String>.from(json["lucky_name_start"]!.map((x) => x)),
        rasi: json["rasi"],
        nakshatra: json["nakshatra"],
        nakshatraPada: json["nakshatra_pada"],
        panchang: json["panchang"] == null
            ? null
            : Panchang.fromJson(json["panchang"]),
        ghatkaChakra: json["ghatka_chakra"] == null
            ? null
            : GhatkaChakra.fromJson(json["ghatka_chakra"]),
      );

  Map<String, dynamic> toJson() => {
        "0": the0?.toJson(),
        "1": the1?.toJson(),
        "2": the2?.toJson(),
        "3": the3?.toJson(),
        "4": the4?.toJson(),
        "5": the5?.toJson(),
        "6": the6?.toJson(),
        "7": the7?.toJson(),
        "8": the8?.toJson(),
        "9": the9?.toJson(),
        "birth_dasa": birthDasa,
        "current_dasa": currentDasa,
        "birth_dasa_time": birthDasaTime,
        "current_dasa_time": currentDasaTime,
        "lucky_gem":
            luckyGem == null ? [] : List<dynamic>.from(luckyGem!.map((x) => x)),
        "lucky_num":
            luckyNum == null ? [] : List<dynamic>.from(luckyNum!.map((x) => x)),
        "lucky_colors": luckyColors == null
            ? []
            : List<dynamic>.from(luckyColors!.map((x) => x)),
        "lucky_letters": luckyLetters == null
            ? []
            : List<dynamic>.from(luckyLetters!.map((x) => x)),
        "lucky_name_start": luckyNameStart == null
            ? []
            : List<dynamic>.from(luckyNameStart!.map((x) => x)),
        "rasi": rasi,
        "nakshatra": nakshatra,
        "nakshatra_pada": nakshatraPada,
        "panchang": panchang?.toJson(),
        "ghatka_chakra": ghatkaChakra?.toJson(),
      };
}

class GhatkaChakra {
  String? rasi;
  List<String>? tithi;
  String? day;
  String? nakshatra;
  String? tatva;
  String? lord;
  String? sameSexLagna;
  String? oppositeSexLagna;

  GhatkaChakra({
    this.rasi,
    this.tithi,
    this.day,
    this.nakshatra,
    this.tatva,
    this.lord,
    this.sameSexLagna,
    this.oppositeSexLagna,
  });

  factory GhatkaChakra.fromJson(Map<String, dynamic> json) => GhatkaChakra(
        rasi: json["rasi"],
        tithi: json["tithi"] == null
            ? []
            : List<String>.from(json["tithi"]!.map((x) => x)),
        day: json["day"],
        nakshatra: json["nakshatra"],
        tatva: json["tatva"],
        lord: json["lord"],
        sameSexLagna: json["same_sex_lagna"],
        oppositeSexLagna: json["opposite_sex_lagna"],
      );

  Map<String, dynamic> toJson() => {
        "rasi": rasi,
        "tithi": tithi == null ? [] : List<dynamic>.from(tithi!.map((x) => x)),
        "day": day,
        "nakshatra": nakshatra,
        "tatva": tatva,
        "lord": lord,
        "same_sex_lagna": sameSexLagna,
        "opposite_sex_lagna": oppositeSexLagna,
      };
}

class Panchang {
  double? ayanamsa;
  String? ayanamsaName;
  String? dayOfBirth;
  String? dayLord;
  String? horaLord;
  String? sunriseAtBirth;
  String? sunsetAtBirth;
  String? karana;
  String? yoga;
  String? tithi;

  Panchang({
    this.ayanamsa,
    this.ayanamsaName,
    this.dayOfBirth,
    this.dayLord,
    this.horaLord,
    this.sunriseAtBirth,
    this.sunsetAtBirth,
    this.karana,
    this.yoga,
    this.tithi,
  });

  factory Panchang.fromJson(Map<String, dynamic> json) => Panchang(
        ayanamsa: json["ayanamsa"]?.toDouble(),
        ayanamsaName: json["ayanamsa_name"],
        dayOfBirth: json["day_of_birth"],
        dayLord: json["day_lord"],
        horaLord: json["hora_lord"],
        sunriseAtBirth: json["sunrise_at_birth"],
        sunsetAtBirth: json["sunset_at_birth"],
        karana: json["karana"],
        yoga: json["yoga"],
        tithi: json["tithi"],
      );

  Map<String, dynamic> toJson() => {
        "ayanamsa": ayanamsa,
        "ayanamsa_name": ayanamsaName,
        "day_of_birth": dayOfBirth,
        "day_lord": dayLord,
        "hora_lord": horaLord,
        "sunrise_at_birth": sunriseAtBirth,
        "sunset_at_birth": sunsetAtBirth,
        "karana": karana,
        "yoga": yoga,
        "tithi": tithi,
      };
}

class The0 {
  String? name;
  String? fullName;
  double? localDegree;
  double? globalDegree;
  double? progressInPercentage;
  int? rasiNo;
  String? zodiac;
  int? house;
  String? nakshatra;
  String? nakshatraLord;
  int? nakshatraPada;
  int? nakshatraNo;
  String? zodiacLord;
  bool? isPlanetSet;
  String? lordStatus;
  String? basicAvastha;
  bool? isCombust;
  double? speedRadiansPerDay;
  bool? retro;

  The0({
    this.name,
    this.fullName,
    this.localDegree,
    this.globalDegree,
    this.progressInPercentage,
    this.rasiNo,
    this.zodiac,
    this.house,
    this.nakshatra,
    this.nakshatraLord,
    this.nakshatraPada,
    this.nakshatraNo,
    this.zodiacLord,
    this.isPlanetSet,
    this.lordStatus,
    this.basicAvastha,
    this.isCombust,
    this.speedRadiansPerDay,
    this.retro,
  });

  factory The0.fromJson(Map<String, dynamic> json) => The0(
        name: json["name"],
        fullName: json["full_name"],
        localDegree: json["local_degree"]?.toDouble(),
        globalDegree: json["global_degree"]?.toDouble(),
        progressInPercentage: json["progress_in_percentage"]?.toDouble(),
        rasiNo: json["rasi_no"],
        zodiac: json["zodiac"],
        house: json["house"],
        nakshatra: json["nakshatra"],
        nakshatraLord: json["nakshatra_lord"],
        nakshatraPada: json["nakshatra_pada"],
        nakshatraNo: json["nakshatra_no"],
        zodiacLord: json["zodiac_lord"],
        isPlanetSet: json["is_planet_set"],
        lordStatus: json["lord_status"],
        basicAvastha: json["basic_avastha"],
        isCombust: json["is_combust"],
        speedRadiansPerDay: json["speed_radians_per_day"]?.toDouble(),
        retro: json["retro"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "full_name": fullName,
        "local_degree": localDegree,
        "global_degree": globalDegree,
        "progress_in_percentage": progressInPercentage,
        "rasi_no": rasiNo,
        "zodiac": zodiac,
        "house": house,
        "nakshatra": nakshatra,
        "nakshatra_lord": nakshatraLord,
        "nakshatra_pada": nakshatraPada,
        "nakshatra_no": nakshatraNo,
        "zodiac_lord": zodiacLord,
        "is_planet_set": isPlanetSet,
        "lord_status": lordStatus,
        "basic_avastha": basicAvastha,
        "is_combust": isCombust,
        "speed_radians_per_day": speedRadiansPerDay,
        "retro": retro,
      };
}

class RecordList {
  int? id;
  String? name;
  String? gender;
  DateTime? birthDate;
  String? birthTime;
  String? birthPlace;
  int? isActive;
  int? isDelete;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? createdBy;
  int? modifiedBy;
  dynamic latitude;
  dynamic longitude;
  dynamic timezone;
  dynamic isForTrackPlanet;
  String? pdfType;
  String? matchType;
  int? forMatch;
  String? pdfLink;

  RecordList({
    this.id,
    this.name,
    this.gender,
    this.birthDate,
    this.birthTime,
    this.birthPlace,
    this.isActive,
    this.isDelete,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.latitude,
    this.longitude,
    this.timezone,
    this.isForTrackPlanet,
    this.pdfType,
    this.matchType,
    this.forMatch,
    this.pdfLink,
  });

  factory RecordList.fromJson(Map<String, dynamic> json) => RecordList(
        id: json["id"],
        name: json["name"],
        gender: json["gender"],
        birthDate: json["birthDate"] == null
            ? null
            : DateTime.parse(json["birthDate"]),
        birthTime: json["birthTime"],
        birthPlace: json["birthPlace"],
        isActive: json["isActive"],
        isDelete: json["isDelete"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        createdBy: json["createdBy"],
        modifiedBy: json["modifiedBy"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        timezone: json["timezone"],
        isForTrackPlanet: json["isForTrackPlanet"],
        pdfType: json["pdf_type"],
        matchType: json["match_type"],
        forMatch: json["forMatch"],
        pdfLink: json["pdf_link"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "gender": gender,
        "birthDate":
            "${birthDate!.year.toString().padLeft(4, '0')}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}",
        "birthTime": birthTime,
        "birthPlace": birthPlace,
        "isActive": isActive,
        "isDelete": isDelete,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "createdBy": createdBy,
        "modifiedBy": modifiedBy,
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone,
        "isForTrackPlanet": isForTrackPlanet,
        "pdf_type": pdfType,
        "match_type": matchType,
        "forMatch": forMatch,
        "pdf_link": pdfLink,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
