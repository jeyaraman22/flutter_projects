import 'package:flutter/material.dart';
import 'package:shopapp/screens/bottombar.dart';
import 'package:shopapp/screens/homescreen.dart';
import 'package:shopapp/utilities/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var mailController = TextEditingController();
  var passwordController = TextEditingController();
  var formkey = GlobalKey<FormState>();
  var token;
  var errorText;
  bool loginCheck = false;
  User? user;
  FirebaseAuth auth = FirebaseAuth.instance;


  Future signIn() async {
    final UserCredential usercredential = await auth.signInWithEmailAndPassword(email: mailController.text,
        password: passwordController.text).catchError((error){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(error.message),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
    user = await usercredential.user;
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Just Shop"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.symmetric(vertical: 200),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: mailController,
                  decoration:  InputDecoration(
                    hintText: "E-mail",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black26,
                          style: BorderStyle.solid,
                        )
                    ),
                  ),
                  validator: (value)=> Validator.validateEmail(email: value!),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration:  InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black26,
                          style: BorderStyle.solid,
                        )
                    ),
                  ),
                  validator: (value)=> Validator.validatePassword(password: value!),
                ),
                SizedBox(height: 25),

                ElevatedButton(onPressed: ()async{
                  if(formkey.currentState!.validate()){
                     await signIn().then((value) {
                      if (user != null) {
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                            BottomBar(screenNumber: 0,)), (Route<dynamic> route) => false);
                      }
                    });
                  }
                }, child: Text("LOGIN"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
