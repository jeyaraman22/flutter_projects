import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:graphql/client.dart';


void main() {
  runApp(const MyApp());
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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Link link = HttpLink(
    "https://middleware.jaz.cloud.fcse.io/",
    defaultHeaders: {"Authorization": "Basic amF6eno6WWhEM3JPeXhZcjk3NkxyNw==",
      "accept-language": "en-gb"},
  );
 String a ='';
  @override
  initState(){
    super.initState();
    a = link.toString();
    print("initstate");
    print("LINK--");
    print("LINK--${a.length}");
  }
  @override
  didChangeDependencies(){
    print("didChangeDependencies");
    super.didChangeDependencies();
  }

  String deviceName ='';

  Future getdeviceModel() async{
  DeviceInfoPlugin deviceInfo =  DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var build = await deviceInfo.androidInfo;
        setState(() {
          deviceName = build.brand.toString();
        });
          print("DEVICE MODEL--${build.brand!}");
      } else if (Platform.isIOS) {
        var data = await deviceInfo.iosInfo;
        print("DEVICE MODEL--${data.name!}");
      }
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: ()=>getdeviceModel(),
              child: const Text("Device Details",
                style: TextStyle(color: Colors.white),),
            ),
             deviceName.isNotEmpty ?
            Column(
              children: [
                const SizedBox(height: 20,),
                Text("Device Name:- "+deviceName,style: const TextStyle
                  (fontWeight: FontWeight.bold)),
              ],
            ): Container(),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );

  }
}
