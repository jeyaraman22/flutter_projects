import 'package:fb_signin/newscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async{
  runApp(const MyApp());
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 bool loginCheck = false;
 Map userDetails = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FLUTTER FACEBOOK AUTH"),
        actions: [
          IconButton(onPressed:()=> Navigator.push(context,
              MaterialPageRoute(builder: (context)=>const SecondScreen())),
              icon: const Icon(Icons.forward),)
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  <Widget>[
            ElevatedButton(
              onPressed:()async{
                print("FACEBOOK LOGIN>>>");
               final fbResults = await FacebookAuth.i.login();

               // permissions: ['email','public_prodile']
               if(fbResults.status == LoginStatus.success) {
                 FacebookAuth.i.getUserData().then((user){
                   setState(() {
                     userDetails = user;
                   });
                 });
                 final AuthCredential fbCredential = FacebookAuthProvider
                     .credential(fbResults.accessToken!.token);
                 var userData = await FirebaseAuth.instance
                     .signInWithCredential(fbCredential);
                 setState(() {
                   loginCheck = true;
                 });
               }else{
                 print("Problem in FB-Login");
               }
              },
              child:Text("FACEBOOK...Login"),
            ),
            SizedBox(height: 15,),
            loginCheck?Container(
              height: 100,
              child: SizedBox(
                height: 200,
                width: 200,
                child: Center(child: Column(
                  children: [
                    Expanded(child:
                    Image.network(userDetails["picture"]["data"]["url"],
                    scale: 1.2,)),
                    Text("UserName:${userDetails['name']}"),
                  ],
                )),
              ),
            ):Container(),
            SizedBox(height: 15,),
            ElevatedButton(
              onPressed:()async{
                print("FACEBOOK LOGOUT<<<");
                FacebookAuth.i.logOut().then((value){
                  setState(() {
                    loginCheck = false;
                  });
                  print("USER  -  LOGOUT");
                });
              },
              child:Text("Logout"),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
