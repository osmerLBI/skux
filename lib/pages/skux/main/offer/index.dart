// ignore_for_file: constant_identifier_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:span_mobile/common/skux/skux_info.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/pages/common/vlog.dart';
import 'package:span_mobile/pages/skux/auth/AuthenticationState.dart';
import 'package:span_mobile/pages/skux/main/offer/horizontal_offer_item.dart';
import 'package:span_mobile/pages/skux/main/offer/vertical_offer_item.dart';
import 'package:span_mobile/pages/skux/main/offer/recently_viewed_offer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:span_mobile/widgets/no_data_tip.dart';

class OfferPage extends HookWidget {
  const OfferPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List _recentOffers;

    const String GetOffersQuery =
        r'''query GetOffers($options: OfferListOptions) {
          offers(options: $options) {
            items {
              uuid
              type
              description
              bannerUrl
              contentUrl
              amountInCents
              status
              expiresAt
              assignedOn
              userCard {
                ... on UserCard {
                  uuid
                  maskedCardNumber
                  cardName
                  cardImage
                  status
                  accountNumber
                }
                ... on ExternalError {
                  errorCode
                  message
                }
              }
              retailers {
                uuid
                name
                logoUrl
                totalOffers
              }
            }
            totalItems
          }
        }
      ''';

    QueryOptions offersGraphQLOptions = QueryOptions(
        document: gql(GetOffersQuery),
        onError: (error) async {
          await showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: Semantics(
                  excludeSemantics: true,
                  label: 'Alert Error',
                  child: const Text('Error'),
                ),
                content: const Text(
                    'There was an error fetching offers.  Please try again...'),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text(tr('OK')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 8),
                    ),
                    onPressed: () async {
                      AuthenticationState authState =
                          Provider.of<AuthenticationState>(context,
                              listen: false);
                      await Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false)
                          .whenComplete(
                              () async => await authState.didUnauthenticate());
                    },
                  ),
                ],
              );
            },
          );
        },
        onComplete: (data) async {
          SchedulerBinding.instance.addPostFrameCallback((_) async {
            EasyLoading.dismiss();
          });
        });

    void _viewRecentButtonClicked() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecentlyViewEdOfferPage(
            offers: _recentOffers,
          ),
        ),
      );
    }

    Widget _recentViewedTitle() {
      return Semantics(
        label: 'Recently Viewed Area, can scroll horizontal to view more.',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              header: true,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  tr('Recently Viewed'),
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: SkuxStyle.textColor),
                ),
              ),
            ),
            Semantics(
              button: true,
              label: 'View all recently offers',
              excludeSemantics: true,
              child: IconButton(
                onPressed: _viewRecentButtonClicked,
                icon: SvgPicture.asset('assets/image/skux/arrow_right.svg'),
              ),
            ),
          ],
        ),
        explicitChildNodes: true,
      );
    }

    return Query(
        options: offersGraphQLOptions,
        builder: (results, {fetchMore, refetch}) {
          if (results.isLoading == true) {
            EasyLoading.show(dismissOnTap: false, status: 'Fetching offers...');
          }
          // ignore: null_aware_in_logical_operator
          if (results.isNotLoading && results.data != null) {
            if (results.data['offers'] != null) {
              Map offers = results.data['offers'];
              List items = offers['items'];
              List recentItems = [];
              final future =
                  useMemoized(() => SkuxInfo.getCurrentRecentViewed());
              final snapshot = useFuture(future);
              if (snapshot.hasData) {
                recentItems = items.where((element) {
                  return snapshot.data.contains(element['uuid']);
                }).toList();
                _recentOffers = recentItems;
                VLog(recentItems, tag: 'Recent Offers');
              }
              return Scaffold(
                backgroundColor: SkuxStyle.bgColor,
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                  child: RefreshIndicator(
                    onRefresh: refetch,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          _recentViewedTitle(),
                          // @TODO Check for no offers
                          if (recentItems.isNotEmpty)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: recentItems
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.only(
                                                right: 18),
                                            child: HorizontalOfferItem(
                                                item: e,
                                                scrollDirection:
                                                    Axis.horizontal),
                                          ))
                                      .toList()),
                            ),
                          if (recentItems.isEmpty)
                            const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: NoDataTip()),
                          Semantics(
                            header: true,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                tr('All Offers'),
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: SkuxStyle.textColor),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: items
                                .map(
                                  (e) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: VerticalOfferItem(
                                          item: e,
                                          scrollDirection: Axis.vertical)),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          }
          return Container();
        });
  }
}
