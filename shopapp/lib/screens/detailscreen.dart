import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopapp/services/productmodel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;


class detailScreen extends StatefulWidget {
  productModel detailItems;
  detailScreen({required this.detailItems});

  @override
  State<detailScreen> createState() => _detailScreenState();
}

class _detailScreenState extends State<detailScreen> {
  List<productModel> cartProduct = [];
  List<productModel> checkList = [];
  bool databaseCart = true;
  final databaseObject = FirebaseDatabase.instance.ref('cart');
  User? currentuser;
  bool checker = false;
  String quantity = "1";

  Future<List<productModel>> productdatafromcartFirebase() async {
    List<productModel> cartproductNames =[];
    var result = await http.get(Uri.parse(
        "https://shop-flut-app-default-rtdb.firebaseio.com/cart.json"));
    var listavailable = jsonDecode(result.body)[currentuser!.uid];
    if(listavailable == null){
      setState(() {
        databaseCart = false;
      });
    }
    else{
      final decodedResult = jsonDecode(result.body);
      decodedResult[currentuser!.uid].forEach((key, value) {
        cartproductNames.add(productModel.fromJson(value));
      });
      return cartproductNames;
    }
    return cartproductNames;
  }

  getcartProduct(){
    productdatafromcartFirebase().then((value) {
      setState(() {
        cartProduct.addAll(value);
      });
    }).then((value) {
      crosscheck(widget.detailItems);
    });
  }

  bool crosscheck(productModel cartItems){
    for(var i=0; i<cartProduct.length; i++){
      productModel check = cartProduct[i];
      if(check.name == cartItems.name){
        checker = true;
        break;
      }else{
        checker = false;
      }
    }
    return checker;
  }
  void addtoCart(productModel cartItems) {
    setState(() {
      cartProduct.add(cartItems);
      databaseObject.child("cartitems").push().set({
        "name": cartItems.name,
        "price": cartItems.price,
        "image": cartItems.image,
        "desc": cartItems.description,
        "quantity":quantity
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getcartProduct();
    currentuser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GestureDetector(
              child: Icon(Icons.arrow_back),
              onTap: () {
                Navigator.pop(context,cartProduct);
              }),
        ),
        leadingWidth: 25,
        title: Text("Product Detail"),
        // actions: [
        //   Stack(
        //     children: [
        //       Container(
        //         height: 100,
        //         child: Stack(children: [
        //           Center(
        //             child: IconButton(
        //                 onPressed: () {
        //                   Navigator.push(
        //                       context,
        //                       MaterialPageRoute(
        //                         builder: (context) =>
        //                             cartScreen(cartModel: cartProduct),
        //                       ));
        //                 },
        //                 icon: Icon(Icons.shopping_cart)),
        //           ),
        //           cartProduct.length == 0
        //               ? Container()
        //               : Positioned(
        //               right: 5.0,
        //               child: Stack(
        //                 children: <Widget>[
        //                   Icon(
        //                     Icons.brightness_1,
        //                     size: 20.0,
        //                     color: Colors.black26,
        //                   ),
        //                   Positioned(
        //                       top: 3.0,
        //                       right: 6.0,
        //                       child: Center(
        //                         child: Text(
        //                           cartProduct.length.toString(),
        //                           style: const TextStyle(
        //                               color: Colors.white,
        //                               fontSize: 11.0,
        //                               fontWeight: FontWeight.w500),
        //                         ),
        //                       )),
        //                 ],
        //               )),
        //         ]),
        //       ),
        //     ],
        //   ),
        // ],
      ),
      body: Container(
          color: Colors.white,
          padding: EdgeInsets.all(10),
          height: 530,
          width: double.infinity,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: Container(
                    child: Image.network(widget.detailItems.image!,
                        fit: BoxFit.cover),
                  ),
                )),
            SizedBox(height: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.detailItems.name!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Rs." + widget.detailItems.price!,
                    style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.detailItems.description!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(shape: StadiumBorder()),
                    onPressed: () {
                      if (checker) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("This item is already added")));
                      } else {
                        setState(() {
                          addtoCart(widget.detailItems);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Product Added to cart",style: TextStyle(color: Colors.green))));
                          checker = true;
                        });
                      }
                    },
                    child: const Text(
                      " AddtoCart ",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  OutlinedButton(
                    style: checker
                        ? OutlinedButton.styleFrom(
                            shape: StadiumBorder(),
                          )
                        : OutlinedButton.styleFrom(
                            shape: StadiumBorder(),
                            backgroundColor: Colors.black26,
                          ),
                    onPressed: () {
                      showDialog(context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: Text("Want to Remove this item"),
                          actions: [
                            TextButton(onPressed: () {
                              if (checker) {
                                setState(() {
                                  for(var i=0;i<cartProduct.length;i++){
                                    productModel removeitem = cartProduct[i];
                                    if(removeitem.name == cartProduct[i].name){
                                      cartProduct.remove(removeitem);
                                      break;
                                    }
                                  }
                                  databaseObject.child("cartitems").orderByChild("name").
                                  equalTo((widget.detailItems.name)!).once().then((value) {
                                    var children = value.snapshot.value as Map<dynamic,dynamic>;
                                    children.forEach((key, value) {
                                      databaseObject.child("cartitems").child(key).remove();
                                    });
                                  });
                                  setState(() {
                                    checker = false;
                                  });
                                });
                              } else {
                                return null;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                   content: Text("Product Removed from cart",style: TextStyle(color: Colors.blue),)));
                              Navigator.pop(context);
                            },
                            child: Text("Yes"),),
                            TextButton(onPressed: () { Navigator.pop(context); },
                            child: Text("No"),)
                          ],
                        );
                      });
                    },
                    child: const Text(" RemovefromCart ",
                        style: TextStyle(color: Colors.green)),
                  )
                ],
              ),
            ),
            // Expanded(child: TextButton(onPressed: () {
            //   Navigator.of(context).pop();
            // }, child: Text("close"),))
          ])),
    );
  }
}
