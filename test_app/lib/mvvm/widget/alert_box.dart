import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/mvvm/utils/snack_bar.dart';
import 'package:test_app/mvvm/view_model/user_list_view_model.dart';

class AlertingBox extends StatefulWidget {
   final String action;
   const  AlertingBox({Key? key,required this.action}) : super(key: key);

  @override
  _AlertingBoxState createState() => _AlertingBoxState();
}

class _AlertingBoxState extends State<AlertingBox> {

  var nameController = TextEditingController();
  var jobController = TextEditingController();
  var idController = TextEditingController();
  var formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ViewModel>(context);
    return AlertDialog(
      content: SizedBox(
        height: (widget.action == "Add")?150:(widget.action == "Delete")?70:220,
        child: Form(
          key: formkey,
          child: Column(
            children: [
              if(widget.action == "Edit" || widget.action == "Delete")...[
                TextFormField(
                  controller:  idController,
                  decoration: const InputDecoration(
                      hintText: "User-id"
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter user id';
                    }
                    return null;
                  },
                ),
              ],
              if(widget.action == "Add" || widget.action == "Edit")...[
              TextFormField(
                controller:  nameController,
                decoration: const InputDecoration(
                    hintText: "Name"
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 7,),
              TextFormField(
                controller: jobController,
                decoration: const InputDecoration(
                    hintText: "Job"
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter users job';
                  }
                  return null;
                },
              ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed:()
    {
      if (formkey.currentState!.validate()){
        if (widget.action == "Add") {
          provider.addUsers(nameController.text, jobController.text).then((
              value) {
            if (provider.isSuccess!) {
             CustomSnackBar.responseSnackBar(context,"User Added Successfully");
             Navigator.of(context).pop();
            } else {
              CustomSnackBar.errorSnackBar(context, "Problem in adding User");
              Navigator.of(context).pop();
            }
          });
        }
      if (widget.action == "Edit") {
        provider.updateUsers(int.parse(idController.text),nameController.text, jobController.text).then((
            value) {
          if (provider.isSuccess!) {
            CustomSnackBar.responseSnackBar(context,"UserData Updated Successfully");
            Navigator.of(context).pop();
          } else {
            CustomSnackBar.errorSnackBar(context, "Problem in updating User");
            Navigator.of(context).pop();
          }
        });
      }
      if (widget.action == "Delete") {
        provider.deleteUsers(int.parse(idController.text)).then((
            value) {
          if (provider.isSuccess!) {
            CustomSnackBar.responseSnackBar(context,"User Deleted Successfully");
            Navigator.of(context).pop();
          } else {
            CustomSnackBar.errorSnackBar(context, "Problem in deleting User");
            Navigator.of(context).pop();
          }
        });
      }
    }
        }, child: Text(widget.action)),
        TextButton(onPressed:()=>Navigator.of(context).pop(),
            child: const Text("Cancel"))
      ],
    );
  }
}

