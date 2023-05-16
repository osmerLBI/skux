import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/pages/common/base_appbar.dart';

class ImageView extends StatefulWidget {
  const ImageView({Key key, this.images, this.index}) : super(key: key);
  final List<String> images;
  final int index;

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  int _currentIndex = 0;

  @override
  void initState() {
    setState(() {
      _currentIndex = widget.index;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: backAppBar(context, '', backgroundColor: Colors.black),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          color: Colors.black,
          child: ExtendedImageGesturePageView.builder(
            itemBuilder: (BuildContext context, int index) {
              var item = widget.images[index];
              Widget image = ExtendedImage.network(
                item,
                headers: {'x-token': Util.token},
                fit: BoxFit.contain,
                mode: ExtendedImageMode.gesture,
                initGestureConfigHandler: (ExtendedImageState state) {
                  return GestureConfig(
                    inPageView: true,
                    initialScale: 1.0,
                    maxScale: 5.0,
                    animationMaxScale: 6.0,
                    initialAlignment: InitialAlignment.center,
                  );
                },
              );
              image = Container(
                child: image,
                padding: const EdgeInsets.all(5.0),
              );
              if (index == _currentIndex) {
                return Hero(
                  tag: item + index.toString(),
                  child: image,
                );
              } else {
                return image;
              }
            },
            itemCount: widget.images.length,
            controller: ExtendedPageController(
              initialPage: _currentIndex,
              // pageSpacing: 50,
            ),
            scrollDirection: Axis.horizontal,
          ),
        ),
      ),
    );
  }
}
