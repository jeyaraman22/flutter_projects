import 'package:equatable/equatable.dart';
import 'package:g_sign_bloc/datalist/modelclass.dart';

abstract class listState extends Equatable {
  listState();
}

class InitialState extends listState {
  @override
  List<Object> get props => [];
}

class FetchlistState extends listState{
  final List<Hotellist> fetchList;

  FetchlistState({required this.fetchList});

  @override

  List<Object?> get props => [fetchList];

}

class listErrorstate extends listState {

String message;

listErrorstate({required this.message});

@override
List<Object> get props => [message];
}