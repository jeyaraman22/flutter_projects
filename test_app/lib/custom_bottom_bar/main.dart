import 'package:flutter/material.dart';
import 'package:test_app/custom_bottom_bar/screens/bottom_bar_mainscreen.dart';

void main(){
  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BottomBarMainScreen(),
    );
  }
}
