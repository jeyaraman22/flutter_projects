import 'package:bloc/bloc.dart';
import 'package:g_sign_bloc/datalist/hotel_provider.dart';
import 'dart:async';
import 'package:g_sign_bloc/datalist/modelclass.dart';
import 'package:g_sign_bloc/datalist/listbloc/listevent.dart';
import 'package:g_sign_bloc/datalist/listbloc/liststate.dart';

class listBloc extends Bloc<listEvent,listState>{
  HotelProvider provider = HotelProvider();

  listBloc({required this.provider}) : super(InitialState());

  @override
  Stream<listState> mapEventToState(listEvent event)async*{
    if(event is Filterlistfetchevent){
      List<Hotellist> hotelHeader = await provider.gethotellist();
      yield FetchlistState(fetchList: hotelHeader);
    }
  }
}