import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shopapp/components/pricerange.dart';
import 'package:shopapp/screens/myproductdetailscreen.dart';
import 'package:shopapp/services/productmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:shopapp/components/daterange.dart';

class MyproductScreen extends StatefulWidget {
  MyproductScreen({Key? key}) : super(key: key);
  @override
  _MyproductScreenState createState() => _MyproductScreenState();
}

class _MyproductScreenState extends State<MyproductScreen> {
  User? currentuser;
  bool myproductCheck = true;
  List<productModel> myProducts = [];
  List<productModel> filterProducts = [];
  double priceFilter = 0;
  final databaseObject = FirebaseDatabase.instance.ref('Products');
  double firstprice = 0;
  double endprice = 20000;
  DateTime date = DateTime.now();
  DatePeriod selectedPeriod =
      DatePeriod(DateTime.now().subtract(Duration(days: 2)), DateTime.now());
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

  Future<List<productModel>> getproductdatafromFirebase() async {
    List<productModel> cartproductNames = [];
    var result = await http.get(Uri.parse(
        "https://shop-flut-app-default-rtdb.firebaseio.com/Products.json"));
    var listavailable = jsonDecode(result.body);
    if (listavailable == null) {
      setState(() {
        myproductCheck = false;
      });
    }
    if (myproductCheck) {
      final decodedResult = jsonDecode(result.body);
      decodedResult.forEach((key, value) {
        if (value['createdby'] == currentuser!.uid) {
          cartproductNames.add(productModel.fromJson(value));
        }
      });
      if (cartproductNames.isEmpty) {
        setState(() {
          myproductCheck = false;
        });
      }
      return cartproductNames;
    }
    return cartproductNames;
  }

  getcurrentuserList() async {
    myProducts = [];
    await getproductdatafromFirebase().then((value) {
      setState(() {
        myProducts.addAll(value);
      });
      filterProducts = myProducts;
    });
    firstprice = 0;
    endprice = 20000;
    date = DateTime.now();
    selectedPeriod =
        DatePeriod(DateTime.now().subtract(Duration(days: 2)), DateTime.now());
  }

  /*filterselectionBox(BuildContext context){
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
              },
                  child: Text("DateRange")),
              TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancel"))
            ],
          );
        });
  }*/

  filterbydate(String date) {
    DateTime selectedorderdate;
    selectedorderdate = DateFormat('dd/MM/yyyy').parse(date);
    setState(() {
      filterProducts = myProducts.where((element) {
        return (selectedorderdate ==
            DateFormat('dd/MM/yyyy').parse(element.date!));
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
      filterProducts = myProducts.where((element) {
        return ((firstDate
                    .isBefore(DateFormat('dd/MM/yyyy').parse(element.date!)) &&
                lastDate
                    .isAfter(DateFormat('dd/MM/yyyy').parse(element.date!))) ||
            ((firstDate == DateFormat('dd/MM/yyyy').parse(element.date!)) ||
                (lastDate == DateFormat('dd/MM/yyyy').parse(element.date!))));
      }).toList();
    });
  }

  /* Future datealertingBox(BuildContext context){
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
                        */ /*child: DayPicker(
                          selectedDate: selectedDate,
                          currentDate: currentDate,
                          onChanged: onChanged,
                          firstDate: firstDate,
                          lastDate: lastDate,
                          displayedMonth: displayedMonth),*/ /*
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
                                getcurrentuserList();
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

  demoBox(BuildContext context){
    return StatefulBuilder(builder:(_,innersetState){
      return DaterangePicker(selectedPeriod: selectedPeriod,
          firstDate: firstDate,
          lastDate: lastDate,
          onChanged: (DatePeriod range) {
            innersetState((){
              selectedPeriod = range;
            });
          },);
    });
  }

  dateRangealertingBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (_, innerSetState) {
            return Dialog(
              child: Container(
                height: 420,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Expanded(
                          child: Text(
                        "Select  Date",
                        style: TextStyle(fontSize: 18),
                      )),
                      Expanded(
                        flex: 10,
                        child: DaterangePicker(
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
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    filterbydateRange(
                                        DateFormat('dd/MM/yyyy')
                                            .format(selectedPeriod.start),
                                        DateFormat('dd/MM/yyyy')
                                            .format(selectedPeriod.end));
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text("OK")),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    getcurrentuserList();
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text("RESET")),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
          /*StatefulBuilder(builder: (_, innerSetState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child:Container(
                height: 420,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Text(
                            "Select  Date",
                            style: TextStyle(fontSize: 18),
                          )),
                      Expanded(
                        flex: 10,
                        child: RangePicker(
                          initiallyShowDate: DateTime.now(),
                          datePickerStyles: styles,
                          selectedPeriod: selectedPeriod,
                          onChanged: (value) {
                            innerSetState(() {
                              selectedPeriod = value;
                            });
                          },
                          firstDate: DateTime.now().subtract(Duration(days: 365)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
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
                                getcurrentuserList();
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
          });*/
        });
  }

  priceRangealertingBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (_, innerSetState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Container(
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Text(
                        "Select Price Range",
                        style: TextStyle(fontSize: 18),
                      )),
                      //SizedBox(height: 10,),
                      Expanded(
                        child: Priceslider(firstprice: firstprice, endprice: endprice, onChanged:(RangeValues values){
                          innerSetState((){
                            firstprice = values.start;
                            endprice = values.end;
                          });
                        })
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    filterProducts =
                                        myProducts.where((element) {
                                      return ((firstprice.round() <
                                              double.parse(element.price!)) &&
                                          (double.parse(element.price!) <
                                              endprice.round()));
                                    }).toList();
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text("OK")),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    getcurrentuserList();
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text("RESET")),
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

  @override
  void initState() {
    super.initState();
    currentuser = FirebaseAuth.instance.currentUser;
    getcurrentuserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("My ProductList"),
          actions: [
            IconButton(
                onPressed: () => priceRangealertingBox(context),
                icon: Icon(
                  Icons.filter_list_alt,
                  color: Colors.lightGreenAccent,
                )),
            /*IconButton(
              onPressed: () {
                setState(() {
                  getcurrentuserList();
                });
              },
              icon: Icon(Icons.restart_alt_outlined),
            ),*/
            IconButton(
                onPressed: () {
                  setState(() {
                    demoBox(context);
                    //dateRangealertingBox(context);
                  });
                },
                // DateTime startdate, endDate;
                // DateTimeRange? pickedDate = await showDateRangePicker(
                //     context: context,
                //     initialEntryMode: DatePickerEntryMode.calendar,
                //     firstDate: DateTime(DateTime.now().year-5),
                //     lastDate: DateTime(DateTime.now().year+5),
                //   initialDateRange: DateTimeRange(
                //     start: DateTime.now(),
                //     end: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1),
                //
                //   ),
                // );
                // if(pickedDate != null){
                //   print("START-${pickedDate.start}");
                //   print("END-${pickedDate.end}");
                //   filterbyDate(DateFormat('dd/MM/yyyy').format(pickedDate.start),
                //       DateFormat('dd/MM/yyyy').format(pickedDate.end));
                // }

                // DatePicker.showDatePicker(context,
                // onConfirm: (value){
                //   var selectedDate  = DateFormat('dd/MM/yyyy').format(value);
                //   print(selectedDate);
                // });
                icon: Icon(Icons.date_range_sharp))
          ],
        ),
        body: Column(children: [
          myProducts.isEmpty
              ? myproductCheck
                  ? Expanded(
                      child: Center(
                      child: CircularProgressIndicator(),
                    ))
                  : Expanded(
                      child: Center(
                        child: Container(
                          child: Text(
                            "Products yet to Add",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    )
              : filterProducts.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Container(
                          child: Text(
                            "No Items on picked Range",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                          itemCount: filterProducts.length,
                          itemBuilder: (context, index) {
                            final product = filterProducts[index];
                            return Container(
                              margin: EdgeInsets.all(8),
                              height: 180,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration:
                                          BoxDecoration(shape: BoxShape.circle),
                                      child: Image.network(
                                        product.image!,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name!,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          "Rs." + product.price!,
                                          style: TextStyle(
                                              color: Colors.lightGreen,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(height: 10),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            shape: StadiumBorder(),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                        "Want to remove this item"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          EasyLoading.show(
                                                              status:
                                                                  "Removing..");
                                                          setState(() {
                                                            databaseObject
                                                                .orderByChild(
                                                                    "name")
                                                                .equalTo(product
                                                                    .name)
                                                                .once()
                                                                .then((value) {
                                                              var children = value
                                                                      .snapshot
                                                                      .value
                                                                  as Map<
                                                                      dynamic,
                                                                      dynamic>;
                                                              children.forEach(
                                                                  (key, value) {
                                                                databaseObject
                                                                    .child(key)
                                                                    .remove()
                                                                    .then(
                                                                        (value) {
                                                                  EasyLoading
                                                                      .showSuccess(
                                                                          "Removed..");
                                                                  setState(() {
                                                                    filterProducts
                                                                        .remove(
                                                                            product);
                                                                    if (filterProducts
                                                                        .isEmpty) {
                                                                      myproductCheck =
                                                                          false;
                                                                    }
                                                                  });
                                                                }
                                                                        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        //     content: Text("Product Removed from List",style: TextStyle(color: Colors.blue))))
                                                                        );
                                                              });
                                                            });
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text("Yes"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text("No"),
                                                      )
                                                    ],
                                                  );
                                                });
                                          },
                                          child: const Text("Remove item",
                                              style: TextStyle(
                                                  color: Colors.green)),
                                        ),
                                        SizedBox(height: 5),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            shape: StadiumBorder(),
                                          ),
                                          onPressed: () async {
                                            var result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyproductDetail(
                                                            updateProduct:
                                                                product)));
                                            if (result == true) {
                                              setState(() {
                                                getcurrentuserList();
                                              });
                                            }
                                          },
                                          child: const Text("  Edit details  ",
                                              style: TextStyle(
                                                  color: Colors.green)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
          /* myProducts.isEmpty?Container():Container(
           padding: EdgeInsets.only(left: 10,right: 60),
           child: Row(
             children: [
               Text("Price Range ",style: TextStyle(fontSize: 17),),
               Expanded(
                 child: RangeSlider(
                   min: 0,
                   max: 100000,
                   //divisions: 10,
                   values: RangeValues(firstprice,endprice),
                   labels: RangeLabels(start,end),
                   onChanged:(values){
                     setState(() {
                       start = values.start.toString();
                       end = values.end.toString();
                       firstprice = values.start;
                       endprice = values.end;
                       filterProducts = myProducts.where((element) {
                         return ((firstprice.round()< double.parse(element.price!)) &&
                             (double.parse(element.price!) > endprice.round()));
                       }).toList();
                     });
                   },
                 ),
               ),
               // Expanded(
               //   child: Slider(
               //     min: 0,
               //     max: 100000,
               //     divisions: 100,
               //     label: "$priceFilter",
               //     value: priceFilter,
               //     onChanged:(value){
               //       setState(() {
               //         priceFilter = value;
               //         filterProducts = myProducts.where((element) {
               //           return (double.parse(element.price!) >= priceFilter.round());
               //         }).toList();
               //       });
               //     },
               //   ),
               // ),
             ],
           ),
         ),*/
        ]));
  }
}

class SetKey {
  final key = GlobalKey();
}
