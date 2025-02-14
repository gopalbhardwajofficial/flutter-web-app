import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

Widget getWebView(String url) {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(url));
    
  return WebViewWidget(controller: controller);
}
