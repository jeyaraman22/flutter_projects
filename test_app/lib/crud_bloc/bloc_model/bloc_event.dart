import 'package:equatable/equatable.dart';
import 'package:test_app/crud_bloc/crud_bloc_model/bloc_modelclass.dart';

abstract class CrudEvent extends Equatable{
const CrudEvent();
}

class GetProductEvent extends CrudEvent{
  @override
  List<Object?> get props => [];
}

class AddEvent extends CrudEvent{
  final Chemicalproduct chemicalproduct;
  const AddEvent(this.chemicalproduct);
  @override
  List<Object?> get props => [];
}

class UpdateEvent extends CrudEvent{
  final Chemicalproduct chemicalproduct;
  const UpdateEvent(this.chemicalproduct);
  @override
  List<Object?> get props => [chemicalproduct];
}

class DeleteEvent extends CrudEvent{
  final String id;
  const DeleteEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class NewScreenEvent extends CrudEvent{
  @override
  List<Object?> get props => [];

}

class ValidateEvent extends CrudEvent{
  final String name,formula;
  const ValidateEvent(this.name,this.formula);
  @override
  List<Object?> get props => [name,formula];
}