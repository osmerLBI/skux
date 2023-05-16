import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/widgets/unfocus.dart';

class IssuerStatement extends StatefulWidget {
  const IssuerStatement({Key key}) : super(key: key);

  @override
  State<IssuerStatement> createState() => _IssuerStatementState();
}

class _IssuerStatementState extends State<IssuerStatement> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: 'Issuer Statement',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          showCupertinoModalBottomSheet(
            context: context,
            isDismissible: false,
            enableDrag: false,
            expand: false,
            backgroundColor: SkuxStyle.bgColor,
            duration: const Duration(milliseconds: 300),
            builder: (context) => SizedBox(
              height: 450,
              child: _mainBody(),
            ),
          );
        },
        child: Text(
          'Issuer Statement',
          style: TextStyle(
            color: style.primaryColor,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _mainBody() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _top(),
              const SizedBox(
                height: 16,
              ),
              SingleChildScrollView(
                child: UnFocusWidget(
                  child: Semantics(
                    child: const Text(
                      'The Loyalty, Awards and Promotion Mastercard Prepaid Card is issued by Pathward, Member FDIC, pursuant to license by Mastercard International Incorporated. This is a loyalty, awards and promotional card which will be authorized for qualified purchases only as set forth in your Pathward card agreement. Valid only in the U.S. No cash access. Other languages are available upon request. Mastercard and the circles design are registered trademarks of Mastercard International Incorporated.',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: SkuxStyle.textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _top() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const ExcludeSemantics(
          child: SizedBox(
            width: 30,
            height: 30,
          ),
        ),
        Semantics(
          child: const Text(
            'Issuer Statement',
            style: TextStyle(fontSize: 18),
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

  void _backButtonClicked() {
    Navigator.pop(context);
  }
}
