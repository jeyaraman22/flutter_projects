import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class RoomTypes extends StatefulWidget {
  const RoomTypes({Key? key}) : super(key: key);

  @override
  _RoomTypesState createState() => _RoomTypesState();
}

class _RoomTypesState extends State<RoomTypes> {
  var formkey = GlobalKey<FormState>();
  var roomnameController = TextEditingController();
  var priceController = TextEditingController();
  var image1Controller = TextEditingController();
  var image2Controller = TextEditingController();
  final databaseObject = FirebaseDatabase.instance.ref('RoomTypes');
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child:Scaffold(
         body: Container(
           margin: const EdgeInsets.all(10),
           child: Form(
             key: formkey,
             child: Column(
               children: [
                 TextFormField(
                   controller: roomnameController,
                   decoration:  const InputDecoration(
                     hintText: "Room",
                     focusedBorder: OutlineInputBorder(
                         borderSide: BorderSide(
                             color: Color(0xff211942),
                             style: BorderStyle.solid
                         )
                     ),
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
                 const SizedBox(height: 10),
                 TextFormField(
                   inputFormatters: [
                     FilteringTextInputFormatter.allow(
                         RegExp(r'^\d+\.?\d{0,2}')),
                   ],
                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
                   controller: priceController,
                   decoration:  const InputDecoration(
                     hintText: "Price",
                     focusedBorder: OutlineInputBorder(
                         borderSide: BorderSide(
                             color: Color(0xff211942),
                             style: BorderStyle.solid
                         )
                     ),
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
                 const SizedBox(height: 10),
                 TextFormField(
                   controller: image1Controller,
                   decoration:  const InputDecoration(
                     hintText: "Image1",
                     focusedBorder: OutlineInputBorder(
                         borderSide: BorderSide(
                             color: Color(0xff211942),
                             style: BorderStyle.solid
                         )
                     ),
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
                 const SizedBox(height: 10),
                 TextFormField(
                   controller: image2Controller,
                   decoration:  const InputDecoration(
                     hintText: "Image2",
                     focusedBorder: OutlineInputBorder(
                         borderSide: BorderSide(
                             color: Color(0xff211942),
                             style: BorderStyle.solid
                         )
                     ),
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
                 const SizedBox(height: 30),
                 OutlinedButton(
                   style: OutlinedButton.styleFrom(
                       shape: const StadiumBorder()),
                   onPressed: () async{
                     if(formkey.currentState!.validate())
                     {
                       EasyLoading.show(status: "Adding...wait");
                       databaseObject.push().set({
                         "name"  : roomnameController.text.toString(),
                         "price" : priceController.text.toString(),
                         "image1": image1Controller.text.toString(),
                         "image2": image2Controller.text.toString()
                       }).then((value) {
                         EasyLoading.showSuccess("Added",duration: const Duration(seconds: 1)).then((value) {
                           roomnameController.clear();
                           priceController.clear();
                           image1Controller.clear();
                           image2Controller.clear();
                         });
                       });
                     }
                   },
                   child: const Text(
                     "  ADD  ",
                     style: TextStyle(color: Color(0xff211942)),
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
