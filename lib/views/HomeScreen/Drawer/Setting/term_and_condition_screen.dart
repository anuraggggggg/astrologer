// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

String termsconditionurl = "https://astroway.diploy.in/terms-condition";

class TermAndConditionScreen extends StatelessWidget {
  TermAndConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }

  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
          const CircularProgressIndicator();
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('Terms condition error- > $error');
        },
      ),
    )
    ..loadRequest(Uri.parse(termsconditionurl));
}
