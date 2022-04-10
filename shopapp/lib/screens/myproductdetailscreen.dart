import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopapp/services/productmodel.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MyproductDetail extends StatefulWidget {
  productModel updateProduct;
MyproductDetail({required this.updateProduct});

  @override
  _MyproductDetailState createState() => _MyproductDetailState();
}

class _MyproductDetailState extends State<MyproductDetail> {

  var formkey = GlobalKey<FormState>();
  var productnameController = TextEditingController();
  var priceController = TextEditingController();
  var imageController = TextEditingController();
  var descriptionController = TextEditingController();
  final databaseObject = FirebaseDatabase.instance.ref('Products');
  final datacartObject = FirebaseDatabase.instance.ref('cart');
  User? currentuser;

  void productDetails() {
    productnameController.text = widget.updateProduct.name!;
    priceController.text = widget.updateProduct.price!;
    imageController.text = widget.updateProduct.image!;
    descriptionController.text = widget.updateProduct.description!;
  }

 Future updateproductDetails()async{
    await databaseObject
        .orderByChild("name")
        .equalTo(widget.updateProduct.name)
        .once()
        .then((value) {
          if(value.snapshot.exists) {
            var children = value.snapshot.value as Map<dynamic, dynamic>;
            children.forEach((key, value) {
              databaseObject
                  .child(key)
                  .update({"name": productnameController.text,
                "image": imageController.text,
                "desc": descriptionController.text});
            });
          }else{
            print("In ParentList the selected Item is not available.");
          }
    });
    await datacartObject
        .child(currentuser!.uid)
        .orderByChild("name")
        .equalTo(widget.updateProduct.name)
        .once()
        .then((value) {
          if(value.snapshot.exists) {
            var children = value.snapshot.value as Map<dynamic, dynamic>;
            children.forEach((key, value) {
              datacartObject
                  .child(currentuser!.uid)
                  .child(key)
                  .update({"name": productnameController.text,
                "image": imageController.text,
                "desc": descriptionController.text});
            });
          }else{
            print("In CartList the selected Item is not available.");
          }
    });
    // await myproductObject
    //     .child(currentuser!.uid)
    //     .orderByChild("name")
    //     .equalTo(widget.updateProduct.name)
    //     .once()
    //     .then((value) {
    //       if(value.snapshot.exists) {
    //         var children = value.snapshot.value as Map<
    //             dynamic,
    //             dynamic>;
    //         children.forEach((key, value) {
    //           myproductObject
    //               .child(currentuser!.uid)
    //               .child(key)
    //               .update({"name": productnameController.text,
    //             "image": imageController.text,
    //             "desc": descriptionController.text});
    //         });
    //       }else{
    //         print("In MyProductList the selected Item is not available.");
    //       }
    // });
  }

  @override
  void initState() {
    super.initState();
    currentuser = FirebaseAuth.instance.currentUser;
    productDetails();
    print("Selected ProductName--${widget.updateProduct.name}");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details"),
      ),
      body: Container(
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
                readOnly: true,
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
                onPressed: () async{
                  if(formkey.currentState!.validate()) {
                    EasyLoading.show(status: "Updating");
                    await updateproductDetails().then((value) {
                      EasyLoading.showSuccess("Updated",duration: Duration(seconds: 1)).then((value) {
                        productnameController.clear();
                        priceController.clear();
                        imageController.clear();
                        descriptionController.clear();
                        Navigator.pop(context,true);
                      });
                    });
                  }
                },
                child: Text("update"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
