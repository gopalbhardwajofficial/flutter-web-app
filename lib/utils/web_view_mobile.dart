import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

Widget getPlatformWebView(String url) {
  final WebViewController controller = WebViewController(); // Declare first

  controller
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          debugPrint('Page started loading: $url');
        },
        onPageFinished: (String url) {
          debugPrint('Page finished loading: $url');
          // Clear cache and storage after page loads
          controller.runJavaScript('''
            localStorage.clear();
            sessionStorage.clear();
            if (window.caches) {
              caches.keys().then(function(names) {
                for (let name of names) caches.delete(name);
              });
            }
          ''');
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('WebView error: ${error.description}');
        },
      ),
    )
    ..setBackgroundColor(const Color(0x00000000))
    ..enableZoom(true)
    ..loadRequest(
      Uri.parse(url),
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    );

  return WebViewWidget(controller: controller);
}