import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_paytabs_bridge/BaseBillingShippingInfo.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkLocale.dart';
import 'package:flutter_paytabs_bridge/flutter_paytabs_bridge.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jaz_app/graphql_provider.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/roommodel.dart';
import 'package:jaz_app/screens/bottomnavigation/bottombar.dart';
import 'package:jaz_app/screens/mybookings/my_bookings.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/commonutils.dart';
import 'package:jaz_app/utils/facebookevents.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/navigatorService.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/widgets/summaryroomlist.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../homebottombar.dart';
import 'package:intl/intl.dart';
import 'package:jaz_app/utils/http_client.dart';

// ignore: must_be_immutable
class AsGuest2 extends StatefulWidget {
  final HashMap<String, dynamic> guestDetail;
  final HashMap<String, dynamic> cardDetail;
  Widget widgetTerms;

  AsGuest2(
      {Key? key,
      required this.widgetTerms,
      required this.guestDetail,
      required this.cardDetail})
      : super(key: key);

  @override
  _AsGuest2State createState() => _AsGuest2State();
}

class _AsGuest2State extends State<AsGuest2> {
  ScrollController _controllerOne = ScrollController();
  bool isExpanded = false;
  int selectedRadio = 0;
  bool valuefirst = false;
  late String roomTypeCode,
      roomRatePlanCode,
      hotelCrsCode,
      hotelName,
      price,
      roomName,
      hotelId;
  String profileId = "";
  String serverKey = "";
  String clientKey = "";
  String hotelcountrycode = "";
  String ratePlanCountryCode = "";
  TextEditingController _currencyController = TextEditingController();
  var _currenciesList = ["USD", "EUR", "GBP", "EGP"];
  var selectedCurrency;

  AppUtility appUtility = AppUtility();
  HttpClient httpClient = HttpClient();
  var userDetails;
  var userId;
  final FirebaseAuth auth = FirebaseAuth.instance;

  var email, firstName, lastName, phoneNumber;
  bool isGuest = false;
  var isPay = 0;
  var currencyconvertedPrice;
  var usdPrice;
  var fullName;
  String promoCode = "";
  List<Room> roomDetails = [];
  var startDate, endDate;

  @override
  void initState() {
    super.initState();
    appUtility = AppUtility();
    isExpanded = true;
    roomDetails = GlobalState.selectedRoomList;
    startDate = GlobalState.checkInDate;
    endDate = GlobalState.checkOutDate;
    //  roomName = GlobalState.selectedBookingRoomDet["selectedRoomName"];
    // roomTypeCode = GlobalState.selectedBookingRoomDet["roomTypeCode"];
    // roomRatePlanCode = GlobalState.selectedBookingRoomDet["roomRatePlanCode"];
    // ignore: unnecessary_null_comparison
    getHotelDetails();
    if (widget.guestDetail.length > 0) {
      firstName = widget.guestDetail["firstName"];
      lastName = widget.guestDetail["lastName"];
      fullName = "$firstName $lastName";
      email = widget.guestDetail["email"];
      phoneNumber = widget.guestDetail["phoneNumber"];
      isGuest = true;
    } else {
      isGuest = false;
      getUserDetails();
    }

    _controllerOne =
        ScrollController(keepScrollOffset: true, initialScrollOffset: 50.0);
  }

  getHotelDetails() {
    hotelCrsCode = roomDetails[0].roomDetail["hotelCrsCode"];
    hotelName = roomDetails[0].roomDetail["hotelName"];
    double doublePrice = 0.0;
    roomDetails.forEach((element) {
      if (element.roomDetail.isNotEmpty) {
        doublePrice = double.parse(element.roomDetail["price"]) + doublePrice;
      }
    });
    price = doublePrice.toString();
    // price = GlobalState.selectedBookingRoomDet["price"];
    hotelId = roomDetails[0].roomDetail["hotelId"];
    isPay = widget.cardDetail["payType"];
    if (widget.cardDetail["payType"] == 2) {
      profileId = roomDetails[0].roomDetail["uae_profileId"];
      serverKey = roomDetails[0].roomDetail["uae_serverKey"];
      clientKey = roomDetails[0].roomDetail["uae_clientKey"];
    } else {
      profileId = roomDetails[0].roomDetail["profileId"];
      serverKey = roomDetails[0].roomDetail["serverKey"];
      clientKey = roomDetails[0].roomDetail["clientKey"];
    }
    ratePlanCountryCode = roomDetails[0].roomDetail["ratePlanCountryCode"];
    hotelcountrycode = roomDetails[0].roomDetail["hotelcountrycode"];
    selectedCurrency = _currenciesList[0];
    currencyconvertedPrice = price;
    usdPrice = price;
    //  promoCode = roomDetails[0].roomDetail["selectedPromoCode"];

    print("promocode $promoCode");
  }

  Future<void> getUserDetails() async {
    final User? user = auth.currentUser;
    if (user != null) {
      userId = user.uid;
      var document = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      userDetails = document.data();
      firstName = userDetails["name"]["firstName"] == ""
          ? userDetails["name"]["fullName"]
          : userDetails["name"]["firstName"];
      lastName = userDetails["name"]["lastName"] == ""
          ? firstName
          : userDetails["name"]["lastName"];
      fullName = "$firstName $lastName";
      //   lastName = "";
      email = userDetails["contact"]["emailAddress"];
      phoneNumber = userDetails["contact"]["mobilePhone"];
    }
  }

  AppBar _appBarData(BuildContext context) {
    return AppBar(
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
                      padding: EdgeInsets.only(left: 0),
                      child: Text(Strings.back, style: backStyle),
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.height * 0.015),
                    child: Text(
                      Strings.summaryStr,
                      style: summaryTextStyle,
                    )),
              ),
            ],
          ),
        ));
  }

  Widget _completeButton(BuildContext context) {
    var overAllHeight = MediaQuery.of(context).size.height;
    var buttonHeight = overAllHeight * 0.055;
    if (buttonHeight < 40) {
      buttonHeight = 45;
    }
    String value = "Complete";
    return Align(
        alignment: Alignment.center,
        child: Container(
            height: buttonHeight,
            width: AppUtility().isTablet(context)
                ? MediaQuery.of(context).size.width * 0.70
                : MediaQuery.of(context).size.width * 0.80,
            decoration: BoxDecoration(
              color: Uicolors.buttonbg,
              borderRadius: BorderRadius.all(Radius.circular(buttonHeight /
                      2) //                 <--- border radius here
                  ),
            ),
            child: MaterialButton(
              color: Uicolors.buttonbg,
              child: Text(
                value.toUpperCase(),
                style: buttonStyle,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonHeight / 2),
              ),
              onPressed: () async {
                //_startCardPayment(["61587SC002808"]);
                print(roomDetails);
                var details =
                    roomDetails.where((element) => element.roomDetail.isEmpty);
                if (details.length > 0) {
                  appUtility.showToastView("Please Select Room.", context);
                } else if (valuefirst) {
                  List reservationIds = [];
                  try {
                    for (int i = 0; i < roomDetails.length; i++) {
                      if (i + 1 <= roomDetails.length) {
                        var reservationId = await confirmBooking(
                            i, currencyconvertedPrice, selectedCurrency);
                        if (reservationId != "") {
                          reservationIds.add(reservationId);
                        }
                      }
                      //  _startCardPayment(["61587SC002808"]);
                    }
                    if (reservationIds.length == roomDetails.length) {
                      FacebookEvents().initiateBookingEvent(
                          hotelCrsCode,
                          selectedCurrency,
                          price,
                          startDate,
                          endDate,
                          AppUtility().getNumberOfPerson(roomDetails),
                          roomDetails.length.toString(),
                          AppUtility().getNumberOfNight(startDate, endDate));
                      if (widget.cardDetail["payType"] == 0) {
                        _startCardPayment(reservationIds,
                            currencyconvertedPrice, selectedCurrency);
                      } else if (widget.cardDetail["payType"] == 2) {
                        if (Platform.isAndroid) {
                          samsungPayClick(reservationIds,
                              currencyconvertedPrice, selectedCurrency);
                        } else if (Platform.isIOS) {
                          applePayClick(reservationIds, currencyconvertedPrice,
                              selectedCurrency);
                        }
                      } else {
                        await callCommitBooking(reservationIds, "");
                      }
                    } else {
                      await callCancelBooking(reservationIds);
                    }
                  } catch (e) {
                    appUtility.showToastView(
                        "Please provide proper information for booking.",
                        context);
                  }
                } else {
                  appUtility.showToastView(
                      "Please accept travel policy.", context);
                }
              },
            )));
  }

  @override
  Widget build(BuildContext context) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    final leftPadding = overAllWidth * 0.035;
    final topPadding = overAllHeight * 0.015;
    final boxHeight = overAllHeight * 0.055;
    final boxWidth = overAllWidth * 0.7;
    var borderRadius = fieldBorderRadius;
    var summaryToppadding = overAllHeight * 0.02;
    var saveCardToppadding = overAllHeight * 0.03;
    var nextButtonTopPadding = overAllHeight * 0.03;
    var boxContentLeftPadding = MediaQuery.of(context).size.width * 0.04;
    final bottomPadding = overAllHeight * 0.03;

    return Scaffold(
      backgroundColor: Uicolors.backgroundColor,
      appBar: _appBarData(context),
      body: StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
          setSelectedRadio(int val) {
            setState(() {
              selectedRadio = val;
            });
          }

          return ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: leftPadding,
                    right: leftPadding,
                    top: summaryToppadding),
                child: GestureDetector(
                  child: Container(
                    //   height: MediaQuery.of(context).size.height*0.077,

                    //   width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(12),
                      boxShadow: boxShadow,
                      color: Colors.white,
                    ),
                    child: SummaryRoomList(roomDetails, "guest2",
                        summaryCallBack: (selectedRoomList, actionName) async {
                      this.setState(() {
                        roomDetails = selectedRoomList;
                      });
                      getHotelDetails();
                      if (actionName != "remove") {
                        int emptyRoomIndex = 0;
                        for (int i = 0; i < roomDetails.length; i++) {
                          if (roomDetails[i].roomDetail.isEmpty) {
                            emptyRoomIndex = i;
                          }
                        }
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setInt("selectedIndex", emptyRoomIndex);
                        String? loginType = prefs.getString("loginType");
                        if (loginType == "guest") {
                          Navigator.pop(context);
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    }),
                  ),
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ),
              if (isPay == 0)
                Padding(
                    padding: EdgeInsets.only(
                        top: topPadding, left: leftPadding, right: leftPadding),
                    child: Container(
                        // alignment: Alignment.center,
                        //  height: boxHeight,
                        //     width: boxWidth,

                        decoration: BoxDecoration(
                            //  borderRadius: BorderRadius.circular(borderRadius),
                            color: Colors.white,
                            border: border,
                            boxShadow: boxShadow),
                        child: Column(children: [
                          Stack(
                            // alignment: Alignment.centerLeft,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                //  padding: EdgeInsets.only(),
                                height: boxHeight,
                                margin: EdgeInsets.only(
                                    top: topPadding,
                                    left: leftPadding,
                                    right: leftPadding),

                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                  color: Colors.white,
                                  border: border,
                                ),

                                child: TypeAheadFormField(
                                    noItemsFoundBuilder: (context) => ListTile(
                                            title: Text(
                                          Strings.noOption,
                                          textAlign: TextAlign.center,
                                          style: placeHolderStyle,
                                        )),
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                            keyboardType: TextInputType.name,
                                            enableInteractiveSelection: true,
                                            controller:
                                                this._currencyController,
                                            style: guestTextFieldStyle,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: selectedCurrency,
                                              isCollapsed: true,
                                              errorStyle: errorTextStyle,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      AppUtility()
                                                              .isTablet(context)
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.02
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                      0,
                                                      0,
                                                      0),
                                              hintStyle: textFieldStyle,
                                            )),
                                    itemBuilder: (context, String currencies) {
                                      return Container(
                                        width: 500,
                                        child: ListTile(
                                          title: Text(
                                            currencies,
                                            style: saluDropTextStyle,
                                          ),
                                        ),
                                      );
                                    },
                                    onSuggestionSelected: (String items) async {
                                      _currencyController.text = items;
                                      if (items != Strings.usd) {
                                        var selectedPrice = await CommonUtils()
                                            .convertCurrency(price, items);
                                        if (selectedPrice == Strings.failure) {
                                          appUtility.showToastView(
                                              Strings.errorMessage, context);
                                        } else {
                                          this.setState(() {
                                            currencyconvertedPrice =
                                                selectedPrice;
                                            selectedCurrency = items;
                                          });
                                        }
                                      } else {
                                        this.setState(() {
                                          currencyconvertedPrice = price;
                                          selectedCurrency = Strings.usd;
                                        });
                                      }
                                      //  this._currencyController.hint;
                                    },
                                    suggestionsCallback: (pattern) {
                                      if (pattern.length > 0) {
                                        return _currenciesList
                                            .where((element) => element
                                                .toLowerCase()
                                                .contains(
                                                    pattern.toLowerCase()))
                                            .toList();
                                      } else {
                                        return _currenciesList;
                                      }
                                    },
                                    transitionBuilder: (context, suggestionsBox,
                                            animationController) =>
                                        suggestionsBox,
                                    validator: (args) {
                                      if (args.toString().isNotEmpty) {
                                        return null;
                                      } else {
                                        return 'Preferred currency is required';
                                      }
                                    }),
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        0.06,
                                    top: MediaQuery.of(context).size.height *
                                        0.035),
                                child: Image.asset(
                                  "assets/images/down-arrow.png",
                                  height: 17,
                                  width: 17,
                                  color: Uicolors.buttonbg,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: leftPadding,
                                top: topPadding,
                                bottom: topPadding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  child: Text(
                                    Strings.totalPrice,
                                    style: roomStrStyle,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 0),
                                  child: Text(
                                    "" + selectedCurrency,
                                    style: dollerStyle,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    double.parse(currencyconvertedPrice)
                                        .toStringAsFixed(2),
                                    style: priceTextStyle,
                                    softWrap: true,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]))),
              Padding(
                child: Container(
                  //height: MediaQuery.of(context).size.height * 0.55,
                  // width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: boxShadow,
                    color: Colors.white,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: topPadding, left: boxContentLeftPadding),
                          child:
                              Text(Strings.policyBTNStr, style: policyBtnStyle),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: topPadding, left: boxContentLeftPadding),
                          child: Text(Strings.regulationBTNStr,
                              style: regulationStrStyle),
                        ),
                        Align(
                          child: Padding(
                            child: Stack(
                              alignment: Alignment.topLeft,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 0),
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
                                          value: valuefirst,
                                          onChanged: (value) {
                                            setState(() {
                                              valuefirst = value!;
                                            });
                                          },
                                        ),
                                      )),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(
                                    left: AppUtility().isTablet(context)
                                        ? MediaQuery.of(context).size.width *
                                            0.08
                                        : MediaQuery.of(context).size.width *
                                            0.13,
                                    right: 0,
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Text(
                                    "I have taken note of the entry and vacation regulations for the destination and transit country corresponding to the individual travellers.",
                                    maxLines: 10,
                                    style: noteEntryStyle,
                                  ),
                                )
                              ],
                            ),
                            padding: EdgeInsets.only(
                                top: topPadding,
                                left: leftPadding,
                                right: leftPadding),
                          ),
                          alignment: Alignment.topLeft,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: topPadding,
                              left: leftPadding,
                              right: leftPadding),
                          child: Text(
                            "Information on data production within the framework of a travel booking or other services",
                            style: informationStyle,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.02,
                              left: leftPadding,
                              right: leftPadding),
                          child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.045,
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.height *
                                        0.045 /
                                        2),
                                color: Uicolors.sslEncriptionBgColor,

                                ///Need to get a correct from UI Team
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(
                                        top: 0, left: leftPadding),
                                    child: Image.asset(
                                      "assets/images/lock.png",
                                      width: backIconSize,
                                      height: backIconSize,
                                    ),
                                    // Icon(
                                    //   Icons.lock,
                                    //   size: 12,
                                    // ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text(
                                      "Your data is transmitted with a secure SSL encryption",
                                      style: dataTransStyle,
                                    ),
                                  )
                                ],
                              )),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.02,
                                left: leftPadding,
                                right: leftPadding,
                                bottom: bottomPadding),
                            child: Container(
                                margin: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.02,
                                    right: MediaQuery.of(context).size.width *
                                        0.02,
                                    top: MediaQuery.of(context).size.width *
                                        0.03),
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                width: MediaQuery.of(context).size.width * 1,
                                child: RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                    style: afterCompletStyle,
                                    text: Strings.travelPolicyStr,
                                  ),
                                  TextSpan(
                                      style: contactNumberStyle,
                                      text: Strings.serviceNumber)
                                ])))),
                      ]),
                ),
                padding: EdgeInsets.only(
                    top: topPadding, left: leftPadding, right: leftPadding),
              ),
              Padding(
                child: _completeButton(context),
                padding: EdgeInsets.only(
                    top: nextButtonTopPadding, bottom: nextButtonTopPadding),
              ),
              widget.widgetTerms
            ],
          );
        },
      ),
    );
  }

  void _startCardPayment(
      List reservationIds, String price, String ratePlanCurrencyCode) {
    GlobalState.reservationIds = reservationIds;
    var reservationIdString = reservationIds.join(",");
    GlobalState.reservationComment =
        "$ratePlanCurrencyCode $usdPrice $price $reservationIdString";
    var billingDetails = new BillingDetails(
        fullName, email, phoneNumber, "", hotelcountrycode, "", "", "");
    var configuration = PaymentSdkConfigurationDetails(
      //Testing
      // profileId: "49350",
      // serverKey: "SZJNLRMR2B-JBTNBNGKDN-KTRLN6ZNLJ",
      // clientKey: "CMKMDH-D9P662-7Q2QTK-VGTBHN",
      profileId: profileId,
      serverKey: serverKey,
      clientKey: clientKey,
      merchantName: hotelName,
      cartId: reservationIds[0].toString(),
      cartDescription: hotelName,
      screentTitle: "Payment",
      billingDetails: billingDetails,
      showBillingInfo: true,
      locale: PaymentSdkLocale.EN,
      // amount: 1,
      amount: double.parse(price),
      currencyCode: ratePlanCurrencyCode,
      merchantCountryCode: hotelcountrycode,
    );
    callBack(event) {
      if (event["status"] == "success") {
        // Handle transaction details here.
        var transactionDetails = event["data"];
        var comment = GlobalState.reservationComment +
            transactionDetails["transactionReference"] +
            " " +
            transactionDetails["cartID"].toString();

        callCommitBooking(GlobalState.reservationIds, comment);
      } else if (event["status"] == "error") {
        callCancelBooking(GlobalState.reservationIds);
      } else if (event["status"] == "event" ||
          event["message"] == "Cancelled") {
        callCancelBooking(GlobalState.reservationIds);
      }
    }

    FlutterPaytabsBridge.startCardPayment(configuration, callBack);
  }

  void samsungPayClick(
      List reservationIds, String price, String ratePlanCurrencyCode) {
    GlobalState.reservationIds = reservationIds;
    var reservationIdString = reservationIds.join(",");
    GlobalState.reservationComment =
        "$ratePlanCurrencyCode $usdPrice $price $reservationIdString";
    var billingDetails = new BillingDetails(
        fullName, email, phoneNumber, "", hotelcountrycode, "", "", "");
    var configuration = PaymentSdkConfigurationDetails(
      profileId: profileId,
      serverKey: serverKey,
      clientKey: clientKey,
      merchantName: hotelName,
      cartId: reservationIds[0].toString(),
      cartDescription: hotelName,
      screentTitle: "Payment",
      billingDetails: billingDetails,
      showBillingInfo: true,
      locale: PaymentSdkLocale.EN,
      // amount: 1,
      amount: double.parse(price),
      currencyCode: ratePlanCurrencyCode,
      merchantCountryCode: hotelcountrycode,
    );
    configuration.samsungPayToken = "b1af54bd57844b8898e573";
    callBack(event) {
      if (event["status"] == "success") {
        // Handle transaction details here.
        var transactionDetails = event["data"];
        var comment = GlobalState.reservationComment +
            transactionDetails["transactionReference"] +
            " " +
            transactionDetails["cartID"].toString();

        callCommitBooking(GlobalState.reservationIds, comment);
      } else if (event["status"] == "error") {
        callCancelBooking(GlobalState.reservationIds);
      } else if (event["status"] == "event" ||
          event["message"] == "Cancelled") {
        callCancelBooking(GlobalState.reservationIds);
      }
    }

    FlutterPaytabsBridge.startSamsungPayPayment(configuration, callBack);
  }

  void applePayClick(
      List reservationIds, String price, String ratePlanCurrencyCode) {
    GlobalState.reservationIds = reservationIds;
    var reservationIdString = reservationIds.join(",");
    GlobalState.reservationComment =
        "$ratePlanCurrencyCode $usdPrice $price $reservationIdString";
    var billingDetails = new BillingDetails(
        fullName, email, phoneNumber, "", hotelcountrycode, "", "", "");
    var configuration = PaymentSdkConfigurationDetails(
      profileId: profileId,
      serverKey: serverKey,
      clientKey: clientKey,
      merchantName: hotelName,
      cartId: reservationIds[0].toString(),
      cartDescription: hotelName,
      screentTitle: "Payment",
      billingDetails: billingDetails,
      showBillingInfo: true,
      locale: PaymentSdkLocale.EN,
      // amount: 1,
      amount: double.parse(price),
      currencyCode: ratePlanCurrencyCode,
      merchantCountryCode: hotelcountrycode,
      merchantApplePayIndentifier: "merchant.com.jaz.JazHotels",
    );
    callBack(event) {
      if (event["status"] == "success") {
        // Handle transaction details here.
        var transactionDetails = event["data"];
        var comment = GlobalState.reservationComment +
            transactionDetails["transactionReference"] +
            " " +
            transactionDetails["cartID"].toString();

        callCommitBooking(GlobalState.reservationIds, comment);
      } else if (event["status"] == "error") {
        callCancelBooking(GlobalState.reservationIds);
      } else if (event["status"] == "event" ||
          event["message"] == "Cancelled") {
        callCancelBooking(GlobalState.reservationIds);
      }
    }

    FlutterPaytabsBridge.startApplePayPayment(configuration, callBack);
  }
  //testing apple and samsung pay
  // samsungPayClick() {
  //   var billingDetails =
  //   new BillingDetails("test", "test@gmail.com", "987454455464", "chennai", "EG", "india", "Tamil nadu", "6000091");
  //   var configuration = PaymentSdkConfigurationDetails(
  //     profileId: "70125",
  //     serverKey: "STJNR2BHML-JBNZH6KRGK-WKHMKNHLMJ",
  //     clientKey: "CMKM6B-Q6VG62-Q9HGKR-TRMV6D",
  //     merchantName: "SOLYMAR IVORY SUITES",
  //     cartId: "123444",
  //     billingDetails: billingDetails,
  //     showBillingInfo: true,
  //     cartDescription: "SOLYMAR IVORY SUITES",
  //     screentTitle: "Payment",
  //     locale: PaymentSdkLocale.EN,
  //     amount: 1,
  //     //amount: double.parse(price),
  //     currencyCode: "AED",
  //     merchantCountryCode: "AE",
  //     //    merchantApplePayIndentifier:"merchant.com.jaz.JazHotels"
  //   );
  //   configuration.samsungPayToken="b1af54bd57844b8898e573";
  //   // configuration.simplifyApplePayValidation = true;
  //   callBack(event){
  //     print(event);
  //     if (event["status"] == "success") {
  //       // Handle transaction details here.
  //       var transactionDetails = event["data"];
  //
  //     } else if (event["status"] == "error") {
  //     } else if (event["status"] == "event" ||
  //         event["message"] == "Cancelled") {
  //     }
  //   }
  //   FlutterPaytabsBridge.startSamsungPayPayment(configuration,
  //       callBack
  //   );
  // }

  // applePayClick(){
  //   var configuration = PaymentSdkConfigurationDetails(
  //     profileId: "70125",
  //     serverKey: "STJNR2BHML-JBNZH6KRGK-WKHMKNHLMJ",
  //     clientKey: "CMKM6B-Q6VG62-Q9HGKR-TRMV6D",
  //     merchantName: "SOLYMAR IVORY SUITES",
  //     cartId: "123444",
  //     cartDescription: "SOLYMAR IVORY SUITES",
  //     screentTitle: "Payment",
  //     locale: PaymentSdkLocale.EN,
  //     amount: 1,
  //     //amount: double.parse(price),
  //     currencyCode: "AED",
  //     merchantCountryCode: "AE",
  //     merchantApplePayIndentifier:"merchant.com.jaz.JazHotels",
  //
  //   );
  //   configuration.simplifyApplePayValidation = true;
  //   callBack(event){
  //     print(event);
  //     if (event["status"] == "success") {
  //     } else if (event["status"] == "error") {
  //     } else if (event["status"] == "event" ||
  //         event["message"] == "Cancelled") {
  //     }
  //   }
  //   FlutterPaytabsBridge.startApplePayPayment(configuration,
  //       callBack
  //   );
  // }

  Future<void> callCommitBooking(List reservationIds, String comment) async {
    List confirmReservationId = [];
    for (int i = 0; i < reservationIds.length; i++) {
      var reserId = await commitBooking(reservationIds[i], comment);
      confirmReservationId.add(reserId);
    }
    if (confirmReservationId.length == reservationIds.length) {
      FacebookEvents().completeBookingEvent(
          hotelCrsCode,
          selectedCurrency,
          price,
          startDate,
          endDate,
          AppUtility().getNumberOfPerson(roomDetails),
          roomDetails.length.toString(),
          AppUtility().getNumberOfNight(startDate, endDate));
      print(reservationIds.join(","));
      showDialog(
          context: NavigationService.navigatorKey.currentContext!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Your booking is completed. Your Reference id " +
                  reservationIds[0].toString()),
              content: Text(Strings.appName),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // getBookingDet(
                    //     hotelCrsCode, "61587SC002726")
                    // getBookingDet(hotelCrsCode, reservationIds[0].toString())
                    //getBookingList();
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) =>
                                    new HomeBottomBarScreen(0) /*BottomBar()*/),
                            (Route<dynamic> route) => false);
                  },
                  child: Text('Ok'),
                ),
              ],
            );
          });
    } else {
      await callCancelBooking(reservationIds);
    }
  }

  Future<void> callCancelBooking(List reservationIds) async {
    try {
      for (int i = 0; i < reservationIds.length; i++) {
        await cancelBooking(
            roomDetails[0].roomDetail["hotelCrsCode"], reservationIds[i]);
      }
      // appUtility.confirmPop(
      //     context,
      //     "An error occurred while processing your payment, please make sure of card details and billing address and try again",
      //     "JAZ APP");

    } catch (e) {}
  }

  Future<String> commitBooking(String reservationId, String comment) async {
    var response;
    HashMap<String, dynamic> params = HashMap();
    params.putIfAbsent(
        "hotel_crs_code", () => roomDetails[0].roomDetail["hotelCrsCode"]);
    params.putIfAbsent("confirmation_number", () => reservationId);
    params.putIfAbsent("comment", () => comment);
    EasyLoading.show();
    response = await httpClient.getData(params, "commit_booking", null);
    if (response.statusCode == 200 && json.decode(response.body) != null) {
      EasyLoading.dismiss();
      return reservationId.toString();
    } else {
      EasyLoading.dismiss();
      return "";
      // If that call was not successful, throw an error.
      //   return [];
    }
    // }
  }

  cancelBooking(String hotelCrsCode, String reservationId) async {
    var response;
    HashMap<String, dynamic> params = HashMap();
    params.putIfAbsent(
        "hotel_crs_code", () => roomDetails[0].roomDetail["hotelCrsCode"]);
    params.putIfAbsent("confirmation_number", () => reservationId);
    EasyLoading.show();
    // BuildContext? dialogContext;
    // AppUtility().showProgressDialog(context,type:null,dismissDialog:(value){
    //   dialogContext = value;
    // });
    response = await httpClient.getData(params, "cancel_booking", null);
    if (response.statusCode == 200 && json.decode(response.body) != null) {
      EasyLoading.dismiss();
      // await new Future.delayed(const Duration(milliseconds: 500));
      // AppUtility().dismissDialog(dialogContext!);
    } else {
      EasyLoading.dismiss();
      // await new Future.delayed(const Duration(milliseconds: 500));
      // AppUtility().dismissDialog(dialogContext!);
    }
  }

  Future<String> confirmBooking(
      int index, String price, String roomRateCurrencyCode) async {
    final DateFormat startFormatter = DateFormat('yyyy-MM-dd');
    // final DateFormat endFormatter = DateFormat('EEE dd');
    final String checkInDate = startFormatter.format(GlobalState.checkInDate);
    final String checkOutDate = startFormatter.format(GlobalState.checkOutDate);
    var response;
    HashMap<String, dynamic> params = HashMap();
    params.putIfAbsent(
        "hotel_crs_code", () => roomDetails[0].roomDetail["hotelCrsCode"]);
    params.putIfAbsent(
        "room_type_code", () => roomDetails[index].roomDetail["roomTypeCode"]);
    params.putIfAbsent("rate_plan_code",
        () => roomDetails[index].roomDetail["roomRatePlanCode"]);
    params.putIfAbsent("check_in", () => checkInDate);
    params.putIfAbsent("check_out", () => checkOutDate);
    params.putIfAbsent("adults",
        () => appUtility.getSingleRoomAdults(roomDetails[index]).toString());
    params.putIfAbsent("children",
        () => appUtility.getSingleRoomChildren(roomDetails[index]).toString());
    params.putIfAbsent(
        "promo_code", () => roomDetails[index].roomDetail["selectedPromoCode"]);
    params.putIfAbsent("paid_amount", () => price);
    params.putIfAbsent("first_name", () => firstName);
    params.putIfAbsent(
        "last_name", () => lastName != "" ? lastName : firstName);
    params.putIfAbsent("email", () => email);
    params.putIfAbsent("country", () => hotelcountrycode);
    params.putIfAbsent("cc_number", () => widget.cardDetail["cardNumber"]);
    // params.putIfAbsent(
    //     "cc_holder",
    //     () =>
    //         widget.cardDetail["firstName"] +
    //         " " +
    //         widget.cardDetail["lastName"]);
    params.putIfAbsent("cc_holder", () => widget.cardDetail["cardHolderName"]);
    params.putIfAbsent("cc_expiry", () => widget.cardDetail["expDate"]);
    params.putIfAbsent("cc_code", () => widget.cardDetail["cardType"]);

    EasyLoading.show();
    // BuildContext? dialogContext;
    // AppUtility().showProgressDialog(context,type:null,dismissDialog:(value){
    //   dialogContext = value;
    // });
    response = await httpClient.getData(params, "initiate_booking", null);
    if (response.statusCode == 200 && json.decode(response.body) != null) {
      EasyLoading.dismiss();
      var responseDecode = json.decode(response.body);
      if (responseDecode['OTA_HotelResRS']['Errors'] == null) {
        var reservationId = (responseDecode['OTA_HotelResRS']
                    ['HotelReservations']['HotelReservation']['UniqueID']
                ['_attributes']['ID']
            .toString());
        CollectionReference confirmBookingDet =
            FirebaseFirestore.instance.collection('confirm_booking');
        // await confirmBookingDet.doc(reservationId)
        //     .set(json.decode(response.body));
        if (!isGuest) {
          final User? user = auth.currentUser;
          if (user != null) {
            final userId = user.uid;
            await confirmBookingDet
                .doc(userId)
                .collection("booking")
                .doc(reservationId)
                .set(json.decode(response.body));
          }
        } else {
          await confirmBookingDet
              .doc(email)
              .collection("booking")
              .doc(reservationId)
              .set(json.decode(response.body));
        }
        return reservationId;
      } else {
        throw new Future.error(json.decode(response.body));
      }
    } else {
      EasyLoading.dismiss();
      throw new Future.error(json.decode(response.body));

      // If that call was not successful, throw an error.
      //   return [];
    }
  }
// }
}
