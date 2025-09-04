// ignore_for_file: file_names

import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../../../../controllers/free_kundli_controller.dart';
import '../../../../utils/config.dart';

// ignore: must_be_immutable
class KundliDetailsScreen extends StatefulWidget {
  String pdfLink;
  KundliDetailsScreen({super.key, required this.pdfLink});

  @override
  State<KundliDetailsScreen> createState() => _KundliDetailsScreenState();
}

class _KundliDetailsScreenState extends State<KundliDetailsScreen> {
  final kundliController = Get.find<KundliController>();

  @override
  Widget build(BuildContext context) {
    log('pdf link is ${"$pdfBaseurl/${widget.pdfLink}"}');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:
            Get.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
        title: Text(
          'Kundli',
          style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
              fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white),
        ).tr(),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
              kIsWeb
                  ? Icons.arrow_back
                  : Platform.isIOS
                      ? Icons.arrow_back_ios
                      : Icons.arrow_back,
              color: Colors.white //Get.theme.iconTheme.color,
              ),
        ),
      ),
      body: SizedBox(
        child: SfPdfViewer.network(
          "$pdfBaseurl/${widget.pdfLink}",
          onDocumentLoadFailed: (e) {
             global.showToast(message: "PDF Failed to Load");
            Get.back();
          },
          onDocumentLoaded: (e) {},
        ),
      ),
    );
  }
}

// import 'package:astrowaypartner/constants/colorConst.dart';
// import 'package:astrowaypartner/constants/imageConst.dart';
// import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
// import 'package:astrowaypartner/models/kundliModel.dart';
// import 'package:astrowaypartner/views/BaseRoute/baseRoute.dart';
// import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/Tabs/ashtakvargaScreen.dart';
// import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/Tabs/basicKundliScreen.dart';
// import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/Tabs/chartsScreen.dart';
// import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/Tabs/kpScreen.dart';
// import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/Tabs/kundliDashaScreen.dart';
// import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/Tabs/kundliReportScreen.dart';
// import 'package:astrowaypartner/widgets/app_bar_widget.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:astrowaypartner/utils/global.dart' as global;

// class KundliDetailsScreen extends BaseRoute {
//   final KundliModel? usreDetails;
//   KundliDetailsScreen({super.key, super.a, super.o, this.usreDetails})
//       : super(r: 'KundliDetailsScreen');
//   final KundliController kundliController = Get.find<KundliController>();
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         appBar: MyCustomAppBar(
//           height: 80,
//           title: const Text("Kundli").tr(),
//           backgroundColor: COLORS().primaryColor,
//           actions: [
//             GestureDetector(
//               onTap: () async {
//                 // Get.find<SplashController>().createAstrologerShareLink();
//                 global.showOnlyLoaderDialog();
//                 await kundliController.shareKundli(usreDetails!);
//                 global.hideLoader();
//               },
//               child: Container(
//                 margin: const EdgeInsets.only(
//                     top: 12, bottom: 12, right: 12, left: 12),
//                 padding: const EdgeInsets.all(5),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.black),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Row(
//                   children: [
//                     Text('Share',
//                             style:
//                                 Theme.of(context).primaryTextTheme.displaySmall)
//                         .tr(),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 6.0),
//                       child: Image.asset(
//                         IMAGECONST.whatsapp,
//                         scale: 7,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//         body: GetBuilder<KundliController>(builder: (c) {
//           return Padding(
//             padding: const EdgeInsets.fromLTRB(8, 15, 8, 0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   height: 40,
//                   width: MediaQuery.of(context).size.width,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       InkWell(
//                         onTap: () async {
//                           DateTime dateBasic = usreDetails!.birthDate;
//                           int formattedYear =
//                               int.parse(DateFormat('yyyy').format(dateBasic));
//                           int formattedDay =
//                               int.parse(DateFormat('dd').format(dateBasic));
//                           int formattedMonth =
//                               int.parse(DateFormat('MM').format(dateBasic));
//                           int formattedHour =
//                               int.parse(DateFormat('HH').format(dateBasic));
//                           int formattedMint =
//                               int.parse(DateFormat('mm').format(dateBasic));

//                           global.showOnlyLoaderDialog();
//                           await kundliController.getBasicDetail(
//                               day: formattedDay,
//                               hour: formattedHour,
//                               min: formattedMint,
//                               month: formattedMonth,
//                               year: formattedYear,
//                               lat: usreDetails!.latitude,
//                               lon: usreDetails!.longitude,
//                               tzone: usreDetails!.timezone);
//                           await kundliController.getBasicPanchangDetail(
//                               day: formattedDay,
//                               hour: formattedHour,
//                               min: formattedMint,
//                               month: formattedMonth,
//                               year: formattedYear,
//                               lat: usreDetails!.latitude,
//                               lon: usreDetails!.longitude,
//                               tzone: usreDetails!.timezone);
//                           await kundliController.getBasicAvakhadaDetail(
//                               day: formattedDay,
//                               hour: formattedHour,
//                               min: formattedMint,
//                               month: formattedMonth,
//                               year: formattedYear,
//                               lat: usreDetails!.latitude,
//                               lon: usreDetails!.longitude,
//                               tzone: usreDetails!.timezone);
//                           await kundliController.getSadesatiDetail(
//                               day: formattedDay,
//                               hour: formattedHour,
//                               min: formattedMint,
//                               month: formattedMonth,
//                               year: formattedYear,
//                               lat: usreDetails!.latitude,
//                               lon: usreDetails!.longitude,
//                               tzone: usreDetails!.timezone);
//                           await kundliController.getKalsarpaDetail(
//                               day: formattedDay,
//                               hour: formattedHour,
//                               min: formattedMint,
//                               month: formattedMonth,
//                               year: formattedYear,
//                               lat: usreDetails!.latitude,
//                               lon: usreDetails!.longitude,
//                               tzone: usreDetails!.timezone);
//                           await kundliController.getGemstoneDetail(
//                               day: formattedDay,
//                               hour: formattedHour,
//                               min: formattedMint,
//                               month: formattedMonth,
//                               year: formattedYear,
//                               lat: usreDetails!.latitude,
//                               lon: usreDetails!.longitude,
//                               tzone: usreDetails!.timezone);
//                           await kundliController.getChartPlanetsDetail(
//                               day: formattedDay,
//                               hour: formattedHour,
//                               min: formattedMint,
//                               month: formattedMonth,
//                               year: formattedYear,
//                               lat: usreDetails!.latitude,
//                               lon: usreDetails!.longitude,
//                               tzone: usreDetails!.timezone);
//                           await kundliController.getVimshattariDetail(
//                               day: formattedDay,
//                               hour: formattedHour,
//                               min: formattedMint,
//                               month: formattedMonth,
//                               year: formattedYear,
//                               lat: usreDetails!.latitude,
//                               lon: usreDetails!.longitude,
//                               tzone: usreDetails!.timezone);
//                           await kundliController.getReportDescDetail(
//                               day: formattedDay,
//                               hour: formattedHour,
//                               min: formattedMint,
//                               month: formattedMonth,
//                               year: formattedYear,
//                               lat: usreDetails!.latitude,
//                               lon: usreDetails!.longitude,
//                               tzone: usreDetails!.timezone);
//                           kundliController.update();
//                           global.hideLoader();
//                           kundliController.changeTapIndex(0);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: kundliController.kundliTabInitialIndex == 0
//                                 ? Get.theme.primaryColor
//                                 : Colors.transparent,
//                             borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(8.0),
//                                 bottomLeft: Radius.circular(8.0)),
//                           ),
//                           child: Text('Basic',
//                                   textAlign: TextAlign.center,
//                                   style: Get.textTheme.titleMedium!.copyWith(
//                                       fontSize: 12, color: Colors.black))
//                               .tr(),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () async {
//                           DateTime dateBasic = usreDetails!.birthDate;
//                           int formattedYear =
//                               int.parse(DateFormat('yyyy').format(dateBasic));
//                           int formattedDay =
//                               int.parse(DateFormat('dd').format(dateBasic));
//                           int formattedMonth =
//                               int.parse(DateFormat('MM').format(dateBasic));
//                           int formattedHour =
//                               int.parse(DateFormat('HH').format(dateBasic));
//                           int formattedMint =
//                               int.parse(DateFormat('mm').format(dateBasic));

//                           global.showOnlyLoaderDialog();
//                           await kundliController.getChartPlanetsDetail(
//                               day: formattedDay,
//                               hour: formattedHour,
//                               min: formattedMint,
//                               month: formattedMonth,
//                               year: formattedYear,
//                               lat: usreDetails!.latitude,
//                               lon: usreDetails!.longitude,
//                               tzone: usreDetails!.timezone);
//                           kundliController.update();
//                           global.hideLoader();
//                           kundliController.changeTapIndex(1);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: kundliController.kundliTabInitialIndex == 1
//                                 ? Get.theme.primaryColor
//                                 : Colors.transparent,
//                             border: const Border(
//                                 right: BorderSide(color: Colors.grey),
//                                 left: BorderSide(color: Colors.grey)),
//                           ),
//                           child: Text('Charts',
//                                   textAlign: TextAlign.center,
//                                   style: Get.textTheme.titleMedium!.copyWith(
//                                       fontSize: 12, color: Colors.black))
//                               .tr(),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () {
//                           kundliController.changeTapIndex(2);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: kundliController.kundliTabInitialIndex == 2
//                                 ? Get.theme.primaryColor
//                                 : Colors.transparent,
//                             border: const Border(
//                                 right: BorderSide(color: Colors.grey)),
//                           ),
//                           child: Text(
//                             'KP',
//                             textAlign: TextAlign.center,
//                             style: Get.textTheme.titleMedium!
//                                 .copyWith(fontSize: 12, color: Colors.black),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 1,
//                         child: InkWell(
//                           onTap: () {
//                             kundliController.changeTapIndex(3);
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: kundliController.kundliTabInitialIndex == 3
//                                   ? Get.theme.primaryColor
//                                   : Colors.transparent,
//                               border: const Border(
//                                   right: BorderSide(color: Colors.grey)),
//                             ),
//                             child: Text('Ashtakvarga',
//                                     textAlign: TextAlign.center,
//                                     style: Get.textTheme.titleMedium!.copyWith(
//                                         fontSize: 12, color: Colors.black))
//                                 .tr(),
//                           ),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () {
//                           kundliController.changeTapIndex(4);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: kundliController.kundliTabInitialIndex == 4
//                                 ? Get.theme.primaryColor
//                                 : Colors.transparent,
//                             border: const Border(
//                                 right: BorderSide(color: Colors.grey)),
//                           ),
//                           child: Text(
//                             'Dasha',
//                             textAlign: TextAlign.center,
//                             style: Get.textTheme.titleMedium!
//                                 .copyWith(fontSize: 12, color: Colors.black),
//                           ).tr(),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () async {
//                           DateTime dateBasic = usreDetails!.birthDate;
//                           int formattedYear =
//                               int.parse(DateFormat('yyyy').format(dateBasic));
//                           int formattedDay =
//                               int.parse(DateFormat('dd').format(dateBasic));
//                           int formattedMonth =
//                               int.parse(DateFormat('MM').format(dateBasic));
//                           int formattedHour =
//                               int.parse(DateFormat('HH').format(dateBasic));
//                           int formattedMint =
//                               int.parse(DateFormat('mm').format(dateBasic));
//                           global.showOnlyLoaderDialog();
//                           await kundliController.getSadesatiDetail(
//                               day: formattedDay,
//                               hour: formattedHour,
//                               min: formattedMint,
//                               month: formattedMonth,
//                               year: formattedYear,
//                               lat: usreDetails!.latitude,
//                               lon: usreDetails!.longitude,
//                               tzone: usreDetails!.timezone);
//                           await kundliController.getKalsarpaDetail(
//                               day: formattedDay,
//                               hour: formattedHour,
//                               min: formattedMint,
//                               month: formattedMonth,
//                               year: formattedYear,
//                               lat: usreDetails!.latitude,
//                               lon: usreDetails!.longitude,
//                               tzone: usreDetails!.timezone);
//                           await kundliController.getGemstoneDetail(
//                               day: formattedDay,
//                               hour: formattedHour,
//                               min: formattedMint,
//                               month: formattedMonth,
//                               year: formattedYear,
//                               lat: usreDetails!.latitude,
//                               lon: usreDetails!.longitude,
//                               tzone: usreDetails!.timezone);
//                           kundliController.update();
//                           global.hideLoader();
//                           kundliController.changeTapIndex(5);
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: kundliController.kundliTabInitialIndex == 5
//                                 ? Get.theme.primaryColor
//                                 : Colors.transparent,
//                             borderRadius: const BorderRadius.only(
//                                 topRight: Radius.circular(8.0),
//                                 bottomRight: Radius.circular(8.0)),
//                           ),
//                           child: Text('Report',
//                                   textAlign: TextAlign.center,
//                                   style: Get.textTheme.titleMedium!.copyWith(
//                                       fontSize: 12, color: Colors.black))
//                               .tr(),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 kundliController.kundliTabInitialIndex == 0
//                     ? BasicKundliScreen(
//                         usreDetails: usreDetails,
//                       )
//                     : const SizedBox(),
//                 kundliController.kundliTabInitialIndex == 1
//                     ? const ChartsScreen()
//                     : const SizedBox(),
//                 kundliController.kundliTabInitialIndex == 2
//                     ? const KPScreen()
//                     : const SizedBox(),
//                 kundliController.kundliTabInitialIndex == 3
//                     ? const AshtakvargaScreen()
//                     : const SizedBox(),
//                 kundliController.kundliTabInitialIndex == 4
//                     ? const KundliDashaScreen()
//                     : const SizedBox(),
//                 kundliController.kundliTabInitialIndex == 5
//                     ? const KundliReportScreen()
//                     : const SizedBox(),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
