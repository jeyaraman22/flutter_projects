import 'package:expand_widget/expand_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro_nullsafety/carousel_pro_nullsafety.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sample_ui/components/ratingbar.dart';


class OverviewScreen extends StatefulWidget {
  const OverviewScreen({Key? key}) : super(key: key);

  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> with
    TickerProviderStateMixin {
  double actualHeight = 380;
  double endscale = 1;
  late AnimationController animationController;
  late Animation<double> animation;
  final databaseObject = FirebaseDatabase.instance.ref('RoomTypes');

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(duration:const Duration(seconds: 2),
        vsync: this);
    animationController.forward();
    //animationController.
    animation = CurvedAnimation(curve:Curves.bounceOut, parent: animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Tween<double> tween = Tween(begin: 1 , end: endscale);
    return SafeArea(
      child: Scaffold(

        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
         child:ScaleTransition(
           scale:tween.animate(animation),
           child: Stack(
             children: <Widget>[
               SizedBox(
                 height: (endscale == 1) ? actualHeight : actualHeight+20,
                 child: GestureDetector(
                   onVerticalDragUpdate: (drag){
                     setState(() {
                       endscale = 1.1;
                     });
                   },
                   onVerticalDragEnd: (drag){
                     setState(() {
                       endscale = 1;
                     });
                   },
                   child: Carousel(
                       images: [
                         Image.asset("images/hotel1.jpg", fit: BoxFit.cover),
                         Image.asset("images/hotel2.jpg", fit: BoxFit.cover),
                         Image.asset("images/hotel3.jpg", fit: BoxFit.cover),
                         Image.asset("images/hotel4.jpg", fit: BoxFit.cover),
                         Image.asset("images/hotel5.jpg", fit: BoxFit.cover),
                       ],
                       autoplay: false,
                       animationDuration: const Duration(milliseconds: 800),
                       dotPosition: DotPosition.bottomRight,
                       dotVerticalPadding: 63,
                       dotHorizontalPadding: -5,
                       dotSize: 10,
                       dotIncreaseSize: 1.35,
                       dotSpacing: 18.0,
                       dotColor: Colors.grey,
                       dotBgColor: Colors.transparent,
                       borderRadius: true),
                 ),
               ),
               Padding(
                 padding: endscale == 1?const EdgeInsets.only(top: 305,bottom: 7):
                 const EdgeInsets.only(top: 325,bottom: 7),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.start,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Container(
                       margin: (endscale == 1)?const EdgeInsets.symmetric(horizontal: 14):
                                        const EdgeInsets.symmetric(horizontal: 25),
                       padding: const EdgeInsets.symmetric(
                           vertical: 10, horizontal: 10),
                       decoration: const BoxDecoration(
                         color: Colors.white,
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black38,
                             spreadRadius: 1,
                             blurRadius: 3
                           )],
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.start,
                             children: [
                               const Icon(Icons.preview_outlined),
                               const SizedBox(
                                 width: 2,
                               ),
                               const Expanded(child: RatingbarWidget()),
                               const SizedBox(
                                 width: 3.5,
                               ),
                               Padding(
                                 padding: const EdgeInsets.only(top: 2),
                                 child: RichText(
                                     text: const TextSpan(children: [
                                       TextSpan(
                                           text: "4.5",
                                           style: TextStyle(
                                               color: Colors.black,
                                               fontWeight: FontWeight.bold,
                                               fontFamily: 'ProximaNova')),
                                       TextSpan(
                                           text: "/5",
                                           style: TextStyle(
                                               color: Colors.black,
                                               fontFamily: 'ProximaNova')),
                                     ])),
                               ),
                               Padding(
                                 padding: const EdgeInsets.only(left: 94.2),
                                 child: TextButton(
                                   onPressed: () {},
                                   child: const Text(
                                     "View Reviews",
                                     style: TextStyle(
                                         color: Color(0xff008078),
                                         fontFamily: 'ProximaNova',
                                         fontWeight: FontWeight.bold),
                                   ),
                                 ),
                               )
                             ],
                           ),
                           const Text(
                             "Solymar Ivory Suites",
                             textScaleFactor: 1.4,
                             style: TextStyle(fontWeight: FontWeight.bold),
                           ),
                           const SizedBox(
                             height: 3,
                           ),
                           const Text(
                             "Egypt - Hurghada",
                             style: TextStyle(
                               color: Colors.black38,
                             ),
                           ),
                           const SizedBox(
                             height: 10,
                           ),
                           Row(
                             children: const [
                               Icon(
                                 Icons.airplanemode_on_outlined,
                                 color: Colors.black12,
                               ),
                               Text(
                                 "Distance to airport - 2.0 Km",
                                 textScaleFactor: 1.6,
                                 style:
                                 TextStyle(color: Colors.black38, fontSize: 8),
                               ),
                               SizedBox(
                                 width: 15,
                               ),
                               SizedBox(
                                 height: 25,
                                 child: VerticalDivider(
                                   color: Colors.black38,
                                   thickness: 0.7,
                                 ),
                               ),
                               SizedBox(
                                 width: 15,
                               ),
                               Icon(
                                 Icons.map_outlined,
                                 color: Colors.black26,
                                 size: 20,
                               ),
                               SizedBox(
                                 width: 5,
                               ),
                               Text(
                                 "Map View",
                                 textScaleFactor: 1.3,
                                 style: TextStyle(
                                     color: Colors.black38, fontSize: 10),
                               )
                             ],
                           ),
                           const SizedBox(
                             height: 17,
                           ),
                           const SizedBox(
                             height: 5,
                             child: Divider(
                               indent: 3,
                               endIndent: 3,
                               thickness: 0.6,
                               color: Colors.black54,
                             ),
                           ),
                           const SizedBox(
                             height: 17,
                           ),
                            ExpandText(
                             "Sunny skies and wonderful weather - its the perfect vacation gateway in  quite corner of Hurghada , just"
                                 " it is one of the Beautiful places to spend your vacations.",
                             textAlign: TextAlign.justify,
                             maxLines: 2,
                             overflow: TextOverflow.visible,
                             style: (endscale == 1)? const TextStyle(fontSize: 15):const TextStyle(fontSize: 14),
                             expandArrowStyle: ExpandArrowStyle.text,
                             capitalArrowtext: false,
                             arrowPadding: (endscale == 1)? const EdgeInsets.only( top: 2,bottom: 3,right: 274,):
                             const EdgeInsets.only( top: 5,bottom: 0,right: 252.5),
                             collapsedHint: "View More",
                             expandedHint: "View Less",
                             hintTextStyle: const TextStyle(color: Color(
                                 0xff008078)),
                           ),
                           //(endscale == 1)?SizedBox(height: 0,):SizedBox(height: 5,),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.start,
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                               const Icon(Icons.king_bed_outlined,color: Color(0xff188B84),size: 25,),
                               const SizedBox(width: 9,),
                               const Icon(Icons.breakfast_dining_outlined,color: Color(0xff188B84),size: 25),
                               const  SizedBox(width: 9,),
                               const Icon(Icons.call_outlined,color: Color(0xff188B84),size: 25),
                               const SizedBox(width: 9,),
                               const  Icon(Icons.view_in_ar,color: Color(0xff188B84),size: 25),
                               const SizedBox(width: 9,),
                               const  Icon(Icons.dinner_dining,color: Color(0xff188B84),size: 25),
                               Padding(
                                 padding: (endscale==1)?const EdgeInsets.only(left: 70):
                                 const EdgeInsets.only(left: 49)  ,
                                 child: TextButton(
                                   onPressed: () {print("SampleUi");},
                                   child: const Text(
                                     "View Amenities",
                                     style: TextStyle(
                                         color: Color(0xff008078),
                                         fontFamily: 'ProximaNova',
                                         fontWeight: FontWeight.bold),
                                   ),
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 5 ),
                           Row(mainAxisAlignment: MainAxisAlignment.start,
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                               OutlinedButton(onPressed:(){},
                                 style: OutlinedButton.styleFrom(
                                   backgroundColor:const Color(0xff008078),
                                   shape: const StadiumBorder(),
                                 ) ,
                                 child: const Padding(
                                   padding: EdgeInsets.symmetric(horizontal: 5,vertical: 13.5),
                                   child: Text("SELECT A ROOM",
                                     style: TextStyle(fontSize: 15.5,
                                         color: Colors.white,
                                         fontWeight: FontWeight.bold),),
                                 ),),
                               Padding(padding: const EdgeInsets.only(left: 100),
                                 child: RatingBarIndicator(
                                   rating: 3,
                                   itemBuilder: (context,index){
                                     return const Icon(Icons.star_rounded,
                                       color: Color(0xffCD8017),);
                                   },
                                   itemCount: 3,
                                   itemSize: 20,
                                   direction: Axis.horizontal,
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 8,),
                         ],
                       ),
                     ),
                     Container(
                       decoration: const BoxDecoration(
                         color: Colors.white,
                         boxShadow: [
                           BoxShadow(
                               color: Colors.black38,
                               spreadRadius: 1,
                               blurRadius: 3
                           )],
                       ),
                       margin: endscale == 1 ? const EdgeInsets.only(top: 10,left: 14,right: 14):
                       const EdgeInsets.only(top: 10,left: 25,right: 25),
                       padding: const EdgeInsets.symmetric(
                           vertical: 10, horizontal: 10),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.start,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Column(
                             mainAxisAlignment: MainAxisAlignment.start,
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: const [
                               Icon(Icons.alarm,size: 25,color: Colors.black26,),
                               SizedBox(height: 5,),
                               Text("Check-in",style: TextStyle(fontSize: 15,
                                   color: Colors.black38),),
                               SizedBox(height: 8,),
                               Text("After 2.00 PM",style: TextStyle(
                                   fontWeight: FontWeight.bold
                               ),),
                             ],
                           ),
                           Padding(
                             padding: const EdgeInsets.only(left: 100),
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.start,
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: const [
                                 Icon(Icons.alarm,size: 25,color: Colors.black26,),
                                 SizedBox(height: 5,),
                                 Text("Check-out",style: TextStyle(fontSize: 15,
                                     color: Colors.black38),),
                                 SizedBox(height: 8,),
                                 Text("Before 12.00 PM",style: TextStyle(
                                     fontWeight: FontWeight.bold
                                 ),),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                     Container(
                       decoration: const BoxDecoration(
                         color: Colors.white,
                         boxShadow: [
                           BoxShadow(
                               color: Colors.black38,
                               spreadRadius: 1,
                               blurRadius: 3
                           )],
                       ),
                       margin: endscale == 1 ? const EdgeInsets.only(top: 10,left: 14,right: 14):
                       const EdgeInsets.only(top: 10,left: 25,right: 25),
                       padding: const EdgeInsets.symmetric(
                           vertical: 10),
                       child: Theme(
                         data: ThemeData().copyWith(dividerColor: Colors.transparent),
                         child: ExpansionTile(
                           textColor: Colors.black,
                           collapsedTextColor: Colors.black,
                           collapsedIconColor: const Color(0xff008078),
                           iconColor:  const Color(0xff008078),
                           // trailing: Icon(Icons.keyboard_arrow_down_outlined,
                           //   color: Color(0xff008078),),
                           title: const Text("What Distinguishes Our Resort?",
                             style: TextStyle(fontWeight: FontWeight.bold),),
                           children: [
                             SizedBox(
                               height: 300,
                               child: Image.asset("images/hotel1.jpg",
                                 fit: BoxFit.cover,),
                             ),
                             Container(
                               padding:const EdgeInsets.symmetric(vertical: 30,horizontal: 15),
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.start,
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   const Text("Reasons to visit:",style: TextStyle(color: Colors.black54),),
                                   const SizedBox(height: 8,),
                                   /*RichText(text:TextSpan(
                                       text: "•",
                                         style: TextStyle(color: Colors.black54, fontSize: 12),
                                       children: [TextSpan(
                                           text: "Just  one  kilometer  away  from  Hurghada  Intenational Airport",
                                         style: TextStyle(color: Colors.black54,fontSize: 14),
                                       )
                                       ]
                                     )),*/
                                   Row(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: const[
                                       SizedBox(width: 10,child: Padding(
                                         padding: EdgeInsets.only(top: 2),
                                         child: Text("•", style: TextStyle(color: Colors.black87,fontSize: 13)),
                                       ),),
                                       SizedBox(
                                         width: 320,
                                         child: Text("Just one kilometer away from Hurghada Intenational Airport",
                                           softWrap: true,
                                           style: TextStyle(color: Colors.black54,height: 1.3),
                                           textAlign: TextAlign.justify,),
                                       )
                                     ],),
                                   const SizedBox(height: 8,),
                                   Row(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: const[
                                       SizedBox(width: 10,child: Padding(
                                         padding: EdgeInsets.only(top: 2),
                                         child: Text("•", style: TextStyle(color: Colors.black87,fontSize: 13)),
                                       ),),
                                       SizedBox(
                                         width: 320,
                                         child: Text("Walking   distance  from  the  centre  of   town   with easy access to shopping, dining and nightlife",
                                           softWrap: true,
                                           style: TextStyle(color: Colors.black54,height: 1.3),),
                                       )
                                     ],),
                                   const SizedBox(height: 8,),
                                   Row(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: const [
                                       SizedBox(width: 10,child: Padding(
                                         padding: EdgeInsets.only(top: 2),
                                         child: Text("•", style: TextStyle(color: Colors.black87,fontSize: 13)),
                                       ),),
                                       Text("Two Swimming pools",
                                         softWrap: true,
                                         style: TextStyle(color: Colors.black54,height: 1.3),)
                                     ],),
                                   const SizedBox(height: 8,),
                                   Row(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: const[
                                       SizedBox(width: 10,child: Padding(
                                         padding: EdgeInsets.only(top: 2),
                                         child: Text("•", style: TextStyle(color: Colors.black87,fontSize: 13)),
                                       ),),
                                       Text("A restaurant and Bar",
                                         softWrap: true,
                                         style: TextStyle(color: Colors.black54,height: 1.3),)
                                     ],),
                                   const SizedBox(height: 8,),
                                   Row(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: const[
                                       SizedBox(width: 10,child: Padding(
                                         padding: EdgeInsets.only(top: 2),
                                         child: Text("•", style: TextStyle(color: Colors.black87,fontSize: 13)),
                                       ),),
                                       Text("24 hour  reception  and  room   service   around  the \n clock",
                                         softWrap: true,
                                         style: TextStyle(color: Colors.black54,height: 1.3),)
                                     ],),
                                 ],
                               ),
                             ),
                           ],
                         ),
                       ),
                     )
                   ],
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
