import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sample_ui/screens/addrooms.dart';
import 'package:sample_ui/screens/editscreen.dart';

import 'loginscreen.dart';
import 'multipleroom.dart';
import 'overview.dart';

class MyHomePage extends StatefulWidget {
 int screenNumber;
 MyHomePage({required this.screenNumber});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int screen = 0;
  List screens = [
    OverviewScreen(),
    MultipleroomScreen(),
    RoomTypes(),
    EditScreen()
  ];

  void onItemTap(int index) {
    setState(() {
      screen = index;
    });
  }

  @override
  void initState() {
    screen = widget.screenNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 90,
          elevation: 0.1,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Padding(padding: EdgeInsets.only(left: 20)),
                            GestureDetector(
                              onTap: () {},
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xff606060),
                                size: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                "Back",
                                style: TextStyle(
                                    color: Color(0xff606060),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 60),
                          child: Text(
                            "Welcome to Solymar Ivory Suites",
                            style: TextStyle(
                              //fontFamily: 'ProximaNova',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff008078)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: const Color(0xff211942),
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Thu 06 Jan - Sun 06 Jan ( 3 nights )",
                                style: TextStyle(
                                    color: Color(0xffFFFFFF),
                                    fontFamily: 'ProximaNova'),
                              ),
                              SizedBox(height: 3),
                              Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: Text("2 Persons - 1 Room",
                                    style: TextStyle(
                                        color: Color(0xffFFFFFF),
                                        fontFamily: 'ProximaNova')),
                              )
                            ],
                          ),
                           Padding(
                            padding: const EdgeInsets.only(left: 63, top: 15),
                            child: GestureDetector(
                              onTap: (){
                                showDialog(context: context, builder:(BuildContext context){
                                  return AlertDialog(
                                    title: const Text("want to Logout"),
                                    actions: [
                                      TextButton(onPressed: () async{
                                        await FirebaseAuth.instance.signOut();
                                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                                            const LoginScreen()), (Route<dynamic> route) => false);
                                      }, child: const Text("yes"),),
                                      TextButton(onPressed: () => Navigator.pop(context),
                                        child: const Text("No"),)
                                    ],
                                  );
                                });
                              },
                              child: const Text("Tap to modify",
                                  style: TextStyle(
                                      color: Colors.transparent,
                                      //fontFamily: 'ProximaNova',
                                      shadows: [
                                        Shadow(
                                            offset: Offset(0, -1.5),
                                            color: Color(0xffFFFFFF))
                                      ],
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationStyle: TextDecorationStyle.solid,
                                      decorationColor: Colors.white,
                                      decorationThickness: 2.5)
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
        body: screens.elementAt(screen),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          iconSize: 25.0,
          selectedItemColor: Color(0xff008078),
          currentIndex: screen,
          onTap: onItemTap,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.table_view_outlined),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.room_preferences_outlined),
              label: 'Rooms',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_activity_outlined),
              label: 'Activities',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.surround_sound_outlined),
              label: 'Surrondings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_dining_outlined),
              label: 'Dining',
            ),
          ],
        ),
      ),
    );
  }
}