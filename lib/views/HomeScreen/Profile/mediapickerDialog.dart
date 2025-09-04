// ignore_for_file: file_names

import 'dart:developer';
import 'dart:io';

import 'package:astrowaypartner/controllers/storiescontroller.dart';
import 'package:astrowaypartner/views/HomeScreen/Profile/trimmerview.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MediaPickerDialog extends StatefulWidget {
  const MediaPickerDialog({super.key});

  @override
  State<MediaPickerDialog> createState() => _MediaPickerDialogState();
}

class _MediaPickerDialogState extends State<MediaPickerDialog> {
  StoriesController storycontroller = Get.find<StoriesController>();

  List<File> selectedImages = [];
  Future<void> _pickMedia(BuildContext context, MediaTypes mediaType) async {
    final picker = ImagePicker();
    List<XFile> pickedMedia = [];
    if (mediaType == MediaTypes.image) {
      storycontroller.pickerController.pickImages();
    } else if (mediaType == MediaTypes.video) {
      XFile? pickedVideo = await picker.pickVideo(source: ImageSource.gallery);
      if (pickedVideo != null) {
        String videoPath = pickedVideo.path;
        pickedMedia.add(pickedVideo);
        log('Picked videoPath Paths: $videoPath');
        File file = File(videoPath);

        await Get.to(() => TrimmerView(file: file));
      }
    }
    log('Picked Media: $pickedMedia');

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Select Media'),
      actions: [
        CupertinoDialogAction(
          child: const Text('Pick Images'),
          onPressed: () {
            _pickMedia(context, MediaTypes.image);
          },
        ),
        CupertinoDialogAction(
          child: const Text('Pick Video'),
          onPressed: () {
            _pickMedia(context, MediaTypes.video);
          },
        ),
        CupertinoDialogAction(
          onPressed: () {
            Get.back();
          },
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

enum MediaTypes {
  image,
  video,
}
