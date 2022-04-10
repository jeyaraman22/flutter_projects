import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_app/crud_firebase/model/modelclass.dart';

class AddEditScreen extends StatefulWidget {
  final String action;
  final Chemicalproduct? editProduct;
  const AddEditScreen({Key? key, required this.action, this.editProduct})
      : super(key: key);

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  var nameController = TextEditingController();
  var formulaController = TextEditingController();
  final formkey = GlobalKey<FormState>();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
        child: Form(
          key: formkey,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              const SizedBox(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: (MediaQuery.of(context).size.width) / 2.8),
                child: ElevatedButton(
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        if (widget.action == "add") {
                          FirebaseFirestore.instance
                              .collection("chemicals")
                              .add({
                            "name": nameController.text,
                            "formula": formulaController.text,
                            "createdAt": FieldValue.serverTimestamp()
                          }).then((value) {
                            nameController.clear();
                            formulaController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content:
                                    Text("Data Added Successfully")));
                            Navigator.pop(context, true);
                          });
                        } else {
                          FirebaseFirestore.instance
                              .collection("chemicals")
                              .doc(widget.editProduct!.id)
                              .update({
                            "name": nameController.text,
                            "formula": formulaController.text
                          }).then((value) {
                            nameController.clear();
                            formulaController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content:
                                    Text("Data Updated Successfully")));
                            Navigator.pop(context, true);
                          });
                        }
                      }
                    },
                    child: Text(widget.action == "add" ? "Add" : "Update")),
              )
            ],
          ),
        ),
      ),
    );
  }
}
