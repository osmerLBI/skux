import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:span_mobile/common/skux/skux_style.dart';
import 'package:span_mobile/pages/common/debug_widget.dart';
import 'package:span_mobile/pages/skux/common/backAppBar.dart';
import 'package:span_mobile/widgets/no_data_tip.dart';
import 'package:span_mobile/pages/skux/main/offer/vertical_offer_item.dart';

class RecentlyViewEdOfferPage extends StatefulWidget {
  const RecentlyViewEdOfferPage({
    Key key,
    this.offers,
  }) : super(key: key);
  final List offers;
  @override
  State<RecentlyViewEdOfferPage> createState() =>
      _RecentlyViewEdOfferPageState();
}

class _RecentlyViewEdOfferPageState extends State<RecentlyViewEdOfferPage> {
  List _recentOffers = [];
  final FocusNode _focusNode = FocusNode();
  FocusScopeNode _focusScopeNode;

  @override
  void initState() {
    _recentOffers = widget.offers;

    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _focusScopeNode = FocusScope.of(context);
      _focusScopeNode.requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SkuBackAppBar(
        context,
        title: 'Recently Viewed Offers',
        titleItem: Semantics(
          header: true,
          excludeSemantics: true,
          label: 'Recently Viewed Offers',
          button: false,
          child: DebugWidget(
            child: Focus(
              child: const Text(
                'Recently Viewed Offers',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
              focusNode: _focusNode,
            ),
          ),
        ),
      ),
      backgroundColor: SkuxStyle.bgColor,
      body: OrientationBuilder(
        builder: (context, orientation) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _mainBody(),
            ),
          );
        },
      ),
    );
  }

  Widget _mainBody() {
    return _recentOffers.isNotEmpty
        ? Semantics(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: VerticalOfferItem(
                      item: _recentOffers[index],
                      scrollDirection: Axis.vertical,
                    ),
                  );
                },
                separatorBuilder: (_, index) {
                  return Container();
                },
                itemCount: _recentOffers.length),
          )
        : const NoDataTip();
  }
}
