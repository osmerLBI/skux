import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:span_mobile/common/skux/skux_info.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/common/vt_common.dart';
import 'package:span_mobile/pages/common/debug_widget.dart';
import 'package:span_mobile/pages/common/issuer_statement.dart';
import 'package:span_mobile/pages/common/jh_button.dart';
import 'package:span_mobile/pages/skux/auth/terms.dart';
import 'package:span_mobile/pages/skux/common/add_wallet.dart';
import 'package:span_mobile/pages/skux/common/card.dart';
import 'package:span_mobile/pages/skux/main/wallet/offer_detail_wallet.dart';
import 'package:span_mobile/states/event_hub_state.dart';
import 'package:span_mobile/widgets/line_separator.dart';
import 'package:span_mobile/widgets/no_data_tip.dart';
import 'package:widget_loading/widget_loading.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:span_mobile/pages/skux/main/wallet/google_pay.dart';
// import 'package:span_mobile/pages/skux/main/wallet/google_wallet.dart';
import 'package:span_mobile/pages/skux/main/wallet/wallet_apple.dart';
import 'package:span_mobile/pages/skux/main/wallet/wallet_apple_dynamic.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({String uuid, Key key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends EventHubState<WalletPage> {
  // static const platform = MethodChannel('samples.flutter.dev/battery');
  List _activeOffers;
  List _redeemedOffers;
  List _expiredOffers;
  List _cards;
  bool _loading;
  bool _imageLoading;
  int _currentCardIndex;

  final bool _hasAddedToWallet = false;
  final List _introduces = [
    {'key': '1', 'value': tr('Scan items at checkout')},
    {
      'key': '2',
      'value': Platform.isIOS
          ? tr('Use  Pay to pay with this card')
          : tr('Use Google Pay to pay with this card')
    },
    {'key': '3', 'value': tr('Pay the rest with your bank card or cash')},
  ];

  final ValueNotifier<String> _segmentController =
      ValueNotifier<String>('active');

  final EasyRefreshController _refreshCtrl = EasyRefreshController();
  final SwiperController _swipController = SwiperController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _termsNode = FocusNode();

  String queryStr =
      r'''
    query {
      getUserCards {
        __typename
        ... on UserCardList {
          totalItems
          items {
            uuid
            maskedCardNumber
            cardName
            cardImage
            status
            termsAndConditionsUrl
            accountNumber
            userPurses {
              totalItems
              items {
                uuid
                offerUUID
                offerCodeUUID
                status
                userCard {
                  uuid
                  maskedCardNumber
                  cardName
                  cardImage
                  status
                  accountNumber
                }
                offer {
                  uuid
                  type
                  description
                  bannerUrl
                  contentUrl
                  amountInCents
                  retailers {
                    uuid
                    name
                    logoUrl
                  }
                  status
                  expiresAt
                  assignedOn
                }
              }
            }
          }
        }
      }
    }
    ''';

  @override
  void initState() {
    _activeOffers = [];
    _redeemedOffers = [];
    _expiredOffers = [];
    _cards = [];
    _loading = true;
    _imageLoading = true;
    _currentCardIndex = 0;

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _termsNode.dispose();
    _refreshCtrl.dispose();
    _swipController.dispose();

    super.dispose();
  }

  // String _batteryLevel = 'Unknown battery level.';
  // Future<void> _getBatteryLevel() async {
  //   String batteryLevel;
  //   try {
  //     final int result = await platform.invokeMethod('getBatteryLevel');
  //     batteryLevel = 'Battery level at $result % .';
  //   } on PlatformException catch (e) {
  //     batteryLevel = "Failed to get battery level: '${e.message}'.";
  //   }
  //   setState(() {
  //     _batteryLevel = batteryLevel;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (_cards.isNotEmpty) {
      _sortOffers(_currentCardIndex);
    }
    return Scaffold(
      backgroundColor: SkuxStyle.bgColor,
      body: OrientationBuilder(
        builder: (context, orientation) {
          return SafeArea(
            child: Query(
              options: QueryOptions(
                document: gql(queryStr),
                onComplete: (data) {
                  if (data.isNotEmpty &&
                      data['getUserCards']['items'].length > 0) {
                    setState(() {
                      _cards = List.from(data['getUserCards']['items']);
                      _loading = false;
                      // _sortOffers(_currentCardIndex);
                      // _refreshCtrl.finishRefresh(success: true);
                      // for (var card in _cards) {
                      //   List _userPurses =
                      //       List.from(card['userPurses']['items']);
                      //   for (var user in _userPurses) {
                      //     user.forEach((key, value) {
                      //       debugPrint('$key : $value');
                      //     });
                      //   }
                      //   card.forEach((key, value) {
                      //     debugPrint('$key : $value');
                      //   });
                      // }
                      _imageLoading = false;
                    });
                    // _sortOffers(_currentCardIndex);
                  } else {
                    setState(() {
                      _loading = false;
                      _currentCardIndex = 0;
                      _imageLoading = false;
                    });
                  }
                },
              ),
              builder: (QueryResult result, {fetchMore, refetch}) {
                if (_loading) {
                  return Semantics(
                    explicitChildNodes: true,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _header(),
                          Center(
                              heightFactor: 20.0,
                              widthFactor: MediaQuery.of(context).size.width,
                              child: const Text(
                                  "One moment while we fetch your wallet..."))
                        ],
                      ),
                    ),
                  );
                }
                return EasyRefresh(
                  onRefresh: () async {
                    await refetch();
                  },
                  controller: _refreshCtrl,
                  header: BallPulseHeader(),
                  child: SingleChildScrollView(
                    // child: UnFocusWidget(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Semantics(
                        explicitChildNodes: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _header(),
                            const SizedBox(height: 16),
                            const IssuerStatement(),
                            const SizedBox(height: 8),

                            if (ObjectUtil.isNotEmpty(_cards)) _cardsArea(),
                            if (ObjectUtil.isNotEmpty(_cards))
                              Semantics(
                                label: ['PFRAUD', 'FRAUD'].contains(
                                        _cards[_currentCardIndex]['status']
                                            .toUpperCase())
                                    ? 'Restricted'
                                    : (_cards[_currentCardIndex]['status'] ??
                                            '')
                                        .toString()
                                        .toUpperCase(),
                                textField: true,
                                excludeSemantics: true,
                                child: Text(
                                  ['PFRAUD', 'FRAUD'].contains(
                                          _cards[_currentCardIndex]['status']
                                              .toUpperCase())
                                      ? 'Restricted'
                                      : (_cards[_currentCardIndex]['status'] ??
                                              '')
                                          .toString()
                                          .toUpperCase(),
                                  style: TextStyle(
                                    color: _cards[_currentCardIndex]['status']
                                                .toLowerCase() ==
                                            'active'
                                        ? SkuxStyle.greenColor
                                        : SkuxStyle.redColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            const SizedBox(
                              height: 4,
                            ),
                            if (ObjectUtil.isEmpty(_cards) &&
                                result.isLoading == false)
                              _offerPromptText(),
                            if (ObjectUtil.isNotEmpty(_cards))
                              Semantics(
                                child: GestureDetector(
                                  child: Focus(
                                    child: const Text(
                                      'Terms & Conditions',
                                      style: TextStyle(
                                        color: Color(0xFF046ED7),
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    focusNode: _termsNode,
                                  ),
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _openTermsClicked,
                                ),
                                button: true,
                                label: 'Terms & Conditions',
                                excludeSemantics: true,
                              ),
                            const SizedBox(height: 32),
                            // _hasAddedToWallet == false ? _walletArea() : _openWidgetButton(),
                            if (ObjectUtil.isNotEmpty(_cards) &&
                                result.isLoading == false)
                              // GooglePay(amount: '99.9'),
                              const SizedBox(height: 32),
                            if (ObjectUtil.isNotEmpty(_cards)) _segment(),
                            const SizedBox(height: 32),
                            if (ObjectUtil.isNotEmpty(_cards))
                              _segmentContent(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                // );
              },
            ),
          );
        },
      ),
    );
  }

  // Widget _nativeAnd() {
  //   return Semantics(
  //       child: Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: [
  //         ElevatedButton(
  //           onPressed: _getBatteryLevel,
  //           child: const Text('Get Battery Level'),
  //         ),
  //         Text(_batteryLevel),
  //       ],
  //     ),
  //   ));
  // }

  Widget _introduceArea() {
    return Semantics(
      explicitChildNodes: true,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              header: true,
              child: Text(
                tr('How to use'),
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: SkuxStyle.textColor),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              child: Text(
                tr('Pay for active offers with this card'),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: SkuxStyle.textColor),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Semantics(
            explicitChildNodes: true,
            child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, index) {
                  return _introduceItem(_introduces[index]);
                },
                separatorBuilder: (_, index) {
                  return const SizedBox(
                    height: 16,
                  );
                },
                itemCount: _introduces.length),
          ),
        ],
      ),
    );
  }

  Widget _expiredInfo() {
    return Semantics(
      explicitChildNodes: true,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              child: Text(
                tr('Why this happened') + '?',
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: SkuxStyle.textColor),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            child: Text(
              tr("Every offer has its expiration date. If you don't want to miss it pay attention to this date or to the \"Expires soon\" section in the offers tab."),
              style:
                  const TextStyle(fontSize: 15, color: SkuxStyle.text64Color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Semantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DebugWidget(
            child: Semantics(
              header: true,
              child: Focus(
                child: Text(
                  tr('My Card'),
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w600),
                ),
                focusNode: _focusNode,
              ),
            ),
          ),
        ],
      ),
      explicitChildNodes: true,
    );
  }

  Widget _cardsArea() {
    double h = 226 * ((VTCommon.screenWidth) * 0.9 * 0.8 / 358) > 226
        ? 226
        : 226 * ((VTCommon.screenWidth) * 0.9 * 0.8 / 358);
    return CircularWidgetLoading(
      child: ObjectUtil.isNotEmpty(_cards)
          ? ConstrainedBox(
              constraints:
                  BoxConstraints.loose(Size(VTCommon.screenWidth - 16 - 16, h)),
              child: Swiper(
                itemBuilder: (context, index) {
                  Map card = _cards[index];
                  return Semantics(
                    explicitChildNodes: false,
                    excludeSemantics: true,
                    button: true,
                    label: "Card number ${card['maskedCardNumber']}, card status ${card['status']}" +
                        (['PFRAUD', 'FRAUD']
                                .contains(card['status'].toUpperCase())
                            ? 'Your account has been restricted. Please email us at programs@skux.io for assistance. We apologize for any inconvenience.'
                            : ''),
                    child: SkuxCard(
                      cardNumber: card['maskedCardNumber'],
                      imgSrc: card['cardImage'],
                      status: card['status'],
                    ),
                  );
                },
                itemCount: _cards.length,
                viewportFraction: 0.8,
                scale: 0.9,
                onIndexChanged: (index) async {
                  _sortOffers(index);
                  setState(() {
                    _currentCardIndex = index;
                  });
                },
                index: _currentCardIndex,
                loop: false,
                controller: _swipController,
              ),
            )
          : SizedBox(
              width: VTCommon.screenWidth,
              height: 226,
            ),
      loading: _imageLoading,
    );
  }

  Widget _walletArea() {
    return SkuxAddWallet(
      onClick: _walletButtonClicked,
    );
  }

  Widget _offerPromptText() {
    return Semantics(
        label: 'Claim offer instructions',
        child: Column(
          children: const [
            SizedBox(height: 30),
            Padding(
              child: Text(
                  'Uh oh!  You don\'t have a card yet.  Claim an offer in order to have a Card issued.'),
              padding: EdgeInsets.fromLTRB(30, 50, 30, 0),
            ),
          ],
        ));
  }

  void _walletButtonClicked() {}

  Widget _openWidgetButton() {
    return Semantics(
      button: true,
      child: JhButton(
          onPressed: _openWidgetButtonClicked,
          borderRadius: BorderRadius.circular(8),
          width: 182,
          height: 40,
          text:
              Platform.isIOS == true ? tr('Open  Pay') : tr('Open Google Pay'),
          fontSize: 15,
          weight: FontWeight.w600,
          textColor: Colors.white,
          color: style.primaryColor),
    );
  }

  void _openWidgetButtonClicked() {}

  Widget _segment() {
    return SizedBox(
      height: 32,
      child: AdvancedSegment(
        controller: _segmentController, // AdvancedSegmentController
        segments: {
          'active': tr('Active Offers'),
          'redeemed': tr('Redeemed'),
          'expired': tr('Expired'),
        },
        activeStyle: const TextStyle(
          // TextStyle
          color: Color(0xFF70728F),
          fontSize: 13,
        ),
        inactiveStyle: const TextStyle(
          // TextStyle
          color: SkuxStyle.inactiveWithLightGreyColor,
          fontSize: 13,
        ),
        backgroundColor: const Color(0xFFeceef6), // Color
        sliderColor: Colors.white, // Color
        sliderOffset: 2.0, // Double
        borderRadius:
            const BorderRadius.all(Radius.circular(8.0)), // BorderRadius
        itemPadding: const EdgeInsets.symmetric(
          // EdgeInsets
          horizontal: 15,
          vertical: 10,
        ),
        animationDuration: const Duration(milliseconds: 250), // Duration
      ),
    );
  }

  Widget _segmentContent() {
    return ValueListenableBuilder<String>(
      valueListenable: _segmentController,
      builder: (_, key, __) {
        switch (key) {
          case 'active':
            return Semantics(
              explicitChildNodes: true,
              child: Column(
                children: [
                  CircularWidgetLoading(
                    child: _activeOffers.isEmpty
                        ? const NoDataTip(
                            refresh: true,
                          )
                        : Semantics(
                            child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (ct, index) {
                                  return _googleWallet(_activeOffers[index]);
                                },
                                separatorBuilder: (ct, index) {
                                  return const LineSeparator();
                                },
                                itemCount: _activeOffers.length),
                            explicitChildNodes: true,
                          ),
                    loading: _loading,
                  ),
                  const SizedBox(height: 40),
                  _introduceArea(),
                ],
              ),
            );
          case 'redeemed':
            return CircularWidgetLoading(
              child: _redeemedOffers.isEmpty
                  ? const NoDataTip(
                      refresh: true,
                    )
                  : Semantics(
                      explicitChildNodes: true,
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (ct, index) {
                            return _offerCard(_redeemedOffers[index]);
                          },
                          separatorBuilder: (ct, index) {
                            return const LineSeparator();
                          },
                          itemCount: _redeemedOffers.length),
                    ),
              loading: _loading,
            );
          case 'expired':
            return Semantics(
              explicitChildNodes: true,
              child: Column(
                children: [
                  CircularWidgetLoading(
                    child: _expiredOffers.isEmpty
                        ? const NoDataTip(
                            refresh: true,
                          )
                        : Semantics(
                            explicitChildNodes: true,
                            child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (ct, index) {
                                  return _offerCard(_expiredOffers[index]);
                                },
                                separatorBuilder: (ct, index) {
                                  return const LineSeparator();
                                },
                                itemCount: _expiredOffers.length),
                          ),
                    loading: _loading,
                  ),
                  const SizedBox(height: 40),
                  _expiredInfo(),
                ],
              ),
            );
          default:
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Semantics(
                child: const Text('Nothing here'),
              ),
            );
        }
      },
    );
  }

  Widget _googleWallet(Map item) {
    return Center(
        child: Column(
      children: [
        _offerCard(item),
        Semantics(
            button: true,
            child: JhButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    // enableDrag: false,
                    // isDismissible: false,
                    builder: (context) {
                      return Wrap(
                        children: [
                          AppleWallet(offer: item),
                        ],
                      );
                    },
                  );
                },
                borderRadius: BorderRadius.circular(8),
                width: 182,
                height: 40,
                text: Platform.isIOS == true
                    ? tr('Open  Wallet')
                    : tr('Open Google Wallet'),
                fontSize: 15,
                weight: FontWeight.w600,
                textColor: Colors.white,
                color: style.primaryColor)),
        Semantics(
            button: true,
            child: JhButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    // enableDrag: false,
                    // isDismissible: false,
                    builder: (context) {
                      return Wrap(
                        children: [
                          AppleWalletDynamic(offer: item),
                        ],
                      );
                    },
                  );
                },
                borderRadius: BorderRadius.circular(8),
                width: 182,
                height: 40,
                text: Platform.isIOS == true
                    ? tr('Dynamic  Wallet')
                    : tr('Dynamic Google Wallet'),
                fontSize: 15,
                weight: FontWeight.w600,
                textColor: Colors.white,
                color: style.primaryColor)),
      ],
    ));
  }

  Widget _offerCard(Map item) {
    Map offer = item['offer'];
    return Semantics(
      label:
          'Double-tap to Enter offer detail page.  ${offer['description']}  ${Util.formatMoney(int.parse(offer['amountInCents'].toString() ?? '0'))}' +
              (offer['status'] == 'EXPIRED' ? 'Expired: ' : 'Expires: ') +
              Util.formatTime(offer['expiresAt'],
                  format: SkuxInfo.dateTimeFormat),
      explicitChildNodes: false,
      excludeSemantics: true,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Semantics(
            explicitChildNodes: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Semantics(
                    explicitChildNodes: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Semantics(
                          explicitChildNodes: true,
                          child: ClipOval(
                              child: ExtendedImage.network(
                            ObjectUtil.isNotEmpty(offer['retailers'])
                                ? offer['retailers'][0]['logoUrl']
                                : '',
                            width: 40,
                            height: 40,
                            headers: {'x-token': Util.token},
                          )),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Semantics(
                            explicitChildNodes: true,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Tooltip(
                                  child: Semantics(
                                    child: Text(
                                      offer['description'],
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xCC000000)),
                                    ),
                                  ),
                                  message: offer['description'],
                                ),
                                Semantics(
                                  child: Text(
                                    ObjectUtil.isNotEmpty(offer['retailers'])
                                        ? offer['retailers'][0]['name']
                                        : '',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xCC000000)),
                                  ),
                                ),
                                Opacity(
                                  opacity: 1,
                                  child: Semantics(
                                    child: Text(
                                      (offer['status'] == 'EXPIRED'
                                              ? 'Expired: '
                                              : 'Expires: ') +
                                          Util.formatTime(offer['expiresAt'],
                                              format: SkuxInfo.dateTimeFormat),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF70728F),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Semantics(
                  explicitChildNodes: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Semantics(
                        child: Text(
                          Util.formatMoney(int.parse(
                              offer['amountInCents'].toString() ?? '0')),
                          style: const TextStyle(
                              fontSize: 15, color: SkuxStyle.textColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Semantics(
                        image: true,
                        label: 'Arrow Right',
                        child: SvgPicture.asset(
                          'assets/image/skux/card_arrow_right.svg',
                          color: const Color(0xFF9194A1),
                          width: 12,
                          height: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          showCupertinoModalBottomSheet(
            context: context,
            isDismissible: false,
            expand: false,
            backgroundColor: SkuxStyle.bgColor,
            duration: const Duration(milliseconds: 300),
            builder: (context) {
              return OfferDetailWalletPage(
                offer: item,
                hideButton: true,
              );
            },
          );
        },
      ),
    );
  }

  Widget _introduceItem(Map item) {
    return Semantics(
      explicitChildNodes: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(35, 42, 81, 0.04),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Semantics(
              child: Text(
                item['key'],
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: SkuxStyle.text64Color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            child: Text(
              item['value'],
              style:
                  const TextStyle(fontSize: 15, color: SkuxStyle.text64Color),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sortOffers(int index) async {
    _activeOffers = [];
    _redeemedOffers = [];
    _expiredOffers = [];
    Map userPurses = _cards[index];

    List data = userPurses['userPurses']['items'];
    if (data != null && data.isNotEmpty) {
      for (var element in data) {
        switch (element['offer']['status']) {
          case 'ACTIVE':
            _activeOffers.add(element);
            break;
          case 'REDEEMED':
            _redeemedOffers.add(element);
            break;
          case 'EXPIRED':
            _expiredOffers.add(element);
            break;
          default:
            break;
        }
      }
    }
  }

  void _openTermsClicked() async {
    String url = _cards[_currentCardIndex]['termsAndConditionsUrl'];
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: SkuxStyle.bgColor,
      duration: const Duration(milliseconds: 300),
      builder: (context) => TermsPage(
        url: url,
        hideButtons: true,
      ),
    );
  }
}
