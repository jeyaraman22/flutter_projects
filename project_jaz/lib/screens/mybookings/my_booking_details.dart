import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/screens/product_overview/galleryimageview.dart';
import 'package:jaz_app/screens/product_overview/hotelreview.dart';
import 'package:jaz_app/utils/carousel.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/uiconstants.dart';
import 'package:jaz_app/widgets/expansionlist.dart';
import 'package:jaz_app/utils/http_client.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:toast/toast.dart';

class MyBookingDetails extends StatefulWidget {
  final myBookingDet;
  final ProductsQuery$Query$Products$PackageProducts hotel;
  final String roomName;
  final String roomDet;
  final int adultCount;
  final int childCount;

  MyBookingDetails(this.myBookingDet, this.hotel, this.roomName, this.roomDet,this.adultCount,this.childCount);

  @override
  _MyBookingDetailsState createState() => _MyBookingDetailsState();
}

class _MyBookingDetailsState extends State<MyBookingDetails>
    with TickerProviderStateMixin {
  double avgRating = 0;
  String location = "";
  int index = 0;
  String hotelName = "";
  double category = 0.0;
  String roomType = 'Room Type';
  var roomTypeContent = 'Jaz Almaza Beach - Superior, Queen Bed';
  String rateDesc =
      'Super Saver Rate - Jaz Almanza Beach - Save 10% Half Board Basis';
  late AnimationController _controller;
  var scale = 1.0;
  List expansionList = [];
  List expansionList2 = [
    {
      "img": null,
      "name": "Cancellation Policy",
      "desc":
          "In Case of cancellation with 02 days priror to arrival or No show, 01 night charge apply."
    }
  ];
  var confirmationNumber;
  var myBooking;
  var startDate;
  var endDate;
  var hotelCrsCode;
  var price;
  AppUtility appUtility = AppUtility();
  HttpClient httpClient = HttpClient();
  var isCancellable;
  late ProductsQuery$Query$Products$PackageProducts product;
  var logoUrl = "default";
  var roomDet;
  var currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    product = widget.hotel;
    myBooking = widget.myBookingDet;
    hotelName = product.hotel!.name.toString();
    roomDet = widget.roomDet.toLowerCase();
    location = (product.hotel!.location!.country.name)! +
        " - " +
        (product.hotel!.location!.city!.name)!;
    roomTypeContent = widget.roomName;
    product.hotel!.ratings?.forEach((e) => e.rating!.forEach((rating) {
          if (rating.name == "averageRating") {
            avgRating = rating.value;
          }
        }));
    product.hotelContent!.logo!.sizes!.forEach((element) {
      logoUrl = element!.url.toString();
    });

    var bookingItem =
        myBooking["OTA_HotelResRS"]["HotelReservations"]["HotelReservation"];
    startDate = bookingItem["RoomStays"]["RoomStay"]["TimeSpan"]["_attributes"]
        ["Start"];
    endDate =
        bookingItem["RoomStays"]["RoomStay"]["TimeSpan"]["_attributes"]["End"];

    price = bookingItem["RoomStays"]["RoomStay"]["Total"]["_attributes"]
        ["AmountAfterTax"];

    hotelCrsCode = bookingItem["RoomStays"]["RoomStay"]["BasicPropertyInfo"]
        ["_attributes"]["HotelCode"];
    confirmationNumber = bookingItem["UniqueID"]["_attributes"]["ID"];
    rateDesc = bookingItem["RoomStays"]["RoomStay"]["RatePlans"]["RatePlan"]
        ["_attributes"]["RatePlanName"];
    var bookingPolicy = bookingItem["RoomStays"]["RoomStay"]["RatePlans"]
        ["RatePlan"]["Guarantee"]["GuaranteeDescription"]["Text"]["_text"];
    var cancelPolicy = bookingItem["RoomStays"]["RoomStay"]["RatePlans"]
            ["RatePlan"]["CancelPenalties"]["CancelPenalty"]
        ["PenaltyDescription"]["Text"]["_text"];
    isCancellable = bookingItem["TPA_Extensions"]["ResStatus"]["_attributes"]
        ["IsCancellable"];
    expansionList = [
      {
        "title": "Booking Policy",
        "name": "Booking Policy",
        "desc": "<h1>" + bookingPolicy + "</h1>"
      }
    ];
    expansionList2 = [
      {
        "img": null,
        "name": "Cancellation Policy",
        "desc": "<h1>" + appUtility.parseHtmlString(cancelPolicy) + "</h1>",
        "IsCancellable": isCancellable
      }
    ];
    _controller = AnimationController(
        upperBound: 0.1,
        lowerBound: 0.1,
        duration: const Duration(milliseconds: 1),
        vsync: this);
    _controller.repeat(reverse: true);
  }
  @override
  dispose() {
    _controller.dispose(); // you need thissuper.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var indicatorSize = AppUtility().indicaorSize(context);
    var currentIndicatorSize = AppUtility().currentIndicatorSize(context);

    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var backTopSpace = 0.0;
    var buttonHeight = overAllHeight * 0.055;
    var buttonWidth = overAllWidth * 0.50;
    var buttonTopPadding = overAllHeight * 0.065;
    var topHeight = overAllHeight * 0.025;
    var leftPadding = overAllWidth * 0.033;
    var backImageheight = overAllHeight * 0.45;
    var viewStartHeight = overAllHeight * 0.36;
    var toppadding = overAllHeight * 0.015;
    var contentLeftPadding = overAllWidth * 0.025;
    var nameTopPadding = overAllHeight * 0.015;
    var priceUSDLeftPadding = overAllWidth * 0.18;
    var dividerTopPadding = overAllHeight * 0.007;
    var bottomContainerPadding = overAllHeight * 0.030;
    var logoTopPadding = overAllHeight * 0.29;

    return Scaffold(
      backgroundColor: Uicolors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
                      Navigator.of(context, rootNavigator: true).pop(context);
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
                      Navigator.of(context, rootNavigator: true).pop(context);
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
                        right: MediaQuery.of(context).size.width * 0.010,
                        top: backTopSpace),
                    child: Text(
                      Strings.welcomeToJaz + product.hotel!.name.toString(),
                      style: welcomJazStyle,
                    )),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: ScaleTransition(
            scale: Tween(begin: 1.0, end: scale).animate(
                CurvedAnimation(parent: _controller, curve: Curves.bounceOut)),
            child: Stack(
              children: <Widget>[
                Container(
                  height: scale == 1 ? backImageheight : overAllHeight * 0.55,
                  width: overAllWidth,
                  child: GestureDetector(
                    onTap: (){
                      List<String> image = [];
                      product.hotelContent!.images!.forEach((element) {
                        image.add(element!.default2x!.url.toString());
                      });
                      pushNewScreen(
                        context,
                        screen: GalleryImageView(image, currentImageIndex),
                        withNavBar: false,
                        // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                        PageTransitionAnimation.cupertino,
                      );
                    },
                      onHorizontalDragStart: (details) {
                      },
                      onVerticalDragUpdate: (dragDetails) {
                        setState(() {
                          scale = 1.2;
                          //     resetScale();
                        });
                      },
                      onVerticalDragEnd: (endDetails) {
                        setState(() {
                          scale = 1.2;
                          resetScale();
                        });
                      },
                      child: ClipRRect(
                        child: Carousel(
                          images: product.hotelContent!.images!
                              .map((e) => AppUtility().loadNetworkImage(e!.default2x!.url.toString())
                              ).toList(),
                          indicatorSize: Size.square(indicatorSize),
                          indicatorActiveSize:
                              Size(currentIndicatorSize, indicatorSize),
                          indicatorColor: Colors.grey,
                          indicatorActiveColor: Colors.white,
                          animationCurve: Curves.easeIn,
                          contentMode: BoxFit.cover,
                          autoPlay: false,
                          indicatorBackgroundColor: Colors.transparent,
                          bottomPadding: backImageheight / 4,
                          onImageChange: (index) {
                            currentImageIndex = index;
                          },
                        ),
                      )),
                ),
                Container(
                    margin: EdgeInsets.only(
                        top: scale == 1
                            ? viewStartHeight
                            : overAllHeight * 0.46),
                    child: AppUtility().isTablet(context)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.65,
                                    child: viewCardWidget(
                                        overAllHeight,
                                        leftPadding,
                                        contentLeftPadding,
                                        topHeight,
                                        nameTopPadding,
                                        buttonHeight,
                                        toppadding,
                                        dividerTopPadding,
                                        bottomContainerPadding), // it contains booking details like hotel name, location ,rooms
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                            0.35 -
                                        contentLeftPadding,
                                    child: checkInCheckOutWidget(
                                        toppadding, leftPadding, topHeight),
                                  ) // it contains check in and checkout ui
                                ],
                              ),
                              showConfirmationNoandPanelWidget(
                                  contentLeftPadding,
                                  topHeight,
                                  toppadding,
                                  leftPadding,
                                  dividerTopPadding,
                                  buttonTopPadding,
                                  bottomContainerPadding,
                                  buttonHeight,
                                  buttonWidth)
                              // it contains confirmation widget and expansion panel widgets
                            ],
                          )
                        : Column(
                            children: [
                              viewCardWidget(
                                  overAllHeight,
                                  leftPadding,
                                  contentLeftPadding,
                                  topHeight,
                                  nameTopPadding,
                                  buttonHeight,
                                  toppadding,
                                  dividerTopPadding,
                                  bottomContainerPadding),
                              // it contains booking details like hotel name, location ,rooms
                              /* checkInCheckOutWidget(
                                  toppadding, leftPadding, topHeight),*/
                              // it contains check in and checkout ui

                              showConfirmationNoandPanelWidget(
                                  contentLeftPadding,
                                  topHeight,
                                  toppadding,
                                  leftPadding,
                                  dividerTopPadding,
                                  buttonTopPadding,
                                  bottomContainerPadding,
                                  buttonHeight,
                                  buttonWidth)
                              // it contains confirmation widget and expansion panel widgets
                            ],
                          )),
              ],
            ),
          )),
    );
  }

  cancelBooking(String hotelCrsCode, String reservationId) async {
    var response;
    HashMap<String, dynamic> params = HashMap();
    params.putIfAbsent("hotel_crs_code", () => hotelCrsCode);
    params.putIfAbsent("confirmation_number", () => reservationId);
    EasyLoading.show();
    // BuildContext? dialogContext;
    // AppUtility().showProgressDialog(context,type:null,dismissDialog:(value){
    //   dialogContext = value;
    // });
    response = await httpClient.getData(params, "cancel_booking", null);
    if (response.statusCode == 200 && json.decode(response.body) != null) {
      EasyLoading.dismiss();

      var res = json.decode(response.body);
      var message = "";
      if (res["OTA_CancelRS"]["_attributes"]["ResResponseType"] == "Cancelled") {
        // message =res["OTA_CancelRS"]["Errors"]["Error"]["_attributes"]["ShortText"];
        message = "Your Booking is cancelled successfully";
        setState(() {
          isCancellable ="false";
        });
      } else {
        message = "Unable to cancel";
      }
      appUtility.showToastView(message, context);

      // ToastView.createView(message, context, Toast.LENGTH_LONG, Toast.BOTTOM,
      //     Uicolors.buttonbg, Colors.white, 3, null);
    } else {
      EasyLoading.dismiss();
    }
  }

  Widget _image(String asset) {
    return Image.asset(
      asset,
      height: 0.5,
      width: 0.5,
      /*  height: 2,
      width: 2,*/
      // color: Colors.amber,
    );
  }

  Widget showCheckOutWidget() {
    return Container(
        margin: !AppUtility().isTablet(context)
            ? EdgeInsets.all(0)
            : EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                "assets/images/clock.png",
                width: iconSize,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01),
              child: Container(
                  alignment: Alignment.centerLeft,
                  // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                  child: Text(
                     Strings.checkout,
                    style: checkInStyle,
                  )),
            ),
            Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.005),
                alignment: Alignment.centerLeft,
                // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                child: Text(
                  endDate+ "\n" +
                  'Before 12.00 PM',
                  style: timeStyle,
                ))
          ],
        ));
  }

  Widget checkInCheckOutWidget(toppadding, leftPadding, topHeight) {
    return Column(
      children: [
        Container(
          margin: !AppUtility().isTablet(context)
              ? EdgeInsets.all(MediaQuery.of(context).size.width * 0.033)
              : EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: boxShadow,
            // borderRadius:
            //     BorderRadius.circular(containerBorderRadius),
            shape: BoxShape.rectangle,
          ),
          child: Row(
            children: <Widget>[
              Container(
                  child: AppUtility().isTablet(context)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            showCheckInWidget(),
                            Container(
                              margin: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.02,
                                  right:
                                      MediaQuery.of(context).size.width * 0.02),
                              width: MediaQuery.of(context).size.width * 0.31 -
                                  leftPadding,
                              height: 1,
                              color: Uicolors.borderColor,
                            ),
                            showCheckOutWidget(),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.50,
                              child: showCheckInWidget(),
                            ),
                            showCheckOutWidget(),
                          ],
                        )),
            ],
          ),
        )
      ],
    );
  }

  Widget showCheckInWidget() {
    return Container(
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                "assets/images/clock.png",
                width: iconSize,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01),
              child: Container(
                  alignment: Alignment.centerLeft,
                  // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                  child: Text(
                    Strings.checkin,
                    style: checkInStyle,
                  )),
            ),
            Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.005),
                alignment: Alignment.centerLeft,
                // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                child: Text(
                  startDate+ "\n" +
                  'After 2.00 PM',
                  style: timeStyle,
                ))
          ],
        ));
  }

  void resetScale() {
    Future.delayed(Duration(milliseconds: 20), () {
      setState(() {
        scale = 1.0;
      });
    });
  }

  Widget viewCardWidget(
      overAllHeight,
      leftPadding,
      contentLeftPadding,
      topHeight,
      nameTopPadding,
      buttonHeight,
      toppadding,
      dividerTopPadding,
      bottomContainerPadding) {
    return Container(
      margin: EdgeInsets.only(left: leftPadding, right: leftPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border.all(color: Colors.white, width: 1),
        // borderRadius:
        //     BorderRadius.circular(containerBorderRadius),
        boxShadow: boxShadow,
        shape: BoxShape.rectangle,
      ),
      child: Column(
        children: <Widget>[
          Container(
            child: Padding(
                padding: EdgeInsets.only(
                    left: contentLeftPadding,
                    right: contentLeftPadding,
                    top: topHeight),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.01,
                              0,
                              0,
                              0),
                          child: Image.asset(
                            "assets/images/owl.png",
                            width: iconSize,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.01,
                              0,
                              0,
                              0),
                          child: RatingBar(
                            ignoreGestures: true,
                            initialRating: avgRating,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: backIconSize,
                            ratingWidget: RatingWidget(
                              full: _image('assets/images/fullround.png'),
                              half: _image('assets/images/halfround.png'),
                              empty: _image('assets/images/greyround.png'),
                            ),
                            itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                            onRatingUpdate: (rating) {
                              setState(() {
                                // here update the rating
                              });
                            },
                            updateOnDrag: true,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.01,
                              0,
                              0,
                              0),
                          child: Text(avgRating.toString(),
                              style: avgRatingTextStyle),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Text('/5', style: overallRatingStyle),
                        ),
                      ],
                    ),
                    if (product.hotel!.ratings != null)
                      Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.015),
                          child: GestureDetector(
                            onTap: () {
                              pushNewScreen(
                                context,
                                //  [TravellersRoomInput(refIds:roomRefType.map((e) => e.refId!).toList())],
                                screen: HotelReview(product),
                                withNavBar: false,
                                // OPTIONAL VALUE. True by default.
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: Text(Strings.viewReviews,
                                style: viewReviewStyle),
                          ))
                  ],
                )),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
                left: contentLeftPadding,
                right: contentLeftPadding,
                top: nameTopPadding),
            child: Text(hotelName, style: hotelNameStyle),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: contentLeftPadding, top: 5),
            child: Text(location, style: locationStyle),
          ),
          Container(
              margin: EdgeInsets.only(
                  top: dividerTopPadding,
                  bottom: dividerTopPadding,
                  right: contentLeftPadding,
                  left: contentLeftPadding),
              child: Divider(
                color: Uicolors.greyText,
                thickness: 0.5,
              )),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
              left: contentLeftPadding,
              right: contentLeftPadding,
            ),
            child: Text(roomType, style: myBookingHeaderTextStyle),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
                left: contentLeftPadding, top: 5, bottom: nameTopPadding),
            child: Text(roomTypeContent, style: myBookingHeaderSubTextStyle),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: contentLeftPadding, top: 5),
                child: Text(Strings.roomsTrip, style: myBookingHeaderTextStyle),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(right: contentLeftPadding, top: 5),
                child: Text((widget.adultCount==1 && widget.childCount==0)?Strings.guest:Strings.guests, style: myBookingHeaderTextStyle),
              ),
            ],
          ),
          Padding(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: contentLeftPadding, top: 5),
                  child:
                      Text(Strings.room1, style: myBookingHeaderSubTextStyle),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(right: contentLeftPadding, top: 5),
                  child: Text(roomDet, style: myBookingHeaderSubTextStyle),
                ),
              ],
            ),
            padding: EdgeInsets.only(bottom: bottomContainerPadding),
          )
        ],
      ),
    );
  }

  Widget showConfirmationNoandPanelWidget(
      contentLeftPadding,
      topHeight,
      toppadding,
      leftPadding,
      dividerTopPadding,
      buttonTopPadding,
      bottomContainerPadding,
      buttonHeight,
      buttonWidth) {
    return Column(
      children: [
        Container(
            // height: MediaQuery.of(context).size.height/2,
            //  height: 400,
            padding: EdgeInsets.only(
                left: contentLeftPadding,
                right: contentLeftPadding,
                top: topHeight,
                bottom: topHeight),
            margin: EdgeInsets.only(
                top: toppadding, left: leftPadding, right: leftPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: boxShadow,
              // borderRadius:
              //     BorderRadius.circular(containerBorderRadius),
              shape: BoxShape.rectangle,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(
                          left: contentLeftPadding,
                          right: contentLeftPadding,
                          top: dividerTopPadding),
                      child: Text(Strings.confirmation + " " + Strings.number,
                          style: myBookingHeaderTextStyle),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(
                      left: contentLeftPadding,
                      right: contentLeftPadding,
                      top: dividerTopPadding),
                  child:
                      Text(confirmationNumber, style: conformationNumberStyle),
                ),
              ],
            )),
        AppUtility().isTablet(context)
            ? Container()
            : Container(
                // height: MediaQuery.of(context).size.height/2,
                //  height: 400,
                margin: EdgeInsets.only(
                    top: toppadding, left: leftPadding, right: leftPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: boxShadow,

                  // borderRadius: BorderRadius.circular(containerBorderRadius),
                  shape: BoxShape.rectangle,
                ),
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.05,
                              top: topHeight),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                            child: Image.asset(
                              "assets/images/clock.png",
                              width: iconSize,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.50,
                              top: topHeight),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                            child: Image.asset(
                              "assets/images/clock.png",
                              width: iconSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.05,
                              top: MediaQuery.of(context).size.height * 0.01),
                          child: Container(
                              alignment: Alignment.centerLeft,
                              // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                              child: Text(
                                Strings.checkin,
                                style: checkInStyle,
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.50,
                              top: MediaQuery.of(context).size.height * 0.01),
                          child: Container(
                              alignment: Alignment.centerLeft,
                              // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                              child: Text(
                                Strings.checkout,
                                style: checkInStyle,
                              )),
                        ),
                      ],
                    ),
/*
                    Stack(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05,
                            top: MediaQuery.of(context).size.height * 0.005,
                          ),
                          child: Container(
                              alignment: Alignment.centerLeft,
                              // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                              child: Text(
                                startDate,
                                style: expansionTitleStyle,
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.50,
                              top: MediaQuery.of(context).size.height * 0.005),
                          child: Container(
                              alignment: Alignment.centerLeft,
                              // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                              child: Text(
                                endDate,
                                style: expansionTitleStyle,
                              )),
                        ),
                      ],
                    ),
*/
                    Stack(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.05,
                              top: MediaQuery.of(context).size.height * 0.005,
                              bottom:
                                  MediaQuery.of(context).size.height * 0.02),
                          child: Container(
                              alignment: Alignment.centerLeft,
                              // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                              child: Column(
                                children: [
                                  Text(
                                    startDate,
                                    style: expansionTitleStyle,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top:
                                        MediaQuery.of(context).size.height *
                                            0.005),
                                    child: Text(
                                      'After 2.00 PM',
                                      style: timeStyle,
                                    ),
                                  )
                                ],
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.50,
                              top: MediaQuery.of(context).size.height * 0.005),
                          child: Container(
                              alignment: Alignment.centerLeft,
                              // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                              child: Column(
                                children: [
                                  Text(
                                    endDate,
                                    style: expansionTitleStyle,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.005),
                                    child: Text(
                                      'Before 12:00 PM',
                                      style: timeStyle,
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        Container(
          // height: MediaQuery.of(context).size.height/2,
          //  height: 400,
          padding: EdgeInsets.only(
              left: contentLeftPadding,
              right: contentLeftPadding,
              top: topHeight,
              bottom: topHeight),
          margin: EdgeInsets.only(
              top: toppadding, left: leftPadding, right: leftPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: boxShadow,

            // borderRadius: BorderRadius.circular(containerBorderRadius),
            shape: BoxShape.rectangle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  left: contentLeftPadding,
                  right: contentLeftPadding,
                ),
                child: Text(Strings.ratePlan, style: myBookingHeaderTextStyle),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  left: contentLeftPadding,
                  right: contentLeftPadding,
                ),
                child: Text(rateDesc, style: ratePlanDesc),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  top: topHeight,
                  left: contentLeftPadding,
                  right: contentLeftPadding,
                ),
                child: Text(Strings.totalStayRate,
                    style: myBookingHeaderTextStyle),
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(
                    left: contentLeftPadding,
                    right: contentLeftPadding,
                    top: dividerTopPadding),
                child: Row(
                  children: [
                    Text(price, style: priceTextStyle),
                    Padding(
                      child: Text(Strings.us$, style: dollerStyle),
                      padding: EdgeInsets.only(top: dividerTopPadding),
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  left: contentLeftPadding,
                  right: contentLeftPadding,
                ),
                child: Text(Strings.incTaxFee, style: exclTaxStyle),
              ),
            ],
          ),
        ),
        if (expansionList.length > 0)
          Container(
            padding: EdgeInsets.only(
              left: contentLeftPadding,
              right: contentLeftPadding,
            ),
            margin: EdgeInsets.only(
                top: toppadding, left: leftPadding, right: leftPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: boxShadow,
              // borderRadius: BorderRadius.circular(containerBorderRadius),
              shape: BoxShape.rectangle,
            ),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      // scrollDirection: Axis.vertical,
                      itemCount: expansionList.length,
                      itemBuilder: (context, index) => ExpansionTile(
                            collapsedIconColor: Uicolors.buttonbg,
                            iconColor: Uicolors.buttonbg,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 0,
                                  bottom: buttonTopPadding,
                                ),
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(
                                    left: contentLeftPadding,
                                    right: contentLeftPadding,
                                  ),
                                  // child: Text(
                                  //   expansionList[index]["desc"],
                                  //   style: descTextStyle,
                                  // ),
                                  child: Html(
                                    data: expansionList[index]["desc"],
                                    shrinkWrap: true,
                                    style: {
                                      "h1": h1Style,
                                      "p": paraStyle,
                                      "li": listStyle,
                                      'html':
                                          Style(textAlign: TextAlign.justify),
                                    },
                                  ),
                                ),
                              )
                            ],
                            title: Text(
                              expansionList[index]["name"],
                              style: expansionTitleStyle,
                            ),
                          )),
                )
              ],
            ),
          ),
        if (expansionList2.length > 0)
          Padding(
            padding: EdgeInsets.only(bottom: bottomContainerPadding),
            child: Container(
              padding: EdgeInsets.only(
                left: contentLeftPadding,
                right: contentLeftPadding,
              ),
              margin: EdgeInsets.only(
                  top: toppadding, left: leftPadding, right: leftPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: boxShadow,
                // borderRadius: BorderRadius.circular(containerBorderRadius),
                shape: BoxShape.rectangle,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        // scrollDirection: Axis.vertical,
                        itemCount: expansionList2.length,
                        itemBuilder: (context, index) => ExpansionTile(
                              collapsedIconColor: Uicolors.buttonbg,
                              iconColor: Uicolors.buttonbg,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(
                                    left: contentLeftPadding,
                                    right: contentLeftPadding,
                                  ),
                                  // child: Text(
                                  //   expansionList2[index]["desc"],
                                  //   style: descTextStyle,
                                  // ),
                                  child: Html(
                                    data: expansionList2[index]["desc"],
                                    shrinkWrap: true,
                                    style: {
                                      "h1": h1Style,
                                      "p": paraStyle,
                                      "li": listStyle,
                                      'html':
                                          Style(textAlign: TextAlign.justify),
                                    },
                                  ),
                                ),
                                if (isCancellable == "true")
                                  Padding(
                                      padding: EdgeInsets.only(
                                        top: buttonTopPadding,
                                        bottom: buttonTopPadding,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          cancelBooking(
                                              hotelCrsCode, confirmationNumber);
                                        },
                                        child: Container(
                                            height: buttonHeight,
                                            width: buttonWidth,
                                            alignment: Alignment.centerLeft,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Uicolors.buttonbg),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      buttonHeight / 2),
                                            ),
                                            child: Center(
                                              child: Text(
                                                Strings.cancelBookings,
                                                style: cancelButtonTextStyle,
                                              ),
                                            )),
                                      ))
                              ],
                              title: Text(
                                expansionList2[index]["name"],
                                style: expansionTitleStyle,
                              ),
                            )),
                  )
                ],
              ),
            ),
          )
      ],
    );
  }
}
