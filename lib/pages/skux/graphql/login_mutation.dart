// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/pages/common/jh_button.dart';
import 'package:span_mobile/pages/common/vlog.dart';
import 'package:span_mobile/pages/skux/auth/AuthenticationState.dart';
import 'package:span_mobile/pages/skux/auth/LoginFormState.dart';
import 'package:span_mobile/pages/skux/graphql/last_offer_viewed_query.dart';
import 'package:span_mobile/pages/skux/graphql/login_endpoint_query.dart';
import 'package:span_mobile/pages/skux/graphql/refresh_token_mutation.dart';
import 'package:span_mobile/pages/skux/main/main.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginMutation extends HookWidget {
  LoginMutation(this.phoneController, this.codeController, this.loginFormState, {Key key, this.navigatorKey}) : super(key: key);

  StreamSubscription _sub;
  AuthenticationState authState;

  final TextEditingController phoneController;
  final TextEditingController codeController;
  LoginFormState loginFormState;
  GraphQLClient client;
  final GlobalKey<NavigatorState> navigatorKey;

  final String LoginMutationString = r'''mutation Login($input: LoginInput!) {
        login(input: $input) {
      ... on User {
        uuid
        phoneNumber
        displayName
        profile {
          firstName
          lastName
          emailAddress
          emailAddressVerified
          hasIdentityProvider
        }
      }
      ... on InvalidPhoneNumberError {
        errorCode
        message
      }
      ... on InvalidVerificationCodeError {
        errorCode
        message
      }
      ... on PhoneValidationLimitReached {
        errorCode
        message
      }
      ... on AccessDeniedError {
        errorCode
        message
      }
    }
  }
  ''';

  void showMainPage() {
    phoneController.text = '';
    codeController.text = '';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await navigatorKey.currentState.push(MaterialPageRoute(builder: (context) => const SkuxMainPage()));
    });
  }

  Future<void> _handleLinkFromSocialLogin(Uri uri, context, refreshToken) async {
    if (uri.path != null && uri.path.contains('continue')) {
      RefreshTokenGraphQL refreshTokenGraphQL = RefreshTokenGraphQL(client: client);
      await refreshTokenGraphQL.mutation(refreshToken).then((value) async {
        if (value.data['refreshToken']['success'] == true) {
          AuthenticationState authState = Provider.of<AuthenticationState>(context, listen: false);
          await authState.didAuthenticate(
            value.context.entry<HttpLinkResponseContext>().headers['x-skux-access-token'],
            value.context.entry<HttpLinkResponseContext>().headers['x-skux-refresh-token'],
            value.context.entry<HttpLinkResponseContext>().headers['x-skux-token-expiration'],
          );
        } else {
          await Provider.of<AuthenticationState>(context, listen: false).didUnauthenticate();
        }
        return value;
      }).then((value) async {
        if (value.data['refreshToken']['success'] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          LastOfferViewedQueryGraphQL lastOfferGraphQL = LastOfferViewedQueryGraphQL(client: client, firstTime: prefs.getBool('first_time'));
          QueryResult result = await lastOfferGraphQL.query();
          if (result.data != null && result.data['lastOfferViewed']['__typename'] == 'OfferNotFoundError') {
            showMainPage();
            return;
          }
          if (result.data['lastOfferViewed']['offer'] != null) {
            showMainPage();
            return;
          }
        }
      });
    }
    if (uri.path != null && uri.toString().contains('cancel?reason')) {
      String query = uri.query;
      if (query.isNotEmpty) {
        query = query.replaceFirst('reason=', '');

        await Util.showErrorDialog(context: Util.context, msg: query ?? '');
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var canClick = useState(false);

    client = useGraphQLClient();
    authState = Provider.of<AuthenticationState>(context, listen: false);

    useEffect(() {
      _sub = uriLinkStream.listen(
        (uri) => {
          SchedulerBinding.instance.addPostFrameCallback((_) async {
            await _handleLinkFromSocialLogin(uri, context, authState.refreshToken);
          })
        },
        onError: (Object err) async {
          VLog('got err: $err');
          await EasyLoading.dismiss();
        },
      );
      return _sub.cancel;
    }, [_sub]);

    return JhButton(
        onPressed: loginFormState.canSubmitVerificationCode == false && canClick.value == false
            ? null
            : () async {
                await EasyLoading.show(dismissOnTap: true);
                loginFormState.setCanSubmitVerificationCode(false);
                canClick.value = false;
                loginFormState.setVerificationCodeErrorMessage('');
                final MutationOptions options = MutationOptions(
                  document: gql(LoginMutationString),
                  variables: {
                    'input': {
                      "phoneNumber": '+1' + phoneController.text.trim(),
                      "verificationCode": codeController.text.trim(),
                      "deviceId": 'impossible_test_id',
                    },
                  },
                  onCompleted: (data) {
                    EasyLoading.dismiss();
                  },
                );
                await client.mutate(options).then((value) async {
                  if (value.data['login']['__typename'] == 'User') {
                    await authState.didAuthenticate(
                      value.context.entry<HttpLinkResponseContext>().headers['x-skux-access-token'],
                      value.context.entry<HttpLinkResponseContext>().headers['x-skux-refresh-token'],
                      value.context.entry<HttpLinkResponseContext>().headers['x-skux-token-expiration'],
                    );
                    if (value.data['login']['profile']['hasIdentityProvider'] == true) {
                      showMainPage();
                    } else {
                      LoginEndpointGraphQL loginEndpointGraphQL = LoginEndpointGraphQL(client: client);
                      QueryResult loginEndpointValue = await loginEndpointGraphQL.query();
                      Uri uri = Uri.parse(loginEndpointValue.data['getLoginEndpoint']['URL']);
                      await EasyLoading.show(dismissOnTap: true, status: 'Waiting for social login, please retry if failed.');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        await EasyLoading.dismiss();
                        await Util.showErrorDialog(context: context, msg: 'Error social url');
                      }
                      canClick.value = true;
                    }
                  } else {
                    // @TODO: Show ERRORS and handle exception
                    loginFormState.setVerificationCodeErrorMessage(value.data['login']['message']);
                  }
                });
              },
        borderRadius: BorderRadius.circular(8),
        width: 182,
        height: 40,
        text: tr('Continue'),
        fontSize: 15,
        weight: FontWeight.w600,
        color: style.primaryColor);
  }
}
