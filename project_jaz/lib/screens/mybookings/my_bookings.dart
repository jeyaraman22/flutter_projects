import 'dart:collection';
import 'dart:convert';
// import 'dart:developer';
// import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/screens/mybookings/my_booking_details.dart';
import 'package:jaz_app/screens/product_overview/amenities_list.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/widgets/expandableDescription.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:jaz_app/utils/http_client.dart';
import 'package:intl/intl.dart';

class MyBookings extends StatefulWidget {
  final List bookingList;
  final QueryDocumentSnapshot lastDocument;
  const MyBookings(this.bookingList,this.lastDocument);
  @override
  _MyBookingsState createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  List bookingList = [];
  HttpClient httpClient = HttpClient();
  AppUtility appUtility = AppUtility();
  bool descTextShowFlag = false;
  var limit = 10;
  var lastDocument;
  bool hasMore = true;
  bool isPerformingRequest = false;
  ScrollController _controller = new ScrollController(initialScrollOffset: 0);


  @override
  void initState() {
    super.initState();
    bookingList = widget.bookingList;
    lastDocument = widget.lastDocument;
    _controller = new ScrollController(initialScrollOffset: 0);
    _controller.addListener(_scrollListener);


  }

  getBookingList() async {
    print("getBookingList");
    this.setState(() {
      isPerformingRequest = true;
    });
  //  EasyLoading.show();
    CollectionReference confirmBookingDetails =
        FirebaseFirestore.instance.collection('confirm_booking');
    final User? user = auth.currentUser;
    if (user != null) {
      final userId = user.uid;

        var document = await confirmBookingDetails
            .doc(userId)
            .collection("booking").startAfterDocument(lastDocument)
            .limit(limit)
            .get();
        print(document.docs.length);
        if (document.docs.length < limit) {
          hasMore = false;
          setState(() {
            isPerformingRequest = false;
          });
        }else {
          lastDocument = document.docs[document.docs.length - 1];
          print("lastDocument $lastDocument ${document.docs.length} ");

          // List bookingList = [];
          for (var booking in document.docs) {
            HashMap<String, dynamic> book = HashMap();
            var bookingItem =
            booking["OTA_HotelResRS"]["HotelReservations"]["HotelReservation"];
            var crsCode = bookingItem["RoomStays"]["RoomStay"]["BasicPropertyInfo"]
            ["_attributes"]["HotelCode"];
            var roomPlanCode = bookingItem["RoomStays"]["RoomStay"]["RoomRates"]
            ["RoomRate"]["_attributes"]["RoomTypeCode"];
            CollectionReference hotelDet =
            FirebaseFirestore.instance.collection('hotels');
            await hotelDet.doc(crsCode).get().then((value) async {
              await hotelDet
                  .doc(crsCode)
                  .collection("rooms")
                  .doc(roomPlanCode)
                  .get()
                  .then((rateplanvalue) {
                book.putIfAbsent("booking", () => booking.data());
                book.putIfAbsent("hotel", () => value.data());
                book.putIfAbsent("rooms", () => rateplanvalue.data());
              });
            });
            bookingList.add(book);
            isPerformingRequest = false;
          }
        }
        // EasyLoading.dismiss();
        if (this.mounted) {
          setState(() {});
        }
      }

  }
  _scrollListener() {

    if (_controller.offset >= _controller.position.maxScrollExtent && !_controller.position.outOfRange) {
        print("reach the bottom");
        if (!hasMore) {
          print('No More Products');
        }else{
          getBookingList();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var topHeight = MediaQuery.of(context).size.height * 0.015;
    var buttonHightPadding = overAllHeight * 0.0075;
    // var buttonHightPadding = overAllHeight * 0.015;
    var topSpace = overAllHeight * 0.055;
    var backTopSpace = 10.0;
    var leftPadding = overAllWidth * 0.055;
    var luxLeftPAdding = overAllWidth * 0.06;
    var listLeftPadding = overAllWidth * 0.035;
    var distanceLeftPadding = overAllWidth * 0.04;
    var dividerTopHeight = overAllHeight * 0.02;
    var buttonLeft = overAllWidth * 0.02;
    var buttonHeight =
        overAllHeight * (AppUtility().isTablet(context) ? 0.055 : 0.04);
    var buttonLeftPadding = overAllWidth * 0.02;
    var bottonBottomPadding = overAllHeight * 0.006;
    var dividerHeight = overAllHeight * 0.05;

    return Scaffold(
        backgroundColor: Uicolors.backgroundbg,
        appBar: AppBar(
          toolbarHeight: AppUtility().isTablet(context)
              ? 80
              : AppBar().preferredSize.height,
          backgroundColor: Colors.white,
          //preferredSize: Size.fromHeight(height), // here the desired height
          automaticallyImplyLeading: false,
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
                            backTopSpace,
                            0,
                            0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Uicolors.backText,
                          size: backIconSize,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 0, top: backTopSpace),
                        child: Text(Strings.back, style: backStyle),
                      ),
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.015,
                          top: backTopSpace),
                      child: Text(
                        Strings.myBooking,
                        style: priceHighGreenTextStyle,
                      )),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          child: Stack(
            children: [
              if (bookingList.length == 0)
                Container(
                  child: Container(
                    width: overAllWidth,
                    height: overAllHeight,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: Text(
                      Strings.noHotelList,
                      style: errorMessageStyle,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              Container(
                // child: LazyLoadScrollView(
                //     onEndOfPage: () {
                //
                //     },
                //     scrollOffset: 100,
                    child: ListView.builder(
                      controller: _controller,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: bookingList.length+1,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        if(index == bookingList.length){
                          return Container(
                              width: 50, height: 50, child: _buildProgressIndicator());
                        }else{
                        var bookingItem = bookingList[index]["booking"]
                                ["OTA_HotelResRS"]["HotelReservations"]
                            ["HotelReservation"];
                        var hotel = bookingList[index]["hotel"];
                        var hotelDet =
                            ProductsQuery$Query$Products$PackageProducts
                                .fromJson(hotel as Map<String, dynamic>);
                        var room = bookingList[index]["rooms"];
                        var roomDetails =
                            GetRoomOverview$Query$RoomOverview$Rooms.fromJson(
                                room as Map<String, dynamic>);
                        String roomName = roomDetails.name.toString();
                        String roomDesc = "<ul>" +
                            roomDetails.description
                                .toString()
                                .replaceAll("<br> •", "</li><li>") +
                            "</ul>";
                        var amenities = [];
                        roomDetails.nbcAttributes!.forEach((e) =>
                            {amenities.add(appUtility.getAmenities(e!.name!))});
                        if (amenities.length < 5) {
                          amenities = amenities;
                        } else {
                          amenities = amenities.take(5).toList();
                        }
                        List<String> amenitiesList = [];
                        var roomViewName = roomDetails.roomView?.name ?? "";

                        if (roomViewName != "") {
                          amenitiesList.add(roomViewName.toString());
                        }
                        roomDetails.nbcAttributes!
                            .forEach((e) => amenitiesList.add(e!.name!));
                        var roomImage =
                            roomDetails.mainImage!.default2x!.url.toString();

                        var startDate = bookingItem["RoomStays"]["RoomStay"]
                            ["TimeSpan"]["_attributes"]["Start"];
                        var endDate = bookingItem["RoomStays"]["RoomStay"]
                            ["TimeSpan"]["_attributes"]["End"];
                        var roomDet = "";
                        var price = bookingItem["RoomStays"]["RoomStay"]
                            ["Total"]["_attributes"]["AmountBeforeTax"];
                        var roomStatus = "";
                        var hotelCrsCode = bookingItem["RoomStays"]["RoomStay"]
                            ["BasicPropertyInfo"]["_attributes"]["HotelCode"];
                        var confirmationNumber =
                            bookingItem["UniqueID"]["_attributes"]["ID"];
                        var roomPlanDet = bookingItem["RoomStays"]["RoomStay"]
                                ["RatePlans"]["RatePlan"]["_attributes"]
                            ["RatePlanName"];
                        var startDateFormat =
                            DateFormat('yyyy-MM-dd').parse(startDate);
                        var endDateFormat =
                            DateFormat('yyyy-MM-dd').parse(endDate);
                        DateTime now = DateTime.now();
                        final day = now.difference(startDateFormat).inDays;
                        roomStatus = day == 0
                            ? "Staying"
                            : day < 0
                                ? "Upcoming"
                                : "Completed";
                        var numberofDay =
                            endDateFormat.difference(startDateFormat).inDays;
                        var daystr = "";
                        if (numberofDay > 1) {
                          daystr =
                              numberofDay.toString() + " " + Strings.nights;
                        } else {
                          daystr = numberofDay.toString() + " " + Strings.night;
                        }
                        int adult = 0, child = 0;
                        if (bookingItem["RoomStays"]["RoomStay"]["GuestCounts"]
                            ["GuestCount"] is List) {
                          bookingItem["RoomStays"]["RoomStay"]["GuestCounts"]
                                  ["GuestCount"]
                              .forEach((guestDetails) {
                            if (guestDetails["_attributes"]
                                    ["AgeQualifyingCode"] ==
                                "10") {
                              adult = int.parse(
                                  guestDetails["_attributes"]["Count"]);
                            } else if (guestDetails["_attributes"]
                                    ["AgeQualifyingCode"] ==
                                "8") {
                              child = int.parse(
                                  guestDetails["_attributes"]["Count"]);
                            }
                          });
                        } else {
                          if (bookingItem["RoomStays"]["RoomStay"]
                                      ["GuestCounts"]["GuestCount"]
                                  ["_attributes"]["AgeQualifyingCode"] ==
                              "10") {
                            adult = int.parse(bookingItem["RoomStays"]
                                    ["RoomStay"]["GuestCounts"]["GuestCount"]
                                ["_attributes"]["Count"]);
                          } else if (bookingItem["RoomStays"]["RoomStay"]
                                      ["GuestCounts"]["GuestCount"]
                                  ["_attributes"]["AgeQualifyingCode"] ==
                              "8") {
                            child = int.parse(bookingItem["RoomStays"]
                                    ["RoomStay"]["GuestCounts"]["GuestCount"]
                                ["_attributes"]["Count"]);
                          }
                        }
                        var adultStr, childStr;

                        if (adult > 1) {
                          adultStr = adult.toString() + " " + Strings.adults;
                        } else {
                          adultStr = adult.toString() + " " + Strings.adult;
                        }
                        if (child > 1) {
                          childStr =
                              child.toString() + " " + Strings.childrensStr;
                        } else {
                          childStr =
                              child.toString() + " " + Strings.childrenStr;
                        }
                        roomDet = daystr + ", " + adultStr + ", " + childStr;

                        return GestureDetector(
                            onTap: () {
                              getBookingDet(hotelCrsCode, confirmationNumber,
                                  hotelDet, roomName, roomDet, adult, child);
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  left: listLeftPadding,
                                  right: listLeftPadding,
                                  top: dividerTopHeight,
                                  bottom: index == 2 ? dividerTopHeight : 0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                //  border: Border.all(color: Colors.white, width: 1),
                                // borderRadius: BorderRadius.circular(containerBorderRadius),
                                boxShadow: boxShadow,
                                shape: BoxShape.rectangle,
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    //  height: 215,
                                    width: MediaQuery.of(context).size.width,
                                    child: ClipRRect(
                                      // borderRadius: BorderRadius.only(
                                      //     topLeft: Radius.circular(containerBorderRadius),
                                      //     topRight: Radius.circular(containerBorderRadius)),
                                      child: Image.network(
                                        roomImage,
                                        fit: BoxFit.cover,
                                      ),
                                      //  Image.asset("assets/images/bgnew.png", fit: BoxFit.fill),
                                    ),
                                  ),
                                  Padding(
                                      child: Row(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: buttonLeft),
                                            child: Container(
                                              height: buttonHeight,
                                              alignment: Alignment.topCenter,
                                              padding: EdgeInsets.only(
                                                left: leftPadding,
                                                right: leftPadding,
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          buttonHeight / 2),
                                                  color: day > 0
                                                      ? Uicolors
                                                          .redContainerColors
                                                      : day == 0
                                                          ? Uicolors
                                                              .yellowContainerColors
                                                          : Uicolors
                                                              .greenContainerColors),
                                              child: Center(
                                                child: Text(roomStatus,
                                                    style: bookingStatusStyle),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                left: leftPadding,
                                                right: leftPadding,
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text("From:\t",
                                                          style:
                                                              fromAndToTextStyle),
                                                      Text(startDate,
                                                          style:
                                                              fromAndToTextStyle),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text("To\t\t\t\t\t:\t",
                                                          style:
                                                              fromAndToTextStyle),
                                                      Text(endDate,
                                                          style:
                                                              fromAndToTextStyle),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            alignment: Alignment.topRight,
                                          )
                                        ],
                                      ),
                                      padding: EdgeInsets.only(
                                          top: dividerTopHeight,
                                          left: buttonLeftPadding,
                                          bottom: bottonBottomPadding)),
                                  Container(
                                      // width: MediaQuery.of(context).size.width * 0.75,
                                      padding: EdgeInsets.only(
                                          left: buttonLeftPadding,
                                          right: buttonLeftPadding,
                                          // bottom: topHeight,
                                          top: bottonBottomPadding),
                                      child: Divider(
                                        color: Uicolors.greyText,
                                        thickness: 0.5,
                                      )),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(
                                        left: distanceLeftPadding,
                                        right: leftPadding,
                                        top: topHeight),
                                    child:
                                        Text(roomName, style: hotelNameStyle),
                                  ),
                                  Container(
                                      child: ExpandableDescription(
                                    description: roomDesc,
                                  )),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: distanceLeftPadding,
                                        top: topHeight),
                                    height: iconSize,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: amenities.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Container(
                                                    padding: EdgeInsets.only(
                                                        right: 15),
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
                                            padding: EdgeInsets.only(
                                                right: leftPadding, top: 0),
                                            child: GestureDetector(
                                              onTap: () {
                                                pushNewScreen(
                                                  context,
                                                  screen: AmenitiesList(
                                                      gridItems: amenitiesList),
                                                  withNavBar:
                                                      false, // OPTIONAL VALUE. True by default.
                                                  pageTransitionAnimation:
                                                      PageTransitionAnimation
                                                          .cupertino,
                                                );
                                              },
                                              child: Text(Strings.viewMore,
                                                  style: showAllAmenitiesStyle),
                                            )),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      // width: MediaQuery.of(context).size.width * 0.75,
                                      padding: EdgeInsets.only(
                                          left: buttonLeftPadding,
                                          right: buttonLeftPadding,
                                          // bottom: topHeight,
                                          top: bottonBottomPadding),
                                      child: Divider(
                                        color: Uicolors.greyText,
                                        thickness: 0.5,
                                      )),
                                  Container(
                                      padding:
                                          EdgeInsets.only(top: 10, bottom: 15),
                                      decoration: BoxDecoration(
                                        // color: Colors.black45,
                                        // border: Border.all(color: Colors.white, width: 1),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        shape: BoxShape.rectangle,
                                      ),
                                      alignment: Alignment.center,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            // onItemTapped = true;
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Column(children: [
                                              Container(
                                                alignment: Alignment.centerLeft,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                padding: EdgeInsets.only(
                                                    right: 10,
                                                    bottom: 0,
                                                    top: 10),
                                                child: Text(
                                                  roomDet.toLowerCase(),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                  textAlign: TextAlign.left,
                                                  style: bookStrStyle,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                    right: 10,
                                                    bottom: 0,
                                                    top: 5,
                                                    left: 0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  roomPlanDet,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                  style: bestRateStyle,
                                                ),
                                              ),
                                            ]),
                                            Container(
                                                child: Column(
                                              //
                                              children: [
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 0,
                                                                top: 0,
                                                                bottom: 0),
                                                        child: Text(
                                                          price,
                                                          style: priceTextStyle,
                                                          textAlign:
                                                              TextAlign.right,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 5,
                                                                bottom: 0),
                                                        child: Text(
                                                          " " +
                                                              Strings.us$
                                                                  .toString(),
                                                          style: dollerStyle,
                                                          textAlign:
                                                              TextAlign.right,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    Strings.exclTaxesFees,
                                                    style: exclTaxStyle,
                                                    textAlign: TextAlign.right,
                                                  ),
                                                )
                                              ],
                                            ))
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                            ));
                      }},
                    ),
              )
            ],
          ),
        ));
  }

  Widget _buildProgressIndicator() {
    return Center(
      child: new Opacity(
        opacity: isPerformingRequest ? 1.0 : 0.0,
        child: new CircularProgressIndicator(),
      ),
    );
  }

  getBookingDet(
      String hotelCode,
      String reservationNmber,
      ProductsQuery$Query$Products$PackageProducts hotel,
      String roomName,
      String roomDet,
      int adult,
      int child) async {
    //for(int i=0;i<reservationIds.length;i++) {
    var response;
    HashMap<String, dynamic> params = HashMap();
    params.putIfAbsent("hotel_crs_code", () => hotelCode);
    params.putIfAbsent("confirmation_number", () => reservationNmber);
    EasyLoading.show();
    // BuildContext? dialogContext;
    // AppUtility().showProgressDialog(context,type: null, dismissDialog:(value){
    //   dialogContext = value;
    // });
    response = await httpClient.getData(params, "get_booking", null);
    if (response.statusCode == 200 && json.decode(response.body) != null) {
      EasyLoading.dismiss();
      // await new Future.delayed(const Duration(milliseconds: 500));
      // AppUtility().dismissDialog(dialogContext!);
      var result = json.decode(response.body);
      pushNewScreen(
        context,
        //  [TravellersRoomInput(refIds:roomRefType.map((e) => e.refId!).toList())],
        screen:
            MyBookingDetails(result, hotel, roomName, roomDet, adult, child),
        withNavBar: false, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } else {
      EasyLoading.dismiss();
      // await new Future.delayed(const Duration(milliseconds: 500));
      // AppUtility().dismissDialog(dialogContext!);
      // If that call was not successful, throw an error.
      //   return [];
    }
  }
}
