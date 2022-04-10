import 'package:cloud_firestore/cloud_firestore.dart';

class Chemicalproduct{
  String name,formula,id;
  Chemicalproduct({required this.name,required this.formula,required this.id});

  factory Chemicalproduct.fromDocumentSnapshot({required DocumentSnapshot<Map<String,dynamic>> doc}){
   return Chemicalproduct(name: doc.data()!['name'], formula: doc.data()!['formula'],id: doc.id);
  }


}