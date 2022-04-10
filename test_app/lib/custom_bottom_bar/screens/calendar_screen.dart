import 'package:flutter/material.dart';
import 'package:test_app/custom_bottom_bar/service/navigator_channel.dart';
import 'package:test_app/custom_bottom_bar/screens/new_screen.dart';
import 'package:test_app/custom_bottom_bar/utils/constants.dart';

class CalendarPage extends StatelessWidget with NavigationChannel{
  const CalendarPage({Key? key}) : super(key: key);

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppBarStrings.calendar),
      ),
      body: Container(
        color: Colors.red,
        child: Center(
          child: ElevatedButton(
            onPressed: (){
             navigatorChannel(context, screen: const NewScreen(),haveBottomBar: true);
            },
            child: Text(Strings.goTo),
          ),
        ),
      ),
    );
  }
}
