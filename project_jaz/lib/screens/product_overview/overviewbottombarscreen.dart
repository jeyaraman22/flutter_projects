import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/screens/homebottombar.dart';
import 'package:jaz_app/screens/product_overview/selectroom.dart';
import 'package:jaz_app/screens/product_overview/surroundings.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/facebookevents.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/http_client.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/FontSize.dart' as fontSize;
import 'package:shared_preferences/shared_preferences.dart';

import 'hotel_details.dart';

class OverviewBottombarScreen extends StatefulWidget {
  // final BuildContext overViewBottomBarContext;
  final int index;
  final ProductsQuery$Query$Products$PackageProducts product;
  //OverViewBottomBar(this.index,this.product);
  HashMap<String, String> listPage;
  String description;
  List expansionList;
  OverviewBottombarScreen(this.index, this.listPage, this.product,
      this.description, this.expansionList);
  _OverviewBottombarScreen createState() => _OverviewBottombarScreen();
}

class _OverviewBottombarScreen extends State<OverviewBottombarScreen> {
  var product;
  // var index = 0;
  PersistentTabController _controller = PersistentTabController();
  HttpClient httpClient = HttpClient();
  HashMap<String, String> listPage = HashMap();
  String productId = "0";
  late Function hp;
  String description = "";
  List expansionList = [];
  int _currentIndex = 0;

  @override
  void dispose() {
    super.dispose();
    GlobalState.overViewTabIndex = 0;
  }

  void initState() {
    super.initState();
    description = widget.description;
    expansionList = widget.expansionList;
    product = widget.product;
    productId = widget.product.hotel!.giataId.toString();
    var startDate = GlobalState.checkInDate;
    var endDate = GlobalState.checkOutDate;
    var roomDetails = GlobalState.selectedRoomList;
    FacebookEvents().viewedContentEvent(widget.product.hotelContent!.crsCode.toString(),startDate,endDate,
        AppUtility().getNumberOfPerson(roomDetails),roomDetails.length.toString(),
        AppUtility().getNumberOfNight(startDate, endDate),
        GlobalState.promoCode);

    if (GlobalState.overViewTabIndex != null) {
      _currentIndex = GlobalState.overViewTabIndex;
    }
    setState(() {
      _currentIndex = _currentIndex;
      listPage = widget.listPage.isNotEmpty ? widget.listPage : HashMap();
    });
    removeGuestPreference();
    _controller = PersistentTabController(initialIndex: 0);
  }

  removeGuestPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("loginType");
  }

  Future<bool> _willPopCallback() async {
    Navigator.pop(context); // await showDialog or Show add banners or whatever
    // then
    return true;
  }

  @override
  Widget build(BuildContext context) {
    hp = Screen(MediaQuery.of(context).size, MediaQuery.of(context).orientation)
        .hp;
    var backTopSpace = 0.0;
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var topSpace =
        overAllHeight * (AppUtility().isTablet(context) ? 0.05 : 0.04);

    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        backgroundColor: Uicolors.backgroundColor,
        appBar: AppBar(
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
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                        margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.010,
                            left: 10,
                            top: backTopSpace),
                        child: Text(
                          "Welcome to ${product.hotel!.name != null ? product.hotel!.name : ""}",
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 1,
                          style: welcomJazStyle,
                        )),
                  ),
                ),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(topSpace),
            child: Container(
              //   height: MediaQuery.of(context).size.height * 0.055,
              color: Uicolors.appbarBlueBg,
              width: MediaQuery.of(context).size.width * 1,
              child: Column(
                children: <Widget>[
                  Container(
                    // margin: EdgeInsets.only(right: 28,left: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.030,
                              top: MediaQuery.of(context).size.height * 0.008,
                              bottom:
                                  MediaQuery.of(context).size.height * 0.008),
                          child: Column(
                            children: [
                              Text(
                                AppUtility().getDateDiff(
                                        GlobalState.checkInDate,
                                        GlobalState.checkOutDate) +
                                    "\n" +
                                    " " +
                                    GlobalState.personDetails,
                                style: timeDetailsStyle,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            GlobalState.destinationString =
                                product.hotel!.name.toString();
                            GlobalState.destinationValue = productId;
                            Navigator.of(context, rootNavigator: true)
                                .pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            new HomeBottomBarScreen(0)),
                                    (Route<dynamic> route) => false);
                          },
                          child: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(
                                right:
                                    MediaQuery.of(context).size.width * 0.030,
                                top:
                                    MediaQuery.of(context).size.height * 0.004),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                child: Text(
                                  Strings.tapToModify,
                                  style: tabToModifyStyle,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        body: Container(
          child: getSelectedWidget(_currentIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onItemTapped,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: Uicolors.buttonbg,
          unselectedItemColor: Uicolors.bottomTextColor,
          items: [
            if (listPage.isNotEmpty || listPage.isEmpty)
              BottomNavigationBarItem(
                  backgroundColor: _currentIndex == 0
                      ? Colors.white
                      : Uicolors.backBorderColor,
                  icon: Container(
                    padding: EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Image.asset(
                          _currentIndex == 0
                              ? "assets/images/overview.png"
                              : "assets/images/overviewactive.png",
                          height: hp(fontSize.FontSize.size25),
                          width: hp(fontSize.FontSize.size25),
                          color: _currentIndex == 0
                              ? Uicolors.buttonbg
                              : Uicolors.bottomTextColor,
                        ),
                        SizedBox(
                          height: AppUtility().isTablet(context) ? 10 : 5,
                        ),
                        Text(
                          Strings.overview,
                          style: TextStyle(
                              fontSize: hp(fontSize.FontSize.size12),
                              color: _currentIndex == 0
                                  ? Uicolors.buttonbg
                                  : Uicolors.bottomTextColor),
                        )
                      ],
                    ),
                  ),
                  title: Text(
                    "",
                    style: TextStyle(fontSize: hp(fontSize.FontSize.size13)),
                  )),
            if (listPage.isNotEmpty || listPage.isEmpty)
              BottomNavigationBarItem(
                  backgroundColor: _currentIndex == 1
                      ? Colors.white
                      : Uicolors.backBorderColor,
                  icon: Container(
                    padding: EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Image.asset(
                            _currentIndex == 1
                                ? "assets/images/roomactive.png"
                                : "assets/images/rooms.png",
                            height: hp(fontSize.FontSize.size25),
                            width: hp(fontSize.FontSize.size25),
                            color: _currentIndex == 1
                                ? Uicolors.buttonbg
                                : Uicolors.bottomTextColor),
                        SizedBox(
                          height: AppUtility().isTablet(context) ? 10 : 5,
                        ),
                        Text(
                          Strings.room,
                          style: TextStyle(
                              fontSize: hp(fontSize.FontSize.size12),
                              color: _currentIndex == 1
                                  ? Uicolors.buttonbg
                                  : Uicolors.bottomTextColor),
                        )
                      ],
                    ),
                  ),
                  title: Text(
                    "",
                    style: TextStyle(fontSize: hp(fontSize.FontSize.size13)),
                  )),
            if (listPage.isNotEmpty)
              BottomNavigationBarItem(
                  backgroundColor: _currentIndex == 2
                      ? Colors.white
                      : Uicolors.backBorderColor,
                  icon: Container(
                    padding: EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Image.asset(
                            _currentIndex == 2
                                ? "assets/images/activityactive.png"
                                : "assets/images/activities.png",
                            height: hp(fontSize.FontSize.size25),
                            width: hp(fontSize.FontSize.size25),
                            color: _currentIndex == 2
                                ? Uicolors.buttonbg
                                : Uicolors.bottomTextColor),
                        SizedBox(
                          height: AppUtility().isTablet(context) ? 10 : 5,
                        ),
                        Text(
                          Strings.activities,
                          style: TextStyle(
                              fontSize: hp(fontSize.FontSize.size12),
                              color: _currentIndex == 2
                                  ? Uicolors.buttonbg
                                  : Uicolors.bottomTextColor),
                        )
                      ],
                    ),
                  ),
                  title: Text(
                    "",
                    style: TextStyle(fontSize: hp(fontSize.FontSize.size13)),
                  )),
            if (listPage.isNotEmpty)
              BottomNavigationBarItem(
                  backgroundColor: _currentIndex == 3
                      ? Colors.white
                      : Uicolors.backBorderColor,
                  icon: Container(
                    padding: EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Image.asset(
                            _currentIndex == 3
                                ? "assets/images/surroundingactive.png"
                                : "assets/images/surrounding.png",
                            height: hp(fontSize.FontSize.size25),
                            width: hp(fontSize.FontSize.size25),
                            color: _currentIndex == 3
                                ? Uicolors.buttonbg
                                : Uicolors.bottomTextColor),
                        SizedBox(
                          height: AppUtility().isTablet(context) ? 10 : 5,
                        ),
                        Text(
                          Strings.surrounding,
                          style: TextStyle(
                              fontSize: hp(fontSize.FontSize.size12),
                              color: _currentIndex == 3
                                  ? Uicolors.buttonbg
                                  : Uicolors.bottomTextColor),
                        )
                      ],
                    ),
                  ),
                  title: Text(
                    "",
                    style: TextStyle(fontSize: hp(fontSize.FontSize.size13)),
                  )),
            if (listPage.isNotEmpty)
              BottomNavigationBarItem(
                  backgroundColor: _currentIndex == 4
                      ? Colors.white
                      : Uicolors.backBorderColor,
                  icon: Container(
                    padding: EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Image.asset(
                            _currentIndex == 4
                                ? "assets/images/dining-active.png"
                                : "assets/images/dining-normal.png",
                            height: hp(fontSize.FontSize.size25),
                            width: hp(fontSize.FontSize.size25),
                            color: _currentIndex == 4
                                ? Uicolors.buttonbg
                                : Uicolors.bottomTextColor),
                        SizedBox(
                          height: AppUtility().isTablet(context) ? 10 : 5,
                        ),
                        Text(
                          Strings.dining,
                          style: TextStyle(
                              fontSize: hp(fontSize.FontSize.size12),
                              color: _currentIndex == 4
                                  ? Uicolors.buttonbg
                                  : Uicolors.bottomTextColor),
                        )
                      ],
                    ),
                  ),
                  title: Text(
                    "",
                    style: TextStyle(fontSize: hp(fontSize.FontSize.size13)),
                  )),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      GlobalState.overViewTabIndex = index;
    });
  }

  getSelectedWidget(int index) {
    switch (index) {
      case 0:
        return HotelDetails(
            product,
            productId,
            listPage.isEmpty
                ? "OverView"
                : listPage["Resort Overview"].toString(),
            description,
            expansionList, onBack: (str) {
          print(str);
          setState(() {
            _onItemTapped(int.parse(str));
            getSelectedWidget(int.parse(str));
          });
        });
      case 1:
        return SelectRoom(product, onBack: (str) {
          print(str);
          setState(() {
            _onItemTapped(int.parse(str));
            getSelectedWidget(int.parse(str));
          });
        });
      case 2:
        return Surrounding(
            product,
            productId,
            listPage[listPage.keys.singleWhere(
                    (element) =>
                        element.toString().toLowerCase().contains("sports"),
                    orElse: () => "")]
                .toString(),
            "Sports & Activities");
      case 3:
        return Surrounding(product, productId,
            listPage["Surroundings"].toString(), "Surroundings");
      case 4:
        return Surrounding(
            product, productId, listPage["Dining"].toString(), "Dining");
    }
    return Container();
  }
}
