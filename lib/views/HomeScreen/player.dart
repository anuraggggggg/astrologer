import 'dart:developer';

import 'package:astrowaypartner/controllers/HomeController/call_detail_controller.dart';
import 'package:astrowaypartner/models/History/call_history_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class Player extends StatefulWidget {
  String sid;
  CallHistoryModel? callHistorydata;
  Player({super.key, required this.sid, required this.callHistorydata});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  // final historyController = Get.find<HistoryController>();
  final historyController = Get.put(CallDetailController());

  @override
  void initState() {
    super.initState();
    log('url playing is ${'https://s3-ap-south-1.amazonaws.com/astroway/${widget.sid}_${widget.callHistorydata!.channelName}.m3u8'}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player'),
      ),
      backgroundColor: Colors.grey.shade300,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
                alignment: Alignment.center,
                child: YoYoPlayer(
                  onPlayingVideo: (videoType) {
                    //  print(videoType);
                  },
                  autoPlayVideoAfterInit: true,
                  aspectRatio: 16 / 9,
                  url:
                      "https://s3-ap-south-1.amazonaws.com/astroway/${widget.sid}_${widget.callHistorydata!.channelName}.m3u8",
                  videoStyle: const VideoStyle(
                      fullScreenIconSize: 1,
                      fullScreenIconColor: Colors.black,
                      enableSystemOrientationsOverride: false,
                      videoQualityBgColor: Colors.black,
                      qualityStyle: TextStyle(
                        fontSize: 1.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      forwardAndBackwardBtSize: 30.0,
                      playButtonIconSize: 40.0,
                      playIcon: Icon(
                        Icons.play_arrow,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      pauseIcon: Icon(
                        Icons.pause,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      videoQualityPadding: EdgeInsets.all(5.0),
                      allowScrubbing: true),
                  videoLoadingStyle: const VideoLoadingStyle(
                    indicatorInitialValue: 0.0,
                    loading: Center(
                      child: Text(
                        "Loading video",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  allowCacheFile: true,
                  onCacheFileCompleted: (files) {
                    debugPrint('Cached file length ::: ${files?.length}');

                    if (files != null && files.isNotEmpty) {
                      for (var file in files) {
                        debugPrint('File path ::: ${file.path}');
                      }
                    }
                  },
                  onCacheFileFailed: (error) {
                    debugPrint('Cache file error ::: $error');
                  },
                ),
              ),
              Positioned(
                  child: Icon(
                Icons.music_video,
                color: Colors.white,
                size: 30.sp,
              ))
            ],
          ),
        ],
      ),
    );
  }
}
