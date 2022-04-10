import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:g_sign_bloc/home/bottomNavigation.dart';
import 'package:g_sign_bloc/login/views/login_main_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'app/observers/app_bloc_observer.dart';
import 'authenticaiton/bloc/authentication_bloc.dart';
import 'authenticaiton/data/providers/authentication_firebase_provider.dart';
import 'authenticaiton/data/providers/google_sign_in_provider.dart';
import 'authenticaiton/data/repositories/authenticaiton_repository.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Bloc.observer = AppBlocObserver();
  runApp(BlocPattern());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
   // ..customAnimation = CustomAnimation();
}


class BlocPattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthenticationBloc(
        authenticationRepository: AuthenticationRepository(
          authenticationFirebaseProvider: AuthenticationFirebaseProvider(
            firebaseAuth: FirebaseAuth.instance,
          ),
          googleSignInProvider: GoogleSignInProvider(
            googleSignIn: GoogleSignIn(),
          ),
        ),
      ),
      child: MaterialApp(
        home: /*BottomnavigatorScreen()*/LoginMainView(),
        builder: EasyLoading.init(),
      ),
    );
  }
}
