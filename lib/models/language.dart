class Language {
  int? id;
  String title;
  String subTitle;
  bool isSelected;
  String lanCode;
  Language({
    required this.title,
    this.id,
    required this.subTitle,
    this.isSelected = false,
    this.lanCode = 'en',
  });
  factory Language.fromJson(Map<String, dynamic> json) => Language(
        id: json["id"],
        title: json["languageName"],
        lanCode: json["languageCode"],
        subTitle: json['language_sign'] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "languageName": title,
        "languageCode": lanCode,
        "language_sign": subTitle,
      };
}

List<Language> staticLanguageList = [
  Language(title: 'English', lanCode: 'en', subTitle: 'English'),
  Language(title: 'Gujarati', lanCode: 'gu', subTitle: 'ગુજરાતી'),
  Language(title: 'Hindi', lanCode: 'hi', subTitle: 'हिन्दी'),
  Language(title: 'Spanish', lanCode: 'es', subTitle: 'Española'),
  Language(title: 'Marathi', lanCode: 'mr', subTitle: 'मराठी'),
  Language(title: 'Sanskrit', lanCode: 'sa', subTitle: 'संस्कृत'),
  Language(title: 'Bengali', lanCode: 'bn', subTitle: 'বাংলা'),
  Language(title: 'Kannada', lanCode: 'kn', subTitle: 'ಕನ್ನಡ'),
  Language(title: 'Malayalam', lanCode: 'ml', subTitle: 'മലയാളം'),
  Language(title: 'Tamil', lanCode: 'ta', subTitle: 'தமிழ்'),
  Language(title: 'Telugu', lanCode: 'te', subTitle: 'తెలుగు'),
];
