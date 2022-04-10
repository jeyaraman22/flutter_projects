import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/crud_bloc/bloc_model/bloc_event.dart';
import 'package:test_app/crud_bloc/bloc_model/bloc_main.dart';
import 'package:test_app/crud_bloc/crud_bloc_model/bloc_modelclass.dart';
import 'package:test_app/crud_bloc/validation_bloc/validator_bloc_event.dart';
import 'package:test_app/crud_bloc/validation_bloc/validator_bloc_state.dart';
import 'package:test_app/crud_bloc/validation_bloc/validator_main_bloc.dart';
import '../crud_bloc_model/bloc_modelclass.dart';


class BlocAddEditScreen extends StatefulWidget {
  final String action;
  final Chemicalproduct? editProduct;
  const BlocAddEditScreen({Key? key, required this.action, this.editProduct})
      : super(key: key);

  @override
  _BlocAddEditScreenState createState() => _BlocAddEditScreenState();
}

class _BlocAddEditScreenState extends State<BlocAddEditScreen> {
  var nameController = TextEditingController();
  var formulaController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  ProductBloc crudBloc = ProductBloc();

  check() {
    if (widget.editProduct != null) {
      nameController.text = widget.editProduct!.name;
      formulaController.text = widget.editProduct!.formula;
    }
  }

  @override
  void initState() {
    super.initState();
    check();
    context.read<ValidationBloc>().add(InitialValidationEvent());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () { context.read<ProductBloc>().add(GetProductEvent());
      return Future(() => true);},
      child: Scaffold(
        appBar: AppBar(),
        body: BlocListener<ValidationBloc,ValidationState>(
          listener: (BuildContext context, state) {
          },
          child: BlocBuilder<ValidationBloc,ValidationState>(
              builder: (context,state){
            // if(state is InitialValidation){
            //   return Container(
            //     margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         TextFormField(
            //           autovalidateMode: AutovalidateMode.onUserInteraction,
            //           textInputAction: TextInputAction.done,
            //           controller: nameController,
            //           decoration: InputDecoration(
            //             hintText: "Chemical Name",
            //             enabledBorder: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(5),
            //               borderSide: const BorderSide(
            //                 color: Colors.green,
            //                 width: 1.0,
            //               ),
            //             ),
            //             focusedBorder: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(30),
            //               borderSide: const BorderSide(
            //                 color: Colors.purple,
            //                 width: 2.0,
            //               ),
            //             ),
            //           ),
            //
            //         ),
            //         SizedBox(
            //           height: 10,
            //         ),
            //         TextFormField(
            //           autovalidateMode: AutovalidateMode.onUserInteraction,
            //           textInputAction: TextInputAction.done,
            //           controller: formulaController,
            //           decoration: InputDecoration(
            //             hintText: "Chemical Formula",
            //             enabledBorder: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(5),
            //               borderSide: const BorderSide(
            //                 color: Colors.green,
            //                 width: 1.0,
            //               ),
            //             ),
            //             focusedBorder: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(30),
            //               borderSide: const BorderSide(
            //                 color: Colors.purple,
            //                 width: 2.0,
            //               ),
            //             ),
            //           ),
            //
            //         ),
            //         SizedBox(
            //           height: 20,
            //         ),
            //         Padding(
            //           padding: EdgeInsets.symmetric(
            //               horizontal: (MediaQuery.of(context).size.width) / 2.8),
            //           child: ElevatedButton(
            //               onPressed: () {
            //                 context.read<ValidationBloc>().add(FieldValidationEvent(
            //                 nameController.text,formulaController.text));
            //                 print("INITAL ON PRESSED CALLED");
            //                 // var data = Chemicalproduct(name: nameController.text,
            //                 //     formula: formulaController.text,
            //                 //     timeStamp: (widget.action == "Edit")?"":FieldValue.serverTimestamp().toString(),
            //                 //     id: (widget.action == "Edit")?widget.editProduct!.id:"");
            //                 //
            //                 // if (formkey.currentState!.validate()) {
            //                 //   if (widget.action == "add") {
            //                 //     context.read<ProductBloc>().add(AddEvent(data));
            //                 //     //crudBloc.add(AddEvent());
            //                 //     nameController.clear();
            //                 //     formulaController.clear();
            //                 //     Navigator.of(context).pop();
            //                 //   } else {
            //                 //     context.read<ProductBloc>().add(UpdateEvent(data));
            //                 //     nameController.clear();
            //                 //     formulaController.clear();
            //                 //     Navigator.of(context).pop();
            //                 //     // FirebaseFirestore.instance
            //                 //     //     .collection("chemicals")
            //                 //     //     .doc(widget.editProduct!.id)
            //                 //     //     .update({
            //                 //     //   "name": nameController.text,
            //                 //     //   "formula": formulaController.text
            //                 //     // }).then((value) {
            //                 //     //   nameController.clear();
            //                 //     //   formulaController.clear();
            //                 //     //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //                 //     //       content:
            //                 //     //       const Text("Data Updated Successfully")));
            //                 //     //   Navigator.pop(context, true);
            //                 //     // });
            //                 //   }
            //                 // }
            //               },
            //               child: Text(widget.action == "add" ? "Add" : "Update")),
            //         )
            //       ],
            //     ),
            //   );
            // }
            if(state is FieldValidationState){
              return buildForm(context, state.validName,state.validFormula,state.valid);
              //   Container(
              //   margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       TextFormField(
              //         autovalidateMode: AutovalidateMode.onUserInteraction,
              //         textInputAction: TextInputAction.done,
              //         controller: nameController,
              //         decoration: InputDecoration(
              //           hintText: "Chemical Name",
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(5),
              //             borderSide: const BorderSide(
              //               color: Colors.green,
              //               width: 1.0,
              //             ),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(30),
              //             borderSide: const BorderSide(
              //               color: Colors.purple,
              //               width: 2.0,
              //             ),
              //           ),
              //         ),
              //       ),
              //       if(state.validName) SizedBox(height: 15,child: Text(
              //         "Please enter valid data",style: TextStyle(color: Colors.pink),),),
              //       SizedBox(
              //         height: 10,
              //       ),
              //       TextFormField(
              //         autovalidateMode: AutovalidateMode.onUserInteraction,
              //         textInputAction: TextInputAction.done,
              //         controller: formulaController,
              //         decoration: InputDecoration(
              //           hintText: "Chemical Formula",
              //           enabledBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(5),
              //             borderSide: const BorderSide(
              //               color: Colors.green,
              //               width: 1.0,
              //             ),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(30),
              //             borderSide: const BorderSide(
              //               color: Colors.purple,
              //               width: 2.0,
              //             ),
              //           ),
              //         ),
              //       ),
              //       if(state.validFormula) SizedBox(height: 15,child: Text(
              //         "Please enter valid data",style: TextStyle(color: Colors.pink),),),
              //       SizedBox(
              //         height: 20,
              //       ),
              //       Padding(
              //         padding: EdgeInsets.symmetric(
              //             horizontal: (MediaQuery.of(context).size.width) / 2.8),
              //         child: ElevatedButton(
              //             onPressed: () async{
              //                context.read<ValidationBloc>().add(
              //                 FieldValidationEvent(nameController.text,formulaController.text));
              //             print("FIELDVALIDATION ON PRESSED");
              //              print(state.validName);
              //              print(state.validFormula);
              //             if(!state.validName && !state.validFormula) {
              //               var data = Chemicalproduct(
              //                   name: nameController.text,
              //                   formula: formulaController.text,
              //                   timeStamp: (widget.action == "Edit")
              //                       ? ""
              //                       : FieldValue.serverTimestamp().toString(),
              //                   id: (widget.action == "Edit") ? widget
              //                       .editProduct!.id : "");
              //               if (widget.action == "add") {
              //                 context.read<ProductBloc>().add(AddEvent(data));
              //                 //crudBloc.add(AddEvent());
              //                 nameController.clear();
              //                 formulaController.clear();
              //                 Navigator.of(context).pop();
              //               } else {
              //                 context.read<ProductBloc>().add(
              //                     UpdateEvent(data));
              //                 nameController.clear();
              //                 formulaController.clear();
              //                 Navigator.of(context).pop();
              //                 // FirebaseFirestore.instance
              //                 //     .collection("chemicals")
              //                 //     .doc(widget.editProduct!.id)
              //                 //     .update({
              //                 //   "name": nameController.text,
              //                 //   "formula": formulaController.text
              //                 // }).then((value) {
              //                 //   nameController.clear();
              //                 //   formulaController.clear();
              //                 //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //                 //       content:
              //                 //       const Text("Data Updated Successfully")));
              //                 //   Navigator.pop(context, true);
              //                 // });
              //               }
              //             }
              //
              //           },
              //             child: Text(widget.action == "add" ? "Add" : "Update")),
              //       )
              //     ],
              //   ),
              // );
            }else{
              return const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    color: Colors.pink,
                    strokeWidth: 2.0,
                  ));
            }
          })
        ),
      ),
    );
  }
  Widget buildForm(BuildContext context, bool isValidName, bool isValidFormula, bool isValidate){
   print("BUILDFORM--$isValidName , $isValidFormula , $isValidate");
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.done,
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Chemical Name",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Colors.green,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.purple,
                  width: 2.0,
                ),
              ),
            ),
            onChanged: (value){
              context.read<ValidationBloc>().add(FieldNameValidationEvent(value));
              context.read<ValidationBloc>().add(FieldValidationEvent(value, formulaController.text));
            },
          ),
          if(isValidName) ...[const SizedBox(height: 15,child: Text(
            "Please enter Chemical Product",style: TextStyle(color: Colors.pink),),),],
          SizedBox(
            height: 10,
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.done,
            controller: formulaController,
            decoration: InputDecoration(
              hintText: "Chemical Formula",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Colors.green,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.purple,
                  width: 2.0,
                ),
              ),
            ),
            onChanged: (value){
                context.read<ValidationBloc>().add(FieldFormulaValidationEvent(value));
                context.read<ValidationBloc>().add(FieldValidationEvent(nameController.text,value));
            },
          ),
          if(isValidFormula) ...[const SizedBox(height: 15,child: Text(
            "Please enter Chemical Formula",style: TextStyle(color: Colors.pink),),),],
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: (MediaQuery.of(context).size.width) / 2.8),
            child: ElevatedButton(
                onPressed: () {
                  print("BUILD FORM-- ON PRESSED");
                   // if(isValidName || isValidFormula) {
                    context.read<ValidationBloc>().add(FieldValidationEvent(nameController.text, formulaController.text));
                  // }
                  print("BUILD FORM RESULT--$isValidName , $isValidFormula , $isValidate");

                  if(isValidate){
                    var data = Chemicalproduct(name: nameController.text,
                        formula: formulaController.text,
                        timeStamp: (widget.action == "Edit")?"":FieldValue.serverTimestamp().toString(),
                        id: (widget.action == "Edit")?widget.editProduct!.id:"");
                    if (widget.action == "add") {
                      context.read<ProductBloc>().add(AddEvent(data));
                      Navigator.of(context).pop();
                    } else {
                      context.read<ProductBloc>().add(UpdateEvent(data));
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: Text(widget.action == "add" ? "Add" : "Update")),
          )
        ],
      ),
    );
  }
}
