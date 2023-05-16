import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/common/style.dart';

class SkuxCard extends StatefulWidget {
  const SkuxCard({
    Key key,
    this.cardNumber,
    this.cardHeight,
    this.cardRadius,
    this.cardWidth,
    this.imgSrc,
    this.termsUrl,
    this.status = 'unknown',
  }) : super(key: key);
  final String cardNumber;
  final double cardWidth;
  final double cardHeight;
  final double cardRadius;
  final String imgSrc;
  final String termsUrl;
  final String status;
  @override
  State<SkuxCard> createState() => _SkuxCardState();
}

class _SkuxCardState extends State<SkuxCard> {
  @override
  Widget build(BuildContext context) {
    return _card();
  }

  Widget _card() {
    double cardWidth = (widget.cardWidth ?? (MediaQuery.of(context).size.width - 16 - 16)) * 0.8 * 0.9;
    double cardBorder = widget.cardRadius ?? (MediaQuery.of(context).size.width > 500 ? 20 : 10);
    double rate = cardWidth / (MediaQuery.of(context).size.width - 40 - 20);
    double ph = cardWidth > 358 ? ((cardWidth - 358) * 0.5) : 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(ph, 0, ph, 14 * rate),
      child: Semantics(
        explicitChildNodes: true,
        // label: 'Card',
        child: Container(
          // height: widget.cardHeight ?? 226,
          width: cardWidth,
          decoration: BoxDecoration(
            color: SkuxStyle.bgColor,
            image: DecorationImage(
              image: widget.imgSrc == null
                  ? const AssetImage('assets/image/skux/card_bg.png')
                  : ExtendedNetworkImageProvider(
                      widget.imgSrc ?? '',
                      cache: true,
                    ),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(cardBorder),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 27 * rate),
            child: Semantics(
              explicitChildNodes: true,
              // label: 'Card Number ${widget.cardNumber}',
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    child: Semantics(
                      child: Text(
                        widget.cardNumber,
                        style: TextStyle(color: Colors.white, fontSize: 16 * rate),
                      ),
                    ),
                    bottom: 0,
                    left: 30 * rate,
                  ),
                  if (['PFRAUD', 'FRAUD'].contains(widget.status.toUpperCase()))
                    Positioned(
                      top: 1,
                      left: 2,
                      right: 2,
                      child: _warningBanner(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _warningBanner() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(
        left: 2,
        bottom: 4,
      ),
      decoration: BoxDecoration(
        color: style.errorColor,
      ),
      child: const Text(
        'Your account has been restricted. Please email us at programs@skux.io for assistance. We apologize for any inconvenience.',
        style: TextStyle(
          fontSize: 13,
          color: Colors.white,
        ),
      ),
    );
  }
}
