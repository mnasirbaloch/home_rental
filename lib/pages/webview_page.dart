import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homerental/theme.dart';
import 'package:homerental/widgets/loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatelessWidget {
  final String url;
  final String? title;

  WebViewPage({Key? key, this.url = MyTheme.webSite, this.title})
      : super(key: key) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            progressVal.value = progress;
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  final progressVal = 1.obs;
  late final WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.theme.colorScheme.secondary,
        title: Text(title ?? 'information'.tr),
        centerTitle: true,
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return Stack(
          children: [
            WebViewWidget(controller: _controller),
            Positioned(
              child: Obx(
                () => Opacity(
                  opacity: 1 - (progressVal.value / 100),
                  child: Center(
                    child: Loading.type2(),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
