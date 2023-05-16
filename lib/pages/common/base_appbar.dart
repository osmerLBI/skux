import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:span_mobile/pages/common/debug_widget.dart';

// const Color _navbgColor = Color(0xFF5856D6);
const Color _navbgColor = Colors.transparent;
const Color _titleColorWhite = Colors.white;
const Color _titleColorBlack = Colors.black;
const double _titleFontSize = 16.0;
const double _textFontSize = 16.0;
const double _itemSpace = 15.0; //右侧item内间距
const double _imgWH = 22.0; //右侧图片wh
const double _rightSpace = 5.0; //右侧item右间距
const Brightness _brightness = Brightness.dark;

const Color appbarStartColor = Color(0xFF2683BE); //渐变开始色
const Color appbarEndColor = Color(0xFF34CABE); //渐变结束色

/*带返回箭头导航条*/
backAppBar(BuildContext context, String title,
    {String rightText,
    String rightImgPath,
    Color backgroundColor = _navbgColor,
    Brightness brightness = _brightness,
    PreferredSizeWidget bottom,
    Function rightItemCallBack,
    Function backCallBack}) {
  return baseAppBar(
    context,
    title: title,
    isBack: true,
    rightText: rightText,
    rightImgPath: rightImgPath,
    rightItemCallBack: rightItemCallBack,
    leftItemCallBack: backCallBack,
    backgroundColor: backgroundColor,
    brightness: brightness,
    bottom: bottom,
  );
}

backAppLogoBar(BuildContext context,
    {String rightText,
    String rightImgPath,
    Widget titleItem,
    Color backgroundColor = _navbgColor,
    Brightness brightness = _brightness,
    PreferredSizeWidget bottom,
    Widget rightItem,
    isBack = true,
    Function rightItemCallBack,
    Function backCallBack}) {
  return baseAppBar(
    context,
    titleItem: titleItem ??
        DebugWidget(
          child: SvgPicture.asset('assets/image/spendr/spendr_logo.svg'),
        ),
    isBack: isBack,
    rightText: rightText,
    rightButton: rightItem,
    rightImgPath: rightImgPath,
    rightItemCallBack: rightItemCallBack,
    leftItemCallBack: backCallBack,
    backgroundColor: backgroundColor,
    brightness: brightness,
    bottom: bottom,
  );
}

/*带返回箭头的渐变导航条*/
backGradientAppBar(
  BuildContext context,
  String title, {
  String rightText,
  String rightImgPath,
  Function rightItemCallBack,
  Function backCallBack,
}) {
  return gradientAppBar(
    context,
    title,
    isBack: true,
    rightText: rightText,
    rightImgPath: rightImgPath,
    rightItemCallBack: rightItemCallBack,
    leftItemCallBack: backCallBack,
  );
}

/*
* 渐变导航条
* */
gradientAppBar(
  BuildContext context,
  String title, {
  String rightText,
  String rightImgPath,
  Widget leftItem,
  bool isBack = false,
  double elevation = 0,
  PreferredSizeWidget bottom,
  Function rightItemCallBack,
  Function leftItemCallBack,
}) {
  return PreferredSize(
    child: Container(
      child: baseAppBar(
        context,
        title: title,
        rightText: rightText,
        rightImgPath: rightImgPath,
        leftItem: leftItem,
        isBack: isBack,
        backgroundColor: Colors.white.withOpacity(0),
        elevation: elevation,
        bottom: bottom,
        rightItemCallBack: rightItemCallBack,
        leftItemCallBack: leftItemCallBack,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appbarStartColor,
            appbarEndColor,
          ],
        ),
      ),
    ),
//        preferredSize: Size(MediaQuery.of(context).size.width, 45),
    preferredSize: Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0)),
  );
}

//baseAppBar
baseAppBar(
  BuildContext context, {
  String title,
  Widget titleItem,
  String rightText,
  String rightImgPath,
  Widget rightButton,
  Widget leftItem,
  bool isBack = true,
  Color backgroundColor = _navbgColor,
  Brightness brightness = _brightness,
  double elevation = 0,
  PreferredSizeWidget bottom,
  Function rightItemCallBack,
  Function leftItemCallBack,
}) {
  Color _color = (backgroundColor == Colors.transparent ||
          backgroundColor == Colors.white ||
          backgroundColor == Colors.white)
      ? _titleColorBlack
      : _titleColorWhite;

  Widget rightItem = const Text("");
  if (rightText != null) {
    rightItem = InkWell(
      child: Container(
          margin: const EdgeInsets.all(_itemSpace),
          color: Colors.transparent,
          child: Center(
              child: Text(rightText,
                  style: TextStyle(fontSize: _textFontSize, color: _color)))),
      onTap: () {
        if (rightItemCallBack != null) {
          rightItemCallBack();
        }
      },
    );
  }
  if (rightImgPath != null) {
    rightItem = IconButton(
      icon: Semantics(
        child: SvgPicture.asset(
          rightImgPath,
          width: _imgWH,
          height: _imgWH,
          color: _color,
        ),
      ),
      // icon: Image.asset(
      //   rightImgPath,
      //   width: _imgWH,
      //   height: _imgWH,
      //   color: _color,
      // ),
      onPressed: () {
        if (rightItemCallBack != null) {
          rightItemCallBack();
        }
      },
    );
  }
  return AppBar(
    title: titleItem ??
        DebugWidget(
          child: Semantics(
            header: true,
            child: Text(title,
                style: TextStyle(fontSize: _titleFontSize, color: _color)),
          ),
        ),
    centerTitle: true,
    // backgroundColor: Colors.transparent,
    backgroundColor: backgroundColor,
    bottom: bottom,
    elevation: elevation,
    leading: isBack == false
        ? leftItem
        : Semantics(
            button: true,
            explicitChildNodes: false,
            excludeSemantics: true,
            label: 'Back',
            child: IconButton(
              // icon: Icon(Icons.arrow_back_ios, color: _color),
              icon: SvgPicture.asset(
                'assets/image/skux/arrow_left.svg',
                color: _color,
              ),
              iconSize: 20,
              onPressed: () {
                if (leftItemCallBack == null) {
                  _popThis(context);
                } else {
                  leftItemCallBack();
                }
              },
            ),
          ),
    actions: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          rightButton ?? Container(),
          rightItem,
          const SizedBox(width: _rightSpace),
        ],
      ),
    ],
  );
}

void _popThis(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).maybePop();
  }
}
