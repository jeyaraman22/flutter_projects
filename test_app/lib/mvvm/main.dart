/// Coded By -- Jeyaraman K

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/mvvm/view/mvvm_mainscreen.dart';
import 'package:test_app/mvvm/view_model/user_list_view_model.dart';

void main(){
  return runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(),
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MainScreen(),
      ),
    );
  }
}
