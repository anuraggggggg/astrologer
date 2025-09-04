import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../constants/colorConst.dart';
import '../../../../widgets/app_bar_widget.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

class AssignmentDetailScreen extends StatelessWidget {
  const AssignmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
            height: 80,
            backgroundColor: COLORS().primaryColor,
            title: const Text("Assignment").tr()),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListTile(
                    enabled: true,
                    tileColor: Colors.white,
                    title: Text(
                      "Number of Foreign Country you Lived",
                      style: Theme.of(context).primaryTextTheme.displaySmall,
                    ).tr(),
                    trailing: Text(
                      global.user.foreignCountryCount != null &&
                              global.user.foreignCountryCount != ''
                          ? '${global.user.foreignCountryCount}'
                          : "3-5",
                      style: Theme.of(context).primaryTextTheme.titleMedium,
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: ExpansionTile(
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(
                      "Currently Working",
                      style: Theme.of(context).primaryTextTheme.displaySmall,
                    ).tr(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          global.user.currentlyWorkingJob != null &&
                                  global.user.currentlyWorkingJob != ''
                              ? '${global.user.currentlyWorkingJob}'
                              : tr(
                                  "No, I am working as a part-timer or freelancer"),
                          style: Theme.of(context).primaryTextTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: ExpansionTile(
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(
                      "Good Quality",
                      style: Theme.of(context).primaryTextTheme.displaySmall,
                    ).tr(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          global.user.goodQualityOfAstrologer != null &&
                                  global.user.goodQualityOfAstrologer != ''
                              ? '${global.user.goodQualityOfAstrologer}'
                              : tr(
                                  "Satisfied Customer with soluion and remedies"),
                          style: Theme.of(context).primaryTextTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: ExpansionTile(
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(
                      "Biggest challenge you faced",
                      style: Theme.of(context).primaryTextTheme.displaySmall,
                    ).tr(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          global.user.biggestChallengeFaced != null &&
                                  global.user.biggestChallengeFaced != ''
                              ? '${global.user.biggestChallengeFaced}'
                              : tr(
                                  "One of the biggest challenge i've overcome happended at my work"),
                          style: Theme.of(context).primaryTextTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: ExpansionTile(
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(
                      "A customer asking the same question repeatedly: What will you do",
                      style: Theme.of(context).primaryTextTheme.displaySmall,
                    ).tr(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          global.user.repeatedQuestion != null &&
                                  global.user.repeatedQuestion != ''
                              ? '${global.user.repeatedQuestion}'
                              : tr(
                                  "Give more information and more clarity to Customer."),
                          style: Theme.of(context).primaryTextTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
