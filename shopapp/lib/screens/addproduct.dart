import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddproductScreen extends StatefulWidget {

  @override
  _AddproductScreenState createState() => _AddproductScreenState();
}

class _AddproductScreenState extends State<AddproductScreen> {
  var formkey = GlobalKey<FormState>();
  var productnameController = TextEditingController();
  var priceController = TextEditingController();
  var imageController = TextEditingController();
  var descriptionController = TextEditingController();
  final databaseObject = FirebaseDatabase.instance.ref('Products');
  final myproductObject = FirebaseDatabase.instance.ref('Myproduct');
  User? currentuser;
  var productDate;


  @override
  void initState() {
    super.initState();
    currentuser = FirebaseAuth.instance.currentUser;
    productDate = DateFormat('dd/MM/yyyy').format(DateTime.now()).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 25,
        title: Text("Add product"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Form(
            key: formkey,
            child: Column(
              children: [
                TextFormField(
                  controller: productnameController,
                  decoration:  InputDecoration(
                    hintText: "Product Name",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black26,
                        style: BorderStyle.solid,
                      )
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter the Product name';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: priceController,
                  decoration:  InputDecoration(
                    hintText: "Price",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black26,
                          style: BorderStyle.solid,
                        )
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter the product price';
                    } else if(value == "0" ){
                      return 'Enter Valid Product Price';
                    }
                    else if(value.isNotEmpty){
                      var price = double.parse(value)*1;
                      if(price == 0){
                        return "Please check the Price";
                      }
                    }
                    else{
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: imageController,
                  decoration:  InputDecoration(
                    hintText: "Image URL",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black26,
                          style: BorderStyle.solid,
                        )
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter the Image URL';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  maxLines: null,
                  decoration:  InputDecoration(
                    hintText: "Description",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black26,
                          style: BorderStyle.solid,
                        )
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter the Product description';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 30),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      shape: StadiumBorder()),
                  onPressed: () async{
                     if(formkey.currentState!.validate())
                     {
                       EasyLoading.show(status: "Adding...wait");
                       databaseObject.push().set({
                         "name"  : productnameController.text.toString(),
                         "price" : priceController.text.toString(),
                         "image" : imageController.text.toString(),
                         "desc"  : descriptionController.text.toString(),
                         "createdby": currentuser!.uid,
                         "date"   : productDate
                       }).then((value) {
                         EasyLoading.showSuccess("Added",duration: Duration(seconds: 1)).then((value) {
                           productnameController.clear();
                           priceController.clear();
                           imageController.clear();
                           descriptionController.clear();
                           Navigator.pop(context,true);
                         });
                       });
                     }
                  },
                  child: const Text(
                    "  ADD  ",
                    style: TextStyle(color: Colors.pink),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
