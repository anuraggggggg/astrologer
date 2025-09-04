// ignore_for_file: file_names

import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:astrowaypartner/models/kundliModel.dart';
import 'package:astrowaypartner/widgets/FreeKundliWidget/container_list_tile_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BasicKundliScreen extends StatelessWidget {
  final KundliModel? usreDetails;
  // ignore: prefer_const_constructors_in_immutables
  BasicKundliScreen({super.key, this.usreDetails});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder<KundliController>(builder: (kundliController) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text(
                  'Basic Details',
                  style: Get.textTheme.bodyLarge,
                ).tr(),
              ),
              const SizedBox(height: 15),
              Container(
                  padding: const EdgeInsets.only(left: 1.5, right: 1.5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: kundliController.kundliBasicDetail != null
                      ? Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 235, 231, 198)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: const Text('Name').tr(),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text('${usreDetails?.name}'),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: const Text('Date').tr(),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      // ignore: unnecessary_string_interpolations
                                      "${DateFormat("dd MMMM yyyy").format(usreDetails!.birthDate)}",
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 235, 231, 198)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: const Text('Time').tr(),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      // ignore: unnecessary_string_interpolations
                                      "${usreDetails!.birthTime}",
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: const Text('Place').tr(),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(usreDetails!.birthPlace).tr(),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 235, 231, 198)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: const Text('Latitude').tr(),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                        '${kundliController.kundliBasicDetail!.lat}'),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: const Text('Longitude').tr(),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                        '${kundliController.kundliBasicDetail!.lon}'),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 235, 231, 198)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: const Text('Timezone').tr(),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                        '${kundliController.kundliBasicDetail!.tzone}'),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: const Text('Sunrise').tr(),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                        '${kundliController.kundliBasicDetail!.sunrise}'),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 235, 231, 198)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: const Text('Sunset').tr(),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                        '${kundliController.kundliBasicDetail!.sunset}'),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: const Text('Ayanamsha').tr(),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                        '${kundliController.kundliBasicDetail!.ayanamsha}'),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      : const SizedBox()),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Maglik Analysis',
                style: Get.textTheme.bodyLarge,
              ).tr(),
              const SizedBox(
                height: 10,
              ),
              ContainerListTileWidget(
                color: Colors.green,
                title: '${usreDetails?.name}',
                doshText: 'NO',
                subTitle: '',
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Panchang Details',
                style: Get.textTheme.bodyLarge,
              ).tr(),
              const SizedBox(
                height: 15,
              ),
              Container(
                  padding: const EdgeInsets.only(left: 1.5, right: 1.5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 231, 198)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Tithi').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliBasicPanchangDetail!.tithi}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Karan').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliBasicPanchangDetail!.karan}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 231, 198)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Yog').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliBasicPanchangDetail!.yog}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Nakshtra').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliBasicPanchangDetail!.nakshatra}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 231, 198)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Sunrise').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliBasicPanchangDetail!.sunrise}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Sunset').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliBasicPanchangDetail!.sunset}'),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Avakhada Details',
                style: Get.textTheme.bodyLarge,
              ).tr(),
              const SizedBox(
                height: 15,
              ),
              Container(
                  padding: const EdgeInsets.only(left: 1.5, right: 1.5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 231, 198)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Varna').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliAvakhadaDetail!.varna}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Vashya').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                "${kundliController.kundliAvakhadaDetail!.vashya}",
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 231, 198)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Yoni').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                "${kundliController.kundliAvakhadaDetail!.yoni}",
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Gan').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliAvakhadaDetail!.gan}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 231, 198)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Nadi').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliAvakhadaDetail!.nadi}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Sign').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliAvakhadaDetail!.sign}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 231, 198)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Sign Lord').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliAvakhadaDetail!.signLord}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: const Text('Nakshatra-Charan').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliAvakhadaDetail!.naksahtra}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 231, 198)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Yog').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliAvakhadaDetail!.yog}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Karan').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliAvakhadaDetail!.karan}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 231, 198)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Tithi').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliAvakhadaDetail!.tithi}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration:
                            const BoxDecoration(color: Colors.transparent),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Yunja').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliAvakhadaDetail!.yunja}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 231, 198)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Tatva').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliAvakhadaDetail!.tatva}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration:
                            const BoxDecoration(color: Colors.transparent),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: const Text('Name albhabet').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliAvakhadaDetail!.nameAlphabet}'),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 231, 198)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 90,
                              child: const Text('Paya').tr(),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                  '${kundliController.kundliAvakhadaDetail!.paya}'),
                            )
                          ],
                        ),
                      )
                    ],
                  )),
            ],
          ),
        );
      }),
    );
  }
}
