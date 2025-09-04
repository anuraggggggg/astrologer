// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings, no_leading_underscores_for_local_identifiers, avoid_print, duplicate_ignore

import 'dart:async';
import 'dart:convert';
import 'dart:developer'; // Kept for general logging, though print is used directly
import 'dart:io';
import 'dart:math'; // Used for generating OTP

import 'package:astrowaypartner/utils/config.dart'; // Ensure this is still needed
import 'package:date_format/date_format.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:astrowaypartner/utils/global.dart' as global; // Alias global for clarity
import 'package:http/http.dart' as http; // Import http for API calls

import '../../models/Master Table Model/all_skill_model.dart';
import '../../models/Master Table Model/astrologer_category_list_model.dart';
import '../../models/Master Table Model/language_list_model.dart';
import '../../models/Master Table Model/primary_skill_model.dart';
import '../../models/time_availability_model.dart';
import '../../models/user_model.dart';
import '../../models/week_model.dart';
import '../../services/apiHelper.dart';
import '../../views/Authentication/OtpScreens/signup_otp_screen.dart';
import '../../views/Authentication/success_registration_screen.dart';
import 'signup_otp_controller.dart';

class SignupController extends GetxController {
  // Class
  final APIHelper _apiHelper = APIHelper(); // Use final and private
  // String screen = 'signup_controller.dart'; // Can be removed if not used for logging string
  final TextEditingController cReply = TextEditingController();
  // Initialize SignupOtpController here or in onInit if needed immediately
  // Removed `late final SignupOtpController signupOtpController;` from here
  // and will declare it right before use in _checkContactExist to avoid recursive instantiation.
  late SignupOtpController signupOtpController; // Changed to late to indicate it will be initialized later

  void clearReply() {
    cReply.text = '';
  }

  List<CurrentUser?> astrologerList = [];
  String countryCode = "+91";
  String phoneNumber = ''; // This will store the 10-digit number
  String? _sentOtp; // Private to store the OTP generated and sent
  String? smsCode; // Added: To store the OTP entered by the user in Pinput

  updateCountryCode(String? value) {
    if (value != null) {
      countryCode = value;
      print('Country code updated to: $countryCode');
      update();
    }
  }

  updatephoneno(String? value) {
    if (value != null) {
      phoneNumber = value;
      print('Phone number updated to: $phoneNumber');
      update();
    }
  }

  // List of checkbox
  List<AstrolgoerCategoryModel> astroId = [];
  List<PrimarySkillModel> primaryId = [];
  List<AllSkillModel> allId = [];
  List<LanguageModel> lId = [];

  // static List
  List<Week>? week = [];
  List<TimeAvailabilityModel>? timeAvailabilityList = [];
  List<String?> daysList = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];
  // -------------------- Personal Details ----------------------
  // Name
  final TextEditingController cName = TextEditingController();
  final FocusNode fName = FocusNode();
  // Email
  final TextEditingController cEmail = TextEditingController();
  final FocusNode fEmail = FocusNode();
  // Mobile Numer
  final TextEditingController cMobileNumber = TextEditingController();
  final FocusNode fMobileNumber = FocusNode();
  // Terms And Condition
  RxBool termAndCondtion = false.obs;

  // -------------------------- Skills Details ----------------------
  // User Image
  Uint8List? tImage;
  File? selectedImage;
  var imagePath = ''.obs;

  onOpenCamera() async {
    selectedImage = await _openCamera(Get.theme.primaryColor);
    if (selectedImage != null) {
      List<int> imageBytes = selectedImage!.readAsBytesSync();
      imagePath.value = base64Encode(imageBytes);
    }
    update();
  }

  onOpenGallery() async {
    selectedImage = await _openGallery(Get.theme.primaryColor);
    if (selectedImage != null) {
      List<int> imageBytes = selectedImage!.readAsBytesSync();
      imagePath.value = base64Encode(imageBytes);
    }
    update();
  }

  Future<File?> _openCamera(Color color, {bool isProfile = true}) async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? _selectedImage = await picker.pickImage(source: ImageSource.camera);
      if (_selectedImage != null) {
        CroppedFile? _croppedFile = await ImageCropper().cropImage(
          sourcePath: _selectedImage.path,
          aspectRatio: isProfile ? const CropAspectRatio(ratioX: 1, ratioY: 1) : null,
          uiSettings: [
            AndroidUiSettings(
              initAspectRatio: isProfile ? CropAspectRatioPreset.square : CropAspectRatioPreset.original,
              backgroundColor: Colors.grey,
              toolbarColor: Colors.grey[100],
              toolbarWidgetColor: color,
              activeControlsWidgetColor: color,
              cropFrameColor: color,
              lockAspectRatio: isProfile,
            ),
          ],
        );
        if (_croppedFile != null) {
          return File(_croppedFile.path);
        }
      }
    } catch (e) {
      print("Exception - _openCamera(): $e");
    }
    return null;
  }

  // Time for Interview
  TimeOfDay timeforInterview = TimeOfDay.now();
  timeforInterView(BuildContext context) async {
    try {
      final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: timeforInterview,
        initialEntryMode: TimePickerEntryMode.dial,
      );
      if (timeOfDay != null) {
        timeforInterview = timeOfDay;
        cTimeForInterview.text = timeOfDay.format(context);
      }
      update();
    } catch (e) {
      print('Exception - timeforInterView(): $e');
    }
  }

  Future<File?> _openGallery(Color color, {bool isProfile = true}) async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? _selectedImage = await picker.pickImage(source: ImageSource.gallery);
      if (_selectedImage != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: _selectedImage.path,
          aspectRatio: isProfile ? const CropAspectRatio(ratioX: 1, ratioY: 1) : null,
          uiSettings: [
            AndroidUiSettings(
              initAspectRatio: isProfile ? CropAspectRatioPreset.square : CropAspectRatioPreset.original,
              backgroundColor: Colors.grey,
              toolbarColor: Colors.grey[100],
              toolbarWidgetColor: color,
              activeControlsWidgetColor: color,
              cropFrameColor: color,
              lockAspectRatio: isProfile,
            ),
          ],
        );
        if (croppedFile != null) {
          return File(croppedFile.path); // Return File directly
        }
      }
    } catch (e) {
      print("Exception - _openGallery(): $e");
    }
    return null;
  }

  // Date oF Birth
  final TextEditingController cBirthDate = TextEditingController();
  DateTime? selectedDate;
  onDateSelected(DateTime? picked) {
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      cBirthDate.text = formatDate(selectedDate!, [dd, '-', mm, '-', yyyy]);
    }
    update();
  }

  bool select = false;
  // Gender List
  String selectedGender = "Male";
  // Choose category
  final TextEditingController cSelectCategory = TextEditingController();
  // Primary Skills
  final TextEditingController cPrimarySkill = TextEditingController();
  // All Skills
  final TextEditingController cAllSkill = TextEditingController();
  // Language
  final TextEditingController cLanguage = TextEditingController();
  // Charge
  final TextEditingController cCharges = TextEditingController();
  final FocusNode fCharges = FocusNode();
  // Video call Charge
  final TextEditingController cVideoCharges = TextEditingController();
  final FocusNode fVideoCharges = FocusNode();
  // Charge
  final TextEditingController cReportCharges = TextEditingController();
  final FocusNode fReportCharges = FocusNode();
  // Expirence
  final TextEditingController cExpirence = TextEditingController();
  final FocusNode fExpirence = FocusNode();
  // Contribution Hours
  final TextEditingController cContributionHours = TextEditingController();
  final FocusNode fContributionHours = FocusNode();
  // Hear about astrotalk
  final TextEditingController cHearAboutAstroGuru = TextEditingController();
  final FocusNode fHearAboutAstroGuru = FocusNode();
  // Working on Any Other Platform
  final TextEditingController cNameOfPlatform = TextEditingController();
  final FocusNode fNameOfPlatform = FocusNode();
  final TextEditingController cMonthlyEarning = TextEditingController();
  final FocusNode fMonthlyEarning = FocusNode();
  int? anyOnlinePlatform;
  void setOnlinePlatform(int? index) {
    anyOnlinePlatform = index;
    update();
  }

  // ---------------- Other Details --------------

  // on board you
  final TextEditingController cOnBoardYou = TextEditingController();
  final FocusNode fOnBoardYou = FocusNode();
  // time for interview
  final TextEditingController cTimeForInterview = TextEditingController();
  final FocusNode fTimeForInterview = FocusNode();
  // live city
  final TextEditingController cLiveCity = TextEditingController();
  final FocusNode fLiveCity = FocusNode();
  // source of business
  String? selectedSourceOfBusiness;
  // source of business
  String? selectedHighestQualification;
  // source of business
  String? selectedDegreeDiploma;
  // College/School/university
  final TextEditingController cCollegeSchoolUniversity = TextEditingController();
  final FocusNode fCollegeSchoolUniversity = FocusNode();
  // Learn Astrology
  final TextEditingController cLearnAstrology = TextEditingController();
  final FocusNode fLearnAstroLogy = FocusNode();
  // Insta
  final TextEditingController cInsta = TextEditingController();
  final FocusNode fInsta = FocusNode();
  // Facebook
  final TextEditingController cFacebook = TextEditingController();
  final FocusNode fFacebook = FocusNode();
  // LinkedIn
  final TextEditingController cLinkedIn = TextEditingController();
  final FocusNode fLinkedIn = FocusNode();
  // Youtube
  final TextEditingController cYoutube = TextEditingController();
  final FocusNode fYoutube = FocusNode();
  // Website
  final TextEditingController cWebSite = TextEditingController();
  final FocusNode fWebSite = FocusNode();
  // refer
  final TextEditingController cNameOfReferPerson = TextEditingController();
  final FocusNode fNameOfReferPerson = FocusNode();
  int? referPerson;
  void setReferPerson(int? index) {
    referPerson = index;
    update();
  }

  // Expected Minimum Earning from Astroguru
  final TextEditingController cExptectedMinimumEarning = TextEditingController();
  final FocusNode fExpectedMinimumEarning = FocusNode();
  // Expected Maximum Earning
  final TextEditingController cExpectedMaximumEarning = TextEditingController();
  final FocusNode fExpectedMaximumEarning = FocusNode();
  // Long Bio
  final TextEditingController cLongBio = TextEditingController();
  final FocusNode fLongBio = FocusNode();
  // ------------------------- Assignment ----------------------------

  // foreign country
  String? selectedForeignCountryCount;
  // currently working as job
  String? selectedCurrentlyWorkingJob;
  // Good Quality
  final TextEditingController cGoodQuality = TextEditingController();
  final FocusNode fGoodQuality = FocusNode();
  // Biggest Challenge
  final TextEditingController cBiggestChallenge = TextEditingController();
  final FocusNode fBiggestChallenge = FocusNode();
  // Repeated Question
  final TextEditingController cRepeatedQuestion = TextEditingController();
  final FocusNode fRepeatedQuestion = FocusNode();
  // --------------------------- Availability ---------------------------
  final TextEditingController cSunday = TextEditingController();
  final TextEditingController cMonday = TextEditingController();
  final TextEditingController cTuesday = TextEditingController();
  final TextEditingController cWednesday = TextEditingController();
  final TextEditingController cThursday = TextEditingController();
  final TextEditingController cFriday = TextEditingController();
  final TextEditingController cSaturday = TextEditingController();
  final TextEditingController cStartTime = TextEditingController();
  final TextEditingController cEndTime = TextEditingController();
  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();
  void clearTime() {
    cStartTime.text = '';
    cEndTime.text = '';
  }

  // dynamic Availability Widget (seems unused based on name and empty content)
  // Consider removing if truly not used.
  Widget dynamicWeekFieldWidget(BuildContext? context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        height: 35,
        child: Container(
          padding: const EdgeInsets.only(bottom: 8.0),
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(""),
        ),
      ),
    );
  }

  // Available Time Start
  selectStartTime(BuildContext context) async {
    try {
      final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedStartTime,
        initialEntryMode: TimePickerEntryMode.dial,
      );
      if (timeOfDay != null) {
        selectedStartTime = timeOfDay;
        cStartTime.text = timeOfDay.format(context);
      }
      update();
    } catch (e) {
      print('Exception - selectStartTime(): $e');
    }
  }

  // Available Time End
  selectEndTime(BuildContext context) async {
    try {
      final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedEndTime,
        initialEntryMode: TimePickerEntryMode.dial,
      );
      if (timeOfDay != null) {
        selectedEndTime = timeOfDay;
        cEndTime.text = timeOfDay.format(context);
      }
      update();
    } catch (e) {
      print('Exception - selectEndTime(): $e');
    }
  }

  // ---------------------- Button On Tap -------------------
  int index = 0;
  onStepBack() {
    try {
      if (index > 0) {
        index -= 1;
        update();
      }
    } catch (err) {
      global.printException("signup_controller.dart", "onStepBack", err);
    }
  }

  onStepNext() {
    try {
      index += 1;
      update();
    } catch (err) {
      global.printException("signup_controller.dart", "onStepNext", err);
    }
  }

  validateForm(
      int formIndex, { // Renamed 'index' to 'formIndex' to avoid confusion with class member 'index'
        BuildContext? context,
        String countrycode = '+91',
      }) async { // Made async because checkContactExist is async
    print("validateForm called with formIndex: $formIndex");
    try {
      // ------ Validation_of_Personal_Detail -----------------
      if (formIndex == 0) {
        if (cName.text.isNotEmpty &&
            GetUtils.isEmail(cEmail.text) &&
            cMobileNumber.text.length == 10 &&
            termAndCondtion.value == true) {
          print("Validation passed for index = 0");
          await _checkContactExist(cMobileNumber.text, countrycode); // Await this call
        } else if (cName.text.isEmpty) {
          global.showToast(message: "Please Enter Valid Name");
        } else if (cEmail.text.isEmpty || !GetUtils.isEmail(cEmail.text)) {
          global.showToast(message: "Please Enter Valid Email Address");
        } else if (cMobileNumber.text.isEmpty || cMobileNumber.text.length != 10) {
          global.showToast(message: "Please Enter Valid 10-digit Mobile Number");
        } else if (!termAndCondtion.value) {
          global.showToast(message: "Please Agree With Terms & Conditions");
        } else {
          global.showToast(message: "Something went wrong in Personal Details Form");
        }
      }
      // ------ Validation_of_Skill_Detail -----------------
      else if (formIndex == 1) {
        if (selectedGender.isNotEmpty &&
            selectedDate != null &&
            cSelectCategory.text.isNotEmpty &&
            cPrimarySkill.text.isNotEmpty &&
            cAllSkill.text.isNotEmpty &&
            cLanguage.text.isNotEmpty &&
            cCharges.text.isNotEmpty &&
            cVideoCharges.text.isNotEmpty &&
            cReportCharges.text.isNotEmpty &&
            cExpirence.text.isNotEmpty &&
            cContributionHours.text.isNotEmpty &&
            (anyOnlinePlatform == 1
                ? cNameOfPlatform.text.isNotEmpty && cMonthlyEarning.text.isNotEmpty
                : true)) {
          print("Validation passed for index = 1");
          onStepNext();
        } else if (selectedImage == null) {
          global.showToast(message: "Please select your profile image.");
        } else if (selectedGender.isEmpty) {
          global.showToast(message: "Please Select Gender");
        } else if (selectedDate == null) {
          global.showToast(message: "Please Select Date of Birth");
        } else if (cSelectCategory.text.isEmpty) {
          global.showToast(message: "Please Select astrologer category");
        } else if (cPrimarySkill.text.isEmpty) {
          global.showToast(message: "Please Select Primary Skill");
        } else if (cAllSkill.text.isEmpty) {
          global.showToast(message: "Please Select All Skill");
        } else if (cLanguage.text.isEmpty) {
          global.showToast(message: "Please Select Language");
        } else if (cCharges.text.isEmpty) {
          global.showToast(message: "Please Enter Call Charges");
        } else if (cVideoCharges.text.isEmpty) {
          global.showToast(message: "Please Enter Video Call Charges");
        } else if (cReportCharges.text.isEmpty) {
          global.showToast(message: "Please Enter Report Charges");
        } else if (cExpirence.text.isEmpty) {
          global.showToast(message: "Please Enter Experience");
        } else if (cContributionHours.text.isEmpty) {
          global.showToast(message: "Please Enter Daily Contribution Hours");
        } else if (anyOnlinePlatform == 1 && cNameOfPlatform.text.isEmpty) {
          global.showToast(message: "Please Enter Name Of Platform you work on");
        } else if (anyOnlinePlatform == 1 && cMonthlyEarning.text.isEmpty) {
          global.showToast(message: "Please Enter Monthly Earning from other platform");
        } else {
          global.showToast(message: "Something went wrong in Skill Details Form");
        }
      }
      // ------ Validation_of_Other_Detail -----------------
      else if (formIndex == 2) {
        if (cOnBoardYou.text.isNotEmpty &&
            cTimeForInterview.text.isNotEmpty &&
            selectedSourceOfBusiness != null &&
            selectedHighestQualification != null &&
            selectedDegreeDiploma != null &&
            cExptectedMinimumEarning.text.isNotEmpty &&
            cExpectedMaximumEarning.text.isNotEmpty &&
            cLongBio.text.isNotEmpty) {
          print("Validation passed for index = 2");
          onStepNext();
        } else if (cOnBoardYou.text.isEmpty) {
          global.showToast(message: "Please Enter Why Should We Onboard You");
        } else if (cTimeForInterview.text.isEmpty) {
          global.showToast(message: "Please Enter Suitable Time For Interview");
        } else if (selectedSourceOfBusiness == null) {
          global.showToast(message: "Please Select Main Source Of Business");
        } else if (selectedHighestQualification == null) {
          global.showToast(message: "Please Select Highest Qualification");
        } else if (selectedDegreeDiploma == null) {
          global.showToast(message: "Please Select Degree/Diploma");
        } else if (cExptectedMinimumEarning.text.isEmpty) {
          global.showToast(message: "Please Enter Expected Minimum Earning");
        } else if (cExpectedMaximumEarning.text.isEmpty) {
          global.showToast(message: "Please Enter Expected Maximum Earning");
        } else if (cLongBio.text.isEmpty) {
          global.showToast(message: "Please Enter Your Long Bio");
        } else {
          global.showToast(message: "Something went wrong in Other Details Form");
        }
      }
      // ------ Validation_of_Assignment -----------------
      else if (formIndex == 3) {
        if (selectedForeignCountryCount != null &&
            selectedCurrentlyWorkingJob != null &&
            cGoodQuality.text.isNotEmpty &&
            cBiggestChallenge.text.isNotEmpty &&
            cRepeatedQuestion.text.isNotEmpty) {
          print("Validation passed for index = 3");
          onStepNext();
        } else if (selectedForeignCountryCount == null) {
          global.showToast(message: "Please Select Number of Foreign Countries You Have Lived In");
        } else if (selectedCurrentlyWorkingJob == null) {
          global.showToast(message: "Please Select If You Are Currently Working Full-time");
        } else if (cGoodQuality.text.isEmpty) {
          global.showToast(message: "Please Enter Your Good Quality");
        } else if (cBiggestChallenge.text.isEmpty) {
          global.showToast(message: "Please Enter Your Biggest Challenge Faced");
        } else if (cRepeatedQuestion.text.isEmpty) {
          global.showToast(message: "Please Enter a Repeated Question from Clients");
        } else {
          global.showToast(message: "Something went wrong in Assignment Form");
        }
      }
      // ------ Validation_of_Availability_Detail -----------------
      else if (formIndex == 4) {
        if (cStartTime.text.isNotEmpty && cEndTime.text.isNotEmpty) {
          await _signupAstrologer(); // Await the signup process
        } else {
          global.showToast(message: "Please select your available time range.");
        }
      } else {
        global.showToast(message: "Invalid form index provided.");
      }
    } catch (err) {
      global.printException("signup_controller.dart", "validateForm()", err);
      global.showToast(message: "An error occurred during form validation.");
    }
  }

  // Register astrologer
  Future<void> _signupAstrologer() async { // Made private as it's an internal step
    try {
      final bool networkResult = await global.checkBody();
      if (!networkResult) {
        global.showToast(message: "No Network Available. Please check your internet connection.");
        return;
      }

      global.showOnlyLoaderDialog();
      await global.getDeviceData(); // Ensure device data is populated

      // Populate global.user model for signup
      global.user.roleId = 2;
      global.user.name = cName.text;
      global.user.email = cEmail.text;
      global.user.contactNo = cMobileNumber.text;
      global.user.imagePath = imagePath.value;
      global.user.gender = selectedGender;
      global.user.birthDate = selectedDate;
      global.user.primarySkill = cPrimarySkill.text;
      global.user.astrologerCategory = cSelectCategory.text;
      global.user.allSkill = cAllSkill.text;
      global.user.languageKnown = cLanguage.text;
      global.user.charges = int.tryParse(cCharges.text);
      global.user.videoCallRate = int.tryParse(cVideoCharges.text);
      global.user.reportRate = int.tryParse(cReportCharges.text);
      global.user.expirenceInYear = int.tryParse(cExpirence.text);
      global.user.dailyContributionHours = int.tryParse(cContributionHours.text);
      global.user.hearAboutAstroGuru = cHearAboutAstroGuru.text;
      global.user.isWorkingOnAnotherPlatform = anyOnlinePlatform;
      global.user.otherPlatformName = cNameOfPlatform.text;
      global.user.otherPlatformMonthlyEarning = cMonthlyEarning.text;
      global.user.onboardYou = cOnBoardYou.text;
      global.user.suitableInterviewTime = cTimeForInterview.text;
      global.user.currentCity = cLiveCity.text;
      global.user.mainSourceOfBusiness = selectedSourceOfBusiness;
      global.user.highestQualification = selectedHighestQualification;
      global.user.degreeDiploma = selectedDegreeDiploma;
      global.user.collegeSchoolUniversity = cCollegeSchoolUniversity.text;
      global.user.learnAstrology = cLearnAstrology.text;
      global.user.instagramProfileLink = cInsta.text;
      global.user.facebookProfileLink = cFacebook.text;
      global.user.linkedInProfileLink = cLinkedIn.text;
      global.user.youtubeProfileLink = cYoutube.text;
      global.user.webSiteProfileLink = cWebSite.text;
      global.user.isAnyBodyRefer = referPerson;
      global.user.referedPersonName = cNameOfReferPerson.text;
      global.user.expectedMinimumEarning = int.tryParse(cExptectedMinimumEarning.text);
      global.user.expectedMaximumEarning = int.tryParse(cExpectedMaximumEarning.text);
      global.user.longBio = cLongBio.text;
      global.user.foreignCountryCount = selectedForeignCountryCount;
      global.user.currentlyWorkingJob = selectedCurrentlyWorkingJob;
      global.user.goodQualityOfAstrologer = cGoodQuality.text;
      global.user.biggestChallengeFaced = cBiggestChallenge.text;
      global.user.repeatedQuestion = cRepeatedQuestion.text;
      // Clear existing lists before adding to avoid duplicates on retries
      global.user.astrologerCategoryId = [];
      global.user.primarySkillId = [];
      global.user.allSkillId = [];
      global.user.languageId = [];

      for (var item in astroId) {
        if (item != null) global.user.astrologerCategoryId!.add(item);
      }
      for (var item in primaryId) {
        if (item != null) global.user.primarySkillId!.add(item);
      }
      for (var item in allId) {
        if (item != null) global.user.allSkillId!.add(item);
      }
      for (var item in lId) {
        if (item != null) global.user.languageId!.add(item);
      }

      global.user.week = [];
      if (week != null) {
        for (var wk in week!) {
          if (wk.timeAvailabilityList != null && wk.timeAvailabilityList!.isNotEmpty) {
            global.user.week!.add(Week(
                day: wk.day,
                timeAvailabilityList: wk.timeAvailabilityList));
          }
        }
        global.user.week!.removeWhere((element) => element.day == "");
      }

      final apiResult = await _apiHelper.signUp(global.user);
      global.hideLoader();
      if (apiResult.status == '200') {
        global.user = apiResult.recordList;
        Get.offAll(() => const SuccessRegistrationScreen()); // Use offAll for clean navigation
        global.showToast(message: "You have successfully registered!");
      } else if (apiResult.status == '400') {
        global.showToast(message: apiResult.message ?? "Registration failed due to invalid data.");
      } else {
        global.showToast(message: apiResult.message ?? "Something went wrong during registration. Please try again.");
      }
    } catch (err) {
      global.hideLoader();
      global.showToast(message: "An unexpected error occurred during signup: ${err.toString()}");
      global.printException("signup_controller.dart", "_signupAstrologer", err);
    }
  }

  // Check contact number exist or not
  Future<void> _checkContactExist(String phoneNumber, String countryCode) async {
    try {
      final bool result = await global.checkBody();
      if (!result) {
        global.showToast(message: "No internet connection. Please check your network.");
        return;
      }

      global.showOnlyLoaderDialog();
      final apiResult = await _apiHelper.checkExistContactNumber(phoneNumber);
      global.hideLoader();

      print("Status code from checkContactExist: ${apiResult.status}");
      print("API Response message: ${apiResult.message}"); // Added for more clarity in logs

      // Corrected logic:
      // If status is 200 AND the message explicitly says "Contact Number is Not Register",
      // then proceed with OTP sending and navigation.
      if (apiResult.status == "200" && apiResult.message == "Contact Number is Not Register") {
        // --- Contact number is NOT registered, proceed to send OTP ---
        signupOtpController = Get.put(SignupOtpController());
        signupOtpController.second = 60;
        signupOtpController.timer();

        await _sendOtpToPhone(phoneNumber, countryCode);

        // This navigation sends the user to the OTP screen where they will enter the OTP.
        Get.to(() => SignupOtpScreen(mobileNumber: phoneNumber));
      } else if (apiResult.status == "200" && apiResult.message == "Contact Number is Register") {
        // This condition handles if the API returns 200 but says the number IS registered
        global.showToast(message: "This contact number is already registered. Please login.");
      } else {
        // Handle any other status code or unexpected message
        global.showToast(message: apiResult.message ?? "Something went wrong while checking contact number.");
      }
      update();
    } catch (e) {
      global.hideLoader();
      print("Exception - SignupController.dart - _checkContactExist(): $e");
      global.showToast(message: "An error occurred while checking phone number. Please try again.");
    }
  }

  /// Generates a 6-digit random OTP.
  String _generateOtp() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  /// Sends an OTP to the given phone number via an SMS gateway.
  /// This method is similar to the one in LoginController, adapted for signup.
  Future<void> _sendOtpToPhone(String phoneNumber, String countryCode) async {
    final String onlyDigits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (onlyDigits.length != 10) {
      global.showToast(message: "Internal error: Invalid phone number format for OTP sending.");
      return;
    }

    _sentOtp = _generateOtp();
    final String message = "Your OTP for mobile application jyotishionline login is $_sentOtp jyotishi online";
    final String url =
        "http://sms.messageindia.in/v2/sendSMS?username=sameerji&message=$message&sendername=JYTSHI&smstype=TRANS&numbers=$onlyDigits&apikey=242d4043-4734-4ae8-acb6-bcbb5b855bcc&peid=1701175032658751812&templateid=1707175048832142304";
    try {
      _logOtpDebugInfo(countryCode, onlyDigits, _sentOtp!, message, url);

      global.showOnlyLoaderDialog(); // Show loader for SMS API call
      final http.Response response = await http.get(Uri.parse(url));
      global.hideLoader(); // Hide loader

      final dynamic body = jsonDecode(response.body);
      print('✅ SMS API Response Body: $body');
      if (response.statusCode == 200 && body is List && body.isNotEmpty && body[0]['status'] == 'success') {
        print('🎉 OTP sent successfully to $onlyDigits for signup');
        // The navigation to SignupOtpScreen is handled in _checkContactExist
      } else {
        print('❌ Failed to send OTP for signup - Status: ${body is List && body.isNotEmpty ? body[0]['status'] : 'Unknown'}');
        global.showToast(message: "Failed to send OTP. Please try again.");
        // Consider navigating back or showing a retry option if OTP send fails critically
      }
    } catch (e) {
      global.hideLoader();
      print('❗ Exception while sending OTP for signup: $e');
      global.showToast(message: "Network error while sending OTP. Please check your connection.");
    }
  }

  /// Public method to resend OTP for signup, called from SignupOtpScreen.
  Future<void> resendOtpForSignup(String phoneNumber, String countryCode) async {
    await _sendOtpToPhone(phoneNumber, countryCode);
  }

  /// Private method to verify the entered OTP against the stored sent OTP.
  bool verifyOtp(String inputOtp) {
    if (inputOtp == _sentOtp) {
      return true;
    } else {
      global.showToast(message: "Invalid OTP. Please try again.");
      return false;
    }
  }

  /// Public method to verify OTP from SignupOtpScreen and proceed with signup.
  Future<void> verifySignupOtp(String otp) async {
    if (verifyOtp(otp)) {
      // If OTP is valid, close the OTP screen and then advance the form step.
      Get.back(); // Dismiss the SignupOtpScreen
      print("OTP verified successfully. Advancing to the next form step (formIndex: 1).");
      onStepNext(); // This will increment `index` from 0 to 1, moving to Skill Details.
      // After onStepNext(), your UI should automatically update to show the next form section.
      // No need to call validateForm(1) here explicitly, as the UI transition
      // will handle showing the next step for user input.
    }
  }


  // Astrologer profile - These methods seem related to an astrologer's profile management,
  // not directly to initial signup. If they are part of the post-signup flow, keep them.
  // Otherwise, consider moving them to a separate controller (e.g., AstrologerProfileController).
  ScrollController walletHistoryScrollController = ScrollController();
  ScrollController callHistoryScrollController = ScrollController();
  ScrollController reportHistoryScrollController = ScrollController();
  ScrollController chatHistoryScrollController = ScrollController();
  int fetchRecord = 10;
  int startIndex = 0;
  bool isDataLoaded = false;
  bool isAllDataLoaded = false;
  bool isMoreDataAvailable = false;

  @override
  onInit() {
    super.onInit();
    // Removed: signupOtpController = Get.put(SignupOtpController()); // This was the cause of the stack overflow
    init();
    // Consider if this `init` is always needed on SignupController init, or specific to a view.
  }

  init() async {
    // This `init` seems to set up scroll listeners for astrologer profile.
    // If this controller is only for signup, these should likely be elsewhere.
    paginateTask();
  }

  void paginateTask() {
    walletHistoryScrollController.addListener(() async {
      if (walletHistoryScrollController.position.pixels ==
          walletHistoryScrollController.position.maxScrollExtent &&
          !isAllDataLoaded) {
        isMoreDataAvailable = true;
        print('scroll my following (wallet)');
        update();
        await astrologerProfileById(true);
      }
    });
    chatHistoryScrollController.addListener(() async {
      if (chatHistoryScrollController.position.pixels ==
          chatHistoryScrollController.position.maxScrollExtent &&
          !isAllDataLoaded) {
        isMoreDataAvailable = true;
        print('scroll my following (chat)');
        update();
        await astrologerProfileById(true);
      }
    });
    callHistoryScrollController.addListener(() async {
      if (callHistoryScrollController.position.pixels ==
          callHistoryScrollController.position.maxScrollExtent &&
          !isAllDataLoaded) {
        isMoreDataAvailable = true;
        print('scroll my following (call)');
        update();
        await astrologerProfileById(true);
      }
    });
    reportHistoryScrollController.addListener(() async {
      if (reportHistoryScrollController.position.pixels ==
          reportHistoryScrollController.position.maxScrollExtent &&
          !isAllDataLoaded) {
        isMoreDataAvailable = true;
        print('scroll my following (report)');
        update();
        await astrologerProfileById(true);
      }
    });
  }

  Future<void> astrologerProfileById(bool isLazyLoading) async {
    debugPrint('Calling astrologer profile (all)');
    try {
      startIndex = astrologerList.length; // Correct startIndex for lazy loading
      if (!isLazyLoading) {
        astrologerList.clear(); // Clear only if not lazy loading (i.e., fresh fetch)
        startIndex = 0;
        isDataLoaded = false;
        isAllDataLoaded = false;
      } else {
        if (isAllDataLoaded) return; // Prevent fetching if all data is already loaded
      }

      final bool hasNetwork = await global.checkBody();
      if (!hasNetwork) {
        global.showToast(message: "No internet connection to fetch profile data.");
        return;
      }

      global.showOnlyLoaderDialog();
      int id = global.user.id ?? 0; // Ensure global.user.id is available
      final apiResult = await _apiHelper.getAstrologerProfile(id, startIndex, fetchRecord);
      global.hideLoader();
      if (apiResult.status == "200") {
        if (apiResult.recordList != null) {
          astrologerList.addAll(apiResult.recordList!);
        }
        update();
        print("astrologerProfileById-> ${apiResult.recordList?.length} items fetched.");
        print('List length is ${astrologerList.length}');
        if (apiResult.recordList == null || apiResult.recordList!.length < fetchRecord) {
          isMoreDataAvailable = false;
          isAllDataLoaded = true;
        } else {
          isMoreDataAvailable = true; // More data might be available
        }
      } else {
        global.showToast(message: apiResult.message ?? "Failed to load astrologer profile.");
        isMoreDataAvailable = false;
      }
      isDataLoaded = true; // Mark data as loaded regardless of success/failure
      update();
    } catch (e) {
      global.hideLoader();
      print('Exception: astrologerProfileById(): $e');
      global.showToast(message: "Error loading astrologer profile: ${e.toString()}");
    }
  }

  // Delete astrologer account
  deleteAstrologer(int id) async {
    try {
      final bool hasNetwork = await global.checkBody();
      if (!hasNetwork) {
        global.showToast(message: "No internet connection to delete account.");
        return;
      }

      global.showOnlyLoaderDialog();
      final apiResult = await _apiHelper.astrologerDelete(id);
      global.hideLoader();
      if (apiResult.status == "200") {
        global.showToast(message: apiResult.message ?? "Account deleted successfully.");
        Get.back(); // Navigate back after deletion
      } else {
        global.showToast(message: apiResult.message ?? "Failed to delete account.");
      }
      update();
    } catch (e) {
      global.hideLoader();
      print('Exception: deleteAstrologer(): $e');
      global.showToast(message: "Error deleting account: ${e.toString()}");
    }
  }

  // Clear astrologer data (checkbox states for filters/selections)
  clearAstrologer() {
    try {
      // Astrologer category
      if (global.astrologerCategoryModelList != null) {
        for (var i = 0; i < global.astrologerCategoryModelList!.length; i++) {
          global.astrologerCategoryModelList![i].isCheck = false;
        }
      }
      // Primary skill
      if (global.skillModelList != null) {
        for (var i = 0; i < global.skillModelList!.length; i++) {
          global.skillModelList![i].isCheck = false;
        }
      }
      // All skill
      if (global.allSkillModelList != null) {
        for (var i = 0; i < global.allSkillModelList!.length; i++) {
          global.allSkillModelList![i].isCheck = false;
        }
      }
      // Language
      if (global.languageModelList != null) {
        for (var i = 0; i < global.languageModelList!.length; i++) {
          global.languageModelList![i].isCheck = false;
        }
      }
      update(); // Important to call update after modifying Rx lists/data
    } catch (e) {
      print("Exception - clearAstrologer(): $e");
    }
  }

  // Send reply
  Future<void> sendReply(int id, String reply) async {
    try {
      final bool hasNetwork = await global.checkBody();
      if (!hasNetwork) {
        global.showToast(message: "No internet connection to send reply.");
        return;
      }

      global.showOnlyLoaderDialog();
      final apiResult = await _apiHelper.astrologerReply(id, reply);
      global.hideLoader();
      if (apiResult.status == "200") {
        cReply.text = ''; // Clear the reply input
        global.showToast(message: apiResult.message ?? "Review reply sent successfully!");
        astrologerList.clear(); // Clear and re-fetch to update the list
        isAllDataLoaded = false;
        await astrologerProfileById(false); // Re-fetch all data
      } else {
        global.showToast(message: apiResult.message ?? "Failed to send review reply.");
      }
      update();
    } catch (e) {
      global.hideLoader();
      print('Exception: sendReply(): $e');
      global.showToast(message: "Error sending reply: ${e.toString()}");
    }
  }

  /// Prints debug information for OTP sending.
  void _logOtpDebugInfo(String countryCode, String phoneNumber, String otp, String message, String url) {
    print('📲 Sending OTP for signup to: $countryCode $phoneNumber');
    print('🔐 Generated OTP: $otp');
    print('📨 Message: $message');
    print('🌐 API URL: $url');
  }
}