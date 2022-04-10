import 'package:equatable/equatable.dart';

abstract class ValidationEvent extends Equatable{
  const ValidationEvent();
}

class InitialValidationEvent extends ValidationEvent{
  @override
  List<Object?> get props => throw UnimplementedError();

}

class FieldValidationEvent extends ValidationEvent{
  final String nameField,formulaField;
  const FieldValidationEvent(this.nameField,this.formulaField);
  @override
  List<Object?> get props =>[nameField,formulaField];
}

class FieldNameValidationEvent extends ValidationEvent{
  final String nameField;
  const FieldNameValidationEvent(this.nameField);
  @override
  List<Object?> get props =>[nameField];
}

class FieldFormulaValidationEvent extends ValidationEvent{
  final String formulaField;
  const FieldFormulaValidationEvent(this.formulaField);
  @override
  List<Object?> get props =>[formulaField];
}