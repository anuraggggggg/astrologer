// ignore_for_file: prefer_final_fields, unused_field

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_compress/video_compress.dart';
import 'package:sizer/sizer.dart';
import '../../../controllers/storiescontroller.dart';

class TrimmerView extends StatefulWidget {
  final File file;
  const TrimmerView({Key? key, required this.file}) : super(key: key);

  @override
  State<TrimmerView> createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final StoriesController storyController = Get.find<StoriesController>();

  double _start = 0, _end = 0;
  bool _isProcessing = false;
  bool _isPlaying = false;

  double _videoDuration = 0.0;

  @override
  void initState() {
    super.initState();
    _loadVideoInfo();
  }

  void _loadVideoInfo() async {
    final info = await VideoCompress.getMediaInfo(widget.file.path);
    setState(() {
      _videoDuration = (info.duration ?? 0) / 1000;
      _end = _videoDuration;
    });
  }

  @override
  void dispose() {
    VideoCompress.cancelCompression();
    VideoCompress.dispose();
    super.dispose();
  }

  Future<void> _processAndShare() async {
    setState(() => _isProcessing = true);

    final info = await VideoCompress.compressVideo(
      widget.file.path,
      startTime: _start.toInt(),
      duration: (_end - _start).toInt(),  // ✅ Correct usage
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );

    setState(() => _isProcessing = false);

    if (!mounted || info == null || info.path == null) return;

    debugPrint('Processed output at: ${info.path}');
    storyController.uploadVideo(File(info.path!));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Get.theme.primaryColor,
        foregroundColor: Colors.black,
        title: Text(
          "Video Trim & Compress",
          style: Get.theme.textTheme.bodyMedium!.copyWith(
            color: Colors.black,
            fontSize: 15.sp,
          ),
        ),
      ),
      body: _videoDuration == 0.0
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (_isProcessing) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processAndShare,
              child: Text(
                "Share",
                style: Get.theme.textTheme.bodyMedium!.copyWith(
                  color: Colors.black,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
          Spacer(),
          Text(
            "Trim Range:",
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
          Slider(
            min: 0,
            max: _videoDuration,
            value: _start,
            onChanged: (v) => setState(() => _start = v),
            activeColor: Colors.yellow,
            inactiveColor: Colors.white30,
          ),
          Slider(
            min: 0,
            max: _videoDuration,
            value: _end,
            onChanged: (v) => setState(() => _end = v),
            activeColor: Colors.yellow,
            inactiveColor: Colors.white30,
          ),
          Text(
            "Start: ${Duration(seconds: _start.toInt())} • End: ${Duration(seconds: _end.toInt())}",
            style: TextStyle(color: Colors.white, fontSize: 10.sp),
          ),
          Spacer(),
          IconButton(
            iconSize: 60,
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              // Implement preview using video_player if desired.
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
