import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryImageView extends StatefulWidget {
  final List<String> listImages;
  final int index;

  GalleryImageView(this.listImages, this.index);

  @override
  _GalleryImageViewState createState() => new _GalleryImageViewState();
}

class _GalleryImageViewState extends State<GalleryImageView>
    with WidgetsBindingObserver {
  AppUtility appUtility = AppUtility();
  var images = [];
  var index = 0;
  Orientation? _currentOrientation;
  int _counter = 0;

  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    appUtility = AppUtility();
    images = widget.listImages;
    index = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    final overallHeight = MediaQuery.of(context).size.height;
    final overallWidth = MediaQuery.of(context).size.width;
    var topPadding = overallHeight * 0.05;
    var leftPadding = overallWidth * 0.03;
    DateTime timeOfLastChange = DateTime.now();

    int get_turns_based_on_orientation(NativeDeviceOrientation orientation) {
      switch (orientation) {
        case NativeDeviceOrientation.portraitDown:
          return 0;
        case NativeDeviceOrientation.portraitUp:
          return 0;
        case NativeDeviceOrientation.landscapeLeft:
          return 1;
        case NativeDeviceOrientation.landscapeRight:
          return 3;
        case NativeDeviceOrientation.unknown:
          return 0;
      }
    }

    return Scaffold(
        body: NativeDeviceOrientationReader(
          builder: (context) {
            final orientation = NativeDeviceOrientationReader.orientation(context);
            return RotatedBox(
              quarterTurns: get_turns_based_on_orientation(orientation),
              child: Stack(children: [
                Container(
                    child: PhotoViewGallery.builder(
                      pageController: PageController(initialPage: index),
                      scrollPhysics: const BouncingScrollPhysics(),
                      builder: (BuildContext context, int index) {
                        return PhotoViewGalleryPageOptions(
                          //   imageProvider: OptimizedCacheImageProvider(images[index],
                          //   cacheManager: AppUtility().getInstance(), cacheKey: images[index],
                          //   //   maxHeight: 1000,maxWidth: 1000
                          // ),
                          imageProvider: NetworkImage(
                            images[index],
                            //   maxHeight: 1000,maxWidth: 1000
                          ),
                          initialScale: PhotoViewComputedScale.contained,
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.contained,
                          heroAttributes: PhotoViewHeroAttributes(tag: images[index]),
                        );
                      },
                      itemCount: images.length,
                      loadingBuilder: (context, event) => Center(
                        child: Container(
                          width: infoIconSize,
                          height: infoIconSize,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      // backgroundDecoration: widget.backgroundDecoration,
                      //  pageController: widget.pageController,
                      onPageChanged: (int i) {
                        //  print(images[index]);
                        //  AppUtility().getInstance().removeFile(images[index]);
                        setState(() {
                          index = i;
                        });
                      },
                    )),
                Positioned(
                    bottom: topPadding,
                    right: leftPadding,
                    child: Text(
                      (index + 1).toString() + "/" + images.length.toString(),
                      style: buttonStyle,
                    )),
                Positioned(
                    left: leftPadding,
                    top: topPadding,
                    child: GestureDetector(
                      onTap: () {
                        /*if (MediaQuery.of(context).orientation == Orientation.landscape) {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
              }*/
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown
                        ]);
                        Navigator.pop(
                          context,
                        );
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 40,
                      ),
                    )),
              ]),
            );
          },
          useSensor: true,
        ));
  }

  @override
  dispose() {
    super.dispose();
  }
}
