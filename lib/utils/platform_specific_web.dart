import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Widget getWebView(String url) {
  // Register the iframe element
  final String viewType = 'iframeElement';
  final html.IFrameElement iframe = html.IFrameElement()
    ..style.border = 'none'
    ..style.height = '100%'
    ..style.width = '100%'
    ..src = url;

  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) => iframe,
  );

  return HtmlElementView(viewType: viewType);
}
