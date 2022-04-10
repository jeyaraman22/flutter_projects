import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController pageController = PageController(initialPage: 0,viewportFraction: 0.9);
  @override
  void initState() {
    super.initState();
  }
  // List<OfferModel> offerlistDemo = [];
  // fetchData() {
  //   List<OfferModel> dummyofferList= [];
  //   return FirebaseFirestore.instance.collection("offers").snapshots().map((offerData){
  //     for(final DocumentSnapshot<Map<String,dynamic>> doc in offerData.docs){
  //       dummyofferList.add(OfferModel.fromDocumentSnapshot(doc: doc));
  //     }
  //     print("OFFER LIST LENGTH -- ${dummyofferList.length}");
  //     offerlistDemo = dummyofferList;
  //     dummyofferList = [];
  //     return offerlistDemo;
  //   });
  // }
 @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
     double height = MediaQuery.of(context).size.height;
     double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Jaz offer section",style: TextStyle(
          color: Color(0xff108079)
        ),),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("offers").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            print("STREAMBUILDER called");
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Container(
              margin: EdgeInsets.only(
                  left: width * 0.038, right: width * 0.038),
              height:
              MediaQuery.of(context).size.height * 0.475,
              // width: MediaQuery.of(context).size.width * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                boxShadow: null,
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: height * 0.02, bottom: 10),
                    height: height * 0.416,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: snapshot.data?.docs.length,
                        itemBuilder:(BuildContext context, int index){
                        //OfferModel offerData = snapshot.data![index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Row(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                  ),
                                  height: height * 0.372,
                                  width: width * 0.883 - 40,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                       Image.network(snapshot.data?.docs[index]['image'],
                                        // offerList[
                                        // appUtility.isTablet(
                                        //     context)
                                        //     ? index * 2
                                        //     : index],
                                        fit: BoxFit.cover,
                                        width: width,
                                        //height:  MediaQuery.of(context).size.height * 0.416,
                                        height: height * 0.32,
                                      ),
                                      Container(
                                        height: height * 0.052,
                                        padding: const EdgeInsets.only(bottom: 5,top: 10,left: 10,right: 10),
                                        color: const Color(0xff108079),
                                        child: Text(
                                          snapshot.data?.docs[index]['desc'],
                                            maxLines: 2,
                                        style: const TextStyle(color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600),),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: pageController,
                      count: (snapshot.data?.docs.length)!,
                    effect: ExpandingDotsEffect(
                        activeDotColor: Color(0xff108079),
                        dotColor: Colors.grey,
                        dotWidth: snapshot.data?.docs.length == 1
                            ? 0
                            : MediaQuery.of(context)
                            .size
                            .width *
                            0.02,
                        dotHeight: snapshot.data?.docs.length == 1
                            ? 0
                            : MediaQuery.of(context)
                            .size
                            .width *
                            0.02),
                  )
                ],
              ),
            );
          }
        ),
      ),
          );
  }
}

// class OfferModel{
//   String image,desc,promocde;
//   OfferModel({required this.image, required this.desc, required this.promocde});
//
//   factory OfferModel.fromDocumentSnapshot({required DocumentSnapshot<Map<String,dynamic>> doc}){
//     return OfferModel(
//         promocde: doc.data()!['promocode'],
//       image: doc.data()!['image'],
//       desc: doc.data()!['desc'],
//     );
//   }
// }