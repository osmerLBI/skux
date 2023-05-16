// ignore_for_file: constant_identifier_names

import 'package:common_utils/common_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/pages/common/debug_widget.dart';
import 'package:span_mobile/pages/common/issuer_statement.dart';
import 'package:span_mobile/pages/common/jh_button.dart';
import 'package:span_mobile/pages/skux/auth/AuthenticationState.dart';
import 'package:span_mobile/pages/skux/auth/LoginFormState.dart';
import 'package:span_mobile/pages/skux/auth/terms.dart';
import 'package:span_mobile/pages/skux/graphql/login_mutation.dart';
import 'package:span_mobile/pages/skux/main/main.dart';
import 'package:span_mobile/widgets/unfocus.dart';

class LoginPage extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const LoginPage({Key key, @required this.navigatorKey}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  FocusNode _phoneFocusNode;
  FocusNode _codeFocusNode;
  final _formKey = GlobalKey<FormState>();

  bool _shouldShowVerificationCode;
  bool _isPhoneInputed;
  bool _canClick;
  bool _didChangePhoneNumber;

  Future isPreviouslyAuthenticated;

  @override
  void initState() {
    _phoneFocusNode = FocusNode();
    _codeFocusNode = FocusNode();

    _shouldShowVerificationCode = false;
    _isPhoneInputed = false;
    _canClick = false;
    _didChangePhoneNumber = false;

    isPreviouslyAuthenticated = _isPreviouslyAuthenticated(context);

    super.initState();
  }

  Future<bool> _isPreviouslyAuthenticated(BuildContext context) async {
    AuthenticationState authState =
        Provider.of<AuthenticationState>(context, listen: false);
    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SkuxMainPage()));
      });
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    // _phoneFocusNode?.unfocus();
    // _codeFocusNode?.unfocus();

    _phoneController.dispose();
    _codeController.dispose();
    _phoneFocusNode.dispose();
    _codeFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> _navigatorKey = widget.navigatorKey;
    const String SendVerificationMutation =
        r'''mutation SendVerificationCode($phoneNumber: String!) {
      sendVerificationCode(phoneNumber: $phoneNumber) {
        ... on InvalidPhoneNumberError {
          __typename
          errorCode
          message
        }
        ... on PhoneValidationInProcess {
          __typename
          success
          status
        }
        ... on PhoneValidationLimitReached {
          __typename
          errorCode
          message
        }
        ... on PrivacyPolicyRequired {
          __typename
          success
          status
          privacyPolicyLink
        }
        ... on PhoneValidationSuccess {
          __typename
          success
          status
        }
        ... on AccessDeniedError {
          __typename
          errorCode
          message
        }
      }
    }''';

    return GraphQLConsumer(
      builder: (GraphQLClient client) => FutureBuilder(
        future: isPreviouslyAuthenticated,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              widthFactor: double.infinity,
              heightFactor: double.infinity,
            );
          }
          return Scaffold(
            backgroundColor: SkuxStyle.bgColor,
            body: OrientationBuilder(builder: (context, orientation) {
              return Semantics(
                child: SafeArea(
                  child: Semantics(
                    explicitChildNodes: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SingleChildScrollView(
                          child: Semantics(
                            child: UnFocusWidget(
                              child: Semantics(
                                explicitChildNodes: true,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Semantics(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ExcludeSemantics(
                                            child: DebugWidget(
                                              child: _top(),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          Semantics(
                                            explicitChildNodes: true,
                                            header: true,
                                            sortKey: const OrdinalSortKey(0),
                                            child: Text(
                                              tr('Sign in with a phone number'),
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: SkuxStyle.textColor),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 24,
                                          ),
                                          Consumer<LoginFormState>(builder:
                                              (contxt, loginState, widget) {
                                            return Form(
                                              key: _formKey,
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Semantics(
                                                      textField: true,
                                                      explicitChildNodes: false,
                                                      excludeSemantics: true,
                                                      sortKey:
                                                          const OrdinalSortKey(
                                                              1),
                                                      hint: 'Phone Number Input'
                                                              '1' +
                                                          _phoneController.text,
                                                      onTapHint:
                                                          'Phone Number Input',
                                                      child: TextFormField(
                                                        keyboardType:
                                                            TextInputType.phone,
                                                        autofocus: true,
                                                        decoration:
                                                            InputDecoration(
                                                          errorText: loginState
                                                                  .phoneInputHasError()
                                                              ? loginState
                                                                  .phoneErrorMessageText
                                                              : null,
                                                          filled: true,
                                                          prefix: Semantics(
                                                            child: const Text(
                                                              '+1 ',
                                                            ),
                                                          ),
                                                          fillColor:
                                                              Colors.white,
                                                          border:
                                                              const OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                          ),
                                                          disabledBorder: const OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                      Radius.circular(
                                                                          10))),
                                                          enabledBorder:
                                                              const OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                          ),
                                                          hintText: tr(
                                                              'Phone Number'),
                                                        ),
                                                        controller:
                                                            _phoneController,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                        focusNode:
                                                            _phoneFocusNode,
                                                        textInputAction:
                                                            TextInputAction
                                                                .done,
                                                        onChanged: (string) {
                                                          if (loginState
                                                              .phoneInputHasError()) {
                                                            loginState
                                                                .setPhoneInputErrorMessage(
                                                                    '');
                                                          }
                                                          if (_shouldShowVerificationCode &&
                                                              _isPhoneInputed) {
                                                            setState(() {
                                                              _shouldShowVerificationCode =
                                                                  false;
                                                              _isPhoneInputed =
                                                                  false;
                                                              _canClick = false;
                                                              _didChangePhoneNumber =
                                                                  false;
                                                            });
                                                            loginState
                                                                .setCanSubmitVerificationCode(
                                                                    false);
                                                          }
                                                          setState(() {
                                                            _canClick =
                                                                string.length >
                                                                    9;
                                                          });
                                                        },
                                                        onTapOutside:
                                                            (PointerDownEvent
                                                                event) {
                                                          if (_shouldShowVerificationCode &&
                                                              _isPhoneInputed) {
                                                            setState(() {
                                                              _shouldShowVerificationCode =
                                                                  _didChangePhoneNumber ==
                                                                      false;
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    if (_shouldShowVerificationCode)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 10, 0, 60),
                                                        child: Semantics(
                                                          textField: true,
                                                          hint: 'SMS Code ' +
                                                              _codeController
                                                                  .text,
                                                          sortKey:
                                                              const OrdinalSortKey(
                                                                  2),
                                                          child: TextFormField(
                                                            decoration:
                                                                InputDecoration(
                                                              errorText: loginState
                                                                      .verificationCodeHasError()
                                                                  ? loginState
                                                                      .verificationCodeErrorMessageText
                                                                  : null,
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                              border:
                                                                  const OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                              disabledBorder:
                                                                  const OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                              enabledBorder:
                                                                  const OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                              hintText: tr(
                                                                  'SMS Code'),
                                                            ),
                                                            controller:
                                                                _codeController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            onChanged:
                                                                (string) {
                                                              loginState
                                                                  .setCanSubmitVerificationCode(
                                                                      string
                                                                          .isNotEmpty);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    if (_isPhoneInputed)
                                                      LoginMutation(
                                                          _phoneController,
                                                          _codeController,
                                                          loginState,
                                                          navigatorKey:
                                                              _navigatorKey),
                                                    if (!_isPhoneInputed)
                                                      Mutation(
                                                        options:
                                                            MutationOptions(
                                                          document: gql(
                                                              SendVerificationMutation),
                                                          onCompleted: (dynamic
                                                              resultData) {
                                                            EasyLoading
                                                                .dismiss();
                                                            if (resultData[
                                                                        'sendVerificationCode']
                                                                    [
                                                                    '__typename'] ==
                                                                "PhoneValidationSuccess") {
                                                              _needInputSMS();
                                                            } else if (resultData[
                                                                        'sendVerificationCode']
                                                                    [
                                                                    '__typename'] ==
                                                                "PrivacyPolicyRequired") {
                                                              _showTermsAndConditionsMutation(
                                                                  resultData[
                                                                      'sendVerificationCode'],
                                                                  _phoneController
                                                                      .text);
                                                            } else if (resultData[
                                                                        'sendVerificationCode']
                                                                    [
                                                                    '__typename'] ==
                                                                "AccessDeniedError") {
                                                              loginState
                                                                  .setPhoneInputErrorMessage(
                                                                      'Invalid Phone Number...');
                                                              Util.showErrorDialog(
                                                                  context:
                                                                      context,
                                                                  msg: resultData[
                                                                          'sendVerificationCode']
                                                                      [
                                                                      'message']);
                                                            } else {
                                                              Util.showErrorDialog(
                                                                  context:
                                                                      context,
                                                                  msg: resultData[
                                                                          'sendVerificationCode']
                                                                      [
                                                                      'message']);
                                                              return;
                                                            }
                                                          },
                                                          onError:
                                                              (OperationException
                                                                  error) {
                                                            EasyLoading
                                                                .dismiss();
                                                            _codeController
                                                                .text = '';
                                                            _isPhoneInputed =
                                                                false;
                                                            setState(() {
                                                              _shouldShowVerificationCode =
                                                                  false;
                                                            });
                                                          },
                                                        ),
                                                        builder: (
                                                          RunMutation
                                                              runMutation,
                                                          QueryResult result,
                                                        ) {
                                                          // @TODO: Format this to be above issuer statement.
                                                          //        not directly below inputs.
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 70),
                                                            child: JhButton(
                                                                onPressed:
                                                                    _canClick ==
                                                                            false
                                                                        ? null
                                                                        : () {
                                                                            EasyLoading.show(
                                                                                dismissOnTap: false,
                                                                                status: "Sending you a verification code...");
                                                                            runMutation({
                                                                              "phoneNumber": '+1' + _phoneController.text.trim(),
                                                                            });
                                                                          },
                                                                // onPressed: () =>
                                                                //     {
                                                                //       startOnpressed(),
                                                                //     },
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                width: 182,
                                                                height: 40,
                                                                text: tr(
                                                                    'Continue'),
                                                                fontSize: 15,
                                                                weight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: style
                                                                    .primaryColor),
                                                          );
                                                        },
                                                      ),
                                                  ]),
                                            );
                                          }),
                                        ]),
                                    explicitChildNodes: true,
                                  ),
                                ),
                              ),
                            ),
                            explicitChildNodes: true,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: IssuerStatement(),
                        ),
                      ],
                    ),
                  ),
                ),
                explicitChildNodes: true,
              );
            }),
          );
        },
      ),
    );
  }

  void startOnpressed() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return SkuxMainPage();
    }));
  }

  Widget _top() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 30,
        ),
        ExcludeFocus(
          child: ExtendedImage.asset(
            'assets/image/skux/login_person.png',
            width: 160,
            height: 160,
          ),
        ),
        const SizedBox(
          width: 30,
        ),
      ],
    );
  }

  void _showTermsAndConditionsMutation(resp, _phoneNumber) async {
    String type = resp['__typename'];
    if (type == 'PrivacyPolicyRequired') {
      String termUrl = resp['privacyPolicyLink'];
      const String PrivacyPolicyAcceptedMutation =
          r'''mutation PrivacyPolicyAccepted($phoneNumber: String!) {
            privacyPolicyAccepted(phoneNumber: $phoneNumber) {
              ... on InvalidPhoneNumberError {
                errorCode
                message
              }
              ... on PrivacyPolicyAcceptedSuccess {
                success
                status
              }
              ... on AccessDeniedError {
                errorCode
                message
              }
            }
          }
          ''';
      showCupertinoModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        expand: false,
        backgroundColor: SkuxStyle.bgColor,
        duration: const Duration(milliseconds: 300),
        builder: (context) => Mutation(
          options: MutationOptions(
            document: gql(PrivacyPolicyAcceptedMutation),
            onCompleted: (dynamic resultData) {
              EasyLoading.dismiss();
              if (resultData['privacyPolicyAccepted']['errorCode'] != null) {
                Util.showErrorDialog(
                    context: context,
                    msg: resultData['privacyPolicyAccepted']['message']);
              }
            },
            onError: (OperationException error) {
              EasyLoading.dismiss();
            },
          ),
          builder: (
            RunMutation runMutation,
            QueryResult result,
          ) {
            return TermsPage(
              url: termUrl,
              onAcceptClicked: () async {
                EasyLoading.show(status: "Accepting the Terms & Conditions...");
                runMutation({
                  "phoneNumber": '+1' + _phoneNumber.trim(),
                });
                _needInputSMS();
              },
            );
          },
        ),
      );
    } else {
      _needInputSMS();
    }
  }

  void _needInputSMS() {
    setState(() {
      _isPhoneInputed = true;
      _shouldShowVerificationCode = true;
      _codeFocusNode.requestFocus();
    });
  }
}
