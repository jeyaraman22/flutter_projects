import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/crud_bloc/constants/constant.dart';
import 'package:test_app/crud_bloc/validation_bloc/validator_bloc_event.dart';
import 'package:test_app/crud_bloc/validation_bloc/validator_bloc_state.dart';

class ValidationBloc extends Bloc<ValidationEvent,ValidationState>{
  ValidationBloc():super(InitialValidation()){
    on<InitialValidationEvent>((event,emit){
      emit(FieldValidationState(Constants.initialValidParams,
          Constants.initialValidParams,
          Constants.initialValidParams));
    });
    on<FieldValidationEvent>((event,emit){
      bool name,formula,valid;
      name = event.nameField.isEmpty?Constants.trueValue:Constants.falseValue;
      formula = event.formulaField.isEmpty?Constants.trueValue:Constants.falseValue;
      if(name && formula){
        valid = Constants.falseValue;
        emit(FieldValidationState(name,formula,valid));
      }
      if(!name && !formula){
        valid = Constants.trueValue;
        emit(FieldValidationState(name,formula,valid));
      }
      if(!name && formula){
        valid = Constants.falseValue;
        emit(FieldValidationState(name,formula,valid));
      }
      if(name && !formula){
        valid = Constants.falseValue;
        emit(FieldValidationState(name,formula,valid));
      }
    });
    on<FieldNameValidationEvent>((event,emit){
      bool name;
      name = event.nameField.isEmpty?Constants.trueValue:Constants.falseValue;
      emit(FieldValidationState(name,Constants.falseValue,Constants.falseValue));
    });
    on<FieldFormulaValidationEvent>((event,emit){
      bool formula;
      formula = event.formulaField.isEmpty?Constants.trueValue:Constants.falseValue;
      emit(FieldValidationState(Constants.falseValue,formula,Constants.falseValue));
    });
  }
}