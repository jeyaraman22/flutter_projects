import 'package:flutter/material.dart';

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Third--Screen"),
        backgroundColor: const Color(0xff008078),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Routing Through Notification",
                style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: 10,),
            Text("Screen--3",
                style: Theme.of(context).textTheme.headline3)
          ],
        ),
      ),
    );
  }
}
