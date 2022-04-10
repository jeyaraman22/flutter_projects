import 'package:flutter/material.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  List<bool> selected = [true,false,false];
  int adultCount = 1;
  int childCount = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              color: Colors.black12,
              child: ToggleButtons(
                  selectedColor: Colors.white,
                  borderColor: Colors.transparent,
                  //borderRadius: BorderRadius.circular(15),
                  color:Colors.black87,
                  fillColor:  const Color(0xff008078),
                  children: const [
                    SizedBox(
                      width: 121.5,
                        child: Center(child: Text("Room1",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        )
                          ,))),
                    SizedBox(
                        width: 121.5,
                        child: Center(child: Text("2 Rooms",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ))),
                    SizedBox(
                        width: 121.5,
                        child: Center(child: Text("3 Rooms",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ))),
                  ],
                  onPressed: (int index) {
                     selected = [false,false,false];
                    setState(() {
                      selected[index] = true;
                    });
                  },
                isSelected: selected,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black38,
                      spreadRadius: 1,
                      blurRadius: 3)
                ],
              ),
              //margin: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
              padding: const EdgeInsets.only(top: 10,left: 10,right: 10,bottom: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                    padding: const EdgeInsets.only(left: 5,top: 5),
                    child: Text("$adultCount Adults - $childCount Children",
                    style: const TextStyle(
                      color: Color(0xff008078),
                    ),),
                  ),
                  const SizedBox(height: 8,),
                  const Divider(
                    color: Colors.black45,
                    indent: 8,
                    endIndent: 8,
                    thickness: 0.6,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("Adults",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                                ),
                                Text("per room",
                                  style: TextStyle(
                                    color: Colors.black54
                                  ),
                                )
                              ],
                            ),
                            Container(
                              width: 100,
                              height: 45,
                              decoration: BoxDecoration(
                                  color: const Color(0xffF3F3F3),
                                  borderRadius: BorderRadius.circular(7)
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children:  [
                                  GestureDetector(
                                    onTap: (){
                                      if(adultCount>1) {
                                        setState(() {
                                          adultCount -= 1;
                                        });
                                      }
                                    },
                                    child: const Icon(Icons.remove_circle_outline_sharp,
                                    color: Color(0xff008078),),
                                  ),
                                   Text("$adultCount",
                                    style:const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xff008078)
                                  ) ,),
                                  GestureDetector(
                                    onTap: (){
                                      if(adultCount<5) {
                                        setState(() {
                                          adultCount += 1;
                                        });
                                      }
                                    },
                                    child: const Icon(Icons.add_circle_outline_sharp,
                                      color: Color(0xff008078),),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("Child",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),),
                                Text("per room",
                                  style: TextStyle(
                                      color: Colors.black54
                                  ),)
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: const Color(0xffF3F3F3),
                                  borderRadius: BorderRadius.circular(7)
                              ),
                              width: 100,
                              height: 45,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children:  [
                                  GestureDetector(
                                    onTap:(){
                                      if(childCount>0){
                                        setState(() {
                                          childCount -= 1;
                                        });
                                      }
                                    },
                                    child: const Icon(Icons.remove_circle_outline_sharp,
                                      color: Color(0xff008078),),
                                  ),
                                   Text("$childCount",
                                    style:const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xff008078)
                                    ) ,),
                                  GestureDetector(
                                    onTap:(){
                                      if(childCount<5){
                                        setState(() {
                                          childCount += 1;
                                        });
                                      }
                                    },
                                    child: const Icon(Icons.add_circle_outline_sharp,
                                      color: Color(0xff008078),),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 5,),
                  const Divider(
                    color: Colors.black26,
                    indent: 8,
                    endIndent: 8,
                    thickness: 0.6,
                  ),
                ],
              ) ,
            ),
            Padding(
              padding:  const EdgeInsets.only(top: 20,left: 15,right: 15),
              child: OutlinedButton(
                onPressed: () {},
                // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                // MyHomePage(screenNumber: 1)), (Route<dynamic> route) => false),
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size.fromWidth(310),
                  maximumSize: Size.fromHeight(45),
                  backgroundColor: const Color(0xff008078),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  "CONFIRM",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
