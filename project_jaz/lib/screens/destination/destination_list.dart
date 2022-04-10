import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/utils/carousel.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/uiconstants.dart';

class DestinationList extends StatefulWidget {
  final destination;

  DestinationList(this.destination);

  @override
  _DestinationListState createState() => _DestinationListState();
}

class _DestinationListState extends State<DestinationList> {
  double circleRating = 4.5;
  double starRating = 4.0;
  bool onItemTapped = false;
  var destination;
  var name = "";
  var subName = "";
  List<String> listImages = [];

  @override
  void initState() {
    super.initState();
    destination = widget.destination;
    name = widget.destination["module"]["result"]["header"].toString();
    subName = widget.destination["module"]["result"]["headline"].toString();
    // print("images123"+widget.destination["module"]["data"]["images"].toString());
    listImages = AppUtility().getImages(widget.destination);
  }


  @override
  void dispose() {
    super.dispose();
    PaintingBinding.instance!.imageCache!.clear();

  }

  @override
  Widget build(BuildContext context) {
    var indicatorSize = AppUtility().indicaorSize(context);
    var currentIndicatorSize = AppUtility().currentIndicatorSize(context);
    final double overAllHeight = MediaQuery
        .of(context)
        .size
        .height;
    final double overAllWidth = MediaQuery
        .of(context)
        .size
        .width;

    var contentHeightPadding =
                overAllHeight * (AppUtility().isTablet(context) ? 0.50 : 0.35);
    var contentWidthPadding = overAllWidth * 1;

    //Contents inside the containers
    var nameHeightPadding = overAllHeight * 0.60;
    var contentTopPadding = overAllHeight * 0.28;
    var transparentPadding = overAllHeight * (AppUtility().isTablet(context)?0.25:  0.27);
    var subNameTopPadding = overAllHeight * 0.33;
    var fromContentLeftPadding = overAllWidth * 0.70;
    var priceContenttopPadding = overAllHeight * 0.185;
    var marginPadding = overAllHeight * 0.02;
    var nameLeftPadding = overAllWidth * 0.04;

    return Container(
      // height: MediaQuery.of(context).size.height/2,
      //  height: 400,

      margin: AppUtility().isTablet(context) ? EdgeInsets.only(
          left: 8, right: 8, top: 5,bottom: marginPadding) : EdgeInsets.only(
          bottom: marginPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        //border: Border.all(color: Colors.white, width: 1),
        //  borderRadius: BorderRadius.circular(containerBorderRadius),
        shape: BoxShape.rectangle,
        boxShadow: boxShadow,
      ),
      child: Stack(
        children: <Widget>[
          Container(
            height: contentHeightPadding,
            width: contentWidthPadding,
            child: ClipRRect(
              // borderRadius: BorderRadius.all(Radius.circular(containerBorderRadius)),
              child: Carousel(
                  images: listImages
                      .map(
                        (e) =>
                            AppUtility().loadNetworkImage(e.toString())
                    // e!.default2x!.url.toString()),
                  )
                      .toList(),
                  indicatorSize: listImages.length > 0
                      ? Size.square(indicatorSize)
                      : Size.square(0.0),
                  indicatorActiveSize:
                  listImages.length > 0 ? Size(
                      currentIndicatorSize, indicatorSize) : Size(0.0, 0.0),
                  indicatorColor: Colors.grey,
                  indicatorActiveColor: Colors.white,
                  animationCurve: Curves.easeIn,
                  contentMode: BoxFit.cover,
                  //     contentMode: BoxFit.fitWidth,
                  autoPlay: false,
                  indicatorBackgroundColor: Colors.transparent,
                  bottomPadding: 20),
            ),
          ),
          Stack(
            children: [
              Container(

                margin: EdgeInsets.only(top: AppUtility().isTablet(context)?overAllHeight * 0.35 :  transparentPadding),
                height: contentHeightPadding - transparentPadding,
                color: Uicolors.destinationTextBg,
              ),
              Container(
                  alignment: Alignment.topLeft,
                  width: nameHeightPadding,
                  margin: EdgeInsets.only(
                      left: nameLeftPadding, top: AppUtility().isTablet(context)?overAllHeight * 0.355 :  transparentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          name,
                          style: destinytitleTextStyle,
                          textAlign: TextAlign.left
                      ),
                      Text(subName, style: destinyContentTextStyle,
                        textAlign: TextAlign.left,)
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
