// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:developer';
import 'dart:io';

import 'package:astrowaypartner/models/viewStoryModel.dart';
import 'package:astrowaypartner/services/apiHelper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';

import '../views/HomeScreen/Profile/mediapickerDialog.dart';
import '../views/HomeScreen/Profile/picker.dart';
import '../views/HomeScreen/Profile/trimmerview.dart';

class StoriesController extends GetxController {
  String screen = 'StoriesController.dart';
  APIHelper apiHelper = APIHelper();
  final picker = ImagePicker();
  List<XFile> pickedMedia = [];
  var imageList = <String>[];
  var viewSingleStory = <ViewStories>[];

  var pickerController = MultiImagePickerController(
    maxImages: 3,
    images: <ImageFile>[],
    picker: (bool allowMultiple) async {
      return await pickImagesUsingImagePicker(allowMultiple);
    },
  );

  Future<void> pickMedia(BuildContext context, MediaTypes mediaType) async {
    if (mediaType == MediaTypes.image) {
      log('inside pick image clicked');
      pickerController.clearImages(); //clear previous images
      await pickerController.pickImages(); //pick images
      global.showOnlyLoaderDialog();
      Future.delayed(const Duration(seconds: 3), () {
        global.hideLoader();
        pickerController.images.every((element) {
          imageList.add(element.path!);
          update();

          return true;
        });
        update();
      });
    } else if (mediaType == MediaTypes.video) {
      XFile? pickedVideo = await picker.pickVideo(source: ImageSource.gallery);

      if (pickedVideo != null) {
        String videoPath = pickedVideo.path;
        pickedMedia.add(pickedVideo);
        log('Picked videoPath Paths: $videoPath');
        File file = File(videoPath);

        await Get.to(() => TrimmerView(file: file))!.then((value) {
          Get.back();
        });
      }
    }
    log('Picked Media: $pickedMedia');

    // Get.back();
  }

  //
  Future uploadText(String texts) async {
    print('astrologer id ${global.currentUserId}');

    try {
      await global.checkBody().then(
        (result) async {
          if (result) {
            global.showOnlyLoaderDialog();
            await apiHelper
                .uploadTextToServer(
              id: global.currentUserId.toString(), // astrologer id
              txts: texts,
            )
                .then(
              (textresponse) {
                print("textReponse");
                print("${textresponse.status}");
                print("$textresponse");
                global.hideLoader();
                if (textresponse.status == 200) {
                  global.showToast(message: textresponse.message.toString());
                  Get.back();
                } else {
                  global.showToast(message: 'something went wrong');
                }
              },
            );
          }
        },
      );
      update();
    } catch (e) {
      print('Exception: $screen - uploadVideo:-' + e.toString());
    }
  }

  Future uploadImage(List<String> imagepathList) async {
    print('astrologer id ${global.currentUserId}');

    try {
      await global.checkBody().then(
        (result) async {
          if (result) {
            global.showOnlyLoaderDialog();
            await apiHelper
                .uploadImageFileToServer(
              id: global.currentUserId.toString(), // astrologer id
              imagePath: imagepathList,
            )
                .then(
              (imageResponse) {
                global.hideLoader();
                if (imageResponse.status == 200) {
                  global.showToast(message: imageResponse.message.toString());
                  Get.back();
                } else {
                  global.showToast(message: 'something went wrong');
                }
              },
            );
          }
        },
      );
      update();
    } catch (e) {
      print('Exception: $screen - uploadVideo:-' + e.toString());
    }
  }

  Future uploadVideo(File file) async {
    log('getting video path is ${file.path}');
    log('astrologer video id ${global.currentUserId}');

    try {
      await global.checkBody().then(
        (result) async {
          if (result) {
            global.showOnlyLoaderDialog();
            await apiHelper
                .uploadFileToServer(
              id: global.currentUserId.toString(), // astrologer id
              videoFile: file,
            )
                .then(
              (videomodel) {
                global.hideLoader();
                if (videomodel.status == 200) {
                  global.showToast(message: videomodel.message.toString());
                  Get.back();
                } else {
                  global.showToast(message: 'something went wrong');
                }
              },
            );
          }
        },
      );
      update();
    } catch (e) {
      print('Exception: $screen - uploadVideo:-' + e.toString());
    }
  }

  Future<List> getAstroStory(String astroId) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getAstroStory(astroId).then((result) {
            if (result.status == "200") {
              viewSingleStory = result.recordList;
              update();
            } else {
              // global.showToast(
              //   message: 'Failed to get client testimonals',
              //   textColor: global.textColor,
              //   bgColor: global.toastBackGoundColor,
              // );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in  getClientsTestimonals:-" + e.toString());
    }
    return viewSingleStory;
  }
}
