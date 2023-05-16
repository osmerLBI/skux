import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/util.dart';

import '../wallet/offer_detail.dart';

class HorizontalOfferItem extends HookWidget {
  const HorizontalOfferItem({Key key, this.item, this.height = 200, this.width = 180, this.scrollDirection}) : super(key: key);

  final Map item;
  final double height;
  final double width;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      explicitChildNodes: false,
      excludeSemantics: true,
      container: true,
      label: 'Double-tap to Click to offer detail page   ' +
          (item['description'] ?? '') +
          Util.formatMoney(int.parse(item['amountInCents'].toString() ?? '0')) +
          (item['retailers'].length > 0
              ? item['retailers'].length == 1
                  ? item['retailers'][0]['name']
                  : '${item['retailers'].length} retailers'
              : ''),
      button: true,
      child: GestureDetector(
        child: Semantics(
          label: 'Click to offer detail page   ' + (item['description'] ?? '') + Util.formatMoney(int.parse(item['amountInCents'].toString() ?? '0')),
          explicitChildNodes: true,
          focusable: false,
          button: true,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                      alignment: Alignment.center,
                      height: 180,
                      child: Stack(
                        children: [
                          Semantics(
                            focusable: false,
                            button: true,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ExtendedImage.network(
                                item['bannerUrl'] ?? '',
                                headers: {'x-token': Util.token},
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          if (item['userCard'] != null && item['userCard']['__typename'] == 'UserCard')
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: SkuxStyle.textColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Semantics(
                                      button: true,
                                      focusable: false,
                                      child: SvgPicture.asset('assets/image/skux/check.svg'),
                                    ),
                                    Opacity(
                                      opacity: 0.64,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                                        child: Semantics(
                                          label: 'The offer has been added',
                                          button: true,
                                          child: Text(
                                            tr('Added'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )),
                  const SizedBox(
                    height: 12,
                  ),
                  Semantics(
                    focusable: false,
                    label: 'Click to offer detail page   ' +
                        (item['description'] ?? '') +
                        Util.formatMoney(int.parse(item['amountInCents'].toString() ?? '0')),
                    button: true,
                    child: SizedBox(
                      width: 200,
                      child: Semantics(
                        button: true,
                        child: Text(
                          item['description'] ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: SkuxStyle.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  SizedBox(
                    width: 300,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Semantics(
                          focusable: false,
                          button: true,
                          label: 'Click to offer detail page   ' +
                              (item['description'] ?? '') +
                              Util.formatMoney(int.parse(item['amountInCents'].toString() ?? '0')),
                          child: Text(
                            Util.formatMoney(int.parse(item['amountInCents'].toString() ?? '0')),
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontSize: 15, color: SkuxStyle.contrastGreyColor),
                          ),
                        ),
                        Semantics(
                          focusable: false,
                          button: true,
                          label: 'Click to offer detail page   ' +
                              (item['retailers'].length > 0
                                  ? item['retailers'].length == 1
                                      ? item['retailers'][0]['name']
                                      : '${item['retailers'].length} retailers'
                                  : ''),
                          child: Text(
                            item['retailers'].length > 0
                                ? item['retailers'].length == 1
                                    ? item['retailers'][0]['name']
                                    : '${item['retailers'].length} retailers'
                                : '',
                            // textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, color: SkuxStyle.contrastGreyColor),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              if (item['status'] == 'EXPIRED')
                Positioned(
                  bottom: 24,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: SkuxStyle.textColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Opacity(
                          opacity: 0.64,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                            child: Semantics(
                              focusable: false,
                              button: true,
                              child: Text(
                                tr('Expired'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
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
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          await showCupertinoModalBottomSheet(
            context: context,
            isDismissible: false,
            expand: false,
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
}
