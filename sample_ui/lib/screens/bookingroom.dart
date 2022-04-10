import 'package:flutter/material.dart';
import 'package:sample_ui/services/modelclass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingroomScreen extends StatefulWidget {
  const BookingroomScreen({Key? key}) : super(key: key);

  @override
  _BookingroomScreenState createState() => _BookingroomScreenState();
}

class _BookingroomScreenState extends State<BookingroomScreen> {
  List<HotelRoom> hotelRoom=[];

 getroomData()async{
   SharedPreferences prefs = await SharedPreferences.getInstance();
   final roomlist = prefs.getString("roomlist")??"";
   setState(() {
     hotelRoom = HotelRoom.decode(roomlist);
   });
 }

  @override
  void initState() {
    getroomData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 2,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Padding(padding: EdgeInsets.only(left: 20)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xff008078),
                          size: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Back",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 220),
                    child: Text(
                      "Summary",
                      style: TextStyle(
                          //fontFamily: 'ProximaNova',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black45, spreadRadius: 1, blurRadius: 3)
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      const Text("Booking Details"),
                      const SizedBox(
                        width: 147,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Tap to modify",
                            style: TextStyle(
                                color: Colors.transparent,
                                //fontFamily: 'ProximaNova',
                                shadows: [
                                  Shadow(
                                      offset: Offset(0, -1.5),
                                      color: Color(0xff008078))
                                ],
                                //fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.solid,
                                decorationColor: Color(0xff008078),
                                decorationThickness: 2.5)),
                      )
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.black38,
                  indent: 8,
                  endIndent: 8,
                  //height: 5,
                  thickness: 0.6,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: hotelRoom.length,
                    itemBuilder: (BuildContext context, index) {
                      var rooms = hotelRoom[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 12,bottom: 15),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Room ${index + 1}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        (rooms.name)!,
                                        style: const TextStyle(
                                            color: Colors.black54, fontSize: 15),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                          "3 nights, 2 adults, 0 children, "),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                          "Mon 10 Jan - Thu 13 Jan (3 nights)"),
                                    )
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            const Text(
                                              "US\$",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              (rooms.price)!,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                         const SizedBox(height: 42,),
                                         GestureDetector(
                                           onTap: ()=>Navigator.of(context).pop(index),
                                           child: const Text(
                                                  "Edit",
                                                  style: TextStyle(
                                                      color: Colors.transparent,
                                                      //fontFamily: 'ProximaNova',
                                                      shadows: [
                                                        Shadow(
                                                            offset: Offset(0, -1.5),
                                                            color: Color(0xff008078))
                                                      ],
                                                      //fontWeight: FontWeight.bold,
                                                      decoration:
                                                          TextDecoration.underline,
                                                      decorationStyle:
                                                          TextDecorationStyle.solid,
                                                      decorationColor:
                                                          Color(0xff008078),
                                                      decorationThickness: 2.5),
                                                ),
                                         )
                                            /* const Text(
                                                "Remove",
                                                style: TextStyle(
                                                    color: Colors.transparent,
                                                    //fontFamily: 'ProximaNova',
                                                    shadows: [
                                                      Shadow(
                                                          offset: Offset(0, -1.5),
                                                          color: Color(0xff008078))
                                                    ],
                                                    //fontWeight: FontWeight.bold,
                                                    decoration:
                                                        TextDecoration.underline,
                                                    decorationStyle:
                                                        TextDecorationStyle.solid,
                                                    decorationColor:
                                                        Color(0xff008078),
                                                    decorationThickness: 2.5),
                                              ),*/
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          index == 0?Container():Container(
                            margin: const EdgeInsets.only(left: 12,bottom: 12),
                            child: GestureDetector(
                              onTap: (){
                                showDialog(context: context, builder: (BuildContext context){
                                  return AlertDialog(
                                    title: const Text("Are you sure"),
                                    actions: [
                                      TextButton(onPressed: () {
                                        setState(() {
                                          hotelRoom.remove(rooms);
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Yes")),
                                      TextButton(onPressed: () =>Navigator.pop(context),
                                          child: const Text("No")),
                                    ],
                                  );
                                });

                              },
                              child: const Text("Remove",
                                style: TextStyle(
                                  color: Colors.transparent,
                                  //fontFamily: 'ProximaNova',
                                  shadows: [
                                    Shadow(
                                        offset: Offset(0, -1.5),
                                        color: Colors.pink)
                                  ],
                                  //fontWeight: FontWeight.bold,
                                  decoration:
                                  TextDecoration.underline,
                                  decorationStyle:
                                  TextDecorationStyle.solid,
                                  decorationColor:Colors.pink,
                                  decorationThickness: 2.5),),
                            ),
                          ),
                        ],
                      );
                    }),
                const Divider(
                  color: Colors.black26,
                  indent: 8,
                  endIndent: 8,
                  thickness: 0.6,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(hotelRoom),
                        // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                        // MyHomePage(screenNumber: 1)), (Route<dynamic> route) => false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xff008078),
                      shape: const StadiumBorder(),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                      child: Text(
                        "Select Next Room",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
