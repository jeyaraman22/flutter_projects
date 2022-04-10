import 'package:equatable/equatable.dart';

abstract class ValidationState extends Equatable{
  const ValidationState();
}

class InitialValidation extends ValidationState{
  @override
  List<Object?> get props =>[];

}


class FieldValidationState extends ValidationState{
  final bool validName,validFormula,valid;
  const FieldValidationState(this.validName, this.validFormula, this.valid);
  @override
  List<Object?> get props => [validName,validFormula,valid];

}