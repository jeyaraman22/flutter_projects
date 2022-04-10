import 'package:flutter/material.dart';

class CustomSnackBar{
  CustomSnackBar();
  static responseSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message)));
  }

  static errorSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message)));
  }
}