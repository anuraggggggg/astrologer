// class Otplesswhatsapp {
//   Future<void> startHeadlessWithWhatsapp() async {
//     if (Platform.isIOS && !isInitIos) {
//       otplessFlutterPlugin.initHeadless(appId);
//       otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
//       isInitIos = true;
//       debugPrint("init headless sdk is called for ios");
//       return;
//     }
//     Map<String, dynamic> arg = {'channelType': "WHATSAPP"};
//     otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);
//   }
// }

