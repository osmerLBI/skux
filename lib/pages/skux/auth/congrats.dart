import 'package:common_utils/common_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:span_mobile/common/skux/skux_info.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/pages/common/const.dart';
import 'package:span_mobile/pages/common/jh_button.dart';
import 'package:span_mobile/pages/skux/main/wallet/offer_detail.dart';
import 'package:span_mobile/widgets/unfocus.dart';

// ignore: must_be_immutable
class CongratsPage extends StatefulWidget {
  CongratsPage({
    Key key,
    this.offer,
  }) : super(key: key);
  Map offer;

  @override
  State<CongratsPage> createState() => _CongratsPageState();
}

class _CongratsPageState extends State<CongratsPage> {
  Map _offer;

  @override
  void initState() {
    _offer = widget.offer;
    SkuxInfo.haveReadRecentViewed = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SkuxStyle.bgColor,
      body: OrientationBuilder(builder: (context, orientation) {
        return SafeArea(
          child: SingleChildScrollView(
            child: UnFocusWidget(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
                child: Semantics(
                  explicitChildNodes: true,
                  // label: 'Congrats Page',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Semantics(
                        explicitChildNodes: true,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 30,
                            ),
                            Opacity(
                              opacity: 0.8,
                              child: Semantics(
                                child: Text(
                                  tr('Congrats!'),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: SkuxStyle.textColor,
                                  ),
                                ),
                              ),
                            ),
                            Semantics(
                              label: 'Close',
                              button: true,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: SvgPicture.asset('assets/image/skux/close_gray.svg'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Semantics(
                        child: Text(
                          tr('Your just added your first offer'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: SkuxStyle.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _offerCard(_offer),
                      const SizedBox(height: 16),
                      ExcludeSemantics(
                        excluding: true,
                        child: ExtendedImage.asset('assets/image/skux/congrats_female.png'),
                      ),
                      const SizedBox(height: 40),
                      if (SkuxInfo.hasClaimedOfferSuccess == true)
                        Semantics(
                          child: JhButton(
                              onPressed: _myCardButtonClick,
                              borderRadius: BorderRadius.circular(8),
                              width: 182,
                              height: 40,
                              text: tr('My Card'),
                              fontSize: 15,
                              weight: FontWeight.w600,
                              textColor: Colors.white,
                              color: style.primaryColor),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _offerCard(Map item) {
    return Semantics(
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
                    child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Semantics(
                        excludeSemantics: true,
                        image: true,
                        label: 'Logo',
                        child: ClipOval(
                            child: ExtendedImage.network(
                          ObjectUtil.isNotEmpty(item['retailers']) ? item['retailers'][0]['logoUrl'] : '',
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
                                    item['description'],
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xCC000000)),
                                  ),
                                ),
                                message: item['description'],
                              ),
                              Semantics(
                                child: Text(
                                  ObjectUtil.isNotEmpty(item['retailers']) ? item['retailers'][0]['name'] : '',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xCC000000)),
                                ),
                              ),
                              Opacity(
                                opacity: 0.48,
                                child: Semantics(
                                  child: Text(
                                    Util.formatTime(item['expiresAt'], format: SkuxInfo.dateTimeFormat),
                                    style: const TextStyle(fontSize: 12, color: SkuxStyle.textColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                Semantics(
                  explicitChildNodes: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Semantics(
                        child: Text(
                          Util.formatMoney(int.parse(item['amountInCents'].toString() ?? '0')),
                          style: const TextStyle(fontSize: 15, color: SkuxStyle.textColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Semantics(
                        child: SvgPicture.asset(
                          'assets/image/skux/card_arrow_right.svg',
                          width: 12,
                          height: 12,
                        ),
                        image: true,
                        label: 'Arrow',
                        excludeSemantics: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          showCupertinoModalBottomSheet(
            context: context,
            expand: false,
            isDismissible: false,
            backgroundColor: SkuxStyle.bgColor,
            duration: const Duration(milliseconds: 300),
            builder: (context) => OfferDetailPage(
              offer: item,
            ),
          );
        },
      ),
    );
  }

  void _myCardButtonClick() {
    Util.eventHub.fire(kOpenCardEvent);
    Navigator.pop(context);
  }
}
