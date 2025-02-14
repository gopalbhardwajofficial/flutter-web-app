import 'package:flutter/material.dart';
import 'web_view_stub.dart'
    if (dart.library.html) 'web_view_web.dart'
    if (dart.library.io) 'web_view_mobile.dart';

Widget getWebView(String url) => getPlatformWebView(url);
