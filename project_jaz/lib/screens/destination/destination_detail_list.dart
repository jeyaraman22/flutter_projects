// import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gql/language.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/utils/carousel.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;

class DestinationDetailList extends StatefulWidget {
  final String name;
  final String desc;
  final List<dynamic> images;
  DestinationDetailList(this.name,this.desc,this.images);
  @override
  _DestinationDetailListState createState() => _DestinationDetailListState();
}

class _DestinationDetailListState extends State<DestinationDetailList> {

  bool descTextShowFlag = false;
  AppUtility appUtility = AppUtility();
  // String descText = "Description Line 1\nDescription Line 2\nDescription Line 3\nDescription Line 4\nDescription Line 5\nDescription Line 6\nDescription Line 7\nDescription Line 8";
  //String textStatus = 'Flutter’s widgets incorporate all critical platform differences such as scrolling, navigation, icons and fonts to provide full native performance on both iOS and Android.';
  // int textlength = textStatus.length;

  var destination;
  var name = "";
  var desc = "";
  List<dynamic> listImages = [];
  int currentImageIndex = 0;


  @override
  void initState() {
    super.initState();
    //destination = widget.destination;
    name = widget.name;
    desc =  appUtility.parseHtmlString(widget.desc);
   // desc = "ExpandableText with regrex validation as ExpandableText with regrex validation as well.";
    listImages = widget.images;

  }

  @override
  Widget build(BuildContext context) {
    var indicatorSize = AppUtility().indicaorSize(context);
    var currentIndicatorSize = AppUtility().currentIndicatorSize(context);
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var containerPadding=overAllHeight*0.025;
    var imageContainerHeight=overAllHeight*0.35;
    var imageContainerWidth=overAllWidth*1;
    var nameTopPadding=overAllHeight*0.015;
    var nameLeftPadding=overAllWidth*0.02;
    var descLeftPadding=overAllWidth*0.03;
    var bottomPadding=overAllHeight*0.02;
    var descTopPadding=overAllHeight*0.01;

    int stringLength =  desc.length;
    return Container(
      // height: MediaQuery.of(context).size.height/2,
      //  height: 400,
      margin:
      EdgeInsets.only(bottom: containerPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        //border: Border.all(color: Colors.white, width: 1),
       // borderRadius: BorderRadius.circular(containerBorderRadius),
        shape: BoxShape.rectangle,
        boxShadow: boxShadow
      ),
      child: Column(
        children: <Widget>[
          if(listImages.length>0&&listImages[0] !=""&&listImages[0]!=null)
            Container(
              height: imageContainerHeight,
              width: imageContainerWidth,
              child: ClipRRect(
                // borderRadius: BorderRadius.only(
                //     topLeft: Radius.circular(containerBorderRadius),
                //     topRight: Radius.circular(containerBorderRadius)),
                child:  Carousel(
                    images: listImages
                        .map(
                            (e) =>  AppUtility().loadNetworkImage(e.toString())
                    )
                        .toList(),
                    indicatorSize: listImages.length > 0
                        ? Size.square(indicatorSize)
                        : Size.square(0.0),
                    indicatorActiveSize: listImages.length > 0
                        ? Size(currentIndicatorSize, indicatorSize)
                        : Size(0.0, 0.0),
                    indicatorColor: Colors.grey,
                    indicatorActiveColor: Colors.white,
                    animationCurve: Curves.easeIn,
                    contentMode: BoxFit.cover,
                    //     contentMode: BoxFit.fitWidth,
                    autoPlay: false,
                    indicatorBackgroundColor: Colors.transparent,
                    bottomPadding: 20,
                    onImageChange: (index) {
                      currentImageIndex = index;
                    }),
              ),
            ),
          Container(
              padding: EdgeInsets.only(left:nameTopPadding,right: nameLeftPadding,top: nameTopPadding),
              alignment: Alignment.topLeft,
              child: Text(name,style: destinationNameStyle)
          ),
          Container(
            padding: EdgeInsets.only(left: descLeftPadding,right: descLeftPadding,top: descTopPadding),
            alignment: Alignment.topLeft,
            child: Text(desc,
              style:descTextStyle,
              maxLines: descTextShowFlag ? 100 : 2,
              textAlign: TextAlign.start,
            ),
          ),
          if(desc.toString().length<100)
            Container(
            padding: EdgeInsets.only(top: bottomPadding),
            ),
            if(desc.toString().length>100)
          GestureDetector(
            onTap: (){ setState(() {
              descTextShowFlag = !descTextShowFlag;
            }); },
            child: Container(
              padding: EdgeInsets.only(left: descLeftPadding,right: descLeftPadding,top:5,bottom: bottomPadding),
              alignment: Alignment.centerLeft,
              child: descTextShowFlag ? Text(Strings.viewLess,style: viewMore,) :
              Text(Strings.viewMore,style: viewMore,),
            ),
          )
        ],
      ),
    );
  }
  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

}

