// ignore_for_file: file_names

import 'dart:developer';

import 'package:astrowaypartner/utils/config.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

class CallUtils {
  static Future<void> showIncomingCall(var body) async {
    log('started showing incoming call');
    Uuid uuid = const Uuid();
    String currentUuid = uuid.v4();

    String defaultImage = 'https://i.pravatar.cc/500';
    String? profilePic = body['profile'];

    String imageUrl;
    if (profilePic != null) {
      imageUrl = imgBaseurl + profilePic;
    } else {
      imageUrl = defaultImage;
    }
    bool calltype = body['call_type'] == 10; //video call or audio call

    log('calltype is  $calltype');
    log('imageUrl is  $imageUrl');
    log('imageUrl is  ${body['name']}');

    CallKitParams callKitParams = CallKitParams(
      id: currentUuid,
      nameCaller: body['name'],
      appName: 'Astroway',
      handle: 'Astroway Partner',
      // avatar: imageUrl,
      type: calltype ? 0 : 1, // 0 for audio call, 1 for video call
      textAccept: 'Accept',
      textDecline: 'Decline',
      duration: 30000,
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      extra: <String, dynamic>{
        'call_type': body['call_type'],
        'notificationType': body['notificationType'],
        'callId': body['callId'],
        'profile': body['profile'],
        'name': body['name'],
        'id': body['id'],
        'fcmToken': body['fcmToken'],
        'call_duration': body['call_duration'].toString(),
      },

      headers: <String, dynamic>{'apiKey': 'sunil@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        // backgroundUrl: defaultImage,
        actionColor: '#4CAF50',
        textColor: '#ffffff',
        incomingCallNotificationChannelName: "Incoming Call 1",
        isShowCallID: true, //for showing handle in incoming call notification
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }
}
