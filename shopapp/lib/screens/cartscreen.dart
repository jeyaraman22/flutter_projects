import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopapp/screens/orderscreen.dart';
import 'package:shopapp/services/productmodel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shopapp/screens/bottombar.dart';
import 'package:intl/intl.dart';

class cartScreen extends StatefulWidget {
  @override
  _cartScreenState createState() => _cartScreenState();
}

class _cartScreenState extends State<cartScreen> {
  List<productModel> cartaddedItems = [];
  List<productModel> cartresultItems = [];
  List<productModel> cartfinalItems = [];
  final databaseObject = FirebaseDatabase.instance.ref('cart');
  final dataorderObject = FirebaseDatabase.instance.ref('Orders');
  int productQuantity = 1;
  bool isLoading = true;
  bool databaseCart = true;
  bool incrementLimit = true;
  bool decrementLimit = true;
  var TotalPrice;
  User? currentuser;
  DateTime? currentTime;
  String? orderID;
  var orderTime;
  var orderDate;

  String totalprice() {
    double total = 0;
    cartfinalItems.forEach((element) {
      total += double.parse(element.price!) * int.parse(element.quantity!);
    });
    return total.toStringAsFixed(2);
  }

  Future<List<productModel>> productdatafromcartFirebase() async {
    List<productModel> cartproductNames = [];
    var result = await http.get(Uri.parse(
        "https://shop-flut-app-default-rtdb.firebaseio.com/cart.json"));
    var listavailable = jsonDecode(result.body);
    if (listavailable == null) {
      setState(() {
        databaseCart = false;
      });
    }
    if (databaseCart) {
      final decodedResult = jsonDecode(result.body);
      decodedResult[currentuser!.uid].forEach((key, value) {
        cartproductNames.add(productModel.fromJson(value));
      });
      return cartproductNames;
    }
    if(cartproductNames.isEmpty){
      setState(() {
        databaseCart = false;
      });
    }
    return cartproductNames;
  }

  Future<String> quantityincrementCounter(productModel quantityCart) async {
    productQuantity = int.parse(quantityCart.quantity!);
    if (productQuantity < 10) {
      productQuantity = productQuantity + 1;
      await databaseObject
          .child(currentuser!.uid)
          .orderByChild("name")
          .equalTo(quantityCart.name)
          .once()
          .then((value) {
        var children = value.snapshot.value as Map<dynamic, dynamic>;
        children.forEach((key, value) {
          databaseObject
              .child(currentuser!.uid)
              .child(key)
              .update({"quantity": productQuantity.toString()});
        });
      });
    }else{
      setState(() {
        incrementLimit = false;
      });
    }
    return productQuantity.toString();
  }

  Future<String> quantitydecrementCounter(productModel quantityCart) async {
    productQuantity = int.parse(quantityCart.quantity!);
    if (productQuantity > 1) {
      productQuantity = productQuantity - 1;
      await databaseObject
          .child(currentuser!.uid)
          .orderByChild("name")
          .equalTo(quantityCart.name)
          .once()
          .then((value) {
        var children = value.snapshot.value as Map<dynamic, dynamic>;
        children.forEach((key, value) {
          databaseObject
              .child(currentuser!.uid)
              .child(key)
              .update({"quantity": productQuantity.toString()});
        });
      });
    } else {
      setState(() {
        decrementLimit = false;
      });
    }
    return productQuantity.toString();
  }

  Future moveCartToOrder()async{
      currentTime = DateTime.now();
      orderTime = DateFormat.yMd().add_jm().format(currentTime!).toString();
      orderDate = DateFormat("dd/MM/yyyy").format(currentTime!);
      orderID = "OrderID_${currentTime!.millisecondsSinceEpoch}";
     await dataorderObject.child(orderID!).push().set({
        "totalAmount": TotalPrice.toString(),
        "orderby"  : currentuser!.uid,
        "orderID"  : orderID,
        "orderTime": orderTime.toString(),
        "orderDate": orderDate.toString(),
      });
     await dataorderObject.child(orderID!).orderByChild('orderID').equalTo(orderID).once().then((value){
       var orderMap = value.snapshot.value as Map<dynamic,dynamic>;
       orderMap.forEach((key, value) {
         for (productModel element in cartfinalItems) {
           dataorderObject.child(orderID!).child(key).child('products').push().set({
             "name" : element.name,
             "quantity" : element.quantity,
             "price" : element.price
           });
         }
       });
     });
  }

  getcartProductdata() async {
    cartfinalItems = [];
    await productdatafromcartFirebase().then((value) {
      setState(() {
        cartfinalItems.addAll(value);
        TotalPrice = totalprice();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    currentuser = FirebaseAuth.instance.currentUser;
    getcartProductdata();
    currentTime = DateTime.now();
    orderTime = DateFormat("dd/MM/yyyy").add_jm().format(currentTime!).toString();
    print(orderTime);
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
                Navigator.pop(
                    context, cartfinalItems.isEmpty ? "empty" : cartfinalItems);
              }),
        ),
        leadingWidth: 25,
        title: Text("Cart Items"),
      ),
      body: cartfinalItems.isEmpty
          ? databaseCart
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Center(
                  child: Container(
                  child: Text(
                    "Cart Items Empty",
                    style: TextStyle(fontSize: 18),
                  ),
                ))
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: ListView.builder(
                    itemCount: cartfinalItems.length,
                    itemBuilder: (context, index) {
                      final cart = cartfinalItems[index];
                      return Container(
                        margin: EdgeInsets.all(8),
                        height: 160,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                decoration:
                                    BoxDecoration(shape: BoxShape.circle),
                                child: Image.network(
                                  cartfinalItems[index].image!,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    cartfinalItems[index].name!,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "Rs." + cartfinalItems[index].price!,
                                    style: TextStyle(
                                        color: Colors.lightGreen,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 15),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: StadiumBorder(),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                  "Want to remove this item"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      databaseObject
                                                          .child(currentuser!.uid)
                                                          .orderByChild(
                                                              "name")
                                                          .equalTo(cart.name)
                                                          .once()
                                                          .then((value) {
                                                        var children = value
                                                                .snapshot
                                                                .value
                                                            as Map<dynamic,
                                                                dynamic>;
                                                        children.forEach(
                                                            (key, value) {
                                                          databaseObject
                                                              .child(
                                                                  currentuser!.uid)
                                                              .child(key)
                                                              .remove();
                                                        });
                                                      });
                                                      cartfinalItems
                                                          .remove(cart);
                                                      if (cartfinalItems
                                                          .isEmpty) {
                                                        databaseCart = false;
                                                      }
                                                      TotalPrice =
                                                          totalprice();
                                                    });
                                                    print(cartfinalItems.length);
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                        content: Text("Product Removed from cart",style: TextStyle(color: Colors.blue))));
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Yes"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("No"),
                                                )
                                              ],
                                            );
                                          });
                                    },
                                    child: const Text(" RemovefromCart ",
                                        style:
                                            TextStyle(color: Colors.green)),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        "Quantity:",
                                        style: TextStyle(
                                            color: Colors.deepPurple,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        child: Icon(
                                          Icons.remove_circle_outline_rounded,
                                          color: Colors.black26,
                                        ),
                                        onTap: () async {
                                          cartfinalItems[index].quantity =
                                              await quantitydecrementCounter(
                                                  cart);
                                          setState(() {
                                            TotalPrice = totalprice();
                                          });
                                          if(!decrementLimit){
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                        "Want to remove this item"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            databaseObject
                                                                .child(currentuser!.uid)
                                                                .orderByChild(
                                                                "name")
                                                                .equalTo(cart.name)
                                                                .once()
                                                                .then((value) {
                                                              var children = value
                                                                  .snapshot
                                                                  .value
                                                              as Map<dynamic,
                                                                  dynamic>;
                                                              children.forEach(
                                                                      (key, value) {
                                                                    databaseObject
                                                                        .child(
                                                                        currentuser!.uid)
                                                                        .child(key)
                                                                        .remove();
                                                                  });
                                                            });
                                                            cartfinalItems
                                                                .remove(cart);
                                                            if (cartfinalItems
                                                                .isEmpty) {
                                                              databaseCart = false;
                                                            }
                                                            TotalPrice =
                                                                totalprice();
                                                          });
                                                          decrementLimit = true;
                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                              content: Text("Product Removed from cart",style: TextStyle(color: Colors.blue))));
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text("Yes"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            decrementLimit = true;
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text("No"),
                                                      )
                                                    ],
                                                  );
                                                });
                                          }
                                        },
                                      ),
                                      SizedBox(
                                          height: 20,
                                          width: 30,
                                          child: Container(
                                            child: Center(
                                              child: Text(
                                                  cartfinalItems[index]
                                                      .quantity
                                                      .toString()),
                                            ),
                                          )),
                                      GestureDetector(
                                        child: Icon(
                                            Icons.add_circle_outline_rounded,
                                            color: Colors.black26),
                                        onTap: () async {
                                          cartfinalItems[index].quantity =
                                              await quantityincrementCounter(
                                                  cart);
                                          setState(() {
                                            TotalPrice = totalprice();
                                          });
                                          if(!incrementLimit){
                                            showDialog(context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context){
                                              return AlertDialog(
                                                title: Text("Quantity limit Exceeds"),
                                                content: Text("To buy more Place an order and again add this item to your cart"),
                                                actions: [
                                                  TextButton(onPressed: (){
                                                    setState(() {
                                                      incrementLimit = true;
                                                    });
                                                    Navigator.pop(context);
                                                  }, child: Text("OK"))
                                                ],
                                              );
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 15),
                    child: Container(
                      child: Row(
                        children: [
                          Text(
                            "Total Amount:",
                            style: TextStyle(
                                color: Colors.purple.shade400,
                                fontSize: 20,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            "Rs.$TotalPrice",
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(context: context, builder:(BuildContext context){
            return AlertDialog(
              title: Text("Move all items to Order Section"),
              actions: [
                TextButton(onPressed: () async{
                   if(cartfinalItems.isNotEmpty){
                  await moveCartToOrder().then((value) => {
                    databaseObject.child(currentuser!.uid).remove().then((value){
                      setState(() {
                        cartfinalItems = [];
                        databaseCart = false;
                      });
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                          BottomBar(screenNumber: 2)), (Route<dynamic> route) => false);
                    }),
                  });
                }else{
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                         content: Text("Cart is Empty",)));
                     Navigator.pop(context);
                   }
             },
                  child: Text("yes"),
                ),
                TextButton(onPressed: () => Navigator.pop(context),
                  child: Text("No"),)
              ],
            );
          });

        },
          child: Icon(Icons.shopping_bag, size: 30),
        tooltip: "Move to Orders",
      ),
    );
  }
}
