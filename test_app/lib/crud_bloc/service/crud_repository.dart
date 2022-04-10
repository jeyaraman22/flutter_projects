import 'package:cloud_firestore/cloud_firestore.dart';
import '../crud_bloc_model/bloc_modelclass.dart';

class Repository{

  Future<List<Chemicalproduct>> getData()async{
    List<Chemicalproduct> repoProductList = [];
    List<DocumentSnapshot<Map<String,dynamic>>> templist;
    print("Get DAta");
    QuerySnapshot responseData = await FirebaseFirestore.instance.collection("chemicals").orderBy("createdAt",descending:true).get();
    print("data.........");
    templist = responseData.docs as List<DocumentSnapshot<Map<String,dynamic>>>;
    for (final DocumentSnapshot<Map<String,dynamic>> docs in templist){
        repoProductList.add(Chemicalproduct.fromDocumentSnapshot(doc: docs));
    }
    print("............data");
    print(repoProductList.length);
    return repoProductList;
  }

  Future<bool> addData(Chemicalproduct product)async{
    bool added = false;
    var data = {"name":product.name,"formula":product.formula,"createdAt":product.timeStamp};
    await FirebaseFirestore.instance
        .collection("chemicals").add(data).then((value) => added = true);
    return added;
  }

  Future<bool> updateData(Chemicalproduct product)async{
    bool updated = false;
    var data = {"name":product.name,"formula":product.formula,"createdAt":product.timeStamp};
    await FirebaseFirestore.instance
        .collection("chemicals").doc(product.id).update(data).then((value) => updated = true);
    return updated;
  }

  Future<bool> deleteData(String id)async{
    bool deleted = false;
    await FirebaseFirestore.instance
        .collection("chemicals").doc(id).delete().then((value) => deleted = true);
    return deleted;
  }
}