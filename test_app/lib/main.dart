import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/crud_bloc/bloc_model/bloc_main.dart';
import 'package:test_app/crud_bloc/screen/homescreen.dart';
import 'package:test_app/crud_bloc/validation_bloc/validator_bloc_event.dart';
import 'package:test_app/crud_bloc/validation_bloc/validator_main_bloc.dart';
import 'package:test_app/custom_bottom_bar/screens/bottom_bar_mainscreen.dart';
import 'package:test_app/custom_bottom_bar/screens/home_screen.dart';
import 'package:test_app/multipledropdown/widgets/dropdownform.dart';
import 'package:test_app/multipledropdown/screen/multipledropdown.dart';
import 'package:test_app/mvvm/view/mvvm_mainscreen.dart';
import 'package:test_app/mvvm/view_model/user_list_view_model.dart';
import 'package:test_app/single_multi_file_pickers/file_pickers_mainscreen.dart';
import 'crud_bloc/bloc_model/bloc_event.dart';
import 'crud_bloc/crud_bloc_model/bloc_modelclass.dart';
import 'customTreeview/widgets/custom_tree_view_widgets/customnode.dart';
import 'customTreeview/widgets/custom_tree_view_widgets/customtreeviewcontroller.dart';
import 'custom_bottom_bar/screens/new_screen.dart';
import 'maps_markers/mapscreen.dart';
import 'package:provider/provider.dart';

void main() {
  BlocOverrides.runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    return runApp(const MyApp());
  }, blocObserver: AppBlocObserver());
  //runApp(const MyApp());
}

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) {}
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(),
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MainScreen(),
      ),
    );

    /// The below code is for Crud_bloc implementation...


    //   MultiBlocProvider(
    //   providers: [
    //     BlocProvider(
    //         create: (context)=> ProductBloc()..add(GetProductEvent())),
    //     BlocProvider(
    //         create: (context)=> ValidationBloc()..add(InitialValidationEvent()))
    //   ],
    //   child: MaterialApp(
    //     title: 'Flutter Demo',
    //     theme: ThemeData(
    //       primarySwatch: Colors.blue,
    //     ),
    //   home: const FilePickerMainScreen(),
    //   ),
    // );
  }
}

