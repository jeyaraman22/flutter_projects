import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/crud_bloc/bloc_model/bloc_event.dart';
import 'package:test_app/crud_bloc/bloc_model/bloc_state.dart';
import 'package:test_app/crud_bloc/service/crud_repository.dart';
import '../crud_bloc_model/bloc_modelclass.dart';


class ProductBloc extends Bloc<CrudEvent,CrudState> {
  Map<String,dynamic>? chemicalproduct;
  bool action = false;

  ProductBloc() : super(InitialState()){
   on<GetProductEvent>((event, emit)async{
     List<Chemicalproduct> chemicalProducts = await Repository().getData();
     emit(GetProductState(chemicalProducts,""));
   });
   on<AddEvent>((event, emit)async{
     emit(InitialState());
     Future.delayed(const Duration(seconds: 1));
     action = await Repository().addData(event.chemicalproduct);
     if(action) {
       List<Chemicalproduct> chemicalProducts = await Repository().getData();
       emit(GetProductState(chemicalProducts,"add"));
     }
   });
   on<UpdateEvent>((event, emit)async{
     emit(InitialState());
     Future.delayed(const Duration(seconds: 1));
     action = await Repository().updateData(event.chemicalproduct);
     if(action) {
       List<Chemicalproduct> chemicalProducts = await Repository().getData();
       emit(GetProductState(chemicalProducts,"edit"));
     }else{
       emit(InitialState());
     }
   });
   on<DeleteEvent>((event, emit)async{
     emit(InitialState());
     Future.delayed(const Duration(seconds: 1));
     action = await Repository().deleteData(event.id);
     if(action) {
       List<Chemicalproduct> chemicalProducts = await Repository().getData();
       emit(GetProductState(chemicalProducts,"delete"));
     }
   });
   on<NewScreenEvent>((event,emit){
     emit(NewScreenState());
   });
  }





  // @override
  // Future<void> close() {
  //   return super.close();
  // }
  // Stream<CrudState> mapEventToState(CrudEvent event) async*{
  //   if(event is GetProductEvent){
  //   List<Chemicalproduct> chemicalProducts = await repo.getData();
  //   yield GetProductState(chemicalProducts,"");
  //   }else{
  //     throw "Problem in Reading data";
  //   }
  //   if(event is AddEvent){
  //     action = await repo.addData(chemicalproduct!);
  //     if(action) {
  //       List<Chemicalproduct> chemicalProducts = await repo.getData();
  //       yield GetProductState(chemicalProducts,"add");
  //     }else{
  //       throw "Problem in adding data";
  //     }
  //   }
  //   if(event is UpdateEvent){
  //     action = await repo.updateData(id, chemicalproduct!);
  //     if(action) {
  //       List<Chemicalproduct> chemicalProducts = await repo.getData();
  //       yield GetProductState(chemicalProducts,"edit");
  //     }else{
  //       throw "Problem in updating data";
  //     }
  //   }
  //   if(event is DeleteEvent){
  //     action = await repo.deleteData(id);
  //     if(action) {
  //       List<Chemicalproduct> chemicalProducts = await repo.getData();
  //       yield GetProductState(chemicalProducts,"delete");
  //     }else{
  //       throw "Problem in deleting data";
  //     }
  //   }
  // }
}

