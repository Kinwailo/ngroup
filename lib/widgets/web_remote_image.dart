import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class RemoteImage extends HookConsumerWidget {
  const RemoteImage(this.url, this.post, {super.key, this.width, this.height});

  final String url;
  final int post;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imgWidth = useState(width ?? 1);
    final imgHeight = useState(height ?? 1);
    final loading = useState(true);
    final error = useState(false);
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          if (!error.value)
            WebViewX(
              ignoreAllGestures: true,
              initialContent: _imagePage(url, imgWidth.value, imgHeight.value),
              initialSourceType: SourceType.html,
              width: imgWidth.value,
              height: imgHeight.value,
              javascriptMode: JavascriptMode.unrestricted,
              jsContent: const {
                EmbeddedJsContent(
                  webJs: "function onLoad(msg) { callbackLoad(msg) }",
                  mobileJs:
                      "function onLoad(msg) { callbackLoad.postMessage(msg) }",
                ),
                EmbeddedJsContent(
                  webJs: "function onError(msg) { callbackError(msg) }",
                  mobileJs:
                      "function onError(msg) { callbackError.postMessage(msg) }",
                ),
              },
              dartCallBacks: {
                DartCallback(
                  name: 'callbackLoad',
                  callBack: (msg) {
                    loading.value = false;
                    if (width != null) {
                      if (height != null) {
                        imgWidth.value = width!;
                        imgHeight.value = height!;
                      } else {
                        imgWidth.value = width!;
                        imgHeight.value = msg["height"] * width! / msg["width"];
                      }
                    } else {
                      if (height != null) {
                        imgWidth.value = msg["width"] * height! / msg["height"];
                        imgHeight.value = height!;
                      } else {
                        imgWidth.value = msg["width"] < constraints.maxWidth
                            ? msg["width"]
                            : constraints.maxWidth;
                        imgHeight.value =
                            msg["height"] * imgWidth.value / msg["width"];
                      }
                    }
                  },
                ),
                DartCallback(
                  name: 'callbackError',
                  callBack: (msg) {
                    error.value = true;
                  },
                ),
              },
              webSpecificParams: const WebSpecificParams(),
              mobileSpecificParams: const MobileSpecificParams(
                androidEnableHybridComposition: true,
              ),
            ),
          if (!error.value && loading.value)
            const SizedBox.square(
              dimension: 50,
              child: Center(child: CircularProgressIndicator()),
            ),
          if (error.value)
            const SizedBox.square(
              dimension: 50,
              child: Icon(Icons.error),
            ),
          if (!error.value && !loading.value)
            InkWell(
              onTap: () => launchUrlString(url),
              child: SizedBox(width: imgWidth.value, height: imgHeight.value),
            )
        ],
      );
    });
  }

  String _imagePage(String url, double width, double height) {
    return """<!DOCTYPE html>
            <html>
              <head>
                <style  type="text/css" rel="stylesheet">
                  body {
                    margin: 0px;
                    width: 100%;
                    height: 100%;
	                  overflow: hidden;
                    }
                    #myImg {
                      cursor: pointer;
                      transition: 0.3s;
                      width: 100%;
                      height: 100%;
                      object-fit: cover;
                    }
                    #myImg:hover {opacity: 0.7}
                </style>
                <meta charset="utf-8"
                <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0">
                <meta http-equiv="Content-Security-Policy" 
                content="default-src * gap:; script-src * 'unsafe-inline' 'unsafe-eval'; connect-src *; 
                img-src * data: blob: android-webview-video-poster:; style-src * 'unsafe-inline';">
              </head>
              <body>
                <img id="myImg" src="$url" frameborder="0" allow="fullscreen" allowfullscreen onload = "onLoad(this)" onerror = "onError(this)">
              </body> 
            <script>
                function onLoad(img) {
                  callbackLoad({width:img.naturalWidth, height:img.naturalHeight});
                }
                function onError(img) { 
                  img.src = "data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=";
                  img.onerror = ""; 
                  callbackError();
                }
            </script>
        </html>
    """;
  }
}
