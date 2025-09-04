// ignore_for_file: must_be_immutable

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/AssistantController/add_assistant_controller.dart';
import 'package:astrowaypartner/models/astrologerAssistant_model.dart';
import 'package:astrowaypartner/views/HomeScreen/Assistant/assistant_screen.dart';
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/config.dart';

class AssistantDetailScreen extends StatelessWidget {
  final AstrologerAssistantModel? astrologerAssistant;
  AssistantDetailScreen({super.key, this.astrologerAssistant});
  AddAssistantController assistantController =
      Get.find<AddAssistantController>();

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Get.to(() => AssistantScreen());
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: MyCustomAppBar(
            height: 80,
            backgroundColor: COLORS().primaryColor,
            title: const Text('Assistant Details').tr(),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: astrologerAssistant!.profile != null
                        ? Container(
                            height: Get.height * 0.12,
                            width: Get.height * 0.12,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: COLORS().primaryColor,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    "$imgBaseurl${astrologerAssistant!.profile}"),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: COLORS().primaryColor,
                            radius: 50,
                            backgroundImage: const AssetImage(
                              "assets/images/no_customer_image.png",
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ListTile(
                      enabled: true,
                      tileColor: Colors.white,
                      title: Text(
                        "Name",
                        style: Theme.of(context).primaryTextTheme.displaySmall,
                      ).tr(),
                      trailing: Text(
                        '${astrologerAssistant!.name}',
                        style: Theme.of(context).primaryTextTheme.titleMedium,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ListTile(
                      enabled: true,
                      tileColor: Colors.white,
                      title: Text(
                        "Mobile Number",
                        style: Theme.of(context).primaryTextTheme.displaySmall,
                      ).tr(),
                      trailing: Text(
                        '${astrologerAssistant!.contactNo}',
                        style: Theme.of(context).primaryTextTheme.titleMedium,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ListTile(
                      enabled: true,
                      tileColor: Colors.white,
                      title: Text(
                        "Email",
                        style: Theme.of(context).primaryTextTheme.displaySmall,
                      ).tr(),
                      trailing: Text(
                        '${astrologerAssistant!.email}',
                        style: Theme.of(context).primaryTextTheme.titleMedium,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ListTile(
                      enabled: true,
                      tileColor: Colors.white,
                      title: Text(
                        "Gender",
                        style: Theme.of(context).primaryTextTheme.displaySmall,
                      ).tr(),
                      trailing: Text(
                        '${astrologerAssistant!.gender}',
                        style: Theme.of(context).primaryTextTheme.titleMedium,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ListTile(
                      enabled: true,
                      tileColor: Colors.white,
                      title: Text(
                        "Date of Birth",
                        style: Theme.of(context).primaryTextTheme.displaySmall,
                      ).tr(),
                      trailing: Text(
                        DateFormat('dd-MM-yyyy').format(DateTime.parse(
                            astrologerAssistant!.birthdate!.toString())),
                        style: Theme.of(context).primaryTextTheme.titleMedium,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ListTile(
                      enabled: true,
                      tileColor: Colors.white,
                      title: Text(
                        "Primary Skills",
                        style: Theme.of(context).primaryTextTheme.displaySmall,
                      ).tr(),
                      trailing: Text(
                        astrologerAssistant!.assistantPrimarySkillId!
                            .map((e) => e.name)
                            .toList()
                            .toString()
                            .replaceAll('[', '')
                            .replaceAll(']', ''),
                        style: Theme.of(context).primaryTextTheme.titleMedium,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ListTile(
                      enabled: true,
                      tileColor: Colors.white,
                      title: Text(
                        "All Skills",
                        style: Theme.of(context).primaryTextTheme.displaySmall,
                      ).tr(),
                      trailing: Text(
                        astrologerAssistant!.assistantAllSkillId!
                            .map((e) => e.name)
                            .toList()
                            .toString()
                            .replaceAll('[', '')
                            .replaceAll(']', ''),
                        style: Theme.of(context).primaryTextTheme.titleMedium,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ListTile(
                      enabled: true,
                      tileColor: Colors.white,
                      title: Text(
                        "Language",
                        style: Theme.of(context).primaryTextTheme.displaySmall,
                      ).tr(),
                      trailing: Text(
                        astrologerAssistant!.assistantLanguageId!
                            .map((e) => e.name)
                            .toList()
                            .toString()
                            .replaceAll('[', '')
                            .replaceAll(']', ''),
                        style: Theme.of(context).primaryTextTheme.titleMedium,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ListTile(
                      enabled: true,
                      tileColor: Colors.white,
                      title: Text(
                        "Expirence In Years",
                        style: Theme.of(context).primaryTextTheme.displaySmall,
                      ).tr(),
                      trailing: Text(
                        '${astrologerAssistant!.experienceInYears}',
                        style: Theme.of(context).primaryTextTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
