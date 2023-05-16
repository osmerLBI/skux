import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:span_mobile/common/style.dart';
import 'package:spring/spring.dart';

class BezierLogoHeader extends Header {
  final Key key;
  Widget logo;
  Color backgroundColor;

  final LinkHeaderNotifier linkNotifier = LinkHeaderNotifier();

  BezierLogoHeader({
    this.key,
    this.logo,
    this.backgroundColor,
    bool enableHapticFeedback = false,
  }) : super(
          extent: 60.0,
          triggerDistance: 60.0,
          float: false,
          enableHapticFeedback: enableHapticFeedback,
          enableInfiniteRefresh: false,
          completeDuration: const Duration(seconds: 1),
        ) {
    backgroundColor ??= style.primaryColor;
    logo ??= style.logoWidget;
  }

  @override
  Widget contentBuilder(
      BuildContext context,
      RefreshMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration completeDuration,
      bool enableInfiniteRefresh,
      bool success,
      bool noMore) {
    assert(axisDirection == AxisDirection.down,
        'Widget can only be vertical and cannot be reversed');
    linkNotifier.contentBuilder(
        context,
        refreshState,
        pulledExtent,
        refreshTriggerPullDistance,
        refreshIndicatorExtent,
        axisDirection,
        float,
        completeDuration,
        enableInfiniteRefresh,
        success,
        noMore);
    return BezierLogoHeaderWidget(
      key: key,
      logo: logo,
      color: Colors.white,
      backgroundColor: backgroundColor,
      linkNotifier: linkNotifier,
    );
  }
}

class BezierLogoHeaderWidget extends StatefulWidget {
  final Color color;
  final Widget logo;
  final Color backgroundColor;

  final LinkHeaderNotifier linkNotifier;

  const BezierLogoHeaderWidget({
    Key key,
    this.color,
    this.backgroundColor,
    this.linkNotifier,
    this.logo,
  }) : super(key: key);

  @override
  BezierLogoHeaderWidgetState createState() {
    return BezierLogoHeaderWidgetState();
  }
}

class BezierLogoHeaderWidgetState extends State<BezierLogoHeaderWidget>
    with TickerProviderStateMixin<BezierLogoHeaderWidget> {
  RefreshMode get _refreshState => widget.linkNotifier.refreshState;

  double get _pulledExtent => widget.linkNotifier.pulledExtent;

  double get _indicatorExtent => widget.linkNotifier.refreshIndicatorExtent;

  bool get _noMore => widget.linkNotifier.noMore;

  AnimationController _backController;
  Animation<double> _backAnimation;
  final double _backAnimationLength = 110.0;
  double _backAnimationPulledExtent = 0.0;
  bool _showBackAnimation = false;

  set showBackAnimation(bool value) {
    if (_showBackAnimation != value) {
      _showBackAnimation = value;
      if (_showBackAnimation) {
        _backAnimationPulledExtent = _pulledExtent - _indicatorExtent;
        _backAnimation = Tween(
                begin: 0.0,
                end: _backAnimationLength + _backAnimationPulledExtent)
            .animate(_backController);
        _backController.reset();
        _backController.forward();
      }
    }
  }

  bool _toggleCircle = false;

  set toggleCircle(bool value) {
    if (_toggleCircle != value) {
      _toggleCircle = value;
    }
  }

  @override
  void initState() {
    super.initState();
    _backController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _backAnimation =
        Tween(begin: 0.0, end: _backAnimationLength).animate(_backController);
  }

  @override
  void dispose() {
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_noMore) return Container();
    if (_refreshState == RefreshMode.armed) {
      showBackAnimation = true;
    } else if (_refreshState == RefreshMode.done) {
      toggleCircle = false;
    } else if (_refreshState == RefreshMode.inactive) {
      showBackAnimation = false;
      toggleCircle = false;
    }
    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Column(
            children: <Widget>[
              Container(
                height: _indicatorExtent,
                width: double.infinity,
                color: widget.backgroundColor,
                child: Stack(
                  children: <Widget>[
                    if ([
                      RefreshMode.armed,
                      RefreshMode.refresh,
                      RefreshMode.refreshed,
                    ].contains(_refreshState))
                      Positioned.fill(
                        child: FractionallySizedBox(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 30,
                              ),
                              child: BounceInUp(
                                from: 60,
                                child: Spring.blink(
                                  // animType: AnimType.Blink,
                                  animDuration:
                                      const Duration(milliseconds: 600),
                                  animStatus: (_) {},
                                  // motion: Motion.Mirror,
                                  child: widget.logo,
                                ),
                              ),
                            ),
                          ),
                          heightFactor: 0.4,
                        ),
                      ),
                    AnimatedBuilder(
                      animation: _backAnimation,
                      builder: (context, child) {
                        double offset = 0.0;
                        if (_backAnimation.value >=
                            _backAnimationPulledExtent) {
                          var animationValue =
                              _backAnimation.value - _backAnimationPulledExtent;
                          if (animationValue > 0 && animationValue != 110.0) {
                            toggleCircle = true;
                          }
                          if (animationValue <= 30.0) {
                            offset = animationValue;
                          } else if (animationValue > 30.0 &&
                              animationValue <= 50.0) {
                            offset = (20.0 - (animationValue - 30.0)) * 3 / 2;
                          } else if (animationValue > 50.0 &&
                              animationValue < 65.0) {
                            offset = animationValue - 50.0;
                          } else if (animationValue > 65.0) {
                            offset = (45.0 - (animationValue - 65.0)) / 3;
                          }
                        }
                        return ClipPath(
                          clipper: _CirclePainter(offset: offset, up: false),
                          child: child,
                        );
                      },
                      child: Container(
                        color: widget.color,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: _pulledExtent > _indicatorExtent
                    ? _pulledExtent - _indicatorExtent
                    : 0.0,
                child: ClipPath(
                  clipper: _CirclePainter(
                    offset: _showBackAnimation
                        ? _backAnimation.value < _backAnimationPulledExtent
                            ? _backAnimationPulledExtent - _backAnimation.value
                            : 0.0
                        : (_pulledExtent > _indicatorExtent &&
                                _refreshState != RefreshMode.refresh &&
                                _refreshState != RefreshMode.refreshed &&
                                _refreshState != RefreshMode.done
                            ? _pulledExtent - _indicatorExtent
                            : 0.0),
                    up: true,
                  ),
                  child: Container(
                    color: widget.backgroundColor,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_refreshState == RefreshMode.drag)
          Positioned.fill(
            child: FractionallySizedBox(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 60,
                  ),
                  child: widget.logo,
                ),
              ),
              heightFactor: 0.4,
            ),
          ),
      ],
    );
  }
}

class _CirclePainter extends CustomClipper<Path> {
  final double offset;
  final bool up;

  _CirclePainter({this.offset, this.up});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (!up) path.moveTo(0.0, size.height);
    path.cubicTo(
        0.0,
        up ? 0.0 : size.height,
        size.width / 2,
        up ? offset * 2 : size.height - offset * 2,
        size.width,
        up ? 0.0 : size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return oldClipper != this;
  }
}
