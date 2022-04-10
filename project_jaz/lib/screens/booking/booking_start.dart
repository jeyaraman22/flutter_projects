import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';
import 'package:jaz_app/helper/graphqlconnectivity/constants.dart';
import 'package:jaz_app/helper/search_service.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/screens/account.dart';
import 'package:jaz_app/screens/onboarding/signup.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:collection';
import '../../graphql_provider.dart';

class BookingStart extends StatefulWidget {
  final HashMap<String, dynamic> selectedRoomdet;
  final String discountPrice;
  final String originalPrice;
  BookingStart(this.selectedRoomdet,this.discountPrice,this.originalPrice);
  _BookingStartState createState() => _BookingStartState();
}

class _BookingStartState extends State<BookingStart> {
  bool checkJoin = false;
  String discountPrice = "";
  String originalPrice = "";
  String currency="";
  Future<bool> _willPopCallback() async {
    Navigator.pop(context);
    // await showDialog or Show add banners or whatever
    // then
    return true; // return true if the route to be popped
  }

  void initState() {
    super.initState();
    currency = AppUtility().getCurrentCurrency().toString();
    discountPrice = widget.discountPrice;
    originalPrice = widget.originalPrice;

  }

    @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.08;
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var buttonHeight = overAllHeight * 0.055;
    var listLeftPadding = overAllWidth * 0.035;
    var boxTopPadding = 0.0;
    var boxBottomPadding = MediaQuery.of(context).size.height * 0.05;
    var logoTopPadding = MediaQuery.of(context).size.height * 0.03;
    var bookingTitleTopPadding = MediaQuery.of(context).size.height * 0.025;
    var contentWidth = MediaQuery.of(context).size.width * 0.75;
    var alreadyMemberTopPadding = MediaQuery.of(context).size.height * 0.03;
    var boxCornerRadius = containerBorderRadius;
    var textLeftpadding = MediaQuery.of(context).size.width * 0.03;
    var textTopPadding = MediaQuery.of(context).size.height * 0.025;
    var checkTopPadding = MediaQuery.of(context).size.height * 0.05;
    var imageLeftpadding = MediaQuery.of(context).size.width * 0.05;
    var dividerTopPadding = MediaQuery.of(context).size.height * 0.015;

    return WillPopScope(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              toolbarHeight: AppUtility().isTablet(context)
                  ? 80
                  : AppBar().preferredSize.height,
              //preferredSize: Size.fromHeight(height), // here the desired height
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.white,
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
                                MediaQuery.of(context).size.width * 0.005,
                                0,
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
                          onTap: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setString("loginType", "back");
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 0),
                            child: Text(Strings.back, style: backStyle),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      bottom: boxTopPadding,
                      top: boxTopPadding,
                      left: listLeftPadding,
                      right: listLeftPadding),
                  decoration: BoxDecoration(
                    color: Uicolors.bookingBg,
                    //border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(boxCornerRadius),
                    shape: BoxShape.rectangle,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: logoTopPadding),
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/images/JHG_logo.png",
                          width: AppUtility().isTablet(context) ? 220 : 150,
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: bookingTitleTopPadding),
                          alignment: Alignment.center,
                          child: Text(
                            Strings.bookingTitle,
                            style: bookingTitleStyle,
                          )),
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              top: bookingTitleTopPadding,
                              left: imageLeftpadding,
                              right: imageLeftpadding),
                          //  width: contentWidth,
                          //height: 50,
                          child: GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 0),
                                  child: Image.asset(
                                    "assets/images/member-benifit-icon.png",
                                    width: iconSize,
                                    height: iconSize,
                                    color: Uicolors.buttonbg,
                                  ),
                                ),
                                Container(
                                  width:
                                  MediaQuery.of(context).size.width * 0.74,
                                  padding:
                                  EdgeInsets.only(left: textLeftpadding),
                                  child:
                                      RichText(
                                        maxLines: 2,
                                        text:TextSpan(
                                          text: "Member Rate starting from ",
                                          style: baseRateStyle,
                                          children: [
                                            TextSpan(text: "$currency $originalPrice ",style: summaryTextStyle),
                                            TextSpan(text: "only.. Enjoy our Membership plan.",style:  baseRateStyle)
                                          ]
                                        ),
                                      )
                                  // Text(
                                  //   "Member Rate starting from $currency $originalPrice only.. Enjoy our Membership plan.",
                                  //   maxLines: 2,
                                  //   style: baseRateStyle,
                                  // ),
                                )
                              ],
                            ),
                          )),
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              top: bookingTitleTopPadding,
                              left: imageLeftpadding,
                              right: imageLeftpadding),
                          //  width: contentWidth,
                          //height: 50,
                          child: GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 0),
                                  child: Image.asset(
                                    "assets/images/ticket.png",
                                    width: iconSize,
                                    height: iconSize,
                                    color: Uicolors.buttonbg,
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.74,
                                  padding:
                                      EdgeInsets.only(left: textLeftpadding),
                                  child: Text(
                                    Strings.bestRates,
                                    maxLines: 2,
                                    style: baseRateStyle,
                                  ),
                                )
                              ],
                            ),
                          )),
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                              top: textTopPadding,
                              left: imageLeftpadding,
                              right: imageLeftpadding),
                          child: GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 0),
                                  child: Image.asset(
                                    "assets/images/spcial_discount.png",
                                    width: iconSize,
                                    height: iconSize,
                                    color: Uicolors.buttonbg,
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  padding:
                                      EdgeInsets.only(left: textLeftpadding),
                                  child: Text(
                                    Strings.getSpecialDiscount,
                                    style: baseRateStyle,
                                  ),
                                )
                              ],
                            ),
                          )),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                          top: checkTopPadding,
                          left: imageLeftpadding, //10
                        ),
                        child: Row(
                          children: [
                            Container(
                                child: Theme(
                                    data: Theme.of(context).copyWith(
                                      unselectedWidgetColor: Uicolors.desText,
                                    ),
                                    child: Transform.scale(
                                      scale: (AppUtility().isTablet(context)
                                          ? 1.8
                                          : 1.0),
                                      child: Checkbox(
                                        checkColor: Colors.white,
                                        activeColor: Uicolors.buttonbg,
                                        value: checkJoin,
                                        onChanged: (value) {
                                          setState(() {
                                            checkJoin = value!;
                                          });
                                        },
                                      ),
                                    ))),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              padding: EdgeInsets.only(
                                  left: AppUtility().isTablet(context) ? 5 : 0),
                              child: Text(
                                Strings.clickingTerms,
                                style: baseRateStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            top: bookingTitleTopPadding,
                            bottom: boxBottomPadding),
                        child: MaterialButton(
                          color: !checkJoin
                              ? Uicolors.inActiveButtonBgColor
                              : Uicolors.buttonbg,
                          minWidth: MediaQuery.of(context).size.width * 0.75,
                          height: buttonHeight,
                          shape: new RoundedRectangleBorder(
                            borderRadius:
                                new BorderRadius.circular(buttonHeight / 2),
                          ),
                          child: Text(
                            Strings.specialDeals,
                            style: TextStyle(
                                fontSize: textFieldIconSize16, //16,
                                fontFamily: 'Popins-light',
                                //  fontWeight: FontWeight.w700,
                                color: !checkJoin
                                    ? Uicolors.inActiveButtonColor
                                    : Colors.white),
                          ),
                          onPressed: () {
                            if(checkJoin){
                              pushNewScreen(
                                context,
                                screen: SignUp("Booking"),
                                withNavBar: true,
                                // OPTIONAL VALUE. True by default.
                                pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(top: alreadyMemberTopPadding),
                    alignment: Alignment.center,
                    child: Text(Strings.alreadyamember,
                        style: alreadyMemberStyle)),
                Container(
                  alignment: Alignment.center,
                  margin: AppUtility().isTablet(context)
                      ? EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.10,
                          right: MediaQuery.of(context).size.width * 0.10,
                          top: MediaQuery.of(context).size.width * 0.05,
                          bottom: MediaQuery.of(context).size.width * 0.025)
                      : EdgeInsets.all(0),
                  padding: EdgeInsets.only(
                    top: dividerTopPadding,
                  ),
                  child: MaterialButton(
                    //color: Uicolors.buttonbg,
                    minWidth: contentWidth,
                    height: buttonHeight,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(buttonHeight / 2),
                      side: BorderSide(color: Uicolors.buttonbg, width: 1.5),
                    ),
                    child: Text(
                      Strings.bookLogin,
                      style: greenColorButtonStyle,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => Account("Booking")));
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.90,
                  margin: EdgeInsets.only(
                      top: dividerTopPadding, bottom: dividerTopPadding),
                  child: Divider(
                    color: Uicolors.sortsearchbg,
                    thickness: 0.5,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                      top: dividerTopPadding,
                      bottom: dividerTopPadding,left:MediaQuery.of(context).size.width * 0.10 ,right: MediaQuery.of(context).size.width * 0.10),
                      child:
                      RichText(
                        maxLines: 2,
                        text:TextSpan(
                            text: "By continuing as a guest, you will pay",
                            style: baseRateStyle,
                            children: [
                              TextSpan(text: " $currency $discountPrice ",style: summaryTextStyle),
                              TextSpan(text: "*(Average price/night) for this booking.",style:  baseRateStyle)
                            ]
                        ),
                      )
                      // Text(
                      //   "By continuing as a guest, you will pay $currency $discountPrice*(Average price/night) for this booking.",
                      //   style: roomNameStyle,
                      // ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(bottom: boxTopPadding),
                  margin: AppUtility().isTablet(context)
                      ? EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.10,
                          right: MediaQuery.of(context).size.width * 0.10,
                          top: MediaQuery.of(context).size.width * 0.025,bottom: MediaQuery.of(context).size.width * 0.025)
                      : EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.025),
                  child: MaterialButton(
                    minWidth: contentWidth,
                    height: buttonHeight,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(buttonHeight / 2),
                      side: BorderSide(
                          color: Uicolors.placeholderTextColor, width: 1.5),
                    ),
                    child:
                        Text(Strings.cntASGuest, style: grayColorButtonStyle),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString("loginType", "guest");
                      Navigator.pop(context);
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (_) => AsGuest(widget.selectedRoomdet))
                      // );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: _willPopCallback);
  }
}
