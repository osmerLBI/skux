import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:span_mobile/common/platform.dart';
import 'package:span_mobile/i18n/localize_js_loader.dart';
import 'package:span_mobile/models/platform.dart';
import 'package:span_mobile/pages/common/vlog.dart';
import 'package:span_mobile/pages/skux/auth/AuthenticationState.dart';
import 'package:span_mobile/pages/skux/auth/login.dart';
// import 'package:span_mobile/pages/skux/main/main.dart';

import 'common/app_theme.dart';

class App extends StatelessWidget {
  App({
    Key key,
    this.authenticationToken,
    this.refreshToken,
    this.expirationTimestamp,
  }) : super(key: key);

  String authenticationToken;
  String refreshToken;
  int expirationTimestamp;

  RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  ValueNotifier<GraphQLClient> getGraphQLClient(BuildContext context) {
    final AuthenticationState authenticationState =
        Provider.of<AuthenticationState>(context, listen: false);

    Link link;
    final HttpLink httpLink = HttpLink(
      'https://stageapp.skux.io/v1/graphql',
    );
    VLog(authenticationToken);
    VLog(refreshToken);

    if (authenticationToken != authenticationState.authenticationToken) {
      VLog("OH NO!!!");
    }

    if (authenticationToken != null &&
        refreshToken != null &&
        expirationTimestamp != null) {
      authenticationState.didAuthenticate(
          authenticationToken, refreshToken, expirationTimestamp);
    }

    final AuthLink authLink = AuthLink(
      getToken: () async =>
          'Bearer ${await Future.value(authenticationState.authenticationToken)}',
    );
    link = authLink.concat(httpLink);

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(),
      ),
    );

    return client;
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: getGraphQLClient(context),
      child: EasyLocalization(
        path: 'assets/translations',
        supportedLocales: platform.locales(),
        fallbackLocale: platform.fallbackLocale(),
        assetLoader: LocalizeJsLoader(),
        child: Builder(
          builder: (BuildContext context) {
            return MaterialApp(
              title: platform.name(),
              theme: ThemeData(
                primarySwatch: platform.swatchColor(),
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              debugShowCheckedModeBanner: false,
              navigatorObservers: [routeObserver],
              navigatorKey: navigatorKey,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: LoginPage(navigatorKey: navigatorKey),
              builder: (BuildContext context, Widget child) {
                return ResponsiveWrapper.builder(
                    FlutterEasyLoading(
                        child: Provider<PlatformModel>.value(
                      value: PlatformModel.global,
                      child: AppTheme(
                        child: MediaQuery(
                          child: child,
                          data: MediaQuery.of(context)
                              .copyWith(textScaleFactor: 1.0),
                        ),
                      ),
                    )),
                    maxWidth: 1200,
                    minWidth: 480,
                    defaultScale: false,
                    breakpoints: [
                      const ResponsiveBreakpoint.resize(600, name: MOBILE),
                      const ResponsiveBreakpoint.autoScale(800, name: TABLET),
                      const ResponsiveBreakpoint.autoScale(1000, name: TABLET),
                      const ResponsiveBreakpoint.resize(1200, name: DESKTOP),
                    ],
                    background: Container(color: Colors.transparent));
              },
            );
          },
        ),
      ),
    );
  }
}
