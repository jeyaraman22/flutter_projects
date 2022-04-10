import 'package:bloc/bloc.dart';
import 'package:g_sign_bloc/datalist/hotel_provider.dart';
import 'dart:async';
import 'package:g_sign_bloc/datalist/Hotelbloc/hotelevent.dart';
import 'package:g_sign_bloc/datalist/Hotelbloc/hotelstate.dart';
import 'package:g_sign_bloc/datalist/modelclass.dart';

class HotelBloc extends Bloc<HotellistEvent, HotelState> {
 HotelProvider provider = HotelProvider();

 HotelBloc({required this.provider}) : super(FetchInitialState());

 @override
 Future<void> close() {
  return super.close();
 }

@override
 Stream<HotelState> mapEventToState(HotellistEvent event) async* {
  if (event is FetchdisplayEvent) {
   List<Hotellist> listitems = await provider.gethotellist();
   yield FetchLoadedState(hotellist: listitems);
   //   try{
   //    Hotellist listitems = await provider.gethotellist();
   //    print("Required data : ${listitems.module!.result!.headline}");
   //    yield FetchLoadedState(hotellist: listitems);
   // }catch(e){
   //  yield FetchErrorState(message: e.toString());
   // }
  }

 }
}

