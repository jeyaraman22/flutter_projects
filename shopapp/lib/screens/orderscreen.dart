import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shopapp/services/productmodel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' hide DayPicker;
import 'package:shopapp/components/daterange.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({Key? key}) : super(key: key);

  @override
  _MyOrderScreenState createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  List<orderModel> orderList = [];
  List<orderModel> temporderList = [];
  //List<List<productModel>> neworderList = [];
  List orderIdcount = [];
  bool dataOrdercheck = true;
  var TotalPrice;
  User? currentuser;
  DateTime? currentTime;
  String? orderID;
  DateTime date = DateTime.now();
  final dataorderObject = FirebaseDatabase.instance.ref('Orders');
  DatePeriod selectedPeriod = DatePeriod(
      DateTime.now().subtract(Duration(days: 2)),
      DateTime.now());
  DatePickerRangeStyles styles = DatePickerRangeStyles(
    selectedPeriodLastDecoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadiusDirectional.only(
            topEnd: Radius.circular(10.0), bottomEnd: Radius.circular(10.0))),
    selectedPeriodStartDecoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(10.0), bottomStart: Radius.circular(10.0)),
    ),
    selectedPeriodMiddleDecoration:
    BoxDecoration(color: Colors.yellow.shade400, shape: BoxShape.rectangle),
  );
  DateTime firstDate = DateTime(DateTime.now().year-50),
      lastDate = DateTime(DateTime.now().year+50);

  Future<List<orderModel>> productdatafromorderFirebase() async {
    List<orderModel> cartproductNames = [];
    Map<dynamic,dynamic> filtermap;
    var result = await http.get(Uri.parse(
        "https://shop-flut-app-default-rtdb.firebaseio.com/Orders.json"));
    var listavailable = jsonDecode(result.body);
    if (listavailable == null) {
      setState(() {
        dataOrdercheck = false;
      });
    }
    if (dataOrdercheck) {
      final decodedResult = jsonDecode(result.body);
      decodedResult.forEach((key, value) {
        var orderseparator = value as Map<String,dynamic>;
        orderseparator.forEach((keys, values) {
          if(values['orderby']== currentuser!.uid) {
            setState(() {
              cartproductNames.add(orderModel.fromJson(values));
            });
          }
          print("LENGth-${cartproductNames.length}");
        });

      });
      // neworderList = List.generate(orderIdcount.length, (index){
      //  final seprator = cartproductNames.where((element){
      //    return (orderIdcount[index] == element.orderID);
      //  }).toList();
      //   return seprator;
      // });
      // neworderList.forEach((elements) {
      //   elements.forEach((element) {
      //   });
      // });
      if(cartproductNames.isEmpty){
        setState(() {
          dataOrdercheck = false;
        });
      }
      return cartproductNames;
    }
    return cartproductNames;
  }

  Future removeorderItem(productModel orderItem)async{
    EasyLoading.show(status: "Removing Item..");
       dataorderObject.orderByKey().equalTo(orderItem.orderID).once().then((value) {
        var orderKey = value.snapshot.value as Map<dynamic,dynamic>;
        orderKey.forEach((keys, value) {
          dataorderObject.child(keys).orderByChild("name").equalTo(orderItem.name).once().then((value) {
            var autoKey = value.snapshot.value as Map<dynamic,dynamic>;
            autoKey.forEach((key, value) {
              dataorderObject.child(keys).child(key).remove().then((value) {
                setState(() {
                  orderList.remove(orderItem);
                  if(orderList.isEmpty){
                    dataOrdercheck = false;
                  }
                });
                EasyLoading.showSuccess("Removed..");
              });
            });
          });
        });
      });
  }

 /* filterselectionBox(BuildContext context){
    return showDialog(context: context,
        builder: (BuildContext context){
         return AlertDialog(
           title: Text("Want to pick a Single Date or Date Range "),
           actions: [
             TextButton(onPressed:(){
           datealertingBox(context).then((value) =>  Navigator.pop(context));

         }, child: Text("SingleDate")),
             TextButton(onPressed:(){
          dateRangealertingBox(context).then((value) =>  Navigator.pop(context));
          }, child: Text("DateRange")),
             TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancel"))
           ],
         );
        });
  }*/
  filterbydate(String date){
    DateTime selectedorderdate;
    selectedorderdate = DateFormat('dd/MM/yyyy').parse(date);
    setState(() {
      temporderList = orderList.where((element){
        return (selectedorderdate == DateFormat('dd/MM/yyyy').parse(element.orderDate!));
      }).toList();
    });
  }

  filterbydateRange(String startdate, String enddate) {
    DateTime firstDate, lastDate;
    firstDate = DateFormat('dd/MM/yyyy').parse(startdate);
    lastDate = DateFormat('dd/MM/yyyy').parse(enddate);
    print(firstDate);
    print(lastDate);
    setState(() {
      temporderList = orderList.where((element) {
        return ((firstDate
            .isBefore(DateFormat('dd/MM/yyyy').parse(element.orderDate!)) &&
            lastDate
                .isAfter(DateFormat('dd/MM/yyyy').parse(element.orderDate!))) ||
            ((firstDate == DateFormat('dd/MM/yyyy').parse(element.orderDate!)) ||
                (lastDate == DateFormat('dd/MM/yyyy').parse(element.orderDate!))));
      }).toList();
    });
  }

 /* datealertingBox(BuildContext context){
    return showDialog(context: context,
        builder: (BuildContext context){
        return StatefulBuilder(builder: (_,innerSetState){
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: 420,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(
                          "Select Date",
                          style: TextStyle(fontSize: 18),
                        )),
                    Expanded(
                      flex: 10,
                      child: CalendarDatePicker(
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(Duration(days: 365)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                          onDateChanged:(value){
                            innerSetState((){
                                  date = value;
                            });
                          }
                      ),
                      *//*child: DayPicker(
                          selectedDate: selectedDate,
                          currentDate: currentDate,
                          onChanged: onChanged,
                          firstDate: firstDate,
                          lastDate: lastDate,
                          displayedMonth: displayedMonth),*//*
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed:(){
                            setState(() {
                                  filterbydate(DateFormat('dd/MM/yyyy').format(date));
                            });
                            Navigator.pop(context);
                          }, child: Text("OK")),
                          TextButton(onPressed:(){
                            setState(() {
                              getorderList();
                            });
                            Navigator.pop(context);
                          }, child: Text("RESET")),
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
  }*/

 dateRangealertingBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (_, innerSetState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                height: 420,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Text(
                            "Select Date Range",
                            style: TextStyle(fontSize: 18),
                          )),
                      Expanded(
                        flex: 10,
                        child:DaterangePicker(
                          firstDate: firstDate,
                          lastDate: lastDate,
                          selectedPeriod: selectedPeriod,
                          onChanged: (DatePeriod range) {
                            innerSetState((){
                              selectedPeriod = range;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed:(){
                              setState(() {
                                filterbydateRange(DateFormat('dd/MM/yyyy').format(selectedPeriod.start),
                                    DateFormat('dd/MM/yyyy').format(selectedPeriod.end));
                              });
                              Navigator.pop(context);
                            }, child: Text("OK")),
                            TextButton(onPressed:(){
                              setState(() {
                                getorderList();
                              });
                              Navigator.pop(context);
                            }, child: Text("RESET")),
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

  getorderList() async {
    orderList = [];
    await productdatafromorderFirebase().then((value) {
      setState(() {
        orderList.addAll(value);
      });
      temporderList = orderList;
    });
    date = DateTime.now();
    selectedPeriod = DatePeriod(
        DateTime.now().subtract(Duration(days: 2)),
        DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    currentuser = FirebaseAuth.instance.currentUser;
    getorderList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My Orders"),
          actions: [
            IconButton(
                onPressed: () {
                 dateRangealertingBox(context);
                },
                icon: Icon(Icons.date_range_sharp))
          ],
        ),
        body: Column(
          children: [
        orderList.isEmpty
            ? dataOrdercheck
                ? Expanded(
                  child: Center(
                      child: CircularProgressIndicator(),
                    ),
                )
                : Expanded(
                  child: Container(
                      child: Center(
                        child: Text(
                          "No items found in Order Section.",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                )
            : temporderList.isEmpty?
        Expanded(
          child: Center(
            child: Container(
              child: Text(
                "No Items on picked Range",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        )
            :Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          padding: EdgeInsets.all(10),
                          itemCount: temporderList.length,
                          itemBuilder: (context,index){
                            final order = temporderList[index];
                            //TotalPrice = totalprice(order[index].orderID!);
                            return ExpansionTile(
                                 tilePadding: EdgeInsets.only(bottom: 10),
                                textColor: Colors.black,
                                collapsedTextColor: Colors.purple,
                                expandedAlignment: Alignment.topLeft,
                                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:  MainAxisAlignment.start,
                              children: [
                                Text("${order.orderId}",style: TextStyle(fontSize: 18),),
                                SizedBox(height: 5,),
                                Text("OrderTime: ${order.orderTime}",style: TextStyle(fontSize: 18),),
                                SizedBox(height: 5,),
                                Text("OrderAmount: Rs.${order.totalAmount}",style: TextStyle(fontSize: 18),)
                              ],
                            ),
                              // onExpansionChanged: (value){
                              //      setState(() {
                              //        temporderList = orderList.where((element){
                              //          return (element.orderID == order[index].orderID);
                              //        }).toList();
                              //      });
                              //      print("tempLength--${temporderList.length}");
                              // },
                              children: [
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: ScrollPhysics(),
                                    itemCount: order.orderProducts!.length,
                                    itemBuilder: (context,position){
                                      final items = order.orderProducts![position];
                                     // print("---${order[position].name}---");
                                    return ListTile(
                                      title:  Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 40,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Product : ${items.name}",style: TextStyle(fontSize: 18,color: Colors.teal),),
                                                SizedBox(height: 5,),
                                                Text("Quantity : ${items.quantity}",style: TextStyle(fontSize: 18,color: Colors.teal),),
                                                SizedBox(height: 5,),
                                                Text("Price : ${items.price}",style: TextStyle(fontSize: 18,color: Colors.teal),),
                                                SizedBox(height: 5,),
                                                // Divider(color: Colors.pink,height: 5,thickness: 5,indent: 100,endIndent: 100,)
                                              ],
                                            ),
                                          ),
                                         /* Expanded(
                                            child: GestureDetector(
                                              child: Icon(Icons.remove_circle_sharp,color: Colors.blueGrey,),
                                              onTap: () {
                                                showDialog(context: context, builder: (BuildContext context){
                                                  return AlertDialog(
                                                    title: Text("Want to remove this Item from Order Section"),
                                                    actions: [
                                                      TextButton(onPressed: () {
                                                        //removeorderItem(items).then((value) =>
                                                        Navigator.pop(context);
                                                      },
                                                          child: Text("Yes")),
                                                      TextButton(onPressed: () => Navigator.pop(context),
                                                          child: Text("No") )
                                                    ],
                                                  );
                                                });
                                              },
                                            ),
                                          )*/
                                        ],
                                      ),
                                    );
                                }),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   children: [
                                //     Expanded(
                                //       child: Column(
                                //         mainAxisAlignment: MainAxisAlignment.start,
                                //         crossAxisAlignment: CrossAxisAlignment.start,
                                //         children: [
                                //           Text("Product :${orderList[index].name}",style: TextStyle(fontSize: 18,color: Colors.teal),),
                                //           SizedBox(height: 5,),
                                //           Text("Quantity:${orderList[index].quantity}",style: TextStyle(fontSize: 18,color: Colors.teal),),
                                //           SizedBox(height: 5,),
                                //         ],
                                //       ),
                                //     ),
                                //     GestureDetector(
                                //       child: Icon(Icons.remove_circle_sharp,color: Colors.blueGrey,),
                                //       onTap: () {
                                //         showDialog(context: context, builder: (BuildContext context){
                                //           return AlertDialog(
                                //             title: Text("Want to remove this Item from Order Section"),
                                //             actions: [
                                //               TextButton(onPressed: () {
                                //                 removeorderItem(order).then((value) => Navigator.pop(context));
                                //               },
                                //               child: Text("Yes")),
                                //               TextButton(onPressed: () => Navigator.pop(context),
                                //               child: Text("No") )
                                //             ],
                                //           );
                                //         });
                                //       },
                                //     )
                                //   ],
                                // ),

                              ],
                            );
                          }
                          ),
                    ),
                  ],
                ),
            )
          ],
        ),
    );
  }
}
