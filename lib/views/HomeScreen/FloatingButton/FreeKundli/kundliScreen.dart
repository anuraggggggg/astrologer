// ignore_for_file: file_names

import 'dart:math';

import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/Tabs/Pdf_Screen.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/createNewKundli.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/editKundliScreen.dart';
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

class KundaliScreen extends StatefulWidget {
  const KundaliScreen({super.key});

  @override
  State<KundaliScreen> createState() => _KundaliScreenState();
}

class _KundaliScreenState extends State<KundaliScreen> {
  final KundliController kundliController = Get.find<KundliController>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: MyCustomAppBar(
        height: 80,
        title: const Text("Kundli").tr(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //SEARCH LAYOUT
              GetBuilder<KundliController>(builder: (kundliController) {
                return SizedBox(
                  height: 38,
                  child: TextField(
                    onChanged: (value) {
                      kundliController.searchKundli(value);
                    },
                    cursorColor: const Color(0xFF757575),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
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
                        hintText: tr('Search kundli by name'),
                        hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ),
                );
              }),

              GetBuilder<KundliController>(builder: (kundliController) {
                return kundliController.searchKundliList.isEmpty
                    ? Column(
                        children: [
                          Container(
                              height: 500,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              alignment: Alignment.center,
                              child: const Text(
                                'Result not found',
                                style: TextStyle(fontSize: 18),
                              ).tr()),
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: kundliController.searchKundliList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () async {
                              int? userid =
                                  kundliController.searchKundliList[index].id;
                              debugPrint('kundali userid $userid');
                              global.showOnlyLoaderDialog();
                              await kundliController.getKundliDetailsPdf(
                                  id: userid!);
                              global.hideLoader();
                              String? pdfUrl = kundliController
                                  .kundlipdfModel!.recordList.response;
                              debugPrint('url is -> $pdfUrl');

                              Get.to(() => PDFScreen(url: pdfUrl));
                              debugPrint('clicked from this');
                              // global.showOnlyLoaderDialog();

                              // debugPrint(
                              //     "selected items -> ${kundliController.searchKundliList[index].toString()}");
                              // await kundliController.kundliAddNew(
                              //     kundliController.searchKundliList[index]);
                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.primaries[Random()
                                      .nextInt(Colors.primaries.length)],
                                  child: Text(
                                    kundliController
                                        .searchKundliList[index].name[0],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  kundliController.searchKundliList[index].name,
                                  style: Get.textTheme.titleMedium!.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${DateFormat("dd MMM yyyy").format(kundliController.searchKundliList[index].birthDate)},${kundliController.searchKundliList[index].birthTime}',
                                        style: Get.textTheme.titleMedium!
                                            .copyWith(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                    Text(
                                      kundliController
                                          .searchKundliList[index].birthPlace,
                                      style: Get.textTheme.titleMedium!
                                          .copyWith(
                                              fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                //EDIT KUNDALI
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        await kundliController
                                            .getKundliListById(index);
                                        Get.to(() => EditKundliScreen(
                                            id: kundliController
                                                .searchKundliList[index].id!));
                                      },
                                      child: const CircleAvatar(
                                        backgroundColor:
                                            Color.fromARGB(255, 235, 231, 231),
                                        radius: 12,
                                        child: Icon(Icons.edit,
                                            size: 14, color: Colors.black),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.dialog(
                                          AlertDialog(
                                            title: Text(
                                              "Are you sure you want to permanently delete this kundli?",
                                              style: Get.textTheme.bodyMedium,
                                            ).tr(),
                                            content: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Get.back();
                                                  },
                                                  child: Text(
                                                    'CANCEL',
                                                    style: TextStyle(
                                                        color: Get.theme
                                                            .primaryColor),
                                                  ).tr(),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    global
                                                        .showOnlyLoaderDialog();
                                                    await kundliController
                                                        .deleteKundli(
                                                            kundliController
                                                                .searchKundliList[
                                                                    index]
                                                                .id!);
                                                    await kundliController
                                                        .getKundliList();
                                                    Get.back();
                                                    global.hideLoader();
                                                  },
                                                  child: Text('YES',
                                                          style: TextStyle(
                                                              color: Get.theme
                                                                  .primaryColor))
                                                      .tr(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: const CircleAvatar(
                                        backgroundColor:
                                            Color.fromARGB(255, 235, 231, 231),
                                        radius: 12,
                                        child: Icon(Icons.delete,
                                            size: 14, color: Colors.red),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
              })
            ],
          ),
        ),
      ),
      bottomSheet: SizedBox(
        height: 60,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(const EdgeInsets.all(10)),
              backgroundColor: WidgetStateProperty.all(Get.theme.primaryColor),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            onPressed: () {
              KundliController kundliController = Get.find<KundliController>();
              kundliController.userName = "";
              kundliController.userNameController.clear();
              kundliController.birthKundliPlaceController.clear();
              kundliController.selectedGender = null;
              kundliController.selectedDate = null;
              kundliController.selectedTime = null;
              kundliController.isDisable = true;
              kundliController.initialIndex = 0;
              kundliController.updateIcon(0);
              kundliController.update();
              kundliController.pdfPrice().then((value) {
                if (value == 1) {
                  Get.to(() => const CreateNewKundki());
                } else {
                  global.showToast(message: "Something went wrong");
                }
              });
            },
            child: Text(
              'Create New Kundli',
              textAlign: TextAlign.center,
              style: Get.theme.primaryTextTheme.titleMedium!
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
            ).tr(),
          ),
        ),
      ),
    ));
  }
}
