import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shopapp/components/pricerange.dart';
import 'package:shopapp/screens/addproduct.dart';
import 'package:shopapp/screens/detailscreen.dart';
import 'package:shopapp/screens/loginscreen.dart';
import 'package:shopapp/services/productmodel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shopapp/screens/cartscreen.dart';
import 'package:shopapp/components/daterange.dart';


class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final databaseObject = FirebaseDatabase.instance.ref('cart');
  List<productModel> product = [];
  List<productModel> finalList = [];
  List<productModel> filteredList = [];
  String quantity = "1";
  bool overlayContainer = false;
  bool checker = false;
  bool addloader = false;
  List<productModel> cartProduct = [];
  bool databaseList = true;
  bool databaseCart = true;
  User? currentuser;
  productModel? detailitem;
  DateTime? currentTime;
  double firstprice=0;
  double endprice = 20000;

  bool crosscheck(productModel cartItems) {
    if(cartProduct.length == 0){
      setState(() {
        checker = false;
      });
    }
    for (var i = 0; i < cartProduct.length; i++) {
      productModel check = cartProduct[i];
      if (check.name == cartItems.name) {
        checker = true;
        break;
      } else {
        checker = false;
      }
    }
    return checker;
  }

   addtoCart(productModel cartItems) {
    setState(() {
      cartProduct.add(cartItems);
      databaseObject.child(currentuser!.uid).push().set({
        "name": cartItems.name,
        "price": cartItems.price,
        "image": cartItems.image,
        "desc": cartItems.description,
        "quantity": quantity
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Product Added to cart",style: TextStyle(color: Colors.green))));
  }

  Future<List<productModel>> productdatafromFirebase() async {
    List<productModel> productNames = [];
    var result = await http.get(Uri.parse(
        "https://shop-flut-app-default-rtdb.firebaseio.com/Products.json"));
    var listavailable = jsonDecode(result.body);
    if (listavailable == null) {
        databaseList = false;
    }else{
        databaseList = true;
    }
    if (databaseList) {
      final decodedResult = jsonDecode(result.body) as Map<String, dynamic>;
      decodedResult.forEach((key, value) {
        productNames.add(productModel.fromJson(value));
      });
      return productNames;
    }
    return productNames;
  }

  Future<List<productModel>> productdatafromcartFirebase() async {
    List<productModel> cartproductNames = [];
    var result = await http.get(Uri.parse(
        "https://shop-flut-app-default-rtdb.firebaseio.com/cart.json"));
    if (result.statusCode == 200) {
      var listavailable = jsonDecode(result.body);
      if (listavailable == null) {
          databaseCart = false;
      }
      if (databaseCart) {
        final decodedResult = jsonDecode(result.body);
        decodedResult.forEach((key, value) {
          cartproductNames.add(productModel.fromJson(value));
        });
        return cartproductNames;
      }
    }
    return cartproductNames;
  }

  getProductdata() async{
    product = [];
    await productdatafromFirebase().then((value) {
      product.addAll(value);
      print("product-Length:${product.length}");
    });
    setState(() {
      filteredList = product;
      addloader = false;
    });
    firstprice = 0;
    endprice = 20000;
  }

  getcartProduct() {
    productdatafromcartFirebase().then((value) {
        cartProduct.addAll(value);
        print("CARTproduct-Length:${cartProduct.length}");
    });
  }

  fetchloading(){
    EasyLoading.showSuccess("Product Added Start Shopping").then((value) => getProductdata());
  }

  alertingBox(BuildContext context){
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (_, innerSetState){
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20.0)), //this right here
              child: Container(
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: Text("Select Price Range",
                        style: TextStyle(
                            fontSize: 18
                        ),)),
                      //SizedBox(height: 10,),
                      Expanded(
                        child: Priceslider(firstprice: firstprice, endprice: endprice, onChanged:(RangeValues values){
                          innerSetState((){
                            firstprice = values.start;
                            endprice = values.end;
                          });
                        })

                        /*SliderTheme(
                          data: SliderThemeData(
                            showValueIndicator: ShowValueIndicator.always,
                          ),
                          child: RangeSlider(
                            min: 0,
                            max: 100000,
                            divisions: 50,
                            values: RangeValues(firstprice,endprice),
                            labels: RangeLabels(firstprice.round().toString(),
                                endprice.round().toString()),
                            onChanged:(values){
                              innerSetState((){
                                firstprice = values.start;
                                endprice = values.end;
                              });
                            },
                          ),
                        ),*/
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: (){
                              setState(() {
                                filteredList = product.where((element) {
                                  return ((firstprice.round()< double.parse(element.price!)) &&
                                      (double.parse(element.price!) < endprice.round()));
                                }).toList();
                              });
                              Navigator.pop(context);
                            },
                                child:Text("OK")),
                            TextButton(onPressed: (){
                              setState(() {
                                getProductdata();

                              });
                              Navigator.pop(context);
                            },
                                child:Text("RESET")),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  void initState() {
    super.initState();
    currentuser = FirebaseAuth.instance.currentUser;
    getProductdata();
    getcartProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Just Shop !!"),
        actions: [
          IconButton(onPressed:()=>alertingBox(context),
              icon:Icon(Icons.filter_list_alt,color: Colors.lightGreenAccent,)),
          Stack(
            children: [
              Container(
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(children: [
                    Center(
                      child: IconButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => cartScreen(),
                                ));
                            if (result != "empty") {
                              setState(() {
                                cartProduct = [];
                                cartProduct.addAll(result);
                              });
                            } else {
                              setState(() {
                                cartProduct = [];
                              });
                            }
                          },
                          icon: Icon(Icons.shopping_cart)),
                    ),
                    (cartProduct.length > 0)
                        ? Positioned(
                        right: 5.0,
                        child: Stack(
                          children: <Widget>[
                            Icon(
                              Icons.brightness_1,
                              size: 20.0,
                              color: Colors.black26,
                            ),
                            Positioned(
                                top: 3.0,
                                right: 6.0,
                                child: Center(
                                  child: Text(
                                    cartProduct.length.toString(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )),
                          ],
                        ))
                        : Container()
                  ]),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
                child: Icon(Icons.logout),
              onTap: () {
                  showDialog(context: context, builder:(BuildContext context){
                    return AlertDialog(
                      title: Text("want to Logout"),
                      actions: [
                        TextButton(onPressed: () async{
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                              LoginScreen()), (Route<dynamic> route) => false);
                        }, child: Text("yes"),),
                        TextButton(onPressed: () => Navigator.pop(context),
                          child: Text("No"),)
                      ],
                    );
                  });
              },
            ),
          ),
        ],
      ),
      body: Column(
    children: [
    addloader?Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ):product.isEmpty
          ? databaseList
          ? Expanded(
            child: Center(
        child: CircularProgressIndicator(),
      ),
          )
          : Expanded(
            child: Center(
            child: Container(
              child: Text(
                "No products in the List, Please Add the product",
                style: TextStyle(fontSize: 18),
              ),
            )),
          )
          : filteredList.isNotEmpty? Expanded(
            child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  return Container(
                    margin: EdgeInsets.all(8),
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            decoration:
                            BoxDecoration(shape: BoxShape.circle),
                            child: Image.network(
                              item.image!,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  item.name!,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700),
                                ),
                                //SizedBox(height: 10),
                                Text(
                                  "RS." + item.price!,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                                //SizedBox(height: 10),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      shape: StadiumBorder()),
                                  onPressed: () async {
                                    var result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                detailScreen(
                                                    detailItems: item)));
                                    if (result != 0) {
                                      setState(() {
                                        cartProduct = [];
                                        cartProduct.addAll(result);
                                      });
                                    } else {
                                      setState(() {
                                        cartProduct = [];
                                      });
                                    }
                                  },
                                  child: const Text(
                                    "ViewDetails",
                                    style: TextStyle(color: Colors.brown),
                                  ),
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      shape: StadiumBorder()),
                                  onPressed: () async {
                                    var removeDuplicates =
                                    await crosscheck(item);
                                    removeDuplicates
                                        ? ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                        content: Text(
                                            "This item is already added")))
                                        : addtoCart(item);


                                    // if (checkList.contains(item)) {
                                    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    //       content: Text("This item is already added")));
                                    // } else {
                                    //   setState(() {
                                    //    addtoCart(item);
                                    //   });
                                    // }
                                    // setState(() {
                                    //   cartProduct.add(item);
                                    //   if (!cartProduct.contains(item)) {
                                    //     setState(() {
                                    //       databaseObject.child("cartitems").push().set({
                                    //         "name": item.name,
                                    //         "price": item.price,
                                    //         "image": item.image,
                                    //         "desc": item.description,
                                    //       });
                                    //       ++cartnumber;
                                    //     });
                                    //   }
                                    //   // addtoCart(item);
                                    // });
                                  },
                                  child: const Text(
                                    " AddtoCart ",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                ),
          ): Expanded(
            child: Center(child: Container(
        child: Text(
            "No Items Available,Above selected PriceRange",
            style: TextStyle(fontSize: 18),
        ),
      ),
    ),
          ),
      // product.isEmpty?Container():Container(
      //   padding: EdgeInsets.only(left: 10,right: 60),
      //   child: Row(
      //     children: [
      //       Text("Price Range",style: TextStyle(fontSize: 17 ),),
      //      /* Expanded(
      //         child: RangeSlider(
      //           min: 0,
      //           max: 100000,
      //            //divisions: 10,
      //           values: RangeValues(firstprice,endprice),
      //           labels: RangeLabels(start,end),
      //           onChanged:(values){
      //             setState(() {
      //               start = values.start.toString();
      //               end = values.end.toString();
      //               firstprice = values.start;
      //               endprice = values.end;
      //               filteredList = product.where((element) {
      //                 return ((firstprice.round()< double.parse(element.price!)) &&
      //                     (double.parse(element.price!) > endprice.round()));
      //               }).toList();
      //             });
      //             print("start-$firstprice---end$endprice");
      //           },
      //         ),
      //       ),*/
      //     ],
      //   ),
      // ),
      ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddproductScreen()));
          if (result == true) {
            setState(() {
              addloader = true;
            });
            getProductdata();
          }
        },
        child: Icon(Icons.add, size: 20),
      ),
    );
  }
}

// Expanded(child: Slider(
// min: 0,
// max: 10000,
// divisions: 10,
// label: "$priceFilter",
// value: priceFilter,
// onChanged:(value){
// setState(() {
// priceFilter = value;
// filteredList = product.where((element) {
// return (double.parse(element.price!) >= priceFilter.round());
// }).toList();
// });
// },
// ),
// ),