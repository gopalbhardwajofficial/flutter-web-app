import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String websiteUrl = 'https://www.avnishkrishna.com';
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  late final WebViewController _controller;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _errorMessage = '';
              });
              // Set a timeout for loading
              _loadingTimer?.cancel();
              _loadingTimer = Timer(const Duration(seconds: 30), () {
                if (_isLoading && mounted) {
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                    _errorMessage = 'Connection timeout. Please check your internet connection.';
                  });
                }
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              _loadingTimer?.cancel();
              setState(() {
                _isLoading = false;
              });
              _injectScripts();
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted) {
              _loadingTimer?.cancel();
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = 'Failed to load content. Please check your internet connection.';
              });
            }
          },
        ),
      );

    await _enableMixedContent();
    await _loadWebsite();
  }

  Future<void> _enableMixedContent() async {
    await _controller.runJavaScript('''
      // Enable mixed content
      var meta = document.createElement('meta');
      meta.httpEquiv = "Content-Security-Policy";
      meta.content = "upgrade-insecure-requests";
      document.head.appendChild(meta);
      
      // Force HTTPS
      if (window.location.protocol === 'http:') {
        window.location.href = window.location.href.replace('http:', 'https:');
      }
    ''');
  }

  Future<void> _injectScripts() async {
    await _controller.runJavaScript('''
      // Clear cache and storage
      if (window.caches) {
        caches.keys().then(function(names) {
          for (let name of names) caches.delete(name);
        });
      }
      localStorage.clear();
      sessionStorage.clear();
      
      // Handle mixed content
      document.querySelectorAll('img[src^="http:"], link[href^="http:"], script[src^="http:"]').forEach(function(element) {
        var url = element.src || element.href;
        if (url) {
          url = url.replace('http:', 'https:');
          if (element.src) element.src = url;
          if (element.href) element.href = url;
        }
      });
    ''');
  }

  Future<void> _loadWebsite() async {
    try {
      await _controller.loadRequest(
        Uri.parse(websiteUrl),
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );
    } catch (e) {
      debugPrint('Load error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load website. Please try again.';
        });
      }
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    
    try {
      await _enableMixedContent();
      await _controller.reload();
    } catch (e) {
      debugPrint('Reload error: $e');
      await _loadWebsite();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Acharya Dr. Avnish Krishna',
                    style: GoogleFonts.playfairDisplay(
                      color: const Color(0xFF1A237E),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Official Website',
                    style: GoogleFonts.lato(
                      color: Colors.grey[600],
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF1A237E)),
              onPressed: _refreshPage,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A237E)),
                ),
              ),
            ),
          if (_hasError)
            Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFF1A237E),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to load website',
                        style: TextStyle(
                          color: Color(0xFF1A237E),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _refreshPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
