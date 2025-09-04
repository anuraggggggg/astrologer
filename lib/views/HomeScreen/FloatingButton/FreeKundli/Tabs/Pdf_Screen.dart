// ignore_for_file: file_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../../../../../constants/colorConst.dart';
import '../../../../../widgets/app_bar_widget.dart';

class PDFScreen extends StatefulWidget {
  final String url;
  const PDFScreen({super.key, required this.url});

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  late bool isPdfLoaded;
  @override
  void initState() {
    isPdfLoaded = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('get pdf link is ${widget.url}');
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
          height: 80,
          backgroundColor: COLORS().primaryColor,
          title: Text(
            "Kundli Pdf",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),
          ).tr(),
        ),
        body: Stack(
          children: [
            SfPdfViewer.network(
              widget.url,
              enableDocumentLinkAnnotation: false,
              canShowPageLoadingIndicator: true,
              enableDoubleTapZooming: true,
              enableTextSelection: true,
              onDocumentLoadFailed: (e) {
                global.showToast(message:  tr("PDF Failed to Load try again"));
                Get.back();
              },
              onDocumentLoaded: (details) {
                setState(() {
                  isPdfLoaded = true;
                });
              },
            ),
            if (!isPdfLoaded)
              SizedBox(
                width: 100.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const Text('Loading ...').tr(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
