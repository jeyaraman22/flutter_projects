import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  bool fbcheck = false;
  var profileInfo;
  User? loggeduser;
  final FacebookLogin facebookSignIn = FacebookLogin();

  facebookSignin()async{
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        // BuildContext? dialogContext;
        // AppUtility().showProgressDialog(context,type:null,dismissDialog:(value){
        //   dialogContext = value;
        // });
        final FacebookAccessToken accessToken = result.accessToken;
        AuthCredential credential =
        FacebookAuthProvider.credential(result.accessToken.token);
        final User? user =
            (await FirebaseAuth.instance.signInWithCredential(credential)).user;
        print("----USER---$user");
        var userName = "";
        if(user?.providerData!=null&&user?.providerData.length!=0&&user?.providerData[0].displayName!=null){
          userName = user!.providerData[0].displayName.toString();
          print("loggedIN,,");
          setState(() {
            fbcheck = true;
          });
          loggeduser = user;
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
      // _showMessage('Login cancelled by the user.');
        print('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
      /*_showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');*/
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FLUTTER FACEBOOK LOGIN"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed:()async{
                  // final facebookLogin = FacebookLogin();
                  // final result = await facebookLogin.logIn(['email']).then((value) async{
                  //   print("access token${value.accessToken.token}");
                  //   var apiResult = await http.get(Uri.parse('https://graph.facebook.com/v12.0/me?fields=id,name,first_name,'
                  //       'last_name,picture.height(100),email&access_token=${value.accessToken.token}'));
                  //    profileInfo = jsonDecode(apiResult.body);
                  //   print("---------$profileInfo");
                  //   if(value.status == FacebookLoginStatus.loggedIn){
                  //     setState(() {
                  //       fbcheck = true;
                  //     });
                  //   }
                  // });
                  facebookSignin();
                    // var apiResult = await http.get(Uri.parse('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,'
                    //     'email&access_token=${value.accessToken.token}'));
                    // var profileInfo = jsonDecode(apiResult.body);
                    // print("---------$profileInfo");

                },
                child: Text("Facebook Login")),
            fbcheck? Center(child:
            Column(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                        loggeduser!.photoURL!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15,),
                Text("username:${loggeduser!.displayName}")
              ],
            ),
            ):Container(),
            ElevatedButton(
                onPressed:()async{
                  await FacebookLogin().logOut().then((value){
                    setState(() {
                      fbcheck = false;
                    });
                  });
                },
                child: Text("Logout")),
          ],
        ),
      ),
    );
  }
}
