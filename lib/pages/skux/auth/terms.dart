// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/pages/common/const.dart';
import 'package:span_mobile/pages/common/pdf_viewer.dart';
import 'package:span_mobile/pages/common/vlog.dart';
import 'package:span_mobile/pages/common/web_view.dart';
import 'package:span_mobile/pages/skux/common/api.dart';
import 'package:span_mobile/widgets/unfocus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TermsPage extends StatefulWidget {
  TermsPage({
    Key key,
    this.url,
    this.hideButtons = false,
    this.onAcceptClicked,
    this.onDeclinePressed,
    this.didFinishLoading,
  }) : super(key: key);
  String url;
  final bool hideButtons;
  final Function onAcceptClicked;
  final Function onDeclinePressed;
  final Function didFinishLoading;

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  final GlobalKey webviewKey = GlobalKey();
  final GlobalKey _bottomAreaKey = GlobalKey();
  String _url;
  String _browserUrl;
  double _bottomAreaHeight = 48.0;
  bool _showButtons = false;
  bool _isPdf = false;
  @override
  void initState() {
    _url = widget.url ?? Util.serverUrl + SKUxAPI.itemsUrl;
    if (_url.endsWith('.pdf') && Platform.isAndroid) {
      _browserUrl = 'https://docs.google.com/gview?url=' + _url;
    } else {
      _browserUrl = _url;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findBottomObject();
    });
    _isPdf = _url.endsWith('.pdf');
    super.initState();
  }

  void _findBottomObject() {
    RenderObject renderObj = _bottomAreaKey.currentContext?.findRenderObject();
    if (renderObj == null) {
      return;
    }
    RenderBox renderBox = renderObj as RenderBox;
    // Offset offset = renderBox?.localToGlobal(Offset.zero);

    setState(() {
      _bottomAreaHeight = renderBox.size.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkuxStyle.bgColor,
      body: OrientationBuilder(builder: (context, orientation) {
        return SafeArea(
          child: SingleChildScrollView(
            child: UnFocusWidget(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Semantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _top(),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.bottom -
                            MediaQuery.of(context).padding.top -
                            _bottomAreaHeight -
                            140,
                        child: _isPdf == true
                            ? PDFViewPage(
                                key: webviewKey,
                                url: _url,
                                onError: () {
                                  Util.showErrorDialog(context: context, msg: 'Load Error');
                                  setState(() {
                                    _showButtons = false;
                                  });
                                },
                                onLoadFinished: () {
                                  setState(() {
                                    _showButtons = true;
                                  });
                                },
                              )
                            : _webViewPage(),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      // LineSeparator(
                      //   color: Color.fromRGBO(35, 42, 81, 0.08),
                      // ),
                      if (_showButtons == true && widget.hideButtons == false) _buttonArea(context),
                    ],
                  ),
                  explicitChildNodes: true,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _top() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Semantics(
          label: 'Open terms and conditions in external browser',
          button: true,
          excludeSemantics: true,
          child: IconButton(
            onPressed: _browsersButtonClicked,
            icon: SvgPicture.asset(
              'assets/image/skux/browser.svg',
              width: 30,
              height: 30,
            ),
          ),
        ),
        Semantics(
          child: Text(
            tr('Terms & Conditions'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SkuxStyle.textColor),
          ),
        ),
        Semantics(
          child: IconButton(
            onPressed: _backButtonClicked,
            icon: SvgPicture.asset('assets/image/skux/close_gray.svg'),
          ),
          label: 'Close',
          button: true,
          excludeSemantics: true,
        ),
      ],
    );
  }

  Widget _webViewPage() {
    return WebViewPage(
      key: webviewKey,
      url: _url,
      showAppBar: false,
      onError: () {
        setState(() {
          _showButtons = false;
        });
      },
      onLoadFinished: () {
        if (widget.didFinishLoading != null) {
          widget.didFinishLoading();
        }
        setState(() {
          _showButtons = true;
        });
      },
    );
  }

  Widget _buttonArea(BuildContext context) {
    double w = (MediaQuery.of(context).size.width - 16 - 16) * 0.5;
    return Semantics(
      child: Row(
        key: _bottomAreaKey,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: w,
            child: Semantics(
              excludeSemantics: true,
              label: 'Accept',
              button: true,
              child: TextButton(
                onPressed: _acceptButtonClicked,
                child: Text(
                  tr('Accept'),
                  style: TextStyle(
                    color: style.primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: w,
            child: Semantics(
              child: TextButton(
                onPressed: _declineButtonClicked,
                child: Text(
                  tr('Decline'),
                  style: TextStyle(
                    color: style.errorColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              excludeSemantics: true,
              label: 'Decline',
              button: true,
            ),
          ),
        ],
      ),
      explicitChildNodes: true,
    );
  }

  void _acceptButtonClicked() async {
    if (widget.onAcceptClicked != null) {
      await widget.onAcceptClicked();
    }
    Navigator.pop(context);
  }

  void _declineButtonClicked() async {
    if (widget.onDeclinePressed != null) {
      await widget.onDeclinePressed();
    }
    Navigator.pop(context);
  }

  void _backButtonClicked() {
    Navigator.pop(context);
  }

  void _browsersButtonClicked() async {
    if (await canLaunchUrlString(_browserUrl)) {
      await launchUrlString(_browserUrl, mode: LaunchMode.externalApplication);
    }
  }
}
