import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'bouncingscrolleffect.dart';
import 'text_embedded.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'How to overlap SliverList on a SliverAppBar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TextEmbedded(),
    );
  }
}