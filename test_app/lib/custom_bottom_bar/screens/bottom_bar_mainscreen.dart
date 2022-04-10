import 'package:flutter/material.dart';
import 'package:test_app/custom_bottom_bar/screens/profile_screen.dart';
import 'package:test_app/custom_bottom_bar/utils/constants.dart';
import 'calendar_screen.dart';
import 'home_screen.dart';

class BottomBarMainScreen extends StatefulWidget {
  const BottomBarMainScreen({Key? key}) : super(key: key);
  @override
  _BottomBarMainScreenState createState() => _BottomBarMainScreenState();
}

class _BottomBarMainScreenState extends State<BottomBarMainScreen> {
  int selectedIndex = BottomBarConstants.selectedIndex;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
  ];

  List<Widget> screens = [
    const HomePage(),
    const CalendarPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(selectedIndex>0){
          setState(() {
            selectedIndex=0;
          });
          return false;
        }else{
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items:  [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: PickColor.brown,
                size: BottomBarConstants.iconSize,
              ),
              label: Strings.home,
              activeIcon: Icon(
                Icons.home,
                color: PickColor.purple,
                size: BottomBarConstants.iconSize,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.calendar_today,
                color: PickColor.brown,
                size: BottomBarConstants.iconSize,
              ),
              label: Strings.calendar,
              activeIcon: Icon(
                Icons.calendar_today,
                color: PickColor.purple,
                size: BottomBarConstants.iconSize,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: PickColor.brown,
                size: BottomBarConstants.iconSize,
              ),
              label: Strings.profile,
              activeIcon: Icon(
                Icons.person,
                color: PickColor.purple,
                size: BottomBarConstants.iconSize,
              ),
            ),
          ],
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
        body: Column(
          children: [
            Expanded(child: buildNavigator(screens[selectedIndex],selectedIndex)
            ),
          ],
        )

      ),
    );
  }

  /// This widget purpose is to locate the screen in stack design
  /// like Navigator's base pattern(stack-based history of child widgets)

  Widget buildNavigator(Widget screen, int index){
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => screen);
        }
    );
  }
}