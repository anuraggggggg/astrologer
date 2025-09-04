// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:astrowaypartner/views/HomeScreen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../../../../../controllers/HomeController/home_controller.dart';

class PaymentScreen extends StatefulWidget {
  String url;
  PaymentScreen({super.key, required this.url});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    log('Loading URL: ${widget.url}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              NavigationDelegate(onProgress: (int progress) {
                const CircularProgressIndicator();
              }, onPageStarted: (url) {
                log('WebView page started loading: $url');
              }, onWebResourceError: (WebResourceError error) {
                log('WebView error: $error');
              }, onPageFinished: (finish) {
                log('WebView finish: $finish');

                log('payment screeen webview');
                log(finish);
                if (finish.toString().split("?").first ==
                    "https://astroway.diploy.in/payment-success") {
                  Get.find<HomeController>().homeTabIndex = 0;
                  Get.find<HomeController>().update();
                  Get.offAll(() => const HomeScreen());
                  global.showToast(
                    message: "Payment Success!",
                  );
                } else if (finish.toString().split("?").first ==
                    "https://astroway.diploy.in/payment-failed") {
                  Get.find<HomeController>().homeTabIndex = 0;
                  Get.find<HomeController>().update();
                  Get.offAll(() => const HomeScreen());

                  global.showToast(
                    message: "Payment Failed!",
                  );
                }
              }),
            )
            ..loadRequest(Uri.parse(widget.url))),
    );
  }
}
