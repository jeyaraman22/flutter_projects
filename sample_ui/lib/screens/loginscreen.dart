import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sample_ui/screens/bottombar.dart';
import 'package:sample_ui/utilities/validators.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var mailController = TextEditingController();
  var passwordController = TextEditingController();
  var formkey = GlobalKey<FormState>();
  // var token;
  // var errorText;
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
              title: const Text("Error"),
              content: Text(error.message),
              actions: [
                TextButton(
                  child: const Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
    user = usercredential.user;
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
        backgroundColor: const Color(0xff211942),
        title: const Text("JAZ Hotels"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(vertical: 200),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: mailController,
                  decoration:  const InputDecoration(
                    hintText: "E-mail",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff211942),
                        style: BorderStyle.solid
                      )
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black26,
                          style: BorderStyle.solid,
                        )
                    ),
                  ),
                  validator: (value)=> Validator.validateEmail(email: value!),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration:  const InputDecoration(
                    hintText: "Password",
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xff211942),
                            style: BorderStyle.solid
                        )
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black26,
                          style: BorderStyle.solid,
                        )
                    ),
                  ),
                  validator: (value)=> Validator.validatePassword(password: value!),
                ),
                const SizedBox(height: 25),

                ElevatedButton(onPressed: ()async{
                  if(formkey.currentState!.validate()){
                     await signIn().then((value) {
                      if (user != null) {
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                            MyHomePage(screenNumber: 0,)), (Route<dynamic> route) => false);
                      }
                    });
                  }
                },
                    style: ElevatedButton.styleFrom(primary: Colors.cyan),
                    child: const Text("LOGIN",style: TextStyle(color: Color(0xff211942)),))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
