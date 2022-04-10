import 'dart:collection';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/screens/booking/as_guest.dart';
import 'package:jaz_app/screens/booking/as_guest1.dart';
import 'package:jaz_app/screens/booking/booking_start.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/commonutils.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jaz_app/utils/http_client.dart';
import 'package:intl/intl.dart';

class RoomInformation extends StatefulWidget {
  final DetailOfferDataMixin$Rooms$Room$Board? board;
  final GetOfferList$Query$ProductOffers$Hotels$Offers offeritem;
  final String hotelName;
  final String hotelCrsCode;
  final String hotelId;
  final int roomIndex;
  final String children;
  final String adult;

  RoomInformation(this.board, this.offeritem, this.hotelCrsCode, this.hotelName,
      this.hotelId,this.roomIndex,this.adult,this.children);
  @override
  _RoomInformationState createState() => new _RoomInformationState();
}

class _RoomInformationState extends State<RoomInformation> {
  AppUtility appUtility = AppUtility();
  List<DetailOfferDataMixin$Rooms$Room> rooms = [];
  HttpClient httpClient = HttpClient();
  final FirebaseAuth auth = FirebaseAuth.instance;
  int currentIndex = -1;


  void initState() {
    super.initState();
    appUtility = AppUtility();
    rooms = widget.offeritem.rooms!.room!;
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery
        .of(context)
        .size
        .height * 0.08;
    final overallHeight = MediaQuery
        .of(context)
        .size
        .height;
    final overallWidth = MediaQuery
        .of(context)
        .size
        .width;
    var leftPadding = overallWidth * 0.033;
    var boxTopPadding = overallHeight * 0.02;
    var boxCornerRadius = containerBorderRadius;
    var boxWidth = overallWidth * 0.7;
    var buttonHeight =
        overallHeight * 0.055;
    var contentLeftPadding = overallWidth * 0.04;
    var topHeight = overallHeight * 0.03;
    var titleTopHeight = overallHeight * 0.02;

    var listTextLeftPadding = overallWidth * 0.02;
    var listTextTopPadding = overallHeight * 0.005;
    var boxBottomPadding = overallHeight * 0.015;
    if (buttonHeight < 40) {
      buttonHeight = 45;
    }

    return Scaffold(
      backgroundColor: Uicolors.backgroundColor,
      appBar: AppBar(
        toolbarHeight:
        AppUtility().isTablet(context) ? 80 : AppBar().preferredSize.height,
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
                          MediaQuery
                              .of(context)
                              .size
                              .height * 0.005, 5, 0, 0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Uicolors.bottomTextColor,
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
                      child: Text(Strings.back, style: backStyle),
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                    margin: EdgeInsets.only(
                      right: MediaQuery
                          .of(context)
                          .size
                          .width * 0.010,
                    ),
                    child: Text(
                      Strings.tripDetails,
                      style: welcomJazStyle,
                    )),
              ),
            ],
          ),
        ),
      ),
      body: Container(
          margin: EdgeInsets.only(
            //             bottom: boxBottomPadding,
            //             top: boxTopPadding,
              left: AppUtility().isTablet(context)
                  ? overallWidth * 0.070
                  : leftPadding,
              right: AppUtility().isTablet(context)
                  ? overallWidth * 0.070
                  : leftPadding),
          child: ListView.builder(
              shrinkWrap: true,
              // scrollDirection: Axis.vertical,
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                var roomName = rooms[index].board!.label.toString();
                var roomPrice =
                rooms[index].price!.amount.toInt().toString();
                var discountPrice = rooms[index].discountInfo != null
                    ? rooms[index].discountInfo!.perNightFullAmount!
                    .toInt().toString() + " " +
                    appUtility.getCurrentCurrency().toString() : "";
                var roomDesc = "<ul>" +
                    rooms[index].board!.description.toString().replaceAll(
                        "<br> •", "</li><li>") +
                    "</ul>";
                return Column(
                  children: [
                    Container(
                      // height: MediaQuery.of(context).size.height/2,
                      // height: MediaQuery.of(context).size.height*0.35,
                      margin: EdgeInsets.only(
                        top: topHeight,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: boxShadow,
                        // border: Border.all(
                        //     color: Colors.white, width: 1),
                        // borderRadius: BorderRadius.circular(
                        //     containerBorderRadius),
                        shape: BoxShape.rectangle,
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            //    height:110,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(
                                left: contentLeftPadding,
                                top: titleTopHeight,
                                right: contentLeftPadding),
                            child: Text(
                              roomName,
                              style: hotelNameStyle,
                              maxLines: AppUtility().isTablet(context) ? 1 : 2,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              left: contentLeftPadding,
                              right: contentLeftPadding,
                            ),
                            child: Divider(
                              color: Uicolors.desText,
                              thickness: 0.5,
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.only(
                                  left: contentLeftPadding,
                                  right: contentLeftPadding),
                              child: Row(children: [
                                if(discountPrice != "")
                                  Container(
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(top: 10, right: 5),
                                    child: Text(
                                      discountPrice,
                                      style: discountCrossStyle,
                                      textAlign: TextAlign.right,
                                    ),),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 0, top: 10, bottom: 0),
                                  child: Text(
                                    roomPrice,
                                    style: priceTextStyle,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 13),
                                  child: Text(
                                    " " + appUtility.getCurrentCurrency()
                                        .toString(),
                                    style: dollerStyle,
                                  ),
                                )
                              ])),
                          Container(
                            padding: EdgeInsets.only(left: contentLeftPadding),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                Strings.exclTaxesFees,
                                style: exclTaxStyle,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(
                                left: contentLeftPadding,
                                top: 0,
                                right: contentLeftPadding),
                            child: Html(
                              data: roomDesc,
                              shrinkWrap: true,
                              style: {
                                '#': Style(
                                  maxLines: currentIndex == index ? 100 : 2,
                                  margin: EdgeInsets.only(top: 0),
                                  padding: EdgeInsets.only(top: 0),
                                  // textAlign: TextAlign.left
                                ),
                                'html': Style(textAlign: TextAlign.justify,
                                ),
                                "h1": h1Style,
                                "p": paraStyle,
                                "li": listStyle,
                                'ul': Style(
                                    margin: EdgeInsets.only(top: 0),
                                    padding: EdgeInsets.only(top: 0))
                              },
                            ),
                          ),
                          if ((roomDesc.length) > 100)
                            Container(
                                alignment: Alignment.centerLeft,
                                height: 30,
                                padding: EdgeInsets.only(
                                    left: contentLeftPadding, bottom: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      currentIndex =
                                      currentIndex == index ? -1 : index;
                                    });
                                  },
                                  child: currentIndex == index
                                      ? Text(
                                    Strings.viewLess,
                                    style: viewMore,
                                  )
                                      : Text(
                                    Strings.viewMore,
                                    style: viewMore,
                                  ),
                                )),
                          Container(
                              alignment: Alignment.center,
                              width: overallWidth * 0.6,
                              height: buttonHeight,
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(buttonHeight / 2),
                                color: Uicolors.buttonbg,
                              ),
                              margin: EdgeInsets.only(
                                  bottom: boxTopPadding,
                                  top: (roomDesc.length) > 100
                                      ? listTextTopPadding
                                      : listTextTopPadding + 35),
                              child: GestureDetector(
                                onTap: () {
                                  var roomTypeName = "";
                                  var roomViewName =
                                      rooms[index].roomView?.name ?? "";
                                  if (roomViewName != "") {
                                    roomTypeName = rooms[index].name! +
                                        ", " +
                                        roomViewName;
                                  } else {
                                    roomTypeName = rooms[index].name!;
                                  }
                                  checkAvailablity(
                                      roomTypeName,
                                      rooms[index].opCode.toString(),
                                      rooms[index].board!.opCode.toString(),
                                      (rooms[index].price!.taxAmount +
                                          rooms[index].price!.amount)
                                          .toStringAsFixed(2)
                                          .toString(),
                                      rooms[index].price!.currency.toString(),
                                      rooms[index],rooms[index].promoCode!=null?rooms[index].promoCode!.toString():''
                                  );
                                },
                                child: Text(
                                  Strings.selectThisRate,
                                  style: buttonStyle,
                                ),
                              ))
                        ],
                      ),
                    ),
                  ],
                );
              })),
    );
  }

  Future<void> checkAvailablity(String selectedRoomName,
      String roomTypeCode,
      String roomRatePlanCode,
      String price,
      String ratePlanCurrencyCode,
      DetailOfferDataMixin$Rooms$Room offer,String promoCode) async {
    HashMap<String, dynamic> params = HashMap();
    params.putIfAbsent("hotel_crs_code", () => widget.hotelCrsCode);
    HashMap<String, dynamic> availabilityResponse = await CommonUtils()
        .checkAvailablity(
        params, roomTypeCode, roomRatePlanCode, widget.hotelId, price,
        ratePlanCurrencyCode,promoCode,widget.roomIndex,widget.adult,widget.children);
    if (availabilityResponse["responseCode"] == Strings.failure) {
      appUtility.showToastView(
          "Currently this room is unavailable. Please check some other room",
          context);
    } else if (availabilityResponse["paymentResponseCode"] == Strings.failure) {
      appUtility.showToastView(Strings.errorMessage, context);
    } else
    if (availabilityResponse["currencyResponseCode"] == Strings.failure) {
      appUtility.showToastView(Strings.errorMessage, context);
    } else {
      availabilityResponse.putIfAbsent(
          "selectedRoomName", () => selectedRoomName);
      availabilityResponse.putIfAbsent(
          "hotelCrsCode", () => widget.hotelCrsCode);
      availabilityResponse.putIfAbsent("hotelName", () => widget.hotelName);
      availabilityResponse.putIfAbsent("hotelId", () => widget.hotelId);
      // availabilityResponse.putIfAbsent("price", () => price);
      // availabilityResponse.putIfAbsent(
      //     "ratePlanCountryCode", () => ratePlanCurrencyCode);
      availabilityResponse.putIfAbsent("roomFullDetails", () => offer);
      availabilityResponse.putIfAbsent("selectedPromoCode", () => promoCode);
      //  print("availabilityResponse"+availabilityResponse["hotelcountrycode"].toString());
      HashMap<String, dynamic> guestDetails = HashMap();
      GlobalState.selectedBookingRoomDet = availabilityResponse;
      GlobalState.selectedRoomList[widget.roomIndex-1].roomDetail = availabilityResponse;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final User? user = auth.currentUser;
      Navigator.pop(context);
      pushNewScreen(
        context,
        screen: (user != null && prefs.getString("loginType")!="guest")
            ? AsGuestSummery(availabilityResponse, guestDetails)
            : AsGuest(availabilityResponse),
        withNavBar: false, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
      // pushNewScreen(
      //   context,
      //   screen: user != null
      //       ? AsGuestSummery(availabilityResponse, guestDetails)
      //       : BookingStart(availabilityResponse),
      //   withNavBar: false, // OPTIONAL VALUE. True by default.
      //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
      // );
    }
  }
}
