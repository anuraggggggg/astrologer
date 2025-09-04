// To parse this JSON data, do
//
//     final whatsapplogindetailsModel = whatsapplogindetailsModelFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

WhatsapplogindetailsModel whatsapplogindetailsModelFromJson(String str) =>
    WhatsapplogindetailsModel.fromJson(json.decode(str));

String whatsapplogindetailsModelToJson(WhatsapplogindetailsModel data) =>
    json.encode(data.toJson());

class WhatsapplogindetailsModel {
  String? responseType;
  int? statusCode;
  Response? response;

  WhatsapplogindetailsModel({
    this.responseType,
    this.statusCode,
    this.response,
  });

  factory WhatsapplogindetailsModel.fromJson(Map<String, dynamic> json) =>
      WhatsapplogindetailsModel(
        responseType: json["responseType"],
        statusCode: json["statusCode"],
        response: json["response"] == null
            ? null
            : Response.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
        "responseType": responseType,
        "statusCode": statusCode,
        "response": response?.toJson(),
      };
}

class Response {
  String? token;
  String? status;
  String? userId;
  DateTime? timestamp;
  List<Identity>? identities;
  String? idToken;
  Network? network;
  DeviceInfo? deviceInfo;
  SessionInfo? sessionInfo;

  Response({
    this.token,
    this.status,
    this.userId,
    this.timestamp,
    this.identities,
    this.idToken,
    this.network,
    this.deviceInfo,
    this.sessionInfo,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        token: json["token"],
        status: json["status"],
        userId: json["userId"],
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
        identities: json["identities"] == null
            ? []
            : List<Identity>.from(
                json["identities"]!.map((x) => Identity.fromJson(x))),
        idToken: json["idToken"],
        network:
            json["network"] == null ? null : Network.fromJson(json["network"]),
        deviceInfo: json["deviceInfo"] == null
            ? null
            : DeviceInfo.fromJson(json["deviceInfo"]),
        sessionInfo: json["sessionInfo"] == null
            ? null
            : SessionInfo.fromJson(json["sessionInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "status": status,
        "userId": userId,
        "timestamp": timestamp?.toIso8601String(),
        "identities": identities == null
            ? []
            : List<dynamic>.from(identities!.map((x) => x.toJson())),
        "idToken": idToken,
        "network": network?.toJson(),
        "deviceInfo": deviceInfo?.toJson(),
        "sessionInfo": sessionInfo?.toJson(),
      };
}

class DeviceInfo {
  String? userAgent;
  String? platform;
  String? vendor;
  String? browser;
  String? connection;
  String? language;
  bool? cookieEnabled;
  int? screenWidth;
  int? screenHeight;
  int? screenColorDepth;
  double? devicePixelRatio;
  int? timezoneOffset;
  String? cpuArchitecture;
  String? fontFamily;

  DeviceInfo({
    this.userAgent,
    this.platform,
    this.vendor,
    this.browser,
    this.connection,
    this.language,
    this.cookieEnabled,
    this.screenWidth,
    this.screenHeight,
    this.screenColorDepth,
    this.devicePixelRatio,
    this.timezoneOffset,
    this.cpuArchitecture,
    this.fontFamily,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
        userAgent: json["userAgent"],
        platform: json["platform"],
        vendor: json["vendor"],
        browser: json["browser"],
        connection: json["connection"],
        language: json["language"],
        cookieEnabled: json["cookieEnabled"],
        screenWidth: json["screenWidth"],
        screenHeight: json["screenHeight"],
        screenColorDepth: json["screenColorDepth"],
        devicePixelRatio: json["devicePixelRatio"]?.toDouble(),
        timezoneOffset: json["timezoneOffset"],
        cpuArchitecture: json["cpuArchitecture"],
        fontFamily: json["fontFamily"],
      );

  Map<String, dynamic> toJson() => {
        "userAgent": userAgent,
        "platform": platform,
        "vendor": vendor,
        "browser": browser,
        "connection": connection,
        "language": language,
        "cookieEnabled": cookieEnabled,
        "screenWidth": screenWidth,
        "screenHeight": screenHeight,
        "screenColorDepth": screenColorDepth,
        "devicePixelRatio": devicePixelRatio,
        "timezoneOffset": timezoneOffset,
        "cpuArchitecture": cpuArchitecture,
        "fontFamily": fontFamily,
      };
}

class Identity {
  String? identityType;
  String? identityValue;
  String? channel;
  List<String>? methods;
  String? name;
  bool? verified;
  DateTime? verifiedAt;

  Identity({
    this.identityType,
    this.identityValue,
    this.channel,
    this.methods,
    this.name,
    this.verified,
    this.verifiedAt,
  });

  factory Identity.fromJson(Map<String, dynamic> json) => Identity(
        identityType: json["identityType"],
        identityValue: json["identityValue"],
        channel: json["channel"],
        methods: json["methods"] == null
            ? []
            : List<String>.from(json["methods"]!.map((x) => x)),
        name: json["name"],
        verified: json["verified"],
        verifiedAt: json["verifiedAt"] == null
            ? null
            : DateTime.parse(json["verifiedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "identityType": identityType,
        "identityValue": identityValue,
        "channel": channel,
        "methods":
            methods == null ? [] : List<dynamic>.from(methods!.map((x) => x)),
        "name": name,
        "verified": verified,
        "verifiedAt": verifiedAt?.toIso8601String(),
      };
}

class Network {
  String? ip;
  String? timezone;
  IpLocation? ipLocation;

  Network({
    this.ip,
    this.timezone,
    this.ipLocation,
  });

  factory Network.fromJson(Map<String, dynamic> json) => Network(
        ip: json["ip"],
        timezone: json["timezone"],
        ipLocation: json["ipLocation"] == null
            ? null
            : IpLocation.fromJson(json["ipLocation"]),
      );

  Map<String, dynamic> toJson() => {
        "ip": ip,
        "timezone": timezone,
        "ipLocation": ipLocation?.toJson(),
      };
}

class IpLocation {
  City? city;
  Country? subdivisions;
  Country? country;
  Continent? continent;
  double? latitude;
  double? longitude;
  String? postalCode;

  IpLocation({
    this.city,
    this.subdivisions,
    this.country,
    this.continent,
    this.latitude,
    this.longitude,
    this.postalCode,
  });

  factory IpLocation.fromJson(Map<String, dynamic> json) => IpLocation(
        city: json["city"] == null ? null : City.fromJson(json["city"]),
        subdivisions: json["subdivisions"] == null
            ? null
            : Country.fromJson(json["subdivisions"]),
        country:
            json["country"] == null ? null : Country.fromJson(json["country"]),
        continent: json["continent"] == null
            ? null
            : Continent.fromJson(json["continent"]),
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        postalCode: json["postalCode"],
      );

  Map<String, dynamic> toJson() => {
        "city": city?.toJson(),
        "subdivisions": subdivisions?.toJson(),
        "country": country?.toJson(),
        "continent": continent?.toJson(),
        "latitude": latitude,
        "longitude": longitude,
        "postalCode": postalCode,
      };
}

class City {
  String? name;

  City({
    this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}

class Continent {
  String? code;

  Continent({
    this.code,
  });

  factory Continent.fromJson(Map<String, dynamic> json) => Continent(
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
      };
}

class Country {
  String? code;
  String? name;

  Country({
    this.code,
    this.name,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        code: json["code"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
      };
}

class SessionInfo {
  String? sessionId;
  String? refreshToken;
  String? sessionToken;

  SessionInfo({
    this.sessionId,
    this.refreshToken,
    this.sessionToken,
  });

  factory SessionInfo.fromJson(Map<String, dynamic> json) => SessionInfo(
        sessionId: json["sessionId"],
        refreshToken: json["refreshToken"],
        sessionToken: json["sessionToken"],
      );

  Map<String, dynamic> toJson() => {
        "sessionId": sessionId,
        "refreshToken": refreshToken,
        "sessionToken": sessionToken,
      };
}
