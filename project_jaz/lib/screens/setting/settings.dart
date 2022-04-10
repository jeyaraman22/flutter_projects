import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jaz_app/helper/graphqlconnectivity/constants.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/AccountMenuModel.dart';
import 'package:jaz_app/models/accountModel.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/models/socialMediaModel.dart';
import 'package:jaz_app/screens/bottomnavigation/bottombar.dart';
import 'package:jaz_app/screens/mybookings/my_bookings.dart';
import 'package:jaz_app/screens/profile/about_us.dart';
import 'package:jaz_app/screens/profile/contact_us.dart';
import 'package:jaz_app/screens/profile/editprofilepage.dart';
import 'package:jaz_app/screens/profile/savedcards.dart';
import 'package:jaz_app/screens/profile/savedlistpage.dart';
import 'package:jaz_app/screens/search/switchCurrency.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:jaz_app/utils/http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../homebottombar.dart';

class Settings extends StatefulWidget {
  _Settings createState() => _Settings();
}

class _Settings extends State<Settings> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  HttpClient httpClient = HttpClient();

  List<AccountModelData> accountData = AccountModelData.getUsers1();

  List<AccountMenuModelData> accountMenuData = AccountMenuModelData.getUsers();

  List<AccountModelData> secondContainerData = [
    AccountModelData(
      img: 'assets/images/chat-withus-icon copy.png',
      title: Strings.chatWithUs,
      trailingText: '',
    )
  ];

  var socialMediaList;

  String name = "";
  String email = "";
  String phoneNumber = "";
  String profileUrl = "";
  String countryCode = "";
  String currencyCode = "";

  Future<void> inputData() async {
    final User? user = auth.currentUser;
    if (user != null) {
      final userId = user.uid;
      var document = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      var userDetails = document.data();
      if(this.mounted) {
        setState(() {
          name = userDetails!["name"]["fullName"];
          email = userDetails["contact"]["emailAddress"];
          phoneNumber = userDetails["contact"]["phoneNumbers"];
          if (name == "") {
            name = userDetails["name"]["firstName"];
          }
          if (name == null) {
            name = "";
          }
          if (phoneNumber == null) {
            phoneNumber = "";
          }
          profileUrl = userDetails['name']['profileImage'];
          countryCode = userDetails['contact']['countryCode'] != null
              ? userDetails['contact']['countryCode']
              : "+91";
        });
      }
        if (GlobalState.socialMediaLinks != null) {
          socialMediaList = GlobalState.socialMediaLinks;
        }
      }

    // here you write the codes to input the data into firestore
  }

  void initState() {
    super.initState();
    getCurrencyCode();
    inputData();
  }

  String getInitials(String name) => name!=null && name.isNotEmpty
      ? name.trim().split(' ').map((l) => l[0]).take(name.length).join()
      : '';

  bool secondContainerActivated = false;
  bool menuSlideActivated = false;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var menuButtonPadding = overAllWidth * 0.04;
    var titlePadding = overAllWidth * 0.02;
    var containerLeftPadding = overAllWidth * 0.035;
    var listTileTopPadding = overAllHeight * 0.025;
    var listTileLeftPadding = overAllWidth * 0.02;
    var listTileLeft1Padding = overAllWidth * 0.2;
    var listTileTop1Padding = overAllHeight * 0.015;
    var spaceTopPadding = overAllHeight * 0.003;
    var accountHolderTopPadding = overAllHeight * 0.006;
    var iconsListLeftPadding = overAllWidth * 0.01;

    var dividerTopPadding = overAllHeight * 0.02;
    var dividerLeftPadding = overAllWidth * 0.035;

    var bottomButtonLeftPadding = overAllWidth * 0.7;
    var dropDownButtonLeftPadding = overAllWidth * 0.06;
    var dropDownButtonTopPadding = overAllHeight * 0.004;

    //drawer
    var containerWidthPadding = overAllWidth * 0.90;
    var drawerImageHeightPadding = overAllHeight * 0.247;
    var drawerListTileTopPadding = overAllHeight * 0.14;
    var imageLeftToRightPadding = overAllWidth * 0.08;
    var drawerTopPadding = overAllHeight * 0.025;
    var logoTopPadding = overAllHeight * 0.035;
    var profileIconSize = overAllWidth * 0.08;

    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Uicolors.backgroundbg,
      appBar: AppBar(
        toolbarHeight:
        AppUtility().isTablet(context) ? 80 : AppBar().preferredSize.height,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Container(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
              onTap: () {

              },
              child: Padding(
                child: Text(Strings.myAccount, style: myAccountTextStyle),
                padding: EdgeInsets.only(left: titlePadding),
              )),
          //child: Text(Strings.backtosign,style: TextStyle(color: Uicolors.buttonbg),)
        ),
        actions: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: menuButtonPadding),
            child: IconButton(
              iconSize: iconSize,
              icon: Image.asset(
                "assets/images/menu_icon.png",
                color: Uicolors.bottomTextColor,
              ),
              onPressed: () {
                // setState(() {
                //   menuSlideActivated=true;
                // });
                _scaffoldkey.currentState!.openEndDrawer();
                // _scaffoldkey.currentState!.showBottomSheet((context) => Container(color: Colors.white,));
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
            child:
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: containerLeftPadding,
                      right: containerLeftPadding,
                      top: listTileTopPadding),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                      ),
                      boxShadow:boxShadow,
                      // borderRadius: BorderRadius.circular(containerBorderRadius),
                      color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          pushNewScreen(
                            context,
                            screen: EditProfilePage(),
                            withNavBar: true,
                            // OPTIONAL VALUE. True by default.
                            pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                          ).then((value) {
                            inputData();
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            left: listTileLeftPadding,
                            right: listTileLeftPadding,
                            top: listTileTop1Padding,
                            // bottom: listTileTopPadding
                          ),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  left: listTileLeftPadding,
                                  right: listTileLeftPadding,
                                  top: listTileTop1Padding,
                                  // bottom: listTileTopPadding
                                ),
                                child: CircleAvatar(
                                  radius: profileIconSize,
                                  child: Material(
                                    shape: CircleBorder(),
                                    clipBehavior: Clip.hardEdge,
                                    color: Colors.transparent,
                                    child: Stack(
                                      children: [
                                        Container(
                                          color: Uicolors.buttonbg,
                                        ),
                                        Center(
                                          child: profileUrl != null &&
                                              profileUrl.length > 0
                                              ? OptimizedCacheImage(
                                            imageUrl: profileUrl,
                                            width: double.maxFinite,
                                            height: double.maxFinite,
                                            placeholder: (context, url) =>
                                                Center(
                                                    child:
                                                    CircularProgressIndicator(
                                                      backgroundColor:
                                                      Colors.transparent,
                                                      valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Theme.of(context)
                                                              .primaryColor),
                                                    )),
                                            //new Icon(Icons.error),
                                            fit: BoxFit.fill,
                                          )
                                              : Text(
                                            getInitials(name),
                                            textAlign: TextAlign.center,
                                            style: initialNameStyle,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: overAllWidth * 0.6,
                                      child: Text(
                                        name,
                                        style: accountHolderName,
                                        maxLines: 6,
                                        softWrap: true,
                                      ),
                                      padding: EdgeInsets.only(
                                          top: accountHolderTopPadding),
                                    ),
                                    Text(
                                      Strings.editProfile,
                                      style: editProfile,
                                    ),
                                    Container(
                                      width: overAllWidth * 0.6,
                                      child: Text(
                                        email,
                                        style: profileContentsTextStyle,
                                        softWrap: true,
                                        maxLines: 2,
                                      ),
                                      padding:
                                      EdgeInsets.only(top: spaceTopPadding),
                                    ),
                                    Padding(
                                      child: Text(
                                        countryCode + " " + phoneNumber,
                                        style: profileContentsTextStyle,
                                      ),
                                      padding:
                                      EdgeInsets.only(top: spaceTopPadding),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.only(
                                    left: listTileLeftPadding,
                                    right: listTileLeftPadding),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(
                              top: dividerTopPadding,
                              left: dividerLeftPadding,
                              right: dividerLeftPadding),
                          child: Divider(
                            color: Uicolors.greyText,
                            thickness: 1,
                            // height: 40,
                          )),
                      Container(
                        padding: EdgeInsets.only(
                          //   bottom: dividerTopPadding
                        ),
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: accountData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                  padding: (AppUtility().isTablet(context)
                                      ? EdgeInsets.only(
                                      top: listTileTop1Padding,
                                      bottom: listTileTop1Padding)
                                      : EdgeInsets.only(top: 0)),
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        leading: Container(
                                          child: SvgPicture.asset(
                                            accountData[index].img,
                                            height: (AppUtility().isTablet(context)
                                                ? menuIconSize
                                                : menuIconSize),
                                            width: (AppUtility().isTablet(context)
                                                ? menuIconSize
                                                : menuIconSize),
                                            color: Uicolors.bottomTextColor,
                                            // fit: BoxFit.cover,
                                          ),
                                          padding: EdgeInsets.only(
                                              left: iconsListLeftPadding,
                                              right: iconsListLeftPadding),
                                          // alignment: Alignment.topCenter,
                                        ),
                                        title: Text(accountData[index].title,
                                            style: contentsListTextStyle),
                                        onTap: () async {
                                          if (accountData[index].title ==
                                              Strings.myTrips) {
                                            getBookingList();
                                          }else if (accountData[index].title ==
                                              Strings.myShortList) {
                                            pushNewScreen(
                                              context,
                                              screen: SavedListPage(),
                                              withNavBar: false,
                                              // OPTIONAL VALUE. True by default.
                                              pageTransitionAnimation:
                                              PageTransitionAnimation.cupertino,
                                            );
                                          }
                                          else if (accountData[index].title ==
                                              Strings.savedCards) {
                                            pushNewScreen(
                                              context,
                                              screen: SavedCards(),
                                              withNavBar: false,
                                              // OPTIONAL VALUE. True by default.
                                              pageTransitionAnimation:
                                              PageTransitionAnimation.cupertino,
                                            );
                                          }
                                          else if (accountData[index].title ==
                                              Strings.logout) {
                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                            prefs.remove(Strings.memberShipCode);
                                            if(GlobalState.promoCode == membershipCode&&GlobalState.offerStartStr != Strings.offers){
                                              GlobalState.promoCode="";
                                            }
                                            FirebaseAuth.instance.signOut();
                                            Navigator.of(context,
                                                rootNavigator: true)
                                                .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                    new HomeBottomBarScreen(
                                                        0) /*BottomBar()*/),
                                                    (Route<dynamic> route) =>
                                                false);
                                          }
                                          else if(accountData[index].title==Strings.preferredCurrency){
                                              final result = await Navigator.push(
                                                  context, MaterialPageRoute(builder: (_) => SwitchCurrency()));
                                              if (result != null && result) {
                                                getCurrencyCode();
                                              }
                                            }
                                        },
                                        trailing: accountData[index].trailingText !=
                                            ''
                                            ? GestureDetector(
                                          child: Stack(
                                            children: [
                                              Container(
                                                child: Text(
                                                    currencyCode,
                                                    style:
                                                    checkBoxListTextStyle),
                                                padding: EdgeInsets.only(
                                                    right:
                                                    dividerLeftPadding +
                                                        5,
                                                    top:
                                                    dropDownButtonTopPadding),
                                              ),
                                              Container(
                                                child: Icon(
                                                  Icons
                                                      .keyboard_arrow_down_sharp,
                                                  color: Uicolors.buttonbg,
                                                  size: textFieldIconSize,
                                                ),
                                                padding: EdgeInsets.only(
                                                    left:
                                                    dropDownButtonLeftPadding +
                                                        5),
                                              )
                                            ],
                                          ),
                                          onTap: () {

                                          },
                                        )
                                            : null,
                                      ),
                                    ],
                                  ));
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            padding: EdgeInsets.only(bottom: dividerTopPadding),
          )),
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Container(
        width: containerWidthPadding,
        child: Drawer(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Stack(
                  children: [
                    Container(
                      // color: Colors.black,
                      height: drawerImageHeightPadding,
                      width: containerWidthPadding,
                      // child: Text("HIIIII",),
                      child: Image.asset(
                        'assets/images/accountmenu/top-section-bg-image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: overAllHeight * 0.02,
                      child: Row(children: [
                        Container(
                            padding: EdgeInsets.only(
                                left: listTileLeftPadding,
                                right: listTileLeftPadding),
                            child: CircleAvatar(
                              radius: profileIconSize,
                              child: Material(
                                shape: CircleBorder(),
                                clipBehavior: Clip.hardEdge,
                                color: Colors.transparent,
                                child: Stack(
                                  children: [
                                    Container(
                                      color: Uicolors.buttonbg,
                                    ),
                                    Center(
                                      child: profileUrl != null &&
                                          profileUrl.length > 0
                                          ? OptimizedCacheImage(
                                        imageUrl: profileUrl,
                                        width: double.maxFinite,
                                        height: double.maxFinite,
                                        placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                              backgroundColor: Colors.transparent,
                                              valueColor: AlwaysStoppedAnimation(
                                                  Theme.of(context).primaryColor),
                                            )),
                                        //new Icon(Icons.error),
                                        fit: BoxFit.fill,
                                      )
                                          : Text(
                                        getInitials(name),
                                        style: initialNameStyle,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width:  overAllWidth*0.6,
                              child: Text(
                                name,
                                style: accountHolderName,
                                softWrap: true,
                                maxLines: 6,
                              ),
                              padding:
                              EdgeInsets.only(top: accountHolderTopPadding),
                            ),
                            GestureDetector(
                              onTap: () {
                                pushNewScreen(
                                  context,
                                  screen: EditProfilePage(),
                                  withNavBar: true,
                                  // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                                ).then((value) {
                                  inputData();
                                });
                              },
                              child: Text(
                                Strings.view + '/' + Strings.editProfile,
                                style: editWhiteProfile,
                              ),
                            ),
                          ],
                        ),
                      ]),
                      //   padding: EdgeInsets.only(top: drawerListTileTopPadding),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: drawerTopPadding),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: accountMenuData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          InkWell(
                            child:
                            Container(
                              height: (AppUtility().isTablet(context) ? 70 : 40),
                              child:
                              Row(
                                children: [
                                  Container(
                                    child: SvgPicture.asset(
                                      accountMenuData[index].img,
                                      height: (AppUtility().isTablet(context)
                                          ? menuIconSize
                                          : menuIconSize),
                                      width: (AppUtility().isTablet(context)
                                          ? menuIconSize
                                          : menuIconSize),
                                      color: Uicolors.bottomTextColor,
                                      // fit: BoxFit.cover,
                                    ),
                                    padding: EdgeInsets.only(
                                        left: imageLeftToRightPadding),
                                    // alignment: Alignment.topCenter,
                                  ),
                                  Padding(
                                    child: Text(accountMenuData[index].title,
                                        style: contentsListTextStyle),
                                    padding: EdgeInsets.only(
                                        left: imageLeftToRightPadding),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {

                              if (index == 0) {
                                pushNewScreen(
                                  context,
                                  screen: AboutUsScreen(),
                                  withNavBar:
                                  false, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                                );
                              }
                              if (index == 1) {
                                pushNewScreen(
                                  context,
                                  screen: ContactUsScreen(),
                                  withNavBar:
                                  false, // OPTIONAL VALUE. True by default.
                                  pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                                );
                              }
                            },
                          ),
                          Container(
                              padding: EdgeInsets.only(
                                // top: dividerTopPadding,
                                // left: imageLeftToRightPadding,
                                //     right: dividerLeftPadding
                              ),
                              child: Divider(
                                color: Uicolors.greyText,
                                thickness: 1,
                                // height: 40,
                              )),
                        ],
                      );
                    },
                  ),
                ),
                Center(
                    child: Column(
                      children: [
                        Container(
                          child: Image.asset(
                            'assets/images/JHG_logo.png',
                            height: 80,
                            width: 180,
                            color: Uicolors.buttonbg,
                            // fit: BoxFit.cover,
                          ),
                          padding: EdgeInsets.only(top: logoTopPadding),
                          // color: Colors.black,
                        ),
                        socialMediaList != null && socialMediaList.isNotEmpty
                            ? Container(
                          height: (AppUtility().isTablet(context) ? 70 : 50),
                          alignment: Alignment.topCenter,
                          child:
                          ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: socialMediaList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                  onTap: () {
                                    if (socialMediaList != null &&
                                        socialMediaList[index]["link"]!=null) {
                                      AppUtility().launchURL(
                                          socialMediaList[index]["link"].toString());
                                    }
                                  },
                                  child: Container(
                                    child: setIcon(index),
                                    padding: EdgeInsets.only(left: 0),
                                    // alignment: Alignment.topCenter,
                                  ));
                            },
                          ),
                        )
                            : Container()
                      ],
                    )),
              ],
            )),
      ),
    );
  }
  void getCurrencyCode() {
    AppUtility.getCurrencyCode().then((value) {
      setState(() {
        if (value != null && !value.contains("null")) {
          currencyCode = value.toString();
          GlobalState.selectedCurrency = value.toString();
        } else {
          AppUtility.saveCurrencyCode(Strings.usd);
          GlobalState.selectedCurrency = Strings.usd;
        }
      });
    });
  }
  getBookingList() async {
    EasyLoading.show();
    CollectionReference confirmBookingDetails =
    FirebaseFirestore.instance.collection('confirm_booking');
    final User? user = auth.currentUser;
    if (user != null) {
      final userId = user.uid;
      var document =
      await confirmBookingDetails.doc(userId).collection("booking").limit(10).get();
     var lastDocument;
      List bookingList = [];
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
        lastDocument = document.docs[document.docs.length - 1];
      }
      EasyLoading.dismiss();
      // await new Future.delayed(const Duration(milliseconds: 500));
      // AppUtility().dismissDialog(dialogContext!);
      pushNewScreen(
        context,
        screen: MyBookings(bookingList,lastDocument),
        withNavBar: false, // OPTIONAL VALUE. True by default.
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }
  }

  setIcon(index) {
    String assetPath = "";

    if (socialMediaList[index]["type"] == Strings.facebookLink) {
      assetPath = "assets/images/accountmenu/facebook_icon.png";
    } else if (socialMediaList[index]["type"] == Strings.instagram) {
      assetPath = "assets/images/accountmenu/instagram_icon.png";
    } else if (socialMediaList[index]["type"] == Strings.linkedin) {
      assetPath = "assets/images/accountmenu/linkedin_icon.png";
    } else if (socialMediaList[index]["type"] == Strings.twitter) {
      assetPath = "assets/images/accountmenu/twitter_icon.png";
    } else if (socialMediaList[index]["type"] == Strings.youtube) {
      assetPath = "assets/images/accountmenu/youtube_icon.png";
    }
    return Image.asset(
      assetPath,
      height: (AppUtility().isTablet(context) ? 70 : 50),
      width: (AppUtility().isTablet(context) ? 70 : 50),
      fit: BoxFit.cover,
    );
  }
}
