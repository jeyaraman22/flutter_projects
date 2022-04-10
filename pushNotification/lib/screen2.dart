import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SecondScreen extends StatefulWidget {
 String name = "Hello";

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
String? a;
bool b = true;
  @override
  void initState() {
    print("INIT");
    super.initState();
  }
  @override
  void didUpdateWidget(covariant SecondScreen oldWidget) {
    print("DID UPDATE WIDGET");
    print(widget.name == oldWidget.name);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    a = widget.name;
    print("BUILD");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Second--Screen"),
        backgroundColor: const Color(0xff008078),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Routing Through Notification",
                style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: 10,),
            Text("Screen--2",
                style: Theme.of(context).textTheme.headline3),
            Text( b?a!:"Flutter",style: Theme.of(context).textTheme.headline2 ,),
            TextButton(onPressed: ()=>setState(() {
              b = !b;
              widget.name = "Hey";
              print(b);
            }), child: const Text("setstate")),
          ],
        ),
      ),
    );
  }
}
