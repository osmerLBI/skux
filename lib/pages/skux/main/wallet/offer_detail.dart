// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:span_mobile/common/skux/skux_info.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/util.dart';
// import 'package:span_mobile/common/vt_common.dart';
import 'package:span_mobile/pages/common/jh_button.dart';
import 'package:span_mobile/pages/common/web_view.dart';
import 'package:span_mobile/pages/skux/auth/AuthenticationState.dart';
import 'package:span_mobile/pages/skux/graphql/claim_offer_button_mutation.dart';
import 'package:span_mobile/states/event_hub_state.dart';
import 'package:span_mobile/widgets/unfocus.dart';

class OfferDetailPage extends StatefulWidget {
  const OfferDetailPage({
    Key key,
    this.offer,
    this.hideButton = false,
  }) : super(key: key);
  final Map offer;
  final bool hideButton;

  @override
  State<OfferDetailPage> createState() => _OfferDetailPageState();
}

class _OfferDetailPageState extends EventHubState<OfferDetailPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  bool _showButtons;

  @override
  void initState() {
    super.initState();
    _showButtons = false;
    Util.postFrame((p0) async {
      await SkuxInfo.writeRecentViewed(widget.offer['uuid']);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return SafeArea(
            child: _webView(context),
          );
        },
      ),
      backgroundColor: SkuxStyle.bgColor,
    );
  }

  Uri getWebViewUrl(url) {
    Uri skuxURL = Uri.parse(url);
    AuthenticationState authenticationState = Provider.of<AuthenticationState>(context, listen: false);
    return Uri(
        scheme: skuxURL.scheme, host: skuxURL.host, path: skuxURL.path, queryParameters: {'access_token': authenticationState.authenticationToken});
  }

  Widget _webView(BuildContext context) {
    return SingleChildScrollView(
      child: UnFocusWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.bottom -
                  MediaQuery.of(context).padding.top -
                  100,
              child: WebViewPage(
                url: getWebViewUrl(widget.offer['contentUrl']).toString(),
                onLoadFinished: () {
                  setState(() {
                    _showButtons = true;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            if ((_showButtons == true) && (widget.offer['status'] == 'REDEEMED'))
              Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Semantics(
                      sortKey: const OrdinalSortKey(1),
                      button: false,
                      child: const JhButton(
                        onPressed: null,
                        text: 'This offer has been redeemed.',
                        height: 40,
                        width: 300,
                      ))),
            if ((_showButtons == true) && (widget.offer['status'] == 'ACTIVE'))
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Semantics(
                  sortKey: const OrdinalSortKey(1),
                  button: true,
                  child: ClaimOfferButtonMutation(
                    offerUuid: widget.offer['uuid'],
                    buttonText: (widget.offer['userCard']['__typename'] == 'UserCard') ? 'Show Card' : 'Claim Offer',
                    isClaimButton: widget.offer['userCard']['__typename'] != 'UserCard',
                    isDisabled: widget.offer['status'] != 'ACTIVE',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
