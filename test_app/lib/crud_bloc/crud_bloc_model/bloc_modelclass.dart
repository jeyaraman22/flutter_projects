import 'package:cloud_firestore/cloud_firestore.dart';

class Chemicalproduct{
  String name,formula;
  String? timeStamp,id;
  Chemicalproduct({required this.name,required this.formula, this.id,this.timeStamp});

  factory Chemicalproduct.fromDocumentSnapshot({required DocumentSnapshot<Map<String,dynamic>> doc}){
    return Chemicalproduct(name: doc.data()!['name'], formula: doc.data()!['formula'],id: doc.id);
  }


}