import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shopapp/screens/addproduct.dart';
import 'package:shopapp/screens/bottombar.dart';
import 'package:shopapp/screens/detailscreen.dart';
import 'package:shopapp/screens/loginscreen.dart';
import 'package:shopapp/services/productmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shopapp/screens/cartscreen.dart';
import 'package:shopapp/screens/homescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
  configLoading();
}


void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
  // ..customAnimation = CustomAnimation();
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.blue
        )
      ),
      home: resultScreen(),
      builder: EasyLoading.init(),
    );
  }
  Widget resultScreen(){
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot){
          if(snapshot.hasData){
            return BottomBar(screenNumber: 0);
          }else{
            return const LoginScreen();
          }
    });
  }
}


