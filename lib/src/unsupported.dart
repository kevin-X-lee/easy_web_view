import 'package:flutter/material.dart';

import 'impl.dart';

class EasyWebView extends StatefulWidget implements EasyWebViewImpl {
  const EasyWebView({
    Key key,
    @required this.src,
    this.resData,
    this.height,
    this.width,
    this.webAllowFullScreen = true,
    this.isHtml = false,
    this.isMarkdown = false,
    this.convertToWidets = false,
    this.headers = const {},
    this.widgetsTextSelectable = false,
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
}

class _EasyWebViewState extends State<EasyWebView> {
  @override
  Widget build(BuildContext context) {
    return OptionalSizedChild(
      width: widget?.width,
      height: widget?.height,
      builder: (w, h) => Placeholder(),
    );
  }
}
