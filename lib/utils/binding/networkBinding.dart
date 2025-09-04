// ignore_for_file: file_names
//packages

import 'package:astrowaypartner/controllers/AssistantController/add_assistant_controller.dart';
import 'package:astrowaypartner/controllers/AssistantController/astrologer_assistant_chat_controller.dart';
import 'package:astrowaypartner/controllers/Authentication/login_controller.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_otp_controller.dart';
import 'package:astrowaypartner/controllers/HistoryController/call_history_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/astrology_blog_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/call_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/call_detail_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/chat_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/edit_profile_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/edit_profile_otp_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/home_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/live_astrologer_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/report_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/timer_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:astrowaypartner/controllers/app_review_controller.dart';
import 'package:astrowaypartner/controllers/callAvailability_controller.dart';
import 'package:astrowaypartner/controllers/chatAvailability_controller.dart';
import 'package:astrowaypartner/controllers/customerReview_controller.dart';
import 'package:astrowaypartner/controllers/dailyHoroscopeController.dart';
import 'package:astrowaypartner/controllers/following_controller.dart';
import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:astrowaypartner/controllers/kundli_matchig_controller.dart';
import 'package:astrowaypartner/controllers/notification_controller.dart';
import 'package:astrowaypartner/controllers/report_detail_controller.dart';
import 'package:astrowaypartner/controllers/search_place_controller.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/controllers/networkController.dart';
import 'package:astrowaypartner/controllers/splashController.dart';

import '../../controllers/Authentication/login_otp_controller.dart';
import '../../controllers/life_cycle_controller.dart';
import '../../controllers/storiescontroller.dart';

class NetworkBinding extends Bindings {
  @override
  void dependencies() {
    //StoriesController
    Get.lazyPut<StoriesController>(() => StoriesController(), fenix: true);

    Get.lazyPut<NetworkController>(() => NetworkController(), fenix: true);
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);

    Get.lazyPut<LoginOtpController>(() => LoginOtpController(), fenix: true);

    Get.lazyPut<SignupController>(() => SignupController(), fenix: true);
    Get.lazyPut<SignupOtpController>(() => SignupOtpController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
    Get.lazyPut<CallController>(() => CallController(), fenix: true);
    Get.lazyPut<ReportController>(() => ReportController(), fenix: true);
    Get.lazyPut<CallDetailController>(() => CallDetailController(),
        fenix: true);
    Get.lazyPut<EditProfileController>(() => EditProfileController(),
        fenix: true);
    Get.lazyPut<EditProfileOTPController>(() => EditProfileOTPController(),
        fenix: true);
    Get.lazyPut<AddAssistantController>(() => AddAssistantController(),
        fenix: true);
    Get.lazyPut<ReportDetailController>(() => ReportDetailController(),
        fenix: true);
    Get.lazyPut<KundliMatchingController>(() => KundliMatchingController(),
        fenix: true);
    Get.lazyPut<DailyHoroscopeController>(() => DailyHoroscopeController(),
        fenix: true);
    Get.lazyPut<KundliController>(() => KundliController(), fenix: true);
    Get.lazyPut<CustomerReviewController>(() => CustomerReviewController(),
        fenix: true);
    Get.lazyPut<LiveAstrologerController>(() => LiveAstrologerController(),
        fenix: true);
    Get.lazyPut<FollowingController>(() => FollowingController(), fenix: true);
    Get.lazyPut<TimerController>(() => TimerController(), fenix: true);
    Get.lazyPut<HomeCheckController>(() => HomeCheckController(), fenix: true);
    Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(),
        fenix: true);
    //History
    Get.lazyPut<CallHistoryController>(() => CallHistoryController(),
        fenix: true);
    Get.lazyPut<SearchPlaceController>(() => SearchPlaceController(),
        fenix: true);
    Get.lazyPut<ChatAvailabilityController>(() => ChatAvailabilityController(),
        fenix: true);
    Get.lazyPut<CallAvailabilityController>(() => CallAvailabilityController(),
        fenix: true);
    Get.lazyPut<AstrologerAssistantChatController>(
        () => AstrologerAssistantChatController(),
        fenix: true);
    Get.lazyPut<AstrologyBlogController>(() => AstrologyBlogController(),
        fenix: true);
    Get.lazyPut<AppReviewController>(() => AppReviewController(), fenix: true);
  }
}
