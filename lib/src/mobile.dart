// import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'impl.dart';
// import 'package:native_webview/native_webview.dart';

class EasyWebView extends StatefulWidget implements EasyWebViewImpl {
  const EasyWebView({
    Key key,
    @required this.src,
    this.resData,
    this.methodName,
    this.height,
    this.width,
    this.webAllowFullScreen = true,
    this.isHtml = false,
    this.isMarkdown = false,
    this.convertToWidets = false,
    this.headers = const {},
    this.widgetsTextSelectable = false,
    this.isAllowEvent = true,
  })  : assert((isHtml && isMarkdown) == false),
        super(key: key);

  @override
  _EasyWebViewState createState() => _EasyWebViewState();

  @override
  final num height;

  @override
  final String src;

  @override
  final String resData;

  @override
  final String methodName;

  @override
  final num width;

  @override
  final bool webAllowFullScreen;

  @override
  final bool isMarkdown;

  @override
  final bool isHtml;

  @override
  final bool convertToWidets;

  @override
  final Map<String, String> headers;

  @override
  final bool widgetsTextSelectable;

  @override
  final bool isAllowEvent;
}

class _EasyWebViewState extends State<EasyWebView> {
  WebViewController _controller;

  @override
  void didUpdateWidget(EasyWebView oldWidget) {
    if (oldWidget.src != widget.src) {
      _controller.loadUrl(_updateUrl(widget.src), headers: widget.headers);
    }
    if (oldWidget.height != widget.height) {
      if (mounted) setState(() {});
    }
    if (oldWidget.width != widget.width) {
      if (mounted) setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  String _updateUrl(String url) {
    String _src = url;
    if (widget.isMarkdown) {
      _src = "data:text/html;charset=utf-8," +
          Uri.encodeComponent(EasyWebViewImpl.md2Html(url));
    }
    if (widget.isHtml) {
      _src = "data:text/html;charset=utf-8," +
          Uri.encodeComponent(EasyWebViewImpl.wrapHtml(url));
    }
    return _src;
  }

  @override
  Widget build(BuildContext context) {
    return OptionalSizedChild(
      width: widget?.width,
      height: widget?.height,
      builder: (w, h) {
        String src = widget.src;
        if (widget.convertToWidets) {
          if (EasyWebViewImpl.isUrl(src)) {
            return RemoteMarkdown(
              src: src,
              headers: widget.headers,
              isSelectable: widget.widgetsTextSelectable,
            );
          }
          String _markdown = '';
          if (widget.isMarkdown) {
            _markdown = src;
          }
          if (widget.isHtml) {
            src = EasyWebViewImpl.wrapHtml(src);
            _markdown = EasyWebViewImpl.html2Md(src);
          }
          return LocalMarkdown(
            data: _markdown,
            isSelectable: widget.widgetsTextSelectable,
          );
        }
        // return WebView(
        //   key: widget?.key,
        //   initialUrl: _updateUrl(src),
        //   onWebViewCreated: (val) {
        //     _controller = val;
        //   },
        //   onPageFinished: (controller, url) {
        //     if (null != widget.resData) {
        //       _controller.evaluateJavascript(widget.resData);
        //     }
        //   },
        // );
        return WebView(
          key: widget?.key,
          initialUrl: _updateUrl(src),
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          ].toSet(),
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (val) {
            _controller = val;
          },
          onPageFinished: (url) {
            if (null != widget.resData) {
              _controller.evaluateJavascript(widget.resData);
            }
          },
          // onJSAlert: (String url, String message) async {
          //   return await showDialog(
          //       context: context,
          //       barrierDismissible: false,
          //       builder: (_) => WillPopScope(
          //           onWillPop: () async => false,
          //           child: MyCupertinoAlertDialog(message: message)));
          // },
          // onJSConfirm: (String url, String message) async {
          //   return await showDialog(
          //     context: context,
          //     barrierDismissible: false,
          //     builder: (_) => WillPopScope(
          //         onWillPop: () async => false,
          //         child: CupertinoConfirmDialog(message: message)),
          //   );
          // },
          // onJSPrompt: (String url, String message, String defaultText) async {
          //   return await showDialog(
          //       context: context,
          //       barrierDismissible: false,
          //       builder: (_) => WillPopScope(
          //           onWillPop: () async => false,
          //           child: CupertinoPromptDialog(
          //               message: message, defaultText: defaultText)));
          // },
        );
      },
    );
  }
}

/// An example for cupertino style alert dialog.
class MyCupertinoAlertDialog extends StatelessWidget {
  /// Dialog message.
  final String message;

  /// Constructs an instance with a message.
  MyCupertinoAlertDialog({this.message = ''});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Text(message),
      actions: <Widget>[
        CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ],
    );
  }
}

/// An example for cupertino style confirm dialog.
class CupertinoConfirmDialog extends StatelessWidget {
  /// Dialog message.
  final String message;

  /// Constructs an instance with a message.
  CupertinoConfirmDialog({this.message = ''});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Text(message),
      actions: <Widget>[
        CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            }),
        CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(true);
            }),
      ],
    );
  }
}

/// An example for cupertino style prompt dialog.
class CupertinoPromptDialog extends StatefulWidget {
  /// Dialog message.
  final String message;

  /// Dialog default text.
  final String defaultText;

  /// Constructs an instance with a message and default text.
  CupertinoPromptDialog({Key key, this.message, this.defaultText})
      : super(key: key);

  @override
  _PromptDialogState createState() => _PromptDialogState();
}

class _PromptDialogState extends State<CupertinoPromptDialog> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = widget.defaultText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(widget.message),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: CupertinoTextField(
                controller: _controller,
                cursorColor: CupertinoColors.inactiveGray,
                style: const TextStyle(
                  fontSize: 16,
                ),
                maxLines: 1,
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(
                    width: 1.2,
                    color: CupertinoColors.inactiveGray,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            )
          ]),
      actions: <Widget>[
        CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop('');
            }),
        CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(_controller.text);
            }),
      ],
    );
  }
}
