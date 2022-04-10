import 'package:flutter/material.dart';
import 'package:shopapp/screens/homescreen.dart';
import 'package:shopapp/screens/myproductscreen.dart';
import 'package:shopapp/screens/orderscreen.dart';

class BottomBar extends StatefulWidget {
  int screenNumber;
  BottomBar({required this.screenNumber});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int screen = 0;
  List screens = [
    MyHomePage(),
    MyproductScreen(),
    MyOrderScreen()
  ];

  void onItemTap(int index) {
    setState(() {
      screen = index;
    });
  }

  @override
  void initState() {
    super.initState();
    screen = widget.screenNumber;
  }

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
        child: Scaffold(
        body: Center(
          child: screens.elementAt(screen),
        ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            iconSize: 27.0,
            currentIndex: screen,
            onTap: onItemTap,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_sharp),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.view_module_sharp),
                label: 'My product',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shop_two_sharp),
                label: 'My Orders',
              ),
            ],
          ),
    ),
    );
  }
}
