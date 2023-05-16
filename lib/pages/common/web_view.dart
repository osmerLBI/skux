import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/pages/common/base_appbar.dart';
import 'package:span_mobile/pages/common/const.dart';
import 'package:span_mobile/pages/common/vlog.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webviewx/webviewx.dart';
import 'package:widget_loading/widget_loading.dart';

class WebViewPage extends StatefulWidget {
  WebViewPage({
    Key key,
    this.url,
    this.onLoadFinished,
    this.onError,
    this.onLoadStart,
    this.showAppBar = true,
  }) : super(key: key);
  final String url;
  Function onLoadFinished;
  Function onError;
  Function onLoadStart;
  bool isFocus = false;
  bool showAppBar;

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewXController _webViewXController;
  String _title = '';
  bool _loading = true;
  double _backButtonIndex = 1;
  double _titleIndex = 2;
  final FocusNode _focusNode = FocusNode();
  FocusScopeNode _focusScopeNode;
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _focusScopeNode = FocusScope.of(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_webViewXController != null) {
      _webViewXController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkuxStyle.bgColor,
      appBar: widget.showAppBar == true
          ? baseAppBar(
              context,
              titleItem: Semantics(
                sortKey: OrdinalSortKey(_titleIndex),
                child: Focus(
                  child: Text(_title),
                  focusNode: _focusNode,
                ),
                excludeSemantics: true,
                label: _title,
                header: true,
              ),
              leftItem: Semantics(
                focused: widget.isFocus,
                sortKey: OrdinalSortKey(_backButtonIndex),
                child: BackButton(
                  onPressed: _backButtonClicked,
                ),
              ),
            )
          : null,
      extendBody: true,
      body: SafeArea(
        child: CircularWidgetLoading(
          child: _webView(context),
          loading: _loading,
        ),
      ),
    );
  }

  Widget _webView(BuildContext context) {
    return WebViewX(
      mobileSpecificParams: MobileSpecificParams(
          mobileGestureRecognizers: Set()
            ..add(
              Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
              ),
            )
            ..add(
              Factory<TapGestureRecognizer>(
                () => TapGestureRecognizer(),
              ),
            )
            ..add(
              Factory<LongPressGestureRecognizer>(
                () => LongPressGestureRecognizer(),
              ),
            )),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - kToolbarHeight,
      initialContent: widget.url ?? '',
      initialSourceType: SourceType.urlBypass,
      onPageStarted: (url) async {
        Util.log('onLoadStart: $url');
        if (widget.onLoadStart != null) {
          widget.onLoadStart();
        }
      },
      onPageFinished: (url) {
        Util.log('onLoadStop: $url');

        String script = 'window.document.title';
        _webViewXController.evalRawJavascript(script).then((result) async {
          String title = result.toString();

          if (title != null && title.trim().isNotEmpty) {
            if (title.indexOf('"') == 0) {
              title = title.substring(1, title.length - 1);
            }
            if ((title.lastIndexOf('"') != -1) && (title.lastIndexOf('"') == title.length - 1)) {
              title = title.substring(0, title.length - 1);
            }
          }

          Util.log('title: $title');
          _title = title;
          if (ObjectUtil.isNotEmpty(title)) {
            _backButtonIndex = 2;
            _titleIndex = 1;
            setState(() {});
          }
        });

        _webViewXController.evalRawJavascript('document.body.baseURI').then((result) {
          Util.log('result: $result', tag: 'baseURI');
          String baseURI = result;
          VLog(baseURI, tag: 'Checking the base URI');
          if (!['about:blank', '"about:blank"', 'null', ''].contains(baseURI)) {
            setState(() {
              _loading = false;
            });
            Future.delayed(const Duration(seconds: 1), () {
              VLog('start focus title');
              _focusScopeNode.requestFocus(_focusNode);
            });
            if (widget.onLoadFinished != null) {
              widget.onLoadFinished();
            }
          }
        });
      },
      onWebResourceError: (WebResourceError error) {
        Util.log('onLoadError: $error');
        setState(() {
          _loading = false;
        });
        // Util.loading(visible: _loading, dismissOnTap: true);
        if (widget.onError != null) {
          widget.onError(error);
        }
      },
      onWebViewCreated: (controller) {
        if (_webViewXController == null) {
          _webViewXController = controller;
          _webViewXController
              .loadContent(widget.url ?? '', SourceType.url, headers: {'Authorization': 'Bearer ${Util.graphQLTempToken ?? Util.graphQLToken}'});
        }
      },
      navigationDelegate: (navigation) async {
        VLog(navigation.content.source, tag: 'navigationDelegate');
        String url = navigation.content.source;
        Uri uri = Uri.parse(url);
        if (uri.path.toLowerCase().endsWith('pdf')) {
          if (await canLaunchUrlString(url)) {
            await launchUrlString(url, mode: LaunchMode.externalApplication);
          }
          return NavigationDecision.prevent;
        }
        if (url.startsWith('mailto:')) {
          VLog(await canLaunchUrlString(url));
          if (await canLaunchUrlString(url)) {
            await launchUrlString(url);
          }
          return NavigationDecision.prevent;
        } else {
          return NavigationDecision.navigate;
        }
      },
    );
  }

  void _backButtonClicked() async {
    bool canBack = await _webViewXController.canGoBack();
    if (canBack) {
      _webViewXController.goBack();
    } else {
      Navigator.pop(context);
    }
  }
}
