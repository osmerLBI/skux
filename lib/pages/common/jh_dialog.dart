import 'package:flutter/material.dart';

class JhDialog {
  //Middle bullet frame
  static void show(
    BuildContext context, {
    String title,
    String content,
    String leftText = 'Cancel',
    String rightText = 'Confirm',
    final VoidCallback onCancel,
    final VoidCallback onConfirm,
    bool hiddenCancel = false,
  }) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return BaseDialog(
              title: title,
              content: content == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child:
                          Text(content, style: const TextStyle(fontSize: 16.0)),
                    ),
              leftText: leftText,
              rightText: rightText,
              onCancel: onCancel,
              onConfirm: onConfirm,
              hiddenCancel: hiddenCancel);
        });
  }

  //Custom pop-up
  static void showCustomDialog(
    BuildContext context, {
    String title,
    Widget content,
    String leftText = 'Cancel',
    String rightText = 'Confirm',
    final VoidCallback onCancel,
    final VoidCallback onConfirm,
    bool hiddenCancel = false,
  }) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return BaseDialog(
              title: title,
              content: content,
              leftText: leftText,
              rightText: rightText,
              onCancel: onCancel,
              onConfirm: onConfirm,
              hiddenCancel: hiddenCancel);
        });
  }

  //Fully custom pop ups
  static void showAllCustomDialog(
    BuildContext context, {
    Widget child,
    Function onDismiss,
    bool clickBgHidden = false,
  }) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return CustomDialog(
            child: child,
            clickBgHidden: clickBgHidden,
            onDismiss: onDismiss,
          );
        });
  }
}

class BaseDialog extends StatelessWidget {
  const BaseDialog({
    Key key,
    this.title,
    this.content,
    this.leftText = 'Cancel',
    this.rightText = 'Confirm',
    this.onCancel,
    this.onConfirm,
    this.hiddenCancel = false,
  }) : super(key: key);

  final String title;
  final Widget content;
  final String leftText;
  final String rightText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool hiddenCancel;

  @override
  Widget build(BuildContext context) {
    Widget dialogTitle = Offstage(
      offstage: title == null || title == '' ? true : false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title ?? "",
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
    );

    Widget bottomButton = Row(
      children: <Widget>[
        hiddenCancel
            ? Container()
            : _DialogButton(
                text: leftText,
                textColor: const Color(0xFF999999),
                onPressed: () {
                  Navigator.pop(context);
                  if (onCancel != null) {
                    onCancel();
                  }
                },
              ),
        const SizedBox(
          height: 48.0,
          width: 0.6,
          child: VerticalDivider(),
        ),
        _DialogButton(
          text: rightText,
          textColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.pop(context);
            if (onConfirm != null) {
              onConfirm();
            }
          },
        ),
      ],
    );

    Widget body = Material(
      borderRadius: BorderRadius.circular(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 24),
          dialogTitle,
          content == null ? Container() : Flexible(child: content),
          const SizedBox(height: 8),
          const Divider(height: 1),
          bottomButton,
        ],
      ),
    );

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInCubic,
      child: MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: Center(
          child: SizedBox(
            width: 270.0,
            child: body,
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    Key key,
    this.text = '',
    this.textColor,
    this.onPressed,
  }) : super(key: key);

  final String text;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 48.0,
        child: TextButton(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.0,
              color: textColor,
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class CustomDialog extends Dialog {
  const CustomDialog({
    Key key,
    this.child,
    this.onDismiss,
    this.clickBgHidden =
        false, //Click Hide background. It is not hidden by default
  }) : super(key: key);

  @override
  // ignore: overridden_fields
  final Widget child;
  final bool clickBgHidden;
  final Function onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (clickBgHidden == true) {
                if (onDismiss != null) {
                  onDismiss();
                }
                Navigator.pop(context);
              }
            },
          ),
          Center(child: child)
//          child
        ],
      ),
    );
  }
}
