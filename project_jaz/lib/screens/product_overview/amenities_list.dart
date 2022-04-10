import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;

class AmenitiesList extends StatefulWidget {
  final List<String> gridItems;
  AmenitiesList({required this.gridItems});
  @override
  _AmenitiesListState createState() => new _AmenitiesListState();
}

class _AmenitiesListState extends State<AmenitiesList> {
  var amenitiesImage = [];
  var amenitiesNameList = [];
  AppUtility appUtility = AppUtility();

  void initState() {
    super.initState();
    appUtility = AppUtility();
    amenitiesNameList = widget.gridItems;
    amenitiesNameList.forEach((e) =>
    {
      amenitiesImage.add(appUtility.getAmenities(e))
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.08;
    final overallHeight = MediaQuery.of(context).size.height;
    final overallWidth = MediaQuery.of(context).size.width;
    var boxLeftPadding = overallWidth * 0.035;
    var boxTopPadding = overallHeight * 0.02;
    var boxCornerRadius = containerBorderRadius;
    var boxWidth = overallWidth * 0.7;
    var boxTextLeftPadding = overallWidth * 0.04;
    var boxTextTopPadding = overallHeight * 0.02;
    var listTextLeftPadding = overallWidth * 0.02;
    var listTextTopPadding = overallHeight * 0.005;
    var boxBottomPadding = overallHeight * 0.015;

    return Scaffold(
        backgroundColor: Uicolors.backgroundColor,
        appBar: AppBar(
          toolbarHeight: AppUtility().isTablet(context)?80:AppBar().preferredSize.height,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Container(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.height * 0.005,
                            5,
                            0,
                            0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Uicolors.buttonbg,
                          size: backIconSize,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(Strings.backtosearch,
                            style: backSigninGreenStyle),
                      ),
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.height * 0.015),
                    child: Image.asset(
                      "assets/images/JHG_logo.png",
                      width: AppUtility().isTablet(context)?180:120,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                margin: EdgeInsets.only(
                    bottom: boxBottomPadding,
                    top: boxTopPadding,
                    left: boxLeftPadding,
                    right: boxLeftPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  //border: Border.all(color: Colors.white, width: 1),
                 // borderRadius: BorderRadius.circular(boxCornerRadius),
                  boxShadow: boxShadow,
                  shape: BoxShape.rectangle,
                ),
                child: Column(children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: boxTextLeftPadding,
                          right: boxTextLeftPadding,
                          top: boxTextTopPadding),
                      child: Text(
                        "Amenities".toUpperCase(),
                        style: amenitiesTextStyle,
                      ),
                    ),
                  ),
                  Container(
                    // height: 200,
                    padding: EdgeInsets.only(
                        left: boxTextLeftPadding,
                        right: boxTextLeftPadding,
                        top: boxTextTopPadding,
                    bottom: boxTextTopPadding),
                    alignment: Alignment.centerLeft,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: amenitiesNameList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            height: AppUtility().isTablet(context)?80:50,
                            padding: EdgeInsets.only(
                                left: listTextLeftPadding,
                                right: listTextLeftPadding,
                                top: listTextTopPadding,),
                            child: Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 0, right: 0, top: 0),
                                    child: Image.asset(
                                      amenitiesImage[index],
                                      width: amentitiesSize,//27,
                                      height: amentitiesSize,//27,
                                      color: Uicolors.buttonbg,
                                    )),
                                Container(
                                    width: boxWidth,
                                    padding: EdgeInsets.only(left: 15, top: 0),
                                    child: Text(
                                      amenitiesNameList[index],
                                      style: filterTextStyle,
                                      maxLines: 2,
                                    )),
                              ],
                            ));
                      },
                    ),
                  )
                ]),
              )
            ]),
          ),
        ));
  }
}
