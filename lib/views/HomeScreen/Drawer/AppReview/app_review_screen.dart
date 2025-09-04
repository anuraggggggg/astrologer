import 'package:astrowaypartner/controllers/app_review_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../../../../constants/colorConst.dart';
import '../../../../utils/config.dart';
import '../../../../widgets/app_bar_widget.dart';

class AppReviewScreen extends StatefulWidget {
  const AppReviewScreen({super.key});

  @override
  State<AppReviewScreen> createState() => _AppReviewScreenState();
}

class _AppReviewScreenState extends State<AppReviewScreen> {
  final AppReviewController appReviewController =
      Get.find<AppReviewController>();

  @override
  void initState() {
    super.initState();
    // global.hideLoader();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
          height: 80,
          backgroundColor: COLORS().primaryColor,
          title: const Text("App Review").tr(),
          actions: [
            IconButton(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("App Review").tr(),
                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    titlePadding: const EdgeInsets.all(8),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    content: Container(
                      width: Get.width,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'I am the Product Manager',
                            style: Get.theme.primaryTextTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.w500),
                          ).tr(),
                          const Text(
                            'share your feedback to help us improve the app',
                            style: TextStyle(fontSize: 10),
                          ).tr(),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: appReviewController.feedbackController,
                            maxLines: 8,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(5),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.white,
                              hintText: tr('Start typing here..'),
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 5),
                              child: SizedBox(
                                height: 35,
                                child: TextButton(
                                  style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                        const EdgeInsets.all(0)),
                                    fixedSize: WidgetStateProperty.all(
                                        Size.fromWidth(Get.width / 2)),
                                    backgroundColor: WidgetStateProperty.all(
                                        Get.theme.primaryColor),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (appReviewController
                                            .feedbackController.text ==
                                        "") {
                                      global.showToast(
                                          message: 'Please enter feedback');
                                    } else {
                                      await appReviewController.addFeedback(
                                          appReviewController
                                              .feedbackController.text);
                                      Get.back();
                                    }
                                  },
                                  child: Text(
                                    'Send Feedback',
                                    style: Get.theme.primaryTextTheme.bodySmall!
                                        .copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                  ).tr(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: GetBuilder<AppReviewController>(builder: (appReviewController) {
          return appReviewController.clientReviews.isEmpty
              ? Center(child: const Text('App reviews not added yet!').tr())
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                      itemCount: appReviewController.clientReviews.length,
                      itemBuilder: (BuildContext ctx, index) {
                        return Container(
                          margin:
                              const EdgeInsets.only(left: 4, right: 4, top: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  appReviewController
                                              .clientReviews[index].profile ==
                                          ""
                                      ? Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            color: Get.theme.primaryColor,
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                  "assets/images/no_customer_image.png"),
                                            ),
                                          ),
                                        )
                                      : CachedNetworkImage(
                                          imageUrl:
                                              '$imgBaseurl${appReviewController.clientReviews[index].profile}',
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              color: Get.theme.primaryColor,
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    "$imgBaseurl${appReviewController.clientReviews[index].profile}"),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              color: Get.theme.primaryColor,
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/no_customer_image.png"),
                                              ),
                                            ),
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, bottom: 10),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            // ignore: unnecessary_null_comparison
                                            (appReviewController
                                                            .clientReviews[
                                                                index]
                                                            .name !=
                                                        '')
                                                ? appReviewController
                                                    .clientReviews[index].name
                                                : 'User',
                                            style: Get.theme.primaryTextTheme
                                                .titleSmall!
                                                .copyWith(
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          appReviewController
                                              .clientReviews[index].location,
                                          style: Get
                                              .theme.primaryTextTheme.bodySmall!
                                              .copyWith(
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  appReviewController
                                      .clientReviews[index].review,
                                  maxLines: 6,
                                  textAlign: TextAlign.justify,
                                  overflow: TextOverflow.ellipsis,
                                  style: Get.theme.primaryTextTheme.bodyMedium!
                                      .copyWith(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                );
        }),
      ),
    );
  }
}
