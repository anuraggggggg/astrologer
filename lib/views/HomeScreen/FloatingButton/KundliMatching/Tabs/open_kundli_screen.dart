import 'dart:math';

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/constants/messageConst.dart';
import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:astrowaypartner/controllers/kundli_matchig_controller.dart';
import 'package:astrowaypartner/widgets/common_padding_2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

class OpenKundliScreen extends StatelessWidget {
  OpenKundliScreen({super.key});
  final KundliMatchingController kundliMatchingController =
      Get.find<KundliMatchingController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CommonPadding2(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GetBuilder<KundliController>(builder: (kundliController) {
              return SizedBox(
                height: 40,
                child: TextFormField(
                  onChanged: (value) {
                    kundliController.searchKundli(value);
                  },
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintStyle:
                        const TextStyle(fontSize: 16, color: Colors.grey),
                    helperStyle: TextStyle(color: COLORS().primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: COLORS().primaryColor),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    hintText: tr("Search kundli by name"),
                    prefixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              );
            }),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                "Recently Opened",
                style: Theme.of(context).primaryTextTheme.titleMedium,
              ).tr(),
            ),
            Expanded(
              child: GetBuilder<KundliController>(builder: (kundliController) {
                return ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemCount: kundliController.searchKundliList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        kundliMatchingController.openKundliData(
                            kundliController.searchKundliList, index);
                        kundliMatchingController.onHomeTabBarIndexChanged(1);
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.primaries[
                              Random().nextInt(Colors.primaries.length)],
                          radius: 20,
                          child: Text(
                            kundliController.searchKundliList[index].name[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kundliController.searchKundliList[index].name,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .displaySmall,
                            ),
                            Text(
                              "${DateFormat("dd MMM yyyy").format(kundliController.searchKundliList[index].birthDate)},${kundliController.searchKundliList[index].birthTime}",
                              style:
                                  Theme.of(context).primaryTextTheme.titleSmall,
                            ),
                            Text(
                              kundliController
                                  .searchKundliList[index].birthPlace,
                              style:
                                  Theme.of(context).primaryTextTheme.titleSmall,
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                title: const Text(
                                        "Are you sure you want to permanently delete this kundli?")
                                    .tr(),
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: const Text(MessageConstants.CANCEL)
                                          .tr(),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        global.showOnlyLoaderDialog();
                                        await kundliController.deleteKundli(
                                            kundliController
                                                .searchKundliList[index].id!);
                                        await kundliController.getKundliList();
                                        Get.back();
                                        global.hideLoader();
                                      },
                                      child:
                                          const Text(MessageConstants.YES).tr(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
