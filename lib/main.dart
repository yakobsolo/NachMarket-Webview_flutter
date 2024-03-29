import 'package:flutter/material.dart';
import 'package:nach/mywebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "nach market",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: WebViewApp(),
    );
  }
}

class WebViewApp extends StatefulWidget {
  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()
      ..loadRequest(Uri.parse("https://nachmarket.com"));
    // TODO: implement initState
    super.initState();
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    if (await controller.canGoBack()) {
                      await controller.goBack();
                    } else {
                      messenger.showSnackBar(
                          SnackBar(content: Text("no back history found")));
                    }
                    // return;
                  },
                  icon: Icon(Icons.arrow_back_ios, color: Colors.grey,)),
        title: Center(child: Column(children: [Text('Welcome!', style: TextStyle( fontSize: 16, fontWeight: FontWeight.w400)),Text("nachmarket.com", style: TextStyle( fontSize: 20, fontWeight: FontWeight.w400)) ],)),
        actions: [
          Row(
            children: [
              
              IconButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    if (await controller.canGoForward()) {
                      await controller.goForward();
                    } else {
                      messenger.showSnackBar(
                          SnackBar(content: Text("no forward history found")));
                    }
                    // return;
                  },
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.grey,)),
              IconButton(
                  onPressed: () {
                    controller.reload();
                  },
                  icon: Icon(Icons.replay, color: Colors.grey)),


            ],


          ),

        
        ],
        
      ),

      body: MyWebView(controller: controller),
    );
  }
}
