import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/currencyModel.dart';
import 'package:jaz_app/screens/onboarding/signup.dart';
import 'package:jaz_app/screens/search/search.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/FontSize.dart' as fontSize;
import 'package:jaz_app/utils/commonutils.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/http_client.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/uiconstants.dart';

import 'account.dart';
import 'booking.dart';
import 'destination/destinations.dart';
import 'offers.dart';

class HomeBottomBarScreen extends StatefulWidget {
  int currentIndex;
  HomeBottomBarScreen(this.currentIndex);
  @override
  State<StatefulWidget> createState() => _HomeBottomBarScreenState();
}

class _HomeBottomBarScreenState extends State<HomeBottomBarScreen> {
  int _currentIndex = 0;
  late Function hp;
  HttpClient _httpClient = HttpClient();

  void initState() {
    if (widget.currentIndex != null) {
      _currentIndex = widget.currentIndex;

      //_currentIndex = widget.currentIndex;
      getCurrencyCode();
    }
  }

  void getCurrencyCode() {
    AppUtility.getCurrencyCode().then((value) {
      if (value != null && !value.contains("null")) {
        GlobalState.selectedCurrency = value.toString();
      } else {
        AppUtility.saveCurrencyCode(Strings.usd);
        GlobalState.selectedCurrency = Strings.usd;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // _controller.index = GlobalState.tabindex;
    hp = Screen(MediaQuery.of(context).size,MediaQuery.of(context).orientation).hp;
    return Scaffold(
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
        backgroundColor: Uicolors.backBorderColor,
        selectedItemColor: Uicolors.buttonbg,
        unselectedItemColor: Uicolors.bottomTextColor,
        items: [
          BottomNavigationBarItem(
              backgroundColor:
                  _currentIndex == 0 ? Colors.white : Uicolors.backBorderColor,
              icon: Container(
                padding: EdgeInsets.all(0),
                child: Column(
                  children: [
                    Image.asset(
                      _currentIndex == 0
                          ? "assets/images/active_search.png"
                          : "assets/images/search.png",
                      height: hp(fontSize.FontSize.size25),
                      width: hp(fontSize.FontSize.size25),
                    ),
                    SizedBox(
                      height: AppUtility().isTablet(context) ? 10 : 5,
                    ),
                    Text(
                      Strings.search,
                      style: TextStyle(
                          fontSize: hp(fontSize.FontSize.size13),
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
          BottomNavigationBarItem(
              backgroundColor:
                  _currentIndex == 1 ? Colors.white : Uicolors.backBorderColor,
              icon: Container(
                padding: EdgeInsets.all(0),
                child: Column(
                  children: [
                    Image.asset(
                      _currentIndex == 1
                          ? "assets/images/offer-active.png"
                          : "assets/images/offer.png",
                      height: hp(fontSize.FontSize.size25),
                      width: hp(fontSize.FontSize.size25),
                    ),
                    SizedBox(
                      height: AppUtility().isTablet(context) ? 10 : 5,
                    ),
                    Text(
                      Strings.offers,
                      style: TextStyle(
                          fontSize: hp(fontSize.FontSize.size13),
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
          BottomNavigationBarItem(
              backgroundColor:
                  _currentIndex == 2 ? Colors.white : Uicolors.backBorderColor,
              icon: Container(
                padding: EdgeInsets.all(0),
                child: Column(
                  children: [
                    Image.asset(
                      _currentIndex == 2
                          ? "assets/images/destination_active.png"
                          : "assets/images/destination.png",
                      height: hp(fontSize.FontSize.size25),
                      width: hp(fontSize.FontSize.size25),
                    ),
                    SizedBox(
                      height: AppUtility().isTablet(context) ? 10 : 5,
                    ),
                    Text(
                      Strings.destinations,
                      style: TextStyle(
                          fontSize: hp(fontSize.FontSize.size13),
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
          BottomNavigationBarItem(
              backgroundColor:
                  _currentIndex == 3 ? Colors.white : Uicolors.backBorderColor,
              icon: Container(
                padding: EdgeInsets.all(0),
                child: Column(
                  children: [
                    Image.asset(
                      _currentIndex == 3
                          ? "assets/images/account_active.png"
                          : "assets/images/account_inactive.png",
                      height: hp(fontSize.FontSize.size25),
                      width: hp(fontSize.FontSize.size25),
                    ),
                    SizedBox(
                      height: AppUtility().isTablet(context) ? 10 : 5,
                    ),
                    Text(
                      Strings.account,
                      style: TextStyle(
                          fontSize: hp(fontSize.FontSize.size13),
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
              ))
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  getSelectedWidget(int index) {
    switch (index) {
      case 0:
        return Search(onBack: onBackMethod);
      case 1:
        return Offers(onBack: onBackMethod);
      case 2:
        return Destination();
      case 3:
        return Account("bottom");
    }
    return Container();
  }

  onBackMethod(str) {
    setState(() {
      _onItemTapped(int.parse(str));
      getSelectedWidget(int.parse(str));
    });
  }
}
