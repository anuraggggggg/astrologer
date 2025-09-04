// // ignore_for_file: avoid_print
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:get/get.dart';

import 'package:astrowaypartner/utils/global.dart' as global;

class SearchPlaceController extends GetxController {
  FlutterGooglePlacesSdk? placesSdk;
  double? latitude;
  double? longitude;
  List<AutocompletePrediction>? predictions = [];
  final searchController = TextEditingController();

  @override
  void onInit() {
    String apiKey =
        global.getSystemFlagValue(global.systemFlagNameList.googlemapKey);
    log('google map key : $apiKey');

    placesSdk = FlutterGooglePlacesSdk(apiKey);
    super.onInit();
  }

  autoCompleteSearch(String? value) async {
    if (value!.isNotEmpty) {
      try {
        final result = await placesSdk!.findAutocompletePredictions(
          value,
          newSessionToken: false,
        );

        log('searched place : ${result.predictions}');
        predictions = result.predictions;

        update();
      } catch (e) {
        debugPrint('$e');
      }
    } else {
      predictions = [];
      update();
    }
  }
}
