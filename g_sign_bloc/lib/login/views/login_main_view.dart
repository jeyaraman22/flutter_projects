import 'package:g_sign_bloc/home/Jaz/home_jaz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:g_sign_bloc/authenticaiton/bloc/authentication_bloc.dart';
import 'package:g_sign_bloc/home/bottomNavigation.dart';



class LoginMainView extends StatefulWidget {
  const LoginMainView({Key? key}) : super(key: key);

  @override
  State<LoginMainView> createState() => _LoginMainViewState();
}

class _LoginMainViewState extends State<LoginMainView> {

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationSuccess) {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
            BottomnavigatorScreen()), (Route<dynamic> route) => false);
          }
        },
        builder: (context, state) {
          if (state is AuthenticationInitial) {
            BlocProvider.of<AuthenticationBloc>(context)
                .add(AuthenticationStarted());
            return Center(child: CircularProgressIndicator());
          } else if (state is AuthenticationLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AuthenticationFailiure) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.purple,
                title: Text('BLoC pattern Google login'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
              BlocProvider.of<AuthenticationBloc>(context).add(
              AuthenticationGoogleStarted());
              },

                      style: OutlinedButton.styleFrom(
                        elevation: 8,
                        backgroundColor: Colors.red,
                        shadowColor: Colors.brown,
                        shape: StadiumBorder(),
                        side: BorderSide(
                            width: 2,
                            color: Colors.purpleAccent
                        ),
                      ),
                      child: const Text('Login with Google',
                        style: TextStyle(
                            color: Colors.white
                        ),),
                    ),

                  ],
                ),
              ),
            );
          }else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
