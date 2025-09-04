// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:astrowaypartner/controllers/kundli_matchig_controller.dart';
import 'package:astrowaypartner/controllers/search_place_controller.dart';
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class PlaceOfBirthSearchScreen extends StatelessWidget {
  final int? flagId;
  PlaceOfBirthSearchScreen({super.key, this.flagId});

  KundliController kundliController = Get.find<KundliController>();

  KundliMatchingController kundliMatchingController =
      Get.find<KundliMatchingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: MyCustomAppBar(
          height: 80,
          title: const Text("Place of Birth").tr(),
          backgroundColor: COLORS().primaryColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            GetBuilder<SearchPlaceController>(builder: (searchPlaceController) {
          return Column(
            children: [
              SizedBox(
                  height: 40,
                  child: TextField(
                    onChanged: (value) async {
                      await searchPlaceController.autoCompleteSearch(value);
                    },
                    controller: searchPlaceController.searchController,
                    decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Get.theme.iconTheme.color,
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        hintText: tr('Search City'),
                        hintStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  )),
              Expanded(
                child: ListView.builder(
                  itemCount: searchPlaceController.predictions?.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(searchPlaceController
                          .predictions![index].primaryText),
                      onTap: () async {
                        late List<Location> location;

                        try {
                          location = await locationFromAddress(
                              searchPlaceController
                                  .predictions![index].primaryText
                                  .toString());
                          kundliController.lat = location[0].latitude;
                          kundliController.long = location[0].longitude;
                        } on Exception catch (e) {
                          log('error on lat long is $e');
                        }

                        if (flagId == 2) //girls lat
                        {
                          try {
                            kundliMatchingController.girl_lat =
                                location[0].latitude;
                            kundliMatchingController.girl_long =
                                location[0].longitude;
                            log('girl lat -> ${location[0].latitude} ');
                            log('girl long-> ${location[0].longitude}');
                            kundliMatchingController.update();
                          } on Exception catch (e) {
                            log('error on lat long girl is $e');
                          }
                        } else if (flagId == 1) //boy lat
                        {
                          try {
                            kundliMatchingController.boy_lat =
                                location[0].latitude;
                            kundliMatchingController.boylong =
                                location[0].longitude;
                            log('boy lat -> ${location[0].latitude} ');
                            log('boy long-> ${location[0].longitude}');
                            kundliMatchingController.update();
                          } on Exception catch (e) {
                            log('error on lat long boy is $e');
                          }
                        }

                        kundliMatchingController.lat = location[0].latitude;
                        kundliMatchingController.long = location[0].longitude;

                        await kundliController.getGeoCodingLatLong(
                            flagId: flagId,
                            kundliMatchingController: kundliMatchingController,
                            latitude: location[0].latitude,
                            longitude: location[0].latitude);
                        searchPlaceController.searchController.text =
                            searchPlaceController
                                .predictions![index].primaryText;
                        searchPlaceController.update();
                        kundliController.birthKundliPlaceController.text =
                            searchPlaceController
                                .predictions![index].primaryText;
                        kundliController.update();
                        kundliController.editBirthPlaceController.text =
                            searchPlaceController
                                .predictions![index].primaryText;
                        kundliController.update();
                        if (flagId == 1) {
                          kundliMatchingController.cBoysBirthPlace.text =
                              searchPlaceController
                                  .predictions![index].primaryText;
                          kundliMatchingController.update();
                        }
                        if (flagId == 2) {
                          kundliMatchingController.cGirlBirthPlace.text =
                              searchPlaceController
                                  .predictions![index].primaryText;
                          kundliMatchingController.update();
                        }
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
