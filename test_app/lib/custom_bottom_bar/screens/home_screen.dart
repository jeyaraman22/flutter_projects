import 'package:flutter/material.dart';
import 'package:test_app/custom_bottom_bar/service/navigator_channel.dart';
import 'package:test_app/custom_bottom_bar/screens/new_screen.dart';
import 'package:test_app/custom_bottom_bar/utils/constants.dart';
import 'package:test_app/custom_bottom_bar/utils/height_width.dart';

class HomePage extends StatelessWidget with NavigationChannel{
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppBarStrings.home),
      ),
      body: Container(
        width: Layout.infinity,
        color: PickColor.green,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                Strings.homeScreen,
                style: TextStyle(
                    color: PickColor.white,
                    fontSize: 20
                ),
              ),
              margin: Layout.homeMargin,
            ),
            ElevatedButton(
              onPressed: () {
                navigatorChannel(context, screen:const NewScreen(),haveBottomBar:false);
              },
              child: Text(Strings.goTo),
            ),
          ],
        ),
      ),
    );
  }
}
