import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:get/get.dart';

class PersonalDetailScreen extends StatelessWidget {
  const PersonalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
          height: 80,
          backgroundColor: COLORS().primaryColor,
          title: const Text("Personal Detail").tr(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                enabled: true,
                tileColor: Colors.white,
                leading: const Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                title: Text(
                  "Name",
                  style: Theme.of(context).primaryTextTheme.displaySmall,
                ).tr(),
                trailing: Text(
                  global.user.name != null && global.user.name != ''
                      ? '${global.user.name}'
                      : tr("Astologer name"),
                  style: Theme.of(context).primaryTextTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListTile(
                  enabled: true,
                  tileColor: Colors.white,
                  leading: const Icon(
                    Icons.email,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Email",
                    style: Theme.of(context).primaryTextTheme.displaySmall,
                  ).tr(),
                  trailing: SizedBox(
                    width: 190,
                    child: Text(
                      global.user.email != null && global.user.email != ''
                          ? '${global.user.email}'
                          : "astri@gmail.com",
                      style: Theme.of(context).primaryTextTheme.titleMedium,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListTile(
                  enabled: true,
                  tileColor: Colors.white,
                  leading: const Icon(
                    Icons.phone,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Mobile Number",
                    style: Theme.of(context).primaryTextTheme.displaySmall,
                  ).tr(),
                  trailing: SizedBox(
                    width: Get.width * 0.35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '+91 ',
                          style: Theme.of(context).primaryTextTheme.titleMedium,
                        ),
                        Text(
                          global.user.contactNo != ''
                              ? '${global.user.contactNo}'
                              : "35345345345",
                          style: Theme.of(context).primaryTextTheme.titleMedium,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
