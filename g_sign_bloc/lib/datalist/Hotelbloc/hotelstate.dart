import 'package:equatable/equatable.dart';
import 'package:g_sign_bloc/datalist/modelclass.dart';


abstract class HotelState extends Equatable {
  HotelState();
}

class FetchInitialState extends HotelState {
  @override
  List<Object> get props => [];
}

class FetchLoadedState extends HotelState {

  final List<Hotellist> hotellist;
 FetchLoadedState({required this.hotellist});

  @override
    List<Object> get props => [hotellist];

}

class FetchErrorState extends HotelState {

  String message;

  FetchErrorState({required this.message});

  @override
    List<Object> get props => [message];
}