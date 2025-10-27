import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> getFcmToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission for iOS
  await messaging.requestPermission();

  String? token = await messaging.getToken();
  print("📱 FCM Token: $token");
  return token;
}
