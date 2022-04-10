import 'dart:collection';
import 'dart:core';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:graphql/client.dart';
import 'package:jaz_app/bloc/get_offer_list_bloc.dart';
import 'package:jaz_app/helper/graphqlconnectivity/constants.dart';
import 'package:jaz_app/helper/search_service.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/models/roommodel.dart';
import 'package:jaz_app/screens/booking/booking_start.dart';
import 'package:jaz_app/screens/product_overview/selectroom_item.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/commonutils.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../graphql_provider.dart';

class SelectRoom extends StatefulWidget {
  final ProductsQuery$Query$Products$PackageProducts product;
  final Function(String) onBack;
  SelectRoom(this.product,{required this.onBack});
  _SelectRoomState createState() => _SelectRoomState();
}

class _SelectRoomState extends State<SelectRoom> {
  List images = [""];
  late GetOfferListBloc bloc;
  // expansion title list
  List<String> expansionList = [
    "Pricing & Conditions",
    "Terms & Policies",
  ];
  HttpClient httpClient = HttpClient();
  AppUtility appUtility = AppUtility();
  var timeDetails;
  int currentSelectedIndex = -1;
  var currency;
  var promocode = "";
  GetOfferList$Query getOfferListQuery = GetOfferList$Query();
  int roomIndex = 0;
  String adults ="0";
  String children ="0";
  List<TravellersRoomInput> roomRef =[];
  List<TravellerFilterInput> roomRefType=[];
  List<Room> roomDetails =[];

  void initState() {
    super.initState();
    redirectLogin();
    if (GlobalState.promoCode != "" && GlobalState.promoCode != null) {
      promocode = GlobalState.promoCode;
    }
    timeDetails = appUtility.getDateDiff(
        GlobalState.checkInDate, GlobalState.checkOutDate) +
        "\n" +
        " " +
        GlobalState.personDetails;
    appUtility = AppUtility();
    roomDetails = GlobalState.selectedRoomList;
    currency = GlobalState.selectedCurrency != null
        ? GlobalState.selectedCurrency
        : Strings.usd;

  }
  redirectLogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;
  if(user == null && prefs.getString("loginType")!="guest") {
    try {
      EasyLoading.show();
      HashMap<String, dynamic> memberResult = await CommonUtils()
          .memberShipPrice(widget.product.hotel!.giataId.toString());
      if (memberResult["memberResponseCode"] == Strings.success) {
        pushNewScreen(
          context,
          screen: BookingStart(GlobalState.selectedRoomList[0].roomDetail,
              memberResult["discountPrice"],memberResult["originalPrice"]),
          withNavBar: false, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation
              .cupertino,
        ).then((value) {
          if (prefs.getString("loginType") == "back") {
            widget.onBack("0");
          }
        });
      } else {
        AppUtility().showToastView(
            memberResult["memberResponseMessage"], context);
      }
    } catch (e) {
      AppUtility().showToastView(Strings.errorMessage, context);
    }
    EasyLoading.dismiss();
  }
}


  getRoomRefDetails(){
      List<int> refs = [];
      int refId = 0;
       roomRef =[];
       roomRefType=[];
      roomDetails[roomIndex].adultList.forEach((adult) {
        roomRefType.add(TravellerFilterInput(age: adult, refId: ++refId));
        refs.add(refId);
      });
      roomDetails[roomIndex].childList.forEach((child) {
        roomRefType
            .add(TravellerFilterInput(age: int.parse(child), refId: ++refId));
        refs.add(refId);
      });
      TravellersRoomInput selectedRoomRef = TravellersRoomInput(refIds: refs);
      roomRef.add(selectedRoomRef);
      adults = appUtility.getSingleRoomAdults(roomDetails[roomIndex]).toString();
      children = appUtility.getSingleRoomChildren(roomDetails[roomIndex]).toString();

  }

  Future<GetOfferList$Query> getOfferList() async {
    GetOfferList$Query getOfferListQuery1 = GetOfferList$Query();
    EasyLoading.show();
    getRoomRefDetails();
    GetOfferListArguments args = SearchService().getOfferListArguments(
        int.parse(widget.product.hotel!.giataId.toString()), currency, "",roomRefType,roomRef);
    GetOfferListArguments membershipArgs = SearchService()
        .getOfferListArguments(
        int.parse(widget.product.hotel!.giataId.toString()), currency, promocode,roomRefType,roomRef);
    try {
      List<Future<QueryResult>> requestQuery = [
        client.query(
          QueryOptions(
              document: GET_OFFER_LIST_QUERY_DOCUMENT,
              variables: args.toJson()),
        )
      ];
      if (promocode != null && promocode != "") {
        requestQuery.add(client.query(
          QueryOptions(
              document: GET_OFFER_LIST_QUERY_DOCUMENT,
              variables: membershipArgs.toJson()),
        ));
      }
      List allResponse = await Future.wait(requestQuery);
      getOfferListQuery1 = GetOfferList$Query.fromJson(
          allResponse[0].data ?? {});
      if (promocode != null && promocode != "") {
        var memberResult = GetOfferList$Query.fromJson(
            allResponse[1].data ?? {});
        // getOfferListQuery!.productOffers!.hotels!.addAll(memberResult.productOffers!.hotels!);
        memberResult.productOffers!.hotels!.forEach((element){
          element.offers.forEach((offer) {
            offer.rooms?.room?.forEach((room) {
              room.promoCode = promocode;
            });
          });
          getOfferListQuery1.productOffers!.hotels!.add(element);
        });
      }
    } on SocketException catch (_) {
      AppUtility().showToastView(Strings.noInternet, context);
    } catch (e) {
      AppUtility().showToastView(Strings.errorMessage, context);
    }
    EasyLoading.dismiss();
    return getOfferListQuery1;
  }


  @override
  void dispose() {
    // bloc.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    print("build method called");
    final double height = MediaQuery.of(context).size.height * 0.15;
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var topSpace = overAllHeight * 0.055;
    var backTopSpace = 10.0;
    var buttonHeight = overAllHeight * 0.05;
    var leftPadding = overAllWidth * 0.055;
    var luxLeftPAdding = overAllWidth * 0.06;
    var listLeftPadding = overAllWidth * 0.035;
    return
      FocusDetector(
        onFocusGained: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          print("selectroom focus gained");
          if(prefs.getInt("selectedIndex") !=null) {
            setState(() {
              roomDetails = GlobalState.selectedRoomList;
              roomIndex = prefs.getInt("selectedIndex") != null ? prefs.getInt(
                  "selectedIndex")! : 0;
              currentSelectedIndex = -1;

            });
          }
          final FirebaseAuth auth = FirebaseAuth.instance;
          final User? user = auth.currentUser;
          if(user!=null){
            setState(() {
              GlobalState.promoCode = membershipCode;
              promocode = membershipCode;
            });
          }
          getOfferList().then((value){
            setState(() {
              getOfferListQuery = value;
            });
          });
        },
        onFocusLost: ()async {
          // SharedPreferences prefs = await SharedPreferences.getInstance();
          //  prefs.remove("selectedIndex");

        },
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              if(getOfferListQuery!=GetOfferList$Query())
              Container(
                  padding: EdgeInsets.only(
                      left: AppUtility().isTablet(context)
                          ? overAllWidth * 0.070
                          : listLeftPadding,
                      right: AppUtility().isTablet(context)
                          ? overAllWidth * 0.070
                          : listLeftPadding),
                  child: _displayResult(getOfferListQuery)
              ),
            ],
          ),
        ),
      );
  }

  Widget _displayResult(
      GetOfferList$Query? data
      ) {
    if (data == null) {
      return Container();
    } else {
      List<GetOfferList$Query$ProductOffers$Hotels$Offers> offers = [];
      Map<String,
          GetOfferList$Query$ProductOffers$Hotels$Offers> roomMap = new HashMap();
      data.productOffers!.hotels!.forEach((element) {
        element.offers.forEach((offer) {
          offer.rooms?.room = offer.rooms?.room?.sublist(0, 1);
          offer.rooms?.room?.forEach((room) {
            room.discountInfo = offer.price!.discountInfo;
            if (!roomMap.containsKey(room.opCode)) {
              roomMap.putIfAbsent(room.opCode!, () => offer);
            } else {
              GetOfferList$Query$ProductOffers$Hotels$Offers d =
              roomMap[room.opCode!]!;
              d.rooms!.room!.add(room);
            }
          });
        });
        // offers.addAll(element.offers);
      });
      offers = roomMap.values.toList();
      offers.sort((a, b) =>
          a.rooms!.room![0].price!.amount
              .compareTo(b.rooms!.room![0].price!.amount));
      if (offers.length == 0) {
        return Container(
          height: 150,
          width: MediaQuery
              .of(context)
              .size
              .width - 10,
          padding: EdgeInsets.only(
              right: MediaQuery
                  .of(context)
                  .size
                  .width * 0.01,
              left: MediaQuery
                  .of(context)
                  .size
                  .width * 0.01,
              top: 100),
          alignment: Alignment.center,
          child: Text(
            Strings.emptyRoom,
            style: errorMessageStyle,
            maxLines: 5,
            textAlign: TextAlign.center,
          ),
        );
      } else {
        return ListView.builder(
            shrinkWrap: true,
            itemCount: offers.length,
            itemBuilder: (BuildContext context, int index) {
              //   offers[index].rooms!.room = offers[index].rooms!.room!.sublist(0,1);
              return Column(
                children: [
                  SelectRoomItem(
                      offers[index],
                      widget.product.hotel!.name.toString(),
                      widget.product.hotelContent!.crsCode.toString(),
                      widget.product.hotel!.giataId.toString(),
                      currentSelectedIndex == index ? true : false,
                      roomIndex + 1,
                      adults,
                      children, () {
                    setState(() {
                      currentSelectedIndex = currentSelectedIndex == index ? -1 : index;
                    });
                  },continueCallBack:(element){
                        print(element);
                        setState(() {
                          getOfferListQuery = GetOfferList$Query();
                        });

                  }),
                  if (offers.length == index + 1)
                    Container(
                      padding: EdgeInsets.only(bottom: 20),
                    ),
                ],
              );
            });
      }
    }
  }
}
