import 'package:equatable/equatable.dart';
import 'package:test_app/crud_bloc/crud_bloc_model/bloc_modelclass.dart';

abstract class CrudState extends Equatable{
  const CrudState();
}

class InitialState extends CrudState{
  @override
  List<Object?> get props => [];
}

class GetProductState extends CrudState{
  final List<Chemicalproduct> productList;
  final String process;
  const GetProductState(this.productList,this.process);
  @override
  List<Object?> get props => [productList];
}

class AddProductState extends CrudState{
   final List<Chemicalproduct> productList;
   const AddProductState(this.productList);
  @override
  List<Object?> get props => [productList];
}

class UpdateProductState extends CrudState{
  final List<Chemicalproduct> productList;
  const UpdateProductState(this.productList);
  @override
  List<Object?> get props => [productList];
}

class DeleteProductState extends CrudState{
  final List<Chemicalproduct> productList;
  const DeleteProductState(this.productList);
  @override
  List<Object?> get props => [productList];
}

class NewScreenState extends CrudState{
  @override
  List<Object?> get props => [];

}