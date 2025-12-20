class CountryPhoneRule {
  final int minLength;
  final int maxLength;
  final RegExp startPattern;

  const CountryPhoneRule({
    required this.minLength,
    required this.maxLength,
    required this.startPattern,
  });
}

final Map<String, CountryPhoneRule> phoneRules = {
  "91": CountryPhoneRule(
    minLength: 10,
    maxLength: 10,
    startPattern: RegExp(r'^[6-9]'),
  ),
  "1": CountryPhoneRule(
    minLength: 10,
    maxLength: 10,
    startPattern: RegExp(r'^[2-9]'),
  ),
  "44": CountryPhoneRule(
    minLength: 10,
    maxLength: 10,
    startPattern: RegExp(r'^7'),
  ),
  "61": CountryPhoneRule(
    minLength: 9,
    maxLength: 9,
    startPattern: RegExp(r'^4'),
  ),
  "971": CountryPhoneRule(
    minLength: 9,
    maxLength: 9,
    startPattern: RegExp(r'^5'),
  ),
};
