import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_app/crud_firebase/model/modelclass.dart';
import 'package:test_app/maps_markers/mapscreen.dart';
import 'add_edit_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int itemCount = 5;
  List<Chemicalproduct> productList = [];
  ScrollController scrollControl = ScrollController();
  bool checker = true;

   getData()async{
     productList = [];
     List<DocumentSnapshot<Map<String,dynamic>>> tempList;
     print("Get DAta");
     QuerySnapshot responseData = await FirebaseFirestore.instance.collection("chemicals").orderBy("createdAt",descending:true).get();

     tempList = responseData.docs as List<DocumentSnapshot<Map<String,dynamic>>>;
     for (final DocumentSnapshot<Map<String,dynamic>> docs in tempList){
       setState(() {
         productList.add(Chemicalproduct.fromDocumentSnapshot(doc: docs));
       });

     }
     print(productList.length);
  }
  Future<void> onRefresh(){
    return Future.delayed(const Duration(seconds: 1)).then((value){
      setState(() {
        getData();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    scrollControl.addListener(() {
      if (scrollControl.position.pixels
          == scrollControl.position.maxScrollExtent) {
        if(productList.length != itemCount) {
          setState(() {
            itemCount += 1;
          });
        }
        print("*****ITEMCOUNT*****  $itemCount");
        //getData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("*******************************${productList.length}");
    print("checker-$checker");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drop_Form"),
        actions: [
          IconButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(
              builder: (context)=>MapScreen())),
            icon: const Icon(Icons.map),),
          IconButton(onPressed: ()async{
            var data = await Navigator.push(
                context, MaterialPageRoute(builder: (context)=> AddEditScreen(action: "add")));
            if(data == true){
              setState(() {
                checker = false;
                getData();
              });
            }
          },
            icon: const Icon(Icons.add),),
          IconButton(onPressed:()async{
            var data = await Navigator.push(
                context, MaterialPageRoute(builder: (context)=> AddEditScreen(action: "Edit")));
            if(data != null){
              setState(() {
                getData();
              });
            }
          },
              icon: const Icon(Icons.edit_location_outlined))
        ],
      ),
      body: productList.isEmpty?checker?
      const Center(child: Text("No Data in list"),):const Center(
        child: CircularProgressIndicator(),
      ):
      RefreshIndicator(
        onRefresh: onRefresh,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:  [
             Flexible(
               fit: FlexFit.loose,
               child: ListView.builder(
                 controller: scrollControl,
                 itemCount: (itemCount<productList.length)?itemCount+1:productList.length,
                   itemBuilder: (context, index){
                   final item = productList[index];
                   if(index == itemCount){
                     return const CupertinoActivityIndicator();
                   }else {
                     return Container(
                       margin: const EdgeInsets.symmetric(
                           horizontal: 10, vertical: 15),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text("Name:${item.name}", style: Theme
                               .of(context)
                               .textTheme
                               .headline4,),
                           const SizedBox(height: 5,),
                           Text("Formula:${item.formula}", style: Theme
                               .of(context)
                               .textTheme
                               .headline5,),
                           const SizedBox(height: 5,),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.end,
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: [
                               TextButton(onPressed: () async {
                                 var result = await Navigator.push(context,
                                     MaterialPageRoute(builder: (context) =>
                                         AddEditScreen(
                                           action: "Edit", editProduct: item,)));
                                 if (result == true) {
                                   print("*****EDIT*****");
                                   setState(() {
                                     getData();
                                   });
                                 }
                               }, child: const Text("Edit",
                                 style: TextStyle(
                                     color: Colors.lightGreen, fontSize: 22),)),
                               const SizedBox(width: 10,),
                               TextButton(onPressed: () {
                                 FirebaseFirestore.instance.collection("chemicals")
                                     .doc(item.id).delete()
                                     .then((value) {
                                   ScaffoldMessenger.of(context).
                                   showSnackBar(const SnackBar(
                                       content: Text("Data Deleted Successfully")));
                                   setState(() {
                                     getData();
                                   });
                                 });
                               }, child: const Text("Delete",
                                 style: TextStyle(color: Colors.pink, fontSize: 22),))
                             ],)
                         ],
                       ),
                     );
                   }
               }),
             ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}