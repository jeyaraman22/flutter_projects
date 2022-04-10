import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:graphql/client.dart';
import 'package:jaz_app/helper/graphqlconnectivity/constants.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/screens/booking/booking_start.dart';
import 'package:jaz_app/screens/bottomnavigation/bottombar.dart';
import 'package:jaz_app/screens/product_overview/selectroom.dart';
import 'package:jaz_app/screens/search/hotel_list.dart';
import 'package:jaz_app/screens/search/search.dart';
import 'package:jaz_app/screens/search/searchmap.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/carousel.dart';
import 'package:jaz_app/utils/commonutils.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/uiconstants.dart';
import 'package:jaz_app/widgets/customdialog.dart';
import 'package:jaz_app/widgets/expansionlist.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:jaz_app/utils/http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../graphql_provider.dart';
import '../homebottombar.dart';
import 'amenities_list.dart';
import 'galleryimageview.dart';
import 'hotelreview.dart';

class HotelDetails extends StatefulWidget {
  //final BuildContext hotelDetailsContext;
  final String pageName;
  final String productId;
  final ProductsQuery$Query$Products$PackageProducts product;
  String description = "";
  List expansionList = [];
  final Function(String) onBack;

  HotelDetails(this.product, this.productId, this.pageName, this.description,
      this.expansionList,
      {required this.onBack});

  _HotelDetailsState createState() => _HotelDetailsState();
}

class _HotelDetailsState extends State<HotelDetails>
    with TickerProviderStateMixin {
  AppUtility appUtility = AppUtility();
  HttpClient httpClient = HttpClient();

  var timeDetails;
  late ProductsQuery$Query$Products$PackageProducts product;
  List expansionList = [];
  List<String> amenitiesList = [];
  List amenities = [];
  double avgRating = 0;
  String location = "";
  String description = "";
  int index = 0;
  String hotelName = "";
  double category = 0.0;
  String hotelContent = "";
  bool descTextShowFlag = false;
  var logoUrl = "default";
  var currentImageIndex = 0;
  late AnimationController _controller;
  var scale = 1.0;

  void initState() {
    super.initState();
    appUtility = AppUtility();
    description = widget.description;
    expansionList = widget.expansionList;
    timeDetails = appUtility.getDateDiff(
            GlobalState.checkInDate, GlobalState.checkOutDate) +
        "\n" +
        " " +
        GlobalState.personDetails;
    product = widget.product;
    product.hotel!.hotelAttributes!.hotelAttributes!
        .forEach((e) => amenitiesList.add(e.label!));

    product.hotel!.hotelAttributes!.hotelAttributes!
        .forEach((e) => {amenities.add(appUtility.getAmenities(e.label!))});

    if (amenities.length < 5) {
      amenities = amenities;
    } else {
      amenities = amenities.take(5).toList();
    }
    product.hotelContent!.logo?.sizes!.forEach((element) {
      logoUrl = element!.url!;
    });

    product.hotel!.ratings?.forEach((e) => e.rating!.forEach((rating) {
          if (rating.name == "averageRating") {
            avgRating = rating.value;
          }
        }));
    location = (product.hotel!.location!.country.name)! +
        " - " +
        (product.hotel!.location!.city!.name)!;
    print(GlobalState.promoCode);
    hotelName = product.hotel!.name ?? "";
    hotelContent = product.hotelContent!.distanceToAirport.toString();
    category = double.parse(product.hotel!.category.toString());
    saveHotelDetailsToFirebase();
    _controller = AnimationController(
        upperBound: 0.1,
        lowerBound: 0.1,
        duration: const Duration(milliseconds: 1),
        vsync: this);
    _controller.repeat(reverse: true);
  }

  saveHotelDetailsToFirebase() async {
    GetRoomOverviewArguments args = GetRoomOverviewArguments(
        hotelContentId: {"giataId": product.hotel!.giataId.toString()});
    QueryResult queryResult = await client.query(
      QueryOptions(
          document: GET_ROOM_OVERVIEW_QUERY_DOCUMENT, variables: args.toJson()),
    );
    CollectionReference hotelDet =
        FirebaseFirestore.instance.collection('hotels');
    HashMap<String, dynamic> setDet = HashMap();
    setDet.putIfAbsent("hotel", () => product.toJson());
    setDet.putIfAbsent("rooms", () => queryResult.data);
    await hotelDet.doc(product.hotelContent!.crsCode).set(product.toJson());
    var roomOverview = GetRoomOverview$Query.fromJson(
        queryResult.data as Map<String, dynamic>);
    roomOverview.roomOverview!.rooms!.forEach((element) async {
      await hotelDet
          .doc(product.hotelContent!.crsCode)
          .collection("rooms")
          .doc(element!.providerId)
          .set(element.toJson());
    });
  }

  @override
  dispose() {
    _controller.dispose(); // you need thissuper.dispose();
    super.dispose();
  }

  Future<bool> _willPopCallback() async {
    Navigator.of(context, rootNavigator: true).pop(context);
    // await showDialog or Show add banners or whatever
    // then
    return true; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);
    final double height = MediaQuery.of(context).size.height * 0.08;
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var topSpace = overAllHeight * 0.04;
    var backTopSpace = 0.0;
    var buttonHeight =
        overAllHeight * (AppUtility().isTablet(context) ? 0.075 : 0.055);
    var topHeight = overAllHeight * 0.025;
    var leftPadding = overAllWidth * 0.033;
    var backImageheight = overAllHeight * 0.45;
    var viewStartHeight = overAllHeight * 0.36;
    var toppadding = overAllHeight * 0.015;
    var contentLeftPadding = MediaQuery.of(context).size.width * 0.025;
    var titileLeftPadding = MediaQuery.of(context).size.width * 0.015;
    var bottomPadding = MediaQuery.of(context).size.height * 0.020;
    var nameTopPadding = MediaQuery.of(context).size.height * 0.015;
    // var amentitiesRightPadding = MediaQuery.of(context).size.width * 0.05;
    var amentitiesRightPadding = 15.0;
    var selectToppadding = overAllHeight * 0.02;
    var logoTopPadding = overAllHeight * 0.29;
    var indicatorSize = AppUtility().indicaorSize(context);
    var currentIndicatorSize = AppUtility().currentIndicatorSize(context);
    if (buttonHeight < 40) {
      buttonHeight = 45;
    }

    return Scaffold(
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
                      onHorizontalDragStart: (details) {
                        print("Drag start called");
                      },
                      onVerticalDragUpdate: (dragDetails) {
                        setState(() {
                          scale = 1.2;
                          //     resetScale();
                        });
                      },
                      onVerticalDragEnd: (endDetails) {
                        print("Drag end ene ee");
                        setState(() {
                          scale = 1.2;
                          resetScale();
                        });
                      },
                      onTap: () {
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
                      child: ClipRRect(
                        child: Carousel(
                          images: product.hotelContent!.images!
                              .map(
                                (e) =>
                                    AppUtility().loadNetworkImage(e!.default2x!.url.toString())

                              )
                              .toList(),
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
                                        amentitiesRightPadding,
                                        buttonHeight,
                                        toppadding,
                                        selectToppadding,
                                        bottomPadding),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                            0.35 -
                                        contentLeftPadding,
                                    child: checkInCheckOutWidget(
                                        toppadding, leftPadding, topHeight),
                                  )
                                ],
                              ),
                              if(expansionList.isNotEmpty)
                                showExpansionWidget(toppadding, leftPadding)
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
                                  amentitiesRightPadding,
                                  buttonHeight,
                                  toppadding,
                                  selectToppadding,
                                  bottomPadding),
                              checkInCheckOutWidget(
                                  toppadding, leftPadding, topHeight),
                              if(expansionList.isEmpty)
                                Container(margin: EdgeInsets.only(top:30),),
                              if(expansionList.isNotEmpty)
                                showExpansionWidget(toppadding, leftPadding)
                            ],
                          )),
              ],
            ),
          )),
    );

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
      amentitiesRightPadding,
      buttonHeight,
      toppadding,
      selectToppadding,
      bottomPadding) {
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
                              // widget.onBack('5');
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
                                style: viewReviewStyle)),
                      )
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
          Stack(
            children: <Widget>[
              Container(
                child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      //   alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            Container(
                              padding:
                                  EdgeInsets.only(left: contentLeftPadding),
                              child: Image.asset(
                                "assets/images/airport.png",
                                width: textFieldIconSize17,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width *
                                      0.010),
                              child: Text(
                                Strings.distanceToAirport +
                                    " - " +
                                    hotelContent +
                                    " Km",
                                style: distanceStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: AppUtility().isTablet(context)
                              ? 0
                              : contentLeftPadding,
                          right: AppUtility().isTablet(context)
                              ? 0
                              : contentLeftPadding,
                        ),
                        alignment: Alignment.center,
                        height: 45,
                        child: VerticalDivider(
                          color: Uicolors.desText,
                          thickness: 0.5,
                          indent: 10,
                          endIndent: 10,
                          width: 20,
                        ),
                      ),
                    ),
                    Align(
                      // alignment: Alignment.topRight,
                      child: GestureDetector(
                          onTap: () {
                            pushNewScreen(
                              context,
                              screen: SearchMap([product], "surroundings"),
                              withNavBar: false,
                              // OPTIONAL VALUE. True by default.
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    left: AppUtility().isTablet(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.001
                                        : MediaQuery.of(context).size.width *
                                            0.015,
                                    right: MediaQuery.of(context).size.width *
                                        0.020),
                                child: Image.asset(
                                  "assets/images/map.png",
                                  width: textFieldIconSize17,
                                ),
                              ),
                              Container(
                                child: Text(
                                  Strings.mapView,
                                  style: distanceStyle,
                                ),
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              )
            ],
          ),
          Container(
              margin: EdgeInsets.only(
                  right: contentLeftPadding, left: contentLeftPadding),
              child: Divider(
                color: Uicolors.desText,
                thickness: 0.5,
              )),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
                left: contentLeftPadding,
                top: 10,
                right: contentLeftPadding,
                bottom: description.length > 100
                    ? MediaQuery.of(context).size.height * 0.005
                    : 0),
            child: Text(
              description.replaceAll("\n", " "),
              style: descTextStyle,
              maxLines: descTextShowFlag ? 100 : 2,
            ),
          ),
          if ((description.length) < 100)
            Container(
                padding: EdgeInsets.only(
              left: contentLeftPadding,
              bottom: (MediaQuery.of(context).size.height * 0.01),
            )),
          if ((description.length) > 100)
            Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                    left: contentLeftPadding,
                    bottom: (description.length) > 100
                        ? MediaQuery.of(context).size.height * 0.01
                        : 0),
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
          Container(
            margin: EdgeInsets.only(left: 15.0, top: 5, bottom: 5),
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
                            padding:
                                EdgeInsets.only(right: amentitiesRightPadding),
                            child: Image.asset(
                              amenities[index],
                              width: iconSize,
                              height: iconSize,
                              color: Uicolors.desText,
                            ));
                      },
                    )),
                if (amenitiesList.length > 0)
                  Container(
                      alignment: Alignment.centerRight,
                      padding:
                          EdgeInsets.only(right: contentLeftPadding, top: 0),
                      child: GestureDetector(
                        onTap: () {
                          // _showAmenities(context);
                          pushNewScreen(
                            context,
                            screen: AmenitiesList(gridItems: amenitiesList),
                            withNavBar: false,
                            // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                          // showDialog(
                          //     context: context,
                          //     builder: (BuildContext context) {
                          //       return CustomDialogBox(
                          //           gridItems: amenitiesList,
                          //           name:
                          //               product.hotel!.name ?? "");
                          //     });
                        },
                        child: Text(Strings.showAllAmenities,
                            style: showAllAmenitiesStyle),
                      )),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(
                    left: contentLeftPadding,
                    top: selectToppadding,
                    bottom: bottomPadding),
                child: MaterialButton(
                  color: Uicolors.buttonbg,
                  minWidth: AppUtility().isTablet(context)
                      ? MediaQuery.of(context).size.width * 0.35
                      : MediaQuery.of(context).size.width * 0.45,
                  height: AppUtility().isTablet(context)
                      ? buttonHeight / 1.3
                      : buttonHeight,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(buttonHeight / 2),
                    side: BorderSide(
                      color: Uicolors.buttonbg,
                    ),
                  ),
                  child: Text(Strings.selectARoom, style: buttonStyle),
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final User? user = auth.currentUser;
                    if(user == null && prefs.getString("loginType")!="guest") {
                      try{
                      EasyLoading.show();
                     HashMap<String,dynamic> memberResult = await CommonUtils().memberShipPrice(product.hotel!.giataId.toString());
                      if(memberResult["memberResponseCode"]==Strings.success){
                    pushNewScreen(
                          context,
                          screen: BookingStart(GlobalState.selectedRoomList[0].roomDetail,memberResult["discountPrice"],memberResult["originalPrice"]),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation: PageTransitionAnimation
                              .cupertino,
                        ).then((value){
                          print("returnback $value");
                          if(prefs.getString("loginType")!="back"){
                            widget.onBack("1");
                          }
                        });
                      }else{
                         AppUtility().showToastView(memberResult["memberResponseMessage"], context);
                       }
                      }catch(e){
                        AppUtility().showToastView(Strings.errorMessage, context);
                      }
                      EasyLoading.dismiss();
                    }else{
                      widget.onBack("1");
                    }
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: toppadding, bottom: toppadding),
                child: RatingBar(
                  ignoreGestures: true,
                  initialRating: category,
                  direction: Axis.horizontal,
                  //allowHalfRating: true,
                  itemCount: 5,
                  itemSize: backIconSize,
                  ratingWidget: RatingWidget(
                    full: _image('assets/images/star.png'),
                    half: _image('assets/images/halfround.png'),
                    empty: _image('assets/images/empty.png'),
                  ),
                  itemPadding: EdgeInsets.symmetric(
                      horizontal: (AppUtility().isTablet(context) ? 2.0 : 1.0)),
                  onRatingUpdate: (rating) {
                    setState(() {
                      // here update the rating
                    });
                  },
                  updateOnDrag: true,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget checkInCheckOutWidget(toppadding, leftPadding, topHeight) {
    return Column(
      children: [
        Container(
          margin: !AppUtility().isTablet(context)
              ? EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.033,
                  right: MediaQuery.of(context).size.width * 0.033,
                  top: toppadding)
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
        ),
        AppUtility().isTablet(context)
            ? InkWell(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: MediaQuery.of(context).size.height * 0.12,
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01),
                  child: InkWell(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true)
                            .pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        new HomeBottomBarScreen(
                                            2) /*BottomBar()*/),
                                (Route<dynamic> route) => false);
                      },
                      child: OptimizedCacheImage(
                        imageUrl: destinationImageUrl,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: MediaQuery.of(context).size.height * 0.12,
                      )),
                ))
            : Container()
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
                    top: MediaQuery.of(context).size.height * 0.01),
                alignment: Alignment.centerLeft,
                // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                child: Text(
                  'After 2.00 PM',
                  style: timeStyle,
                ))
          ],
        ));
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
                    top: MediaQuery.of(context).size.height * 0.01),
                alignment: Alignment.centerLeft,
                // padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.21),
                child: Text(
                  'Before 12.00 PM',
                  style: timeStyle,
                ))
          ],
        ));
  }

  showExpansionWidget(toppadding, leftPadding) {
    if (expansionList.length > 0)
      return Container(
        margin: EdgeInsets.only(
            bottom: toppadding, left: leftPadding, right: leftPadding),
        child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            // scrollDirection: Axis.vertical,
            itemCount: expansionList.length,
            itemBuilder: (context, index) => Expansion(
                expansionList[index]["image"],
                expansionList[index]["name"],
                expansionList[index]["desc"])),
      );
  }
}
