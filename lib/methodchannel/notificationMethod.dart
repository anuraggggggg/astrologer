// ignore_for_file: file_names

import 'dart:developer';

import 'package:flutter/services.dart';

class NotificationMethodChannel {
  void createNewChannel() async {
    const notichannel = MethodChannel('com.astroway.partner/channel_test');

    Map<String, String> channelMap = {
      "id": "channel_id_17",
      "name": "Chats",
      "description": "Chat notifications",
    };
    log('create channel start');
    try {
      final bool finished =
          await notichannel.invokeMethod('mynotichannel', channelMap);
      log('create channel start $finished');

      if (finished) {
        log('create channel finished successfully!');
      }
      log('create channel start finsihed $channelMap and status is $finished ');
    } on PlatformException catch (e) {
      log('create channel exception is $e');
    }
  }
}
