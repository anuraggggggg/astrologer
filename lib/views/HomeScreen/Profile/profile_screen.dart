// ignore_for_file: unused_local_variable, must_be_immutable, use_build_context_synchronously

import 'dart:developer';

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/controllers/callAvailability_controller.dart';
import 'package:astrowaypartner/controllers/chatAvailability_controller.dart';
import 'package:astrowaypartner/controllers/following_controller.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/Tabs/reportTabs/chatAvailabilityScreen.dart';
import 'package:astrowaypartner/views/HomeScreen/Profile/ProfileDetailScreen/assignment_detail_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Profile/ProfileDetailScreen/availabity_Detail_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Profile/ProfileDetailScreen/other_detail_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Profile/ProfileDetailScreen/personal_detail_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Profile/ProfileDetailScreen/skill_detail_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Profile/follower_list_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Profile/mediapickerDialog.dart';
import 'package:astrowaypartner/views/HomeScreen/Profile/stories_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/call/callAvailabilityScreen.dart';
import 'package:astrowaypartner/views/HomeScreen/viewStories.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:sizer/sizer.dart';

import '../../../controllers/storiescontroller.dart';
import '../../../utils/config.dart';
import 'testscreen.dart';

enum StatusOption { image, video, text }

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  SignupController signupController = Get.find<SignupController>();
  FollowingController followingController = Get.find<FollowingController>();
  ChatAvailabilityController chatAvailabilityController =
      Get.find<ChatAvailabilityController>();
  CallAvailabilityController callAvailabilityController =
      Get.find<CallAvailabilityController>();
  StoriesController storycontroller = Get.find<StoriesController>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: GetBuilder<SignupController>(
        builder: (controller) {
          return ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 170,
                    width: width,
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      log('clicked bro');

                                      storycontroller
                                          .getAstroStory(signupController
                                              .astrologerList[0]!.id
                                              .toString())
                                          .then((value) {
                                        value.isEmpty
                                            ? global.showToast(
                                                message: 'No Story Uploaded',
                                              )
                                            : Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewStoriesScreen(
                                                          profile:
                                                              "$imgBaseurl${signupController.astrologerList[0]!.imagePath}",
                                                          name: signupController
                                                              .astrologerList[
                                                                  0]!
                                                              .name
                                                              .toString(),
                                                          isprofile: false,
                                                          astroId: int.parse(
                                                              signupController
                                                                  .astrologerList[
                                                                      0]!
                                                                  .id
                                                                  .toString()),
                                                        )),
                                              );
                                      });

                                      // Get.to(() => const StoriesScreen());
                                      //OPen dialog to get image video or text
                                      //showStatusOptionsDialog(context);
                                    },
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          child: signupController.astrologerList
                                                      .isNotEmpty &&
                                                  global.user.imagePath !=
                                                      null &&
                                                  global.user.imagePath!
                                                      .isNotEmpty
                                              ? signupController
                                                      .astrologerList[0]!
                                                      .imagePath!
                                                      .isNotEmpty
                                                  ? SizedBox(
                                                      height: Get.height * 0.1,
                                                      width: Get.width * 0.2,
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        imageUrl:
                                                            "$imgBaseurl${signupController.astrologerList[0]!.imagePath}",
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            Container(
                                                          height: 75,
                                                          width: 75,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                            color: Get.theme
                                                                .primaryColor,
                                                            image:
                                                                DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image:
                                                                  NetworkImage(
                                                                "$imgBaseurl${signupController.astrologerList[0]!.imagePath}",
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Container(
                                                          height: 75,
                                                          width: 75,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                            color: Get.theme
                                                                .primaryColor,
                                                            image:
                                                                const DecorationImage(
                                                              image: AssetImage(
                                                                  "assets/images/no_customer_image.png"),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // decoration: BoxDecoration(
                                                      //   borderRadius:
                                                      //       BorderRadius
                                                      //           .circular(7),

                                                      //   image: NetworkImage(
                                                      //       "$imgBaseurl${signupController.astrologerList[0]!.imagePath}"),
                                                      //   fit: BoxFit.cover,
                                                      // ),
                                                      // ),
                                                    )
                                                  : Container(
                                                      height: Get.height * 0.1,
                                                      width: Get.width * 0.2,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              "$imgBaseurl${global.user.imagePath}"),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    )
                                              : Container(
                                                  height: 75,
                                                  width: 75,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                      color: COLORS()
                                                          .primaryColor),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        COLORS().primaryColor,
                                                    radius: 45,
                                                    backgroundImage:
                                                        const AssetImage(
                                                      "assets/images/no_customer_image.png",
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        Positioned(
                                            right: 1,
                                            top: 1,
                                            child: InkWell(
                                              onTap: () {
                                                showStatusOptionsDialog(
                                                    context);
                                              },
                                              child: Image(
                                                fit: BoxFit.cover,
                                                color: Colors.white,
                                                height: 20,
                                                width: 20,
                                                image: AssetImage(storiesIcon),
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                  GetBuilder<FollowingController>(
                                    builder: (followingController) {
                                      return TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor:
                                                COLORS().greyBackgroundColor),
                                        onPressed: () {
                                          followingController.followerList
                                              .clear();
                                          followingController
                                              .followingList(false);
                                          Get.to(() => FollowerListScreen());
                                        },
                                        child: Center(
                                          child: Text(
                                            'followers',
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                color: Colors.black),
                                          ).tr(args: [
                                            followingController
                                                .followerList.length
                                                .toString()
                                          ]),
                                        ),
                                      );
                                    },
                                  ),
                                ], //follwinController.followerList.length
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    global.user.name != null &&
                                            global.user.name != ''
                                        ? '${global.user.name}'
                                        : tr("Astrologer Name"),
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .displayMedium,
                                  ).tr(),
                                  Row(
                                    children: [
                                      Text(
                                        "Email",
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .titleMedium,
                                      ).tr(),
                                      Text(
                                        global.user.email != null &&
                                                global.user.email != ''
                                            ? '${global.user.email}'
                                            : "",
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Mobile Number",
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .titleMedium,
                                      ).tr(),
                                      Text(
                                        global.user.contactNo != null &&
                                                global.user.contactNo != ''
                                            ? ' ${global.user.contactNo}'
                                            : "",
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        ListTile(
                          enabled: true,
                          tileColor: Colors.white,
                          leading: Icon(
                            Icons.person,
                            size: 20.sp,
                          ),
                          title: Text(
                            "Personal Detail",
                            style:
                                Theme.of(context).primaryTextTheme.titleMedium,
                          ).tr(),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                          ),
                          onTap: () {
                            Get.to(() => const PersonalDetailScreen());
                          },
                        ),
                        Divider(
                          height: 3.w,
                          color: Colors.grey.shade400,
                        ),
                        ListTile(
                          enabled: true,
                          tileColor: Colors.white,
                          leading: Icon(
                            Icons.work,
                            size: 20.sp,
                          ),
                          title: Text(
                            "Skill Details",
                            style:
                                Theme.of(context).primaryTextTheme.titleMedium,
                          ).tr(),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                          ),
                          onTap: () {
                            Get.to(() => SkillDetailScreen());
                          },
                        ),
                        Divider(
                          height: 3.w,
                          color: Colors.grey.shade400,
                        ),
                        ListTile(
                          enabled: true,
                          tileColor: Colors.white,
                          leading: SizedBox(
                            width: 2.h,
                            height: 2.h,
                            child: Image.asset(
                              'assets/images/profileicons/other-details.png',
                            ),
                          ),
                          title: Text(
                            "Other Details",
                            style:
                                Theme.of(context).primaryTextTheme.titleMedium,
                          ).tr(),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                          ),
                          onTap: () {
                            Get.to(() => const OtherDetailScreen());
                          },
                        ),
                        Divider(
                          height: 3.w,
                          color: Colors.grey.shade400,
                        ),
                        ListTile(
                          enabled: true,
                          tileColor: Colors.white,
                          leading: SizedBox(
                            width: 2.h,
                            height: 2.h,
                            child: Image.asset(
                              'assets/images/profileicons/assignment.png',
                            ),
                          ),
                          title: Text(
                            "Assignment",
                            style:
                                Theme.of(context).primaryTextTheme.titleMedium,
                          ).tr(),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                          ),
                          onTap: () {
                            Get.to(() => const AssignmentDetailScreen());
                          },
                        ),
                        Divider(
                          height: 3.w,
                          color: Colors.grey.shade400,
                        ),
                        ListTile(
                          enabled: true,
                          tileColor: Colors.white,
                          leading: SizedBox(
                            width: 2.h,
                            height: 2.h,
                            child: Image.asset(
                              'assets/images/profileicons/availability.png',
                            ),
                          ),
                          title: Text(
                            "Availability",
                            style:
                                Theme.of(context).primaryTextTheme.titleMedium,
                          ).tr(),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                          ),
                          onTap: () async {
                            await signupController.astrologerProfileById(false);
                            signupController.update();
                            Get.to(() => AvailabiltyScreen());
                          },
                        ),
                        Divider(
                          height: 3.w,
                          color: Colors.grey.shade400,
                        ),
                        ListTile(
                          enabled: true,
                          tileColor: Colors.white,
                          leading: SizedBox(
                            width: 2.h,
                            height: 2.h,
                            child: Image.asset(
                              'assets/images/profileicons/chat.png',
                            ),
                          ),
                          title: Text(
                            "Chat Availability",
                            style:
                                Theme.of(context).primaryTextTheme.titleMedium,
                          ).tr(),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                          ),
                          onTap: () {
                            chatAvailabilityController.chatStatusName =
                                global.user.chatStatus;
                            global.user;
                            if (global.user.chatWaitTime != null) {
                              String formattedTime = DateFormat('HH:mm')
                                  .format(global.user.chatWaitTime!);
                              chatAvailabilityController.waitTime.text =
                                  formattedTime;
                              chatAvailabilityController.timeOfDay2 = TimeOfDay(
                                  hour: global.user.chatWaitTime!.hour,
                                  minute: global.user.chatWaitTime!.minute);
                            }
                            if (global.user.chatStatus == "Online") {
                              chatAvailabilityController.chatType = 1;
                              chatAvailabilityController.showAvailableTime =
                                  true;
                            } else if (global.user.chatStatus == "Offline") {
                              chatAvailabilityController.chatType = 2;
                              chatAvailabilityController.showAvailableTime =
                                  true;
                            } else {
                              chatAvailabilityController.chatType = 3;
                              chatAvailabilityController.showAvailableTime =
                                  false;
                            }
                            chatAvailabilityController.update();
                            Get.to(() => ChatAvailabilityScreen());
                          },
                        ),
                        Divider(
                          height: 3.w,
                          color: Colors.grey.shade400,
                        ),
                        ListTile(
                          enabled: true,
                          tileColor: Colors.white,
                          leading: SizedBox(
                            width: 2.h,
                            height: 2.h,
                            child: Image.asset(
                              'assets/images/profileicons/telephone.png',
                            ),
                          ),
                          title: Text(
                            "Call Availability",
                            style:
                                Theme.of(context).primaryTextTheme.titleMedium,
                          ).tr(),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                          ),
                          onTap: () {
                            callAvailabilityController.callStatusName =
                                global.user.callStatus;
                            if (global.user.callWaitTime != null) {
                              String formattedTime = DateFormat('HH:mm')
                                  .format(global.user.callWaitTime!);
                              callAvailabilityController.waitTime.text =
                                  formattedTime;
                              callAvailabilityController.timeOfDay2 = TimeOfDay(
                                  hour: global.user.callWaitTime!.hour,
                                  minute: global.user.callWaitTime!.minute);
                            }
                            if (global.user.callStatus == "Online") {
                              callAvailabilityController.callType = 1;
                              callAvailabilityController.showAvailableTime =
                                  true;
                            } else if (global.user.callStatus == "Offline") {
                              callAvailabilityController.callType = 2;
                              callAvailabilityController.showAvailableTime =
                                  true;
                            } else {
                              callAvailabilityController.callType = 3;
                              callAvailabilityController.showAvailableTime =
                                  false;
                            }
                            callAvailabilityController.update();
                            Get.to(() => CallAvailabilityScreen());
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void showStatusOptionsDialog(BuildContext context) {
    showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Option for Image
                CupertinoButton(
                  onPressed: () async {
                    log('pick image clicked');
                    await storycontroller.pickMedia(context, MediaTypes.image);
                    Get.back();
                    Get.to(() => const StoriesScreen());
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.image,
                        color: Theme.of(context).primaryColor,
                        size: 12.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Image',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 0.3,
                  color: Colors.black,
                ),

                // Option for Video
                CupertinoButton(
                  onPressed: () {
                    storycontroller.pickMedia(context, MediaTypes.video);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.videocam,
                        color: Theme.of(context).primaryColor,
                        size: 12.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Video',
                        style: TextStyle(color: Colors.black, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 0.3,
                  color: Colors.black,
                ),

                // Option for Text
                CupertinoButton(
                  onPressed: () {
                    // Navigator.pop(context, StatusOption.text);
                    Get.to(() => const TextScreen())!.then((value) {
                      Get.back();
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.text_increase,
                        color: Theme.of(context).primaryColor,
                        size: 14.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Text',
                        style: TextStyle(color: Colors.black, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
