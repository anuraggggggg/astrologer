// ignore_for_file: must_be_immutable

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/AssistantController/add_assistant_controller.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/home_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:astrowaypartner/controllers/app_review_controller.dart';
import 'package:astrowaypartner/controllers/customerReview_controller.dart';

import 'package:astrowaypartner/views/HomeScreen/Assistant/assistant_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Drawer/AppReview/app_review_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Drawer/Setting/setting_list_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Drawer/Wallet/Wallet_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Drawer/customer_review_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:sizer/sizer.dart';

import '../../../controllers/AssistantController/astrologer_assistant_chat_controller.dart';
import '../../../utils/config.dart';
import '../Assistant/assistant_chat_request_screen.dart';

class DrawerScreen extends StatelessWidget {
  DrawerScreen({super.key});
  AddAssistantController assistantController =
      Get.find<AddAssistantController>();
  CustomerReviewController customerReviewController =
      Get.find<CustomerReviewController>();
  SignupController signupController = Get.find<SignupController>();
  HomeController homeController = Get.find<HomeController>();
  WalletController walletController = Get.find<WalletController>();
  AppReviewController appReviewController = Get.find<AppReviewController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    homeController.isSelectedBottomIcon = 4;
                    homeController.update();
                    Navigator.pop(context);
                  },
                  //if (astrologerList != null && astrologerList.isNotEmpty) {

                  child: signupController.astrologerList.isNotEmpty &&
                          global.user.imagePath != null &&
                          global.user.imagePath!.isNotEmpty
                      ? signupController
                              .astrologerList[0]!.imagePath!.isNotEmpty
                          ? Container(
                              height: Get.height * 0.1,
                              width: Get.width * 0.2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      "$imgBaseurl${signupController.astrologerList[0]!.imagePath}"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              height: Get.height * 0.1,
                              width: Get.width * 0.2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                image: DecorationImage(
                                  image:
                                      NetworkImage("${global.user.imagePath}"),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                            )
                      : Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: COLORS().primaryColor),
                          child: CircleAvatar(
                            backgroundColor: COLORS().primaryColor,
                            radius: 45,
                            backgroundImage: const AssetImage(
                              "assets/images/no_customer_image.png",
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        global.user.name != null && global.user.name != ''
                            ? '${global.user.name}'
                            : "Astrologer",
                        style: Theme.of(context).primaryTextTheme.displayMedium,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 1),
                              child: Text(
                                '+91-',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            Text(
                              global.user.contactNo != null &&
                                      global.user.contactNo != ''
                                  ? '${global.user.contactNo}'
                                  : "",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontSize: 9.sp),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Experience ${global.user.expirenceInYear} years',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontSize: 9.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              height: 3.w,
              color: Colors.grey.shade400,
            ),
            // ListTile(
            //   contentPadding: EdgeInsets.zero,
            //   title: Row(
            //     children: [
            //       SizedBox(
            //         width: 3.h,
            //         height: 3.h,
            //         child: Image.asset(
            //           'assets/images/drawericons/assistant.png',
            //         ),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.only(left: 10),
            //         child: Text(
            //           "My Assistant",
            //           style: Theme.of(context)
            //               .textTheme
            //               .titleMedium!
            //               .copyWith(fontSize: 12.sp),
            //         ).tr(),
            //       ),
            //     ],
            //   ),
            //   onTap: () async {
            //     await assistantController.getAstrologerAssistantList();
            //     Get.to(() => AssistantScreen());
            //   },
            // ),
            // ListTile(
            //   contentPadding: EdgeInsets.zero,
            //   title: Row(
            //     children: [
            //       SizedBox(
            //         width: 3.h,
            //         height: 3.h,
            //         child: Image.asset(
            //           'assets/images/drawericons/assistantrequest.png',
            //         ),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.only(left: 10),
            //         child: Text(
            //           "Assistant Chat Request",
            //           style: Theme.of(context)
            //               .textTheme
            //               .titleMedium!
            //               .copyWith(fontSize: 12.sp),
            //         ).tr(),
            //       ),
            //     ],
            //   ),
            //   onTap: () async {
            //     final AstrologerAssistantChatController
            //         astrologerAssistantChatController =
            //         Get.find<AstrologerAssistantChatController>();
            //     global.showOnlyLoaderDialog();
            //     await astrologerAssistantChatController
            //         .getAstrologerAssistantChatRequest();
            //     global.hideLoader();
            //     Get.to(() => AssistantChatRequestScreen());
            //   },
            // ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  SizedBox(
                    width: 3.h,
                    height: 3.h,
                    child: Image.asset(
                      'assets/images/drawericons/wallet.png',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Wallet Transactions",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 12.sp),
                    ).tr(),
                  ),
                ],
              ),
              onTap: () {
                walletController.getAmountList();
                Get.to(() => WalletScreen());
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  SizedBox(
                    width: 3.h,
                    height: 3.h,
                    child: Image.asset(
                      'assets/images/drawericons/feedback.png',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Customer Review",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 12.sp),
                    ).tr(),
                  ),
                ],
              ),
              onTap: () async {
                signupController.astrologerList.clear();
                signupController.clearReply();
                await signupController.astrologerProfileById(false);
                signupController.update();
                Get.to(() => CustomeReviewScreen());
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  const Icon(
                    Icons.rate_review_outlined,
                    color: Colors.green,
                    size: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Contact Support",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 12.sp),
                    ).tr(),
                  ),
                ],
              ),
              onTap: () async {
                appReviewController.getAppReview();
                Get.to(() => const AppReviewScreen());
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  SizedBox(
                    width: 3.h,
                    height: 3.h,
                    child: Image.asset(
                      'assets/images/drawericons/settings.png',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Settings",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 12.sp),
                    ).tr(),
                  ),
                ],
              ),
              onTap: () {
                Get.to(() => SettingListScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
