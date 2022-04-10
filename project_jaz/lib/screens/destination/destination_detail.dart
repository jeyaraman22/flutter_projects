import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';
import 'package:jaz_app/helper/graphqlconnectivity/constants.dart';
import 'package:jaz_app/helper/search_service.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/models/roommodel.dart';
import 'package:jaz_app/screens/product_overview/galleryimageview.dart';
import 'package:jaz_app/screens/product_overview/selectroom.dart';
import 'package:jaz_app/screens/search/confirmsearch.dart';
import 'package:jaz_app/screens/search/daterangepage.dart';
import 'package:jaz_app/screens/search/searchdetailpage.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/carousel.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/uiconstants.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:toast/toast.dart';
import '../../graphql_provider.dart';
import 'destination_detail_list.dart';
import 'package:jaz_app/utils/http_client.dart';

class DestinationDetails extends StatefulWidget {
  final String redirectPath;

  DestinationDetails(this.redirectPath);

  _DestinationDetailsState createState() => _DestinationDetailsState();
}

class _DestinationDetailsState extends State<DestinationDetails> {
  HttpClient httpClient = HttpClient();
  var destinationName = "";
  var destDescription = "";
  var holidayStr = "";
  var holidayDescStr = "";
  List<String> holidayImage = [];
  List<dynamic> holidayList = [];
  List<String> backgroundImage = [];
  List<String> galleryImages =[];
  var numberofHotels = "0";
  var hotelText = " hotels";

  DateTime startDate = DateTime.now().add(const Duration(days: 3));
  DateTime endDate = DateTime.now().add(const Duration(days: 6));
  String destinationValue = "";
  String pickedDate = "";
  String _personDetails = "2 Person - 1 Room";
  AppUtility appUtility = AppUtility();
  SearchService searchService = SearchService();

  List<TravellerFilterInput> roomRefType = [
    TravellerFilterInput(age: 25, refId: 1),
    TravellerFilterInput(age: 25, refId: 1)
  ];
  List<TravellersRoomInput> roomRef = [
    TravellersRoomInput(refIds: [1,2])
  ];
  Room room = Room(childList: [], roomNumber: 1, adultList: [25, 25],roomDetail: HashMap());
  List<Room> roomList = [];
  TextEditingController _promocode = TextEditingController();
  int currentImageIndex = 0;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    appUtility = AppUtility();
    pickedDate = appUtility.getDateDiff(startDate, endDate);

    if (GlobalState.selectedRoomList != null) {
      roomList = GlobalState.selectedRoomList;
    }
    if (GlobalState.selectedRoomList == null || roomList.length == 0) {
      roomList.add(room);
      GlobalState.selectedRoomList = roomList;
    }
    //if (GlobalState.selectedRoomList == null) {
    // if (roomList.length == 0) {
    //   roomList.add(room);
    // }
    // GlobalState.selectedRoomList = roomList;
    //}
    getDestinationDetail();
  }

  getDestinationDetail() async {
    try{
    HashMap<String, dynamic> params = HashMap();
    List<dynamic> destinationList = [];
    String splitString = widget.redirectPath;
    var list = splitString.split("?nodes=");

    params.putIfAbsent("renderPage", () => list[0].toString());
    if (list.length > 1) {
      destinationValue = list[1].toString();
    }
    params.putIfAbsent("_locale", () => "en-gb");
    var response;
    EasyLoading.show();
    // BuildContext? dialogContext;
    // AppUtility().showProgressDialog(context,type:null,dismissDialog:(value){
    //   dialogContext = value;
    // });
    response = await httpClient.getRenderData(params, "/api/renders", null);
    if (response.statusCode == 200 && json.decode(response.body) != null) {
      // await new Future.delayed(const Duration(milliseconds: 500));
      // AppUtility().dismissDialog(dialogContext!);
      var result = json.decode(response.body);
      if (this.mounted) {
        setState(() {
          result["content"]["main"]["children"].forEach((destination) {
            if (destination["children"].length > 0 &&
                destination["children"][0]["module"]["result"]["product"] !=
                    null) {
              // numberofHotels = destination["children"][0]["module"]["result"]
              //         ["product"]["hotels"]
              //     .length
              //     .toString();
              hotelText = int.parse(numberofHotels) > 1 ? " hotels" : " hotel";
            }

            if (destination["module"]["result"]["headlines"] != null) {
              destinationName = destination["module"]["result"]["headlines"][0]
              ["headline"]
                  .toString();
            }

            if (destination["module"]["result"]["subheadline"] != null) {
              destDescription =
                  destination["module"]["result"]["subheadline"].toString();

            }
            if (destination["module"]["result"]["headlines"] == null &&
                destination["module"]["result"]["images"] != null) {
              setState(() {
                holidayList.add(destination);
              });
            }
          });
          holidayStr =
              holidayList[0]["module"]["result"]["headline"].toString();
          holidayDescStr = appUtility.parseHtmlString(
              holidayList[0]["module"]["result"]["text"].toString());
          backgroundImage = AppUtility().getImages(holidayList[0]);
          galleryImages = AppUtility().getGalleyViewImages(holidayList[0]);
      //    print(galleryImages);
        });
      }
      if (holidayList.length > 0) {
        if (this.mounted) {
          setState(() {
            // holidayImage.forEach((element) {
            //   if (element != null && element.toString() != "null") {
            //     backgroundImage.add(element.toString());
            // //    backgroundImage.add("https://storage.googleapis.com/jaz-prod/cms/Egypt/Hurghada/Jaz%20Aquamarine/shutterstock_81049690.jpg");
            //   }
            // });
            holidayList.removeAt(0);
          });
        }
      }
    } else {
      // EasyLoading.dismiss();
      // await new Future.delayed(const Duration(milliseconds: 500));
      // AppUtility().dismissDialog(dialogContext!);
    }
    }on SocketException catch (_) {
      AppUtility().showToastView(Strings.noInternet, context);
    }catch(e){
      AppUtility().showToastView(Strings.errorMessage, context);
    }
    EasyLoading.dismiss();

  }

  @override
  Widget build(BuildContext context) {
    var indicatorSize = AppUtility().indicaorSize(context);
    var currentIndicatorSize = AppUtility().currentIndicatorSize(context);

    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var backButtonPadding = overAllWidth * 0.005;
    var searchTopPadding = overAllHeight * 0.005;
    var imageHeight = overAllHeight * 0.48;
    var imageWidth = overAllWidth * 1;
    var travelTopTextPadding = overAllHeight * 0.39;
    var titleTopPadding = overAllHeight * 0.01;
    var imageAlignPadding = overAllHeight * 0.015;
    var commonHeightPadding = overAllHeight * 0.02;
    var commonWidthPadding = overAllWidth * 0.02;
    var commonContainerWidthPadding = overAllWidth * 0.035;
    var imageAndNameHeightPadding = overAllHeight * 0.02;
    var imageAndNameWidthPadding = overAllWidth * 0.03;
    var destinationNameTopPadding = overAllHeight * 0.035;
    var contentHeightPadding =
        overAllHeight * (AppUtility().isTablet(context) ? 0.055 : 0.055);
    var textFromFieldAdjustLeft = overAllWidth * 0.06;
    var contentWidthPadding = overAllWidth * 1;
    var searchButtonWidth = overAllWidth * 0.50;

    if (contentHeightPadding < 40) {
      contentHeightPadding = 45;
    }

    return Scaffold(
        backgroundColor: Uicolors.backgroundColor,
        appBar: AppBar(
          toolbarHeight: AppUtility().isTablet(context)
              ? 80
              : AppBar().preferredSize.height,
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
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * 0.005, 0, 0, 0),
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
                        padding: EdgeInsets.only(
                          left: 0,
                        ),
                        child:
                        Text(Strings.backToDestination, style: backStyle),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Scrollbar(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Stack(
              children: <Widget>[
                backgroundImage != null && backgroundImage.length > 0
                    ? Container(
                  height: imageHeight,
                  width: imageWidth,
                  child: GestureDetector(
                    onTap: () {
                      pushNewScreen(
                        context,
                        screen: GalleryImageView(
                            backgroundImage, currentImageIndex),
                        withNavBar:
                        false, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                        PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Carousel(
                        images: backgroundImage
                            .map(
                              (e) =>  AppUtility().loadNetworkImage(e.toString())
                        )
                            .toList(),
                        indicatorSize: backgroundImage.length > 0
                            ? Size.square(indicatorSize)
                            : Size.square(0.0),
                        indicatorActiveSize: backgroundImage.length > 0
                            ? Size(currentIndicatorSize, indicatorSize)
                            : Size(0.0, 0.0),
                        indicatorColor: Colors.grey,
                        indicatorActiveColor: Colors.white,
                        animationCurve: Curves.easeIn,
                        contentMode: BoxFit.cover,
                        //     contentMode: BoxFit.fitWidth,
                        autoPlay: false,
                        indicatorBackgroundColor: Colors.transparent,
                        bottomPadding: backgroundImage.length > 0
                            ? imageHeight / 4
                            : 0,
                        onImageChange: (index) {
                          currentImageIndex = index;
                        }),
                  ),
                )
                    : Container(),
                new Column(
                  children: [
                    if (destinationName != "")
                      Container(
                        // height: MediaQuery.of(context).size.height/2,
                        //  height: 400,
                        margin: EdgeInsets.only(
                            top: travelTopTextPadding,
                            left: commonContainerWidthPadding,
                            right: commonContainerWidthPadding,
                            bottom: commonHeightPadding),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: boxShadow,
                          // border: Border.all(color: Colors.white, width: 1),
                          // borderRadius:
                          //     BorderRadius.circular(containerBorderRadius),
                          shape: BoxShape.rectangle,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(
                                  left: imageAndNameWidthPadding,
                                  top: destinationNameTopPadding),
                              child:
                              Text(destinationName, style: hotelNameStyle),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: imageAndNameWidthPadding,
                                  right: imageAndNameWidthPadding,
                                  top: imageAndNameHeightPadding),
                              child: Text(destDescription,
                                  textAlign: TextAlign.start,
                                  style: descTextStyle),
                            ),
                            GestureDetector(
                                onTap: () {
                                  calenderPageRedirect(context);
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                      top: commonHeightPadding,
                                      left: imageAndNameWidthPadding,
                                      right: imageAndNameWidthPadding),
                                  width: contentWidthPadding,
                                  height: contentHeightPadding,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          fieldBorderRadius),
                                      color: Uicolors.desSearchBg),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: imageAndNameWidthPadding / 1),
                                      ),
                                      Image.asset(
                                        "assets/images/calendar-icon.png",
                                        width: textFieldIconSize,
                                        height: textFieldIconSize,
                                        color: Uicolors.buttonbg,
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.only(
                                            left:
                                            imageAndNameWidthPadding / 0.8),
                                        child: Text(
                                            pickedDate != ""
                                                ? pickedDate
                                                : "Select Dates",
                                            style: fieldTextStyle),
                                      )
                                    ],
                                  ),
                                )),
                            GestureDetector(
                                onTap: () {
                                  goToRoomScreen(context);
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                      top: commonHeightPadding,
                                      left: imageAndNameWidthPadding,
                                      right: imageAndNameWidthPadding),
                                  width: contentWidthPadding,
                                  height: contentHeightPadding,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          fieldBorderRadius),
                                      color: Uicolors.desSearchBg),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: imageAndNameWidthPadding / 1),
                                      ),
                                      Image.asset(
                                        "assets/images/persons-icon.png",
                                        width: textFieldIconSize,
                                        height: textFieldIconSize,
                                        color: Uicolors.buttonbg,
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            left:
                                            imageAndNameWidthPadding / 0.8),
                                        child: Text(
                                            _personDetails != ""
                                                ? _personDetails
                                                : Strings.whoWillTravel,
                                            style: fieldTextStyle),
                                      )
                                    ],
                                  ),
                                )),
                            Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(
                                    top: commonHeightPadding,
                                    bottom: commonHeightPadding,
                                    left: imageAndNameWidthPadding,
                                    right: imageAndNameWidthPadding),
                                width: contentWidthPadding,
                                height: contentHeightPadding,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        fieldBorderRadius),
                                    color: Uicolors.desSearchBg),
                                child: Row(
                                  //alignment: Alignment.centerLeft,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.fromLTRB(
                                          imageAndNameWidthPadding, 0, 0, 0),
                                      child: Image.asset(
                                        "assets/images/ticket.png",
                                        width: textFieldIconSize,
                                        height: textFieldIconSize,
                                        color: Uicolors.buttonbg,
                                      ),
                                    ),
                                    Container(
                                        width: contentWidthPadding * 0.7,
                                        padding: EdgeInsets.fromLTRB(
                                            imageAndNameWidthPadding, 0, 0, 0),
                                        child: TextFormField(
                                          controller: _promocode,
                                          style: fieldTextStyle,
                                          textAlignVertical:
                                          TextAlignVertical.center,
                                          cursorColor: Uicolors
                                              .textFromFieldContentColors,
                                          decoration: InputDecoration(
                                            isCollapsed: true,
                                            hintStyle: fieldTextStyle,
                                            hintText: Strings.promocode,
                                            enabledBorder: InputBorder.none,
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,

                                            // prefixIcon: IconButton(
                                            //   onPressed: () =>
                                            //       _promocode.clear(),
                                            //   //  icon: Icon(Icons.confirmation_num_outlined),
                                            //   icon: Image.asset(
                                            //     "assets/images/ticket.png",
                                            //     width: textFieldIconSize,
                                            //     height: textFieldIconSize,
                                            //     color: Uicolors.buttonbg,
                                            //   ),
                                            //),
                                          ),
                                        ))
                                  ],
                                )),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                  top: commonHeightPadding,
                                  bottom: commonHeightPadding),
                              child: Container(
                                  height: contentHeightPadding,
                                  width: searchButtonWidth,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          contentWidthPadding / 2),
                                      color: Uicolors.buttonbg),
                                  child: MaterialButton(
                                    //child: ListView(
                                    //  physics: NeverScrollableScrollPhysics(),
                                    //children: [
                                    child: Center(
                                      child: Padding(
                                        child: Text(
                                          'SEARCH',
                                          style: buttonStyle,
                                        ),
                                        padding: EdgeInsets.only(
                                            top: contentHeightPadding / 10),
                                      ),
                                    ),
                                    // Center(
                                    //   child: Padding(
                                    //     child: Text(
                                    //       '( ' +
                                    //           numberofHotels +
                                    //           hotelText +
                                    //           ' )',
                                    //       style: numberOfNightStyle,
                                    //     ),
                                    //     padding: EdgeInsets.only(
                                    //         bottom:
                                    //             contentHeightPadding / 4),
                                    //   ),
                                    // )
                                    //  ],
                                    // ),
                                    onPressed: () {
                                      searchClicked();
                                      // pushNewScreen(
                                      //   context,
                                      //   screen: SelectRoom(),
                                      //   withNavBar: true, // OPTIONAL VALUE. True by default.
                                      //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                      // );
                                    },
                                  )),
                            )
                          ],
                        ),
                      ),
                    if (destinationName != "")
                      Container(
                        // height: MediaQuery.of(context).size.height/2,
                        //  height: 400,
                        margin: EdgeInsets.only(
                          // top: titleTopPadding,
                            left: commonContainerWidthPadding,
                            right: commonContainerWidthPadding,
                            bottom: titleTopPadding),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: boxShadow,
                          // border: Border.all(color: Colors.white, width: 1),
                          // borderRadius:
                          //     BorderRadius.circular(containerBorderRadius),
                          shape: BoxShape.rectangle,
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(
                                  left: imageAndNameWidthPadding,
                                  top: imageAndNameHeightPadding),
                              child:
                              Text(holidayStr, style: destinationNameStyle),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: imageAndNameWidthPadding,
                                  right: imageAndNameWidthPadding,
                                  top: imageAndNameHeightPadding,
                                  bottom: imageAndNameHeightPadding),
                              child: Text(holidayDescStr, style: descTextStyle),
                            ),
                          ],
                        ),
                      ),
                    if (destinationName != "")
                      Container(
                        margin: EdgeInsets.only(
                            top: titleTopPadding,
                            left: commonContainerWidthPadding,
                            right: commonContainerWidthPadding),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          // scrollDirection: Axis.vertical,
                          itemCount: holidayList.length,
                          itemBuilder: (context, index) {
                            List<dynamic> listImages = [];
                               listImages = AppUtility().getImages(holidayList[index]);

                            return DestinationDetailList(
                                holidayList[index]["module"]["result"]
                                ["headline"]
                                    .toString(),
                                holidayList[index]["module"]["result"]["text"]
                                    .toString(),
                                listImages);
                          },
                        ),
                      )
                  ],
                )
              ],
            ),
          ),
        ));
  }

  void goToRoomScreen(BuildContext context) async {
    String dataFromSecondPage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ConfirmSearch(roomList, roomCallBack: (selectedRoomLists) {
                roomList = selectedRoomLists;
                GlobalState.selectedRoomList = selectedRoomLists;
                setState(() {
                  roomList = selectedRoomLists;
                  getRoomRefDetails();
                });
              }),
        ));
    setState(() {
      if (GlobalState.selectedRoomRefType != null) {
        roomRefType = GlobalState.selectedRoomRefType;
      }
      if (GlobalState.selectedRoomRef != null) {
        roomRef = GlobalState.selectedRoomRef;
      }
      if (GlobalState.personDetails != null) {
        _personDetails = GlobalState.personDetails;
      }
      if (GlobalState.selectedRoomList != null) {
      }
    });
  }

  searchClicked() async {

    String selectedPromoCode="";
    final User? user = auth.currentUser;
    HashMap<String,ProductsQuery$Query$Products$PackageProducts> membershipData = HashMap();

    if(GlobalState.promoCode==membershipCode && GlobalState.offerStartStr == Strings.offers){
      GlobalState.promoCode ="";
      _promocode.text="";
    } else {
      if (GlobalState.promoCode != null) {
        GlobalState.promoCode = _promocode.text;
      } else {
        GlobalState.promoCode = "";
      }
    }
    GlobalState.checkInDate = startDate;
    GlobalState.checkOutDate = endDate;
    GlobalState.personDetails = _personDetails;
    GlobalState.destinationValue = destinationValue;
    GlobalState.selectedRoomRef = roomRef;
    GlobalState.selectedRoomRefType = roomRefType;
    EasyLoading.show();

    if(GlobalState.promoCode != null&&GlobalState.promoCode != ""){
      selectedPromoCode = GlobalState.promoCode;
    }else if(user != null) {
      selectedPromoCode = membershipCode;
    }
    GlobalState.promoCode = selectedPromoCode;
    ProductsQueryArguments args = searchService.getProductQueryArguments(
        startDate,
        endDate,
        destinationValue,
        "",
        roomRef,
        roomRefType,
        "");
    ProductsQueryArguments memberArgs = searchService.getProductQueryArguments(
        startDate,
        endDate,
        destinationValue,
        "",
        roomRef,
        roomRefType,
        selectedPromoCode);
    memberArgs.resultsPerPage = 1000;
    memberArgs.showingResultsFrom = 0;
    var errorMessage = "";
    try {
      List<Future<dynamic>> requestQuery = [
        client.query(
          QueryOptions(
              document: PRODUCTS_QUERY_QUERY_DOCUMENT,
              variables: args.toJson()),
        ),
      ];
      if(selectedPromoCode!=""){
        print("promocode $selectedPromoCode");
        requestQuery.add(client.query(
          QueryOptions(
              document: PRODUCTS_QUERY_QUERY_DOCUMENT,
              variables: memberArgs.toJson()),
        ));
      }
    var allResponse = await Future.wait(requestQuery);
      QueryResult queryResult = allResponse[0];
      final exception = queryResult.hasException.hashCode;
      if (queryResult.hasException) {
        if (exception is NetworkException) {
          errorMessage = Strings.noInternet;
        } else {
          errorMessage = Strings.errorMessage;
        }
        appUtility.showToastView(errorMessage, context);
      } else {
        if(selectedPromoCode!="") {
          final memberException = queryResult.hasException.hashCode;
          QueryResult memberResult = allResponse[requestQuery.length - 1];
          if (memberResult.hasException) {} else {
            ProductsQuery$Query membershipProduct = ProductsQuery$Query
                .fromJson(memberResult.data ?? {});
            membershipProduct.products!.packageProducts!.forEach((element) {
              membershipData.putIfAbsent(
                  element.hotel!.giataId.toString(), () => element);
            });
          }
        }
        pushNewScreen(
          context,
          //  [TravellersRoomInput(refIds:roomRefType.map((e) => e.refId!).toList())],
          screen: SearchDetail(
              context,
              destinationValue,
              "",
              startDate,
              endDate,
              roomRefType,
              roomRef,
              "",
              _personDetails,
              ProductsQuery$Query.fromJson(queryResult.data ?? {}),
              membershipData),
          withNavBar: false, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      }
    } on SocketException catch (_) {
      AppUtility().showToastView(Strings.noInternet, context);
    }catch (e) {
      AppUtility().showToastView(Strings.errorMessage, context);
    }
    EasyLoading.dismiss();
  }

  getRoomRefDetails() {
    int totalPerson = 0;
    roomList.forEach((element) {
      totalPerson += element.adultList.length + element.childList.length;
    });
    var personString = "", roomString = "";
    if (totalPerson > 1) {
      personString = Strings.persons;
    } else {
      personString = Strings.person;
    }
    if (roomList.length > 1) {
      roomString = Strings.roomsStr;
    } else {
      roomString = Strings.roomStr;
    }
    int refId = 0;
    roomRefType = [];
    roomRef = [];
    for (int i = 0; i < roomList.length; i++) {
      List<int> refs = [];
      roomList[i].adultList.forEach((adult) {
        roomRefType.add(TravellerFilterInput(age: adult, refId: ++refId));
        refs.add(refId);
      });
      roomList[i].childList.forEach((child) {
        roomRefType
            .add(TravellerFilterInput(age: int.parse(child), refId: ++refId));
        refs.add(refId);
      });
      TravellersRoomInput selectedRoomRef = TravellersRoomInput(refIds: refs);
      roomRef.add(selectedRoomRef);
    }
    this.setState(() {
      GlobalState.selectedRoomRef = roomRef;
      GlobalState.selectedRoomRefType = roomRefType;
      _personDetails = totalPerson.toString() +
          " " +
          personString +
          " - " +
          roomList.length.toString() +
          " " +
          roomString;
      GlobalState.personDetails = _personDetails;
    });
  }

// void _printLatestValue() {
//   double contentHeight = MediaQuery.of(context).size.height > 700 ? MediaQuery.of(context).size.height * 0.35 : MediaQuery.of(context).size.height * 0.3;
//    if(typeAheadController.text=="") {
//      scrollController.jumpTo(200);
//    }
// }

  void calenderPageRedirect(BuildContext context) async {
    pushNewScreen(
      context,
      screen: DateRangePage(
        startDate,
        endDate,
        selectedDateRange: (start, end) {
          setState(() {
            startDate = start;
            endDate = end;
            pickedDate = appUtility.getDateDiff(startDate, endDate);
          });
        },
      ),
      withNavBar: false, // OPTIONAL VALUE. True by default.
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }
}
