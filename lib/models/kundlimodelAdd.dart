// ignore_for_file: non_constant_identifier_names, file_names

class KundliModelAdd {
  KundliModelAdd({
    this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    this.latitude,
    this.longitude,
    this.timezone,
    required this.pdf_type,
    required this.match_type,
    this.forMatch,
    this.language,
  });

  int? id;
  String name;
  String gender;
  DateTime birthDate;
  String birthTime;
  String birthPlace;
  double? latitude;
  double? longitude;
  double? timezone;
  String pdf_type;
  String? match_type;
  int? forMatch;
  String? language;

  factory KundliModelAdd.fromJson(Map<String, dynamic> json) => KundliModelAdd(
        id: json["id"],
        language: json["lang"],
        match_type: json["match_type"],
        pdf_type: json["pdf_type"],
        name: json["name"] ?? "",
        forMatch: json["forMatch"] ?? "",
        gender: json["gender"] ?? "",
        birthDate: json["birthDate"] != null
            ? DateTime.parse(json["birthDate"])
            : DateTime.now(),
        birthTime: json["birthTime"] ?? "",
        birthPlace: json["birthPlace"] ?? "",
        latitude: (json["latitude"] != null && json["latitude"] != '')
            ? double.parse(json["latitude"].toString())
            : 0,
        longitude: (json["longitude"] != null && json["longitude"] != '')
            ? double.parse(json["longitude"].toString())
            : 0,
        timezone: (json["timezone"] != null && json["timezone"] != '')
            ? double.parse(json["timezone"].toString())
            : 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "lang": language,
        "name": name,
        "gender": gender,
        "birthDate": birthDate.toIso8601String(),
        "birthTime": birthTime,
        "birthPlace": birthPlace,
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone,
        "pdf_type": pdf_type,
        "match_type": match_type,
        "forMatch": forMatch,
      };

  @override
  String toString() {
    return 'KundliModelAdd{id: $id, name: $name, gender: $gender, birthDate: $birthDate, birthTime: $birthTime, birthPlace: $birthPlace, latitude: $latitude, longitude: $longitude, timezone: $timezone, pdf_type: $pdf_type, match_type: $match_type, forMatch: $forMatch}';
  }
}
