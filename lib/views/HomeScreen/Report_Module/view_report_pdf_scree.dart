import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/models/History/report_history_model.dart';
import 'package:astrowaypartner/utils/config.dart';
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewReportPdfScreen extends StatelessWidget {
  final ReportHistoryModel? reportHistoryData;
  ViewReportPdfScreen({super.key, this.reportHistoryData});
  final SignupController signupController = Get.find<SignupController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
          height: 80,
          backgroundColor: COLORS().primaryColor,
          title: const Text("PDF"),
        ),
        body: SfPdfViewer.network(
          '$pdfBaseurl${reportHistoryData!.reportFile}',
          enableDocumentLinkAnnotation: false,
        ),
      ),
    );
  }
}
