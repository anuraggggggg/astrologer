class AstrologerProfile {
  final String id;
  final String? availabilitiesId;
  final String name;
  final String contactNo;
  final bool isContactVerified;
  final String? otpCode;
  final String? otpExpiry;
  final DateTime birthDate;
  final String primarySkill;
  final String languageKnown;
  final String? profileImage;
  final int charge;
  final int experienceInYears;
  final String currentCity;
  final String highestQualification;
  final String learnAstrology;
  final String astrologerCategoryId;
  final String instaProfileLink;
  final String facebookProfileLink;
  final String linkedInProfileLink;
  final String youtubeChannelLink;
  final String websiteProfileLink;
  final int minimumEarning;
  final int maximumEarning;
  final String loginBio;
  final String currentlyworkingfulltimejob;
  final String goodQuality;
  final String whatwillDo;
  final bool isVerified;
  final int totalOrder;
  final String country;
  final bool isActive;
  final bool isDelete;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int createdBy;
  final int modifiedBy;
  final String nameofplateform;
  final String monthlyEarning;
  final String referedPerson;
  final String chatStatus;
  final String chatWaitTime;
  final String callStatus;
  final String callWaitTime;
  final int videoCallRate;
  final int reportRate;
  final String? deletedAt;

  AstrologerProfile({
    required this.id,
    this.availabilitiesId,
    required this.name,
    required this.contactNo,
    required this.isContactVerified,
    this.otpCode,
    this.otpExpiry,
    required this.birthDate,
    required this.primarySkill,
    required this.languageKnown,
    this.profileImage,
    required this.charge,
    required this.experienceInYears,
    required this.currentCity,
    required this.highestQualification,
    required this.learnAstrology,
    required this.astrologerCategoryId,
    required this.instaProfileLink,
    required this.facebookProfileLink,
    required this.linkedInProfileLink,
    required this.youtubeChannelLink,
    required this.websiteProfileLink,
    required this.minimumEarning,
    required this.maximumEarning,
    required this.loginBio,
    required this.currentlyworkingfulltimejob,
    required this.goodQuality,
    required this.whatwillDo,
    required this.isVerified,
    required this.totalOrder,
    required this.country,
    required this.isActive,
    required this.isDelete,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.modifiedBy,
    required this.nameofplateform,
    required this.monthlyEarning,
    required this.referedPerson,
    required this.chatStatus,
    required this.chatWaitTime,
    required this.callStatus,
    required this.callWaitTime,
    required this.videoCallRate,
    required this.reportRate,
    this.deletedAt,
  });

  factory AstrologerProfile.fromJson(Map<String, dynamic> json) {
    return AstrologerProfile(
      id: json['id'],
      availabilitiesId: json['availabilitiesId'],
      name: json['name'],
      contactNo: json['contactNo'],
      isContactVerified: json['isContactVerified'],
      otpCode: json['otpCode'],
      otpExpiry: json['otpExpiry'],
      birthDate: DateTime.parse(json['birthDate']),
      primarySkill: json['primarySkill'],
      languageKnown: json['languageKnown'],
      profileImage: json['profileImage'],
      charge: json['charge'],
      experienceInYears: json['experienceInYears'],
      currentCity: json['currentCity'],
      highestQualification: json['highestQualification'],
      learnAstrology: json['learnAstrology'],
      astrologerCategoryId: json['astrologerCategoryId'],
      instaProfileLink: json['instaProfileLink'],
      facebookProfileLink: json['facebookProfileLink'],
      linkedInProfileLink: json['linkedInProfileLink'],
      youtubeChannelLink: json['youtubeChannelLink'],
      websiteProfileLink: json['websiteProfileLink'],
      minimumEarning: json['minimumEarning'],
      maximumEarning: json['maximumEarning'],
      loginBio: json['loginBio'],
      currentlyworkingfulltimejob: json['currentlyworkingfulltimejob'],
      goodQuality: json['goodQuality'],
      whatwillDo: json['whatwillDo'],
      isVerified: json['isVerified'],
      totalOrder: json['totalOrder'],
      country: json['country'],
      isActive: json['isActive'],
      isDelete: json['isDelete'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      createdBy: json['createdBy'],
      modifiedBy: json['modifiedBy'],
      nameofplateform: json['nameofplateform'],
      monthlyEarning: json['monthlyEarning'],
      referedPerson: json['referedPerson'],
      chatStatus: json['chatStatus'],
      chatWaitTime: json['chatWaitTime'],
      callStatus: json['callStatus'],
      callWaitTime: json['callWaitTime'],
      videoCallRate: json['videoCallRate'],
      reportRate: json['reportRate'],
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "availabilitiesId": availabilitiesId,
      "name": name,
      "contactNo": contactNo,
      "isContactVerified": isContactVerified,
      "otpCode": otpCode,
      "otpExpiry": otpExpiry,
      "birthDate": birthDate.toIso8601String(),
      "primarySkill": primarySkill,
      "languageKnown": languageKnown,
      "profileImage": profileImage,
      "charge": charge,
      "experienceInYears": experienceInYears,
      "currentCity": currentCity,
      "highestQualification": highestQualification,
      "learnAstrology": learnAstrology,
      "astrologerCategoryId": astrologerCategoryId,
      "instaProfileLink": instaProfileLink,
      "facebookProfileLink": facebookProfileLink,
      "linkedInProfileLink": linkedInProfileLink,
      "youtubeChannelLink": youtubeChannelLink,
      "websiteProfileLink": websiteProfileLink,
      "minimumEarning": minimumEarning,
      "maximumEarning": maximumEarning,
      "loginBio": loginBio,
      "currentlyworkingfulltimejob": currentlyworkingfulltimejob,
      "goodQuality": goodQuality,
      "whatwillDo": whatwillDo,
      "isVerified": isVerified,
      "totalOrder": totalOrder,
      "country": country,
      "isActive": isActive,
      "isDelete": isDelete,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "createdBy": createdBy,
      "modifiedBy": modifiedBy,
      "nameofplateform": nameofplateform,
      "monthlyEarning": monthlyEarning,
      "referedPerson": referedPerson,
      "chatStatus": chatStatus,
      "chatWaitTime": chatWaitTime,
      "callStatus": callStatus,
      "callWaitTime": callWaitTime,
      "videoCallRate": videoCallRate,
      "reportRate": reportRate,
      "deleted_at": deletedAt,
    };
  }
}
