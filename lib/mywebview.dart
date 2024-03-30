import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebView extends StatefulWidget {
  final WebViewController controller;
  const MyWebView({super.key, required this.controller});

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  var loadingPercentage = 0;
  var isConnected = true;

  @override
  void initState() {
    widget.controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            Uri uri = Uri.parse(request.url);

            if (request.url.contains("tg:")) {
              // TELEGRAM
              canLaunchUrl(uri).then((bool result) {
                launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              });
              return NavigationDecision.prevent;
            } else if (request.url.contains("whatsapp:")) {
              canLaunchUrl(uri).then((bool result) async {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              });

              return NavigationDecision.prevent;
            } else if (request.url.contains("tel:")) {
              canLaunchUrl(uri).then((bool result) {
                launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              });
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("SnackBar", onMessageReceived: (message) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message.message)));
      });

    // checkConnectivity();
    // TODO: implement initState
    super.initState();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(
          controller: widget.controller,
        ),
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            value: loadingPercentage / 100.0,
            color: Color.fromARGB(255, 18, 173, 44),
          )
      ],
    );
  }
}
