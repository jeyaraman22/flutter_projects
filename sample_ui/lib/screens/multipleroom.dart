import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carousel_pro_nullsafety/carousel_pro_nullsafety.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sample_ui/screens/bookingroom.dart';
import 'package:sample_ui/services/modelclass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MultipleroomScreen extends StatefulWidget {
  const MultipleroomScreen({Key? key}) : super(key: key);

  @override
  _MultipleroomScreenState createState() => _MultipleroomScreenState();
}

class _MultipleroomScreenState extends State<MultipleroomScreen> {
  bool onContinue1 = false;
  bool onContinue2 = false;
  bool onContinue3 = false;
  final databaseroomObject = FirebaseDatabase.instance.ref('SelectedRooms');
  List<HotelRoom> hotelRoom = [];
  List continueBooking = [];
  List<HotelRoom> shareList = [];
  bool checker = true;
  bool editChecker = false;
  int? editIndex ;


  Future<List<HotelRoom>> hotelroomfromFirebase() async {
    List<HotelRoom> room = [];
    var result = await http.get(Uri.parse(
        "https://multi-room-default-rtdb.firebaseio.com/RoomTypes.json"));
    if (result.statusCode == 200) {
      final decodedResult = jsonDecode(result.body) as Map<String, dynamic>;
      decodedResult.forEach((key, value) {
        room.add(HotelRoom.fromJson(value));
      });
    }
    return room;
  }

  getroomData() async {
    await hotelroomfromFirebase().then((value) {
      setState(() {
        hotelRoom = value;
        continueBooking = List<bool>.generate(hotelRoom.length, (i) => false);
      });
    });
  }

  @override
  void initState() {
    getroomData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return hotelRoom.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: hotelRoom.length,
            itemBuilder: (BuildContext context, index) {
              var room = hotelRoom[index];
              return Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black38,
                        spreadRadius: 1,
                        blurRadius: 3)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 350,
                      child: Carousel(
                        images: [
                          Image.network(room.image1!,
                              fit: BoxFit.cover),
                          Image.network(room.image2!,
                              fit: BoxFit.cover),
                        ],
                        autoplay: false,
                        dotBgColor: Colors.transparent,
                        dotPosition: DotPosition.bottomRight,
                        dotColor: Colors.grey,
                        dotSize: 10,
                        dotIncreaseSize: 1.35,
                        dotSpacing: 20.0,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Text(
                        room.name!,
                        //textScaleFactor: 1.25,
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 12, right: 12, bottom: 5),
                      child: const ExpandText(
                        "Sunny skies and wonderful weather - its the perfect vacation gateway in  quite corner of Hurghada , just"
                        " it is one of the Beautiful places to spend your vacations.",
                        textAlign: TextAlign.justify,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        style: TextStyle(fontSize: 15),
                        expandArrowStyle: ExpandArrowStyle.text,
                        capitalArrowtext: false,
                        arrowPadding: EdgeInsets.only(
                          top: 2,
                          bottom: 3,
                          right: 274,
                        ),
                        collapsedHint: "View More",
                        expandedHint: "View Less",
                        hintTextStyle:
                            TextStyle(color: Color(0xff008078)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        List<bool> checkingBooking = [];
                        setState(() {
                          if(continueBooking[index] == false){
                            for(int i=0;i<continueBooking.length;i++){
                               checkingBooking.add(false);
                            }
                            continueBooking = checkingBooking;
                              continueBooking[index] = !continueBooking[index];
                          }else {
                            continueBooking[index] = !continueBooking[index];
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        height: 65,
                        decoration: continueBooking[index]
                            ? const BoxDecoration(
                                color: Color(0xff008078),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black38,
                                      spreadRadius: 1,
                                      blurRadius: 3)
                                ],
                              )
                            : const BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black38,
                                      spreadRadius: 1,
                                      blurRadius: 3)
                                ],
                              ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Member Rate Room Only",
                                  style: continueBooking[index]
                                      ? const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15)
                                      : const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 15),
                                ),
                                Text(
                                  "Basis",
                                  style: continueBooking[index]
                                      ? const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15)
                                      : const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 35,
                            ),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(room.price!,
                                        style: continueBooking[index]
                                            ? const TextStyle(
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 20,
                                              )
                                            : const TextStyle(
                                                color:
                                                    Color(0xff008078),
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 20,
                                              )),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      "US\$",
                                      style: continueBooking[index]
                                          ? const TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.bold,
                                            )
                                          : const TextStyle(
                                              color: Color(0xff008078),
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  "Excl. Taxes & Fees",
                                  style: continueBooking[index]
                                      ? const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15)
                                      : const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 15),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      padding: const EdgeInsets.only(
                          top: 5, bottom: 5, left: 173),
                      child: continueBooking[index]
                          ? OutlinedButton(
                              onPressed: () async{
                                  if(editChecker){
                                    shareList[editIndex!] = room;
                                    SharedPreferences prefs = await SharedPreferences
                                        .getInstance();
                                    final String encodedData = HotelRoom.encode(
                                        shareList);
                                    await prefs.setString(
                                        "roomlist", encodedData);
                                    setState(() {editChecker = false;});
                                  }else
                                if(shareList.length<3) {
                                  if(checker){
                                  shareList.add(room);}
                                  SharedPreferences prefs = await SharedPreferences
                                      .getInstance();
                                  final String encodedData = HotelRoom.encode(
                                      shareList);
                                  await prefs.setString(
                                      "roomlist", encodedData);
                                }else{
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                      content: Text(
                                          "Please complete the selected room(s) Booking, Limit shouldn't exceed more than 3")
                                  )
                                  );
                                }
                                var result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                    const BookingroomScreen(),
                                  ),
                                );
                                if(result == null){
                                  setState(() {
                                    shareList = [];
                                    checker = true;
                                    continueBooking[index] = !continueBooking[index];
                                  });
                                }else
                                  if((result == 0)||(result == 1)||(result == 2)){
                                    setState(() {
                                      continueBooking[index] = !continueBooking[index];
                                      editIndex = result;
                                      editChecker = true;
                                    });
                                  }
                                else
                                  if(result.length == 3){
                                  setState(() {
                                    checker = false;
                                    shareList = result;
                                    continueBooking[index] = !continueBooking[index];
                                  });
                                }else{
                                  setState(() {
                                    checker = true;
                                    shareList = result;
                                    continueBooking[index] = !continueBooking[index];
                                  });
                                }
                                // EasyLoading.show(status: "");
                                // databaseroomObject.push().set({
                                //   "name": "Suite, Twin Bed",
                                //   "price": "79"
                                // }).then((value) {
                                //   EasyLoading.showSuccess("");
                                //   Navigator.of(context).push(
                                //     MaterialPageRoute(
                                //       builder: (BuildContext context) =>
                                //           BookingroomScreen(),
                                //     ),
                                //   );
                                // });

                                },
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xff008078),
                                shape: const StadiumBorder(),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 13.5),
                                child: Text(
                                  "CONTINUE BOOKING",
                                  style: TextStyle(
                                      fontSize: 15.5,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          : OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xff008078),
                                shape: const StadiumBorder(),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 13.5),
                                child: Text(
                                  "VIEW MORE RATES",
                                  style: TextStyle(
                                      fontSize: 15.5,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                    )
                  ],
                ),
              );
            });
  }
}
