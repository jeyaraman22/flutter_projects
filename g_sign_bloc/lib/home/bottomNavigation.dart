import 'package:flutter/material.dart';
import 'package:g_sign_bloc/constatnts/spaces.dart';
import 'package:g_sign_bloc/home/views/UserProfile/userprofilelist.dart';
import 'package:g_sign_bloc/home/views/locationscreen.dart';
import 'package:g_sign_bloc/home/views/profile.dart';
import 'package:g_sign_bloc/home/views/serachScreen.dart';
import 'Jaz/home_jaz.dart';

class BottomnavigatorScreen extends StatefulWidget {
  const BottomnavigatorScreen({Key? key}) : super(key: key);

  @override
  _BottomnavigatorScreenState createState() => _BottomnavigatorScreenState();
}

class _BottomnavigatorScreenState extends State<BottomnavigatorScreen> {
  List screens = [
    SearchitemScreen(),
    LocationScreen(),
    HomeScreen(),
   ];

  void onItemTap(int index) {
    if(index != 3){
      setState(() {
        Bottomindex.selectedIndex = index;
      });
    }else{
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => profileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: screens.elementAt(Bottomindex.selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          iconSize: 36.0,
          currentIndex: Bottomindex.selectedIndex,
          selectedItemColor: Color(0xff487E79),
          onTap: onItemTap,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.filter_tilt_shift_outlined),
              label: 'Offers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes_rounded),
              label: 'Destination',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
