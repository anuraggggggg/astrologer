// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/storiescontroller.dart';
import 'mediapickerDialog.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final selectedImages = <ImageFile>[];
  final storycontroller = Get.find<StoriesController>();
  int clickItem = 0;

  @override
  void initState() {
    log('inint state called ');
    super.initState();
  }

  @override
  void dispose() {
    storycontroller.pickerController.clearImages();
    storycontroller.imageList.clear();
    storycontroller.update();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        storycontroller.pickerController.clearImages();
        storycontroller.imageList.clear();
        storycontroller.update();

        debugPrint('clear done backpress');
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.green.shade100,
          body: Stack(
            children: [
              GetBuilder<StoriesController>(builder: (storycontroller) {
                if (clickItem <= 0) {
                  clickItem = 0;
                }
                log('length item ${storycontroller.imageList}');
                return storycontroller.imageList.isNotEmpty
                    ? Container(
                        height: 50.h,
                        width: 100.w,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(
                                File(storycontroller.imageList[clickItem])),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 50.h,
                        child: const Center(
                          child: Text('Choose iamages to upload'),
                        ),
                      );
              }),
              Positioned(
                top: 2.w,
                right: 5.w,
                child: InkWell(
                  onTap: () {
                    log('share iamge clicked');
                    log('image list is ${storycontroller.imageList}');

                    storycontroller.uploadImage(storycontroller.imageList);
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.arrow_forward_ios_sharp,
                      size: 18.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: GetBuilder(
              init: storycontroller,
              builder: (storycontroller) {
                return storycontroller.imageList.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        height: 18.h,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                                storycontroller.imageList.length, (index) {
                              return Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      log('clicked on $index');
                                      setState(() {
                                        clickItem = index;
                                      });
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 1.w),
                                      height: 18.h,
                                      width: 18.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                          image: FileImage(File(storycontroller
                                              .imageList[index])),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (index <= clickItem) {
                                            clickItem--;
                                          }
                                          storycontroller.imageList
                                              .removeAt(index);
                                        });
                                      },
                                      child: const CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 12,
                                        child: Icon(Icons.close,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 10.h,
                        width: 100.w,
                        child: SizedBox(
                          height: 10.h,
                          width: 100.w,
                          child: Center(
                            child: InkWell(
                              onTap: () async {
                                storycontroller.pickerController.clearImages();
                                storycontroller.imageList.clear();
                                storycontroller.update();
                                await storycontroller.pickMedia(
                                    context, MediaTypes.image);
                              },
                              child: CircleAvatar(
                                radius: 4.h,
                                backgroundColor: Colors.yellow,
                                child: Icon(
                                  Icons.add,
                                  size: 25.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
              }),
        ),
      ),
    );
  }
}
