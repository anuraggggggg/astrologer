import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class HostWidget extends StatelessWidget {
  final int uid;
  final RtcEngine agoraEngine;

  const HostWidget({super.key, required this.uid, required this.agoraEngine});

  @override
  Widget build(BuildContext context) {
    // Local user joined as a host
    return SizedBox(
      child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(
            uid: uid,
            //Put it same for both like 0 for both but dont use  0 then in hostscreen
          ),
        ),
      ),
    );
  }
}
