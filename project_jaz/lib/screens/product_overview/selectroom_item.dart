import 'dart:collection';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/screens/booking/as_guest.dart';
import 'package:jaz_app/screens/booking/as_guest1.dart';
import 'package:jaz_app/screens/booking/booking_start.dart';
import 'package:jaz_app/screens/product_overview/roomInformation.dart';
import 'package:jaz_app/screens/product_overview/selectroom.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/carousel.dart';
import 'package:jaz_app/utils/commonutils.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/models/roommodel.dart';
import 'package:http/http.dart' as http;
import 'package:jaz_app/utils/http_client.dart';
import 'package:intl/intl.dart';
import 'package:jaz_app/utils/uiconstants.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'amenities_list.dart';
import 'galleryimageview.dart';

class SelectRoomItem extends StatefulWidget {
  final GetOfferList$Query$ProductOffers$Hotels$Offers offeritem;
  final String hotelName;
  final String hotelCrsCode;
  final String hotelId;
  final bool isSelected;
  final int roomIndex;
  final String children;
  final String adult;
  final VoidCallback onSelect;
  final Function(String) continueCallBack;
  SelectRoomItem(
      this.offeritem, this.hotelName, this.hotelCrsCode, this.hotelId,this.isSelected,this.roomIndex,this.children,this.adult
      ,this.onSelect,{required this.continueCallBack});
  @override
  _SelectRoomItemState createState() => _SelectRoomItemState();
}

class _SelectRoomItemState extends State<SelectRoomItem> {
  double circleRating = 4.5;
  double starRating = 4.0;
  bool onItemTapped = false;
  late DetailOfferDataMixin$Rooms$Room offer;
  String roomId = "";
  String offerId = "";
  List amenities = [];
  List<String> amenitiesList = [];
  var roomName = "";
  var roomDesc = "";
  List<Room> personList = [];

  var bookStr = "";
  AppUtility appUtility = AppUtility();
  HttpClient httpClient = HttpClient();
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool descTextShowFlag = false;
  int currentImageIndex =0;
  var discountPrice;


  void initState() {
    super.initState();
    appUtility = AppUtility();
    widget.offeritem.rooms!.room!.sort((a, b) => a.price!.amount
        .compareTo(b.price!.amount));
    offer = widget.offeritem.rooms!.room![0];
    var roomViewName =  "";
    roomName = offer.name??"";
    if(roomViewName!=""){
      amenitiesList.add(roomViewName);
    }
    roomDesc = offer.description ?? "";
    if(offer.nbcAttributes!=null) {
      offer.nbcAttributes!.forEach((e) => amenitiesList.add(e!.name!));

      offer.nbcAttributes!.forEach((e) =>
      {
        amenities.add(appUtility.getAmenities(e!.name!))
      });
    }
    if (amenities.length < 5) {
      amenities = amenities;
    } else {
      amenities = amenities.take(5).toList();
    }
    personList = GlobalState.selectedRoomList;
    bookStr = appUtility.getNumberOfDays(
        GlobalState.checkInDate, GlobalState.checkOutDate, personList);
    discountPrice=offer.discountInfo != null
        ? offer.discountInfo!
        .perNightFullAmount!
        .toInt().toString() +" "+
        appUtility.getCurrentCurrency().toString() : "";
  }


  @override
  Widget build(BuildContext context) {
    var overallHeight = MediaQuery.of(context).size.height;
    var topHeight = MediaQuery.of(context).size.height * 0.015;
    var leftPadding = MediaQuery.of(context).size.width * 0.035;
    var distanceLeftPadding = MediaQuery.of(context).size.width * 0.04;
    var dividerTopHeight = MediaQuery.of(context).size.height * 0.02;
    var buttonHeight = overallHeight * 0.055;
    var descTopHeight = MediaQuery.of(context).size.height * 0.015;
    if (buttonHeight < 40) {
      buttonHeight = 45;
    }
    return Container(
      // height: MediaQuery.of(context).size.height/2,
      //  height: 400,
      margin: EdgeInsets.only(bottom: 10, top: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        //  border: Border.all(color: Colors.white, width: 1),
        //  borderRadius: BorderRadius.circular(containerBorderRadius),
        boxShadow: boxShadow,
        shape: BoxShape.rectangle,
      ),
      child: Column(
        children: <Widget>[
          if(offer.images!=null && offer.images!.length>0)
            Container(
              // height: MediaQuery.of(context).size.height * 0.25,
              height: MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                  child:
                  GestureDetector(
                    onTap: (){
                      List<String> image=[];
                      offer.images!.forEach((element) {
                        image.add(element!.original!.url.toString());
                      });
                      widget.continueCallBack.call("room page redirected");
                      pushNewScreen(
                        context,
                        screen: GalleryImageView(image,currentImageIndex),
                        withNavBar: false, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Carousel(
                      images: offer.images!
                          .map(
                              (e) =>
                              AppUtility().loadNetworkImage(e!.original!.url.toString())

                      ).toList(),
                      indicatorSize: const Size.square(8.0),
                      indicatorActiveSize: const Size(30.0, 8.0),
                      indicatorColor: Colors.grey,
                      indicatorActiveColor: Colors.white,
                      animationCurve: Curves.easeIn,
                      contentMode: BoxFit.cover,
                      autoPlay: false,
                      indicatorBackgroundColor: Colors.transparent,
                      bottomPadding: 20,
                      onImageChange: (index){
                        currentImageIndex = index;
                      },
                    ),
                    //  Image.asset("assets/images/bgnew.png", fit: BoxFit.fill),
                  )),
            ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
                left: leftPadding, right: leftPadding, top: topHeight),
            child: Text(roomName, style: hotelNameStyle),
          ),
          // Stack(
          //   children: <Widget>[
          //     Container(
          //       child: Row(
          //         children: <Widget>[
          //           Align(
          //             alignment: Alignment.centerLeft,
          //             child: Container(
          //                 padding: EdgeInsets.only(left: distanceLeftPadding),
          //                 child: Row(
          //                   children: [
          //                     Container(
          //                       padding: EdgeInsets.only(top: 1),
          //                       child: Text(
          //                         '35 m',
          //                         style: descTextStyle,
          //                       ),
          //                     ),
          //                     Container(
          //                         padding: EdgeInsets.only(top: 0),
          //                         child: Text(
          //                           '2',
          //                           style: meterSqureStyle,
          //                         )),
          //                   ],
          //                 )),
          //           ),
          //           Align(
          //             child: Container(
          //               padding: EdgeInsets.only(
          //                   left:
          //                       leftPadding), //padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.005),
          //               height: 45,
          //               child: VerticalDivider(
          //                 color: Uicolors.desText,
          //                 thickness: 0.5,
          //                 indent: 10,
          //                 endIndent: 10,
          //                 width: 20,
          //               ),
          //             ),
          //           ),
          //           Align(
          //               alignment: Alignment.centerLeft,
          //               child: Container(
          //                 padding: EdgeInsets.only(left: leftPadding),
          //                 child: Text(
          //                   '2 adults max',
          //                   style: descTextStyle,
          //                 ),
          //               )),
          //           Align(
          //             // alignment: Alignment.topCenter,
          //             child: Container(
          //               padding: EdgeInsets.only(left: leftPadding),
          //               height: 45,
          //               child: VerticalDivider(
          //                 color: Uicolors.desText,
          //                 thickness: 0.5,
          //                 indent: 10,
          //                 endIndent: 10,
          //                 width: 20,
          //               ),
          //             ),
          //           ),
          //           Align(
          //               alignment: Alignment.centerLeft,
          //               child: Container(
          //                 padding: EdgeInsets.only(left: leftPadding),
          //                 child: Text(
          //                   '1 child max',
          //                   style: descTextStyle,
          //                 ),
          //               )),
          //         ],
          //       ),
          //     )
          //   ],
          // ),
          Container(
            padding: EdgeInsets.only(
                left: leftPadding, right: leftPadding,top: topHeight),
            child: Text(
              AppUtility().parseHtmlString(roomDesc).replaceAll("\n", ""),
              style: descTextStyle,
              maxLines: descTextShowFlag?100:2,
            ),
          ),
          if ((roomDesc.length) < 100)
            Container(
                padding: EdgeInsets.only(
                  left: leftPadding,
                  bottom: (MediaQuery.of(context).size.height * 0.01),
                )),
          if ((roomDesc.length) > 100)
            Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                    left: leftPadding,bottom: topHeight),
                child: GestureDetector(
                  onTap: () {
                    // _showAmenities(context);
                    setState(() {
                      descTextShowFlag = !descTextShowFlag;
                    });
                  },
                  child: descTextShowFlag
                      ? Text(
                    Strings.viewLess,
                    style: viewMore,
                  )
                      : Text(
                    Strings.viewMore,
                    style: viewMore,
                  ),
                )),
          if(amenitiesList.length>0)
            Container(
              margin:  EdgeInsets.only(left: AppUtility().isTablet(context) ? MediaQuery.of(context).size.width * 0.035 : 12.0, top: 8),
              height: iconSize,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      alignment: Alignment.centerLeft,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: amenities.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              padding: EdgeInsets.only(right: 15),
                              child: Image.asset(
                                amenities[index],
                                width: iconSize,
                                height: iconSize,
                                color: Uicolors.desText,
                              ));
                        },
                      )),
                  Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: leftPadding, top: 0),
                      child: GestureDetector(
                           onTap: () {
                             widget.continueCallBack.call("room page redirected");
                             // _showAmenities(context);
                          pushNewScreen(
                            context,
                            screen: AmenitiesList(gridItems: amenitiesList),
                            withNavBar: false, // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                          );
                        },
                        child:
                        Text(Strings.viewMore, style: showAllAmenitiesStyle),
                      )),
                ],
              ),
            ),
          Container(
            // width: MediaQuery.of(context).size.width * 0.75,
              padding: EdgeInsets.only(
                  left: leftPadding,
                  right: leftPadding,
                  //  bottom: topHeight,
                  top: dividerTopHeight),
              child: Divider(
                color: Uicolors.desText,
                thickness: 0.5,
              )),
          GestureDetector(
            onTap:widget.onSelect,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                      margin: EdgeInsets.only(left: leftPadding, right: leftPadding,top: topHeight),
                      decoration: BoxDecoration(
                        boxShadow: boxShadow,
                        border: border,
                        color: widget.isSelected?Uicolors.buttonbg:Colors.white,
                      ),
                      padding: EdgeInsets.only(left: 10, right: 3, top: 10, bottom: 10),
                      child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 10, bottom: 0, top: 5, left: 0),
                              width: MediaQuery.of(context).size.width * 0.48,
                              child: Text(
                                widget.offeritem.rooms!.room![0].board!.label.toString(),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                //softWrap: false,
                                textAlign: TextAlign.left,
                                style: widget.isSelected?baseRateWhiteStyle:baseRateStyle,
                              ),
                            ),
                            Expanded(
                                child: Container(
                                  // alignment: Alignment.centerRight,
                                  //width: MediaQuery.of(context).size.width * 0.34,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          //   alignment: Alignment.centerRight,
                                          child: Row(
                                            // mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  widget.offeritem.rooms!.room![0]
                                                      .price!.amount.toInt().toString(),
                                                  style:widget.isSelected?priceTextWhiteStyle:priceTextStyle,
                                                  textAlign: TextAlign.right,
                                                  //  overflow: TextOverflow.ellipsis,
                                                  softWrap: true,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 5, bottom: 0,right: leftPadding),
                                                child: Text(
                                                  " "+appUtility.getCurrentCurrency().toString(),
                                                  style:widget.isSelected?dollerWhiteStyle:dollerStyle,
                                                  textAlign: TextAlign.right,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        if(discountPrice!="")
                                          Container(
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.only(right: leftPadding),
                                            child: Text(discountPrice,
                                              style: widget.isSelected?discountWhiteCrossStyle:discountCrossStyle,
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(right: leftPadding),
                                          child: Text(
                                            Strings.exclTaxesFees,
                                            style: widget.isSelected?exclTaxWhiteStyle:exclTaxStyle,
                                            textAlign: TextAlign.right,
                                          ),
                                        )
                                      ],
                                    )))
                          ])
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(
                right: leftPadding,
                top: MediaQuery.of(context).size.height * 0.015,
                bottom: MediaQuery.of(context).size.height * 0.015),
            child: FlatButton(
              //color: Uicolors.buttonbg,
                minWidth: MediaQuery.of(context).size.width * 0.5,
                height: buttonHeight,
                color: Uicolors.buttonbg,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(buttonHeight / 2),
                  // side: BorderSide(
                  //   color: Uicolors.buttonbg,
                  // ),
                ),
                child: Text( widget.isSelected?Strings.continueBooking:Strings.viewAllRate,
                  style:buttonStyle,
                ),
                onPressed: () {
                  if (widget.isSelected) {
                    checkAvailablity(
                        roomName,
                        offer.opCode.toString(),
                        offer.board!.opCode.toString(),
                        (widget.offeritem.rooms!.room![0].price!
                            .taxAmount +
                            widget.offeritem.rooms!.room![0]
                                .price!.amount).toStringAsFixed(2)
                            .toString(),offer.price!.currency.toString(),offer,offer.promoCode!=null?offer.promoCode!.toString():'');
                  } else {
                    widget.continueCallBack.call("room page redirected");
                    pushNewScreen(
                      context,
                      //  [TravellersRoomInput(refIds:roomRefType.map((e) => e.refId!).toList())],
                      screen: RoomInformation(
                          widget.offeritem.rooms!.room![0].board,
                          widget.offeritem, widget.hotelCrsCode, widget.hotelName,
                          widget.hotelId,widget.roomIndex,widget.adult,widget.children
                    ),
                      // screen:AsGuestSummery(selectedRoomName,roomTypeCode,roomRatePlanCode,widget.hotelCrsCode,widget.hotelName,price),
                      withNavBar:
                      false,
                      // OPTIONAL VALUE. True by default.
                      pageTransitionAnimation:
                      PageTransitionAnimation.cupertino,
                    );
                  }
                }
              //_sendDataBack(context);
              // },
            ),
          )
        ],
      ),
    );
  }

  Future<void> checkAvailablity(String selectedRoomName, String roomTypeCode,
      String roomRatePlanCode,
      String price,
      String ratePlanCurrencyCode,
      DetailOfferDataMixin$Rooms$Room offer,String promoCode) async{
    HashMap<String, dynamic> params = HashMap();
    params.putIfAbsent("hotel_crs_code", () => widget.hotelCrsCode);
    HashMap<String, dynamic> availabilityResponse = await CommonUtils().checkAvailablity(params, roomTypeCode, roomRatePlanCode,widget.hotelId,price,ratePlanCurrencyCode,promoCode,widget.roomIndex,widget.adult,widget.children);
    if( availabilityResponse["responseCode"]==Strings.failure) {
      appUtility.showToastView("Currently this room is unavailable. Please check some other room",context);
    }else if(availabilityResponse["paymentResponseCode"]==Strings.failure){
      appUtility.showToastView(Strings.errorMessage,context);
    }else if(availabilityResponse["currencyResponseCode"]==Strings.failure){
      appUtility.showToastView(Strings.errorMessage,context);
    } else{
      availabilityResponse.putIfAbsent("selectedRoomName", () => selectedRoomName);
      availabilityResponse.putIfAbsent("hotelCrsCode", () => widget.hotelCrsCode);
      availabilityResponse.putIfAbsent("hotelName", () => widget.hotelName);
      availabilityResponse.putIfAbsent("hotelId", () => widget.hotelId);
      // availabilityResponse.putIfAbsent("price", () => price);
      // availabilityResponse.putIfAbsent("ratePlanCountryCode", () => ratePlanCurrencyCode);
      availabilityResponse.putIfAbsent("roomFullDetails", () => offer);
      availabilityResponse.putIfAbsent("selectedPromoCode", () => promoCode);
      print("profile_id"+availabilityResponse["profileId"].toString());
      HashMap<String, dynamic> guestDetails = HashMap();
   //   GlobalState.selectedBookingRoomDet = availabilityResponse;
      GlobalState.selectedRoomList[widget.roomIndex-1].roomDetail = availabilityResponse;
      final User? user = auth.currentUser;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      widget.continueCallBack.call("room page redirected");
      pushNewScreen(
        context,
        screen: (user != null && prefs.getString("loginType")!="guest")
            ? AsGuestSummery(availabilityResponse, guestDetails)
            : AsGuest(availabilityResponse),
        withNavBar: false, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }

  }

  Widget _image(String asset) {
    return Image.asset(
      asset,
      height: 0.5,
      width: 0.5,
    );
  }


}
