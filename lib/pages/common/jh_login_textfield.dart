import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:span_mobile/common/style.dart';

const Color _textColor = Colors.white;
const TextStyle _textStyle = TextStyle(fontSize: 16.0, color: _textColor);
const TextStyle _hintTextStyle =
    TextStyle(fontSize: 16.0, color: Color(0xFFBBBBBB));

typedef _InputCallBack = void Function(String value);

class JhLoginTextField extends StatefulWidget {
  final String text;
  final String hintText;
  final String labelText; //top tip
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode focusNode;
  final bool isPwd; //Whether it is a password, default is not
  final Widget leftWidget; //left widget , default hide
  final Widget rightWidget; //right widget ，default hide
  final int maxLength; //max length，default 20
  final int maxLines; //max lines，default 20
  final bool
      isShowDeleteBtn; //Whether to display the delete button on the right. It is not displayed by default
  final List<TextInputFormatter> inputFormatters;
  final _InputCallBack inputCallBack;
  final String pwdOpen; //Custom password picture path, open your eyes
  final String pwdClose; //Custom password picture path, closed eyes
  final InputBorder border; //border style
  final bool isDense; //Compact display，default false
  final TextStyle hintTextStyle;
  final TextStyle textStyle;
  final TextStyle labelStyle;
  final double height;
  final Color cursorColor;
  final bool enabled;
  final ValueChanged<String> onSubmitted;

  const JhLoginTextField(
      {Key key,
      this.enabled = true,
      this.text = '',
      this.keyboardType = TextInputType.text,
      this.textInputAction,
      this.hintText = '',
      this.labelText,
      this.controller,
      this.focusNode,
      this.isPwd = false,
      this.leftWidget,
      this.rightWidget,
      this.maxLength = 80,
      this.isShowDeleteBtn = false,
      this.inputFormatters,
      this.inputCallBack,
      this.pwdOpen,
      this.pwdClose,
      this.border,
      this.maxLines = 1,
      this.isDense = false,
      this.hintTextStyle = _hintTextStyle,
      this.textStyle = _textStyle,
      this.cursorColor = Colors.black,
      this.labelStyle,
      this.onSubmitted,
      this.height = 44})
      : super(key: key);

  @override
  _JhLoginTextFieldState createState() => _JhLoginTextFieldState();
}

class _JhLoginTextFieldState extends State<JhLoginTextField> {
  TextEditingController _textController;
  FocusNode _focusNode;
  bool _isShowDelete;
  bool
      _isHiddenPwdBtn; //Whether to hide the password plaintext switch button on the right, and the password style will be displayed (ispwd = true),
  bool _pwdShow; //is show password
  Widget _pwdImg; //customer password image

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _textController.text = widget.text;
    _focusNode = widget.focusNode ?? FocusNode();
    _isHiddenPwdBtn = !widget.isPwd;
    _pwdShow = widget.isPwd;

    _isShowDelete = _focusNode.hasFocus && _textController.text.isNotEmpty;
    _textController.addListener(() {
      setState(() {
        _isShowDelete = _textController.text.isNotEmpty && _focusNode.hasFocus;
      });
    });
    _focusNode.addListener(() {
      setState(() {
        _isShowDelete = _textController.text.isNotEmpty && _focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pwdOpen != null && widget.pwdClose != null) {
      if (widget.pwdOpen.isNotEmpty && widget.pwdClose.isNotEmpty) {
        _pwdImg = _pwdShow
            ? ImageIcon(
                AssetImage(widget.pwdClose),
                color: style.psdEyeIconColor,
              )
            : ImageIcon(
                AssetImage(widget.pwdOpen),
                color: style.psdEyeIconColor,
              );
      } else {
        _pwdImg = Icon(_pwdShow ? Icons.visibility_off : Icons.visibility);
      }
    } else {
      _pwdImg = Icon(_pwdShow ? Icons.visibility_off : Icons.visibility);
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.centerRight,
        children: <Widget>[
          TextField(
            onSubmitted: widget.onSubmitted,
            enabled: widget.enabled,
            cursorColor: widget.cursorColor,
            textAlignVertical: TextAlignVertical.center,
            maxLines: widget.maxLines,
            focusNode: _focusNode,
            controller: _textController,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            style: widget.textStyle,
//            // 数字、手机号限制格式为0到9(白名单)， 密码限制不包含汉字（黑名单）
//            inputFormatters: (widget.keyboardType == TextInputType.number || widget.keyboardType == TextInputType.phone) ?
//            [WhitelistingTextInputFormatter(RegExp('[0-9]'))] : [BlacklistingTextInputFormatter(RegExp('[\u4e00-\u9fa5]'))],
            inputFormatters: widget.inputFormatters ??
                [LengthLimitingTextInputFormatter(widget.maxLength)],
            decoration: InputDecoration(
              prefixIcon: widget.leftWidget,
              labelText: widget.labelText,
              labelStyle: widget.labelStyle ?? widget.hintTextStyle,
              hintText: widget.hintText,
              hintStyle: widget.hintTextStyle,
              isDense: widget.isDense,
              border: widget.border,
              enabledBorder: widget.border ??
                  const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.8)),
              focusedBorder: widget.border ??
                  UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 0.8)),
//          suffixIcon:
            ),
            obscureText: _pwdShow,
            onChanged: (value) {
              if (widget.inputCallBack != null) {
                widget.inputCallBack(_textController.text);
              }
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Offstage(
                offstage: !widget.isShowDeleteBtn,
                child: _isShowDelete
                    ? IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: Color(0xFFC8C8C8),
                          size: 20,
                        ),
                        onPressed: () {
                          _textController.text = "";
                          if (widget.inputCallBack != null) {
                            widget.inputCallBack(_textController.text);
                          }
                        })
                    : const Text(""),
              ),
              Offstage(
                  offstage: _isHiddenPwdBtn,
                  child: IconButton(
//                  icon: Icon(_pwdShow ? Icons.visibility_off : Icons.visibility),
//                  icon: Image.asset("assets/images/ic_pwd_close.png",width: 18.0,),
                    icon: _pwdImg,
                    iconSize: 18.0,
                    onPressed: () {
                      setState(() {
                        _pwdShow = !_pwdShow;
                      });
                    },
                  )),
              widget.rightWidget ?? Container(),
            ],
          ),
        ],
      ),
    );
  }
}
