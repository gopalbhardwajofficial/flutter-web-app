import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import platform-specific implementations at the top
import 'platform_specific_web.dart' as web;
import 'platform_specific_mobile.dart' as mobile;

Widget getWebView(String url) {
  if (kIsWeb) {
    return web.getWebView(url); // Web implementation
  } else {
    return mobile.getWebView(url); // Mobile implementation
  }
}