import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'dart:io';

class MyWebView extends StatefulWidget {
  final WebViewController controller;
  const MyWebView({super.key, required this.controller});

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  var loadingPercentage = 0;
  var isConnected = true;
  var isinternetconnected = true;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;

  @override
  void initState() {
    // _initializeWebView();
    void addFileSelectionListener() async {
      if (Platform.isAndroid) {
        final androidController =
            widget.controller.platform as AndroidWebViewController;
        await androidController.setOnShowFileSelector(_androidFilePicker);
      }
    }

    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      setState(() {
        _connectivityResult =
            results.isNotEmpty ? results.last : ConnectivityResult.none;
      });
    });

    widget.controller
      ..setUserAgent("random")
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

    // TODO: implement initState
    super.initState();
  }

  Future<List<String>> _androidFilePicker(
      final FileSelectorParams params) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      return [file.uri.toString()];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _connectivityResult != ConnectivityResult.none
            ? WebViewWidget(
                controller: widget.controller,
              )
            : Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                margin:
                    EdgeInsets.all(MediaQuery.of(context).size.width / 2 - 125),
                width: 250,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Color.fromARGB(255, 255, 255, 255),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2), // shadow color
                      spreadRadius: 1, // spread radius
                      blurRadius: 3, // blur radius
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "No internet connections",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 7, right: 7),
                      child: Text(
                        "Pleasse turn on your",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      child: Text(
                        "internet connection",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                )),
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            value: loadingPercentage / 100.0,
            color: Color.fromARGB(255, 18, 173, 44),
          )
      ],
    );
  }
}
