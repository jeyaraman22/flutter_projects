import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/mvvm/model/user_model.dart';
import 'package:test_app/mvvm/view_model/user_list_view_model.dart';
import 'package:test_app/mvvm/widget/alert_box.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  List<UserModel> userList = [];
  var nameController = TextEditingController();
  var jobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    /// To invoke the viewModel method to receive response from API
    Provider.of<ViewModel>(context,listen: false).fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ViewModel>(context);
    /// Once the userList in ViewModel loaded with fresh data MainScreen userList will get notified.
    userList = provider.userList;
    return Scaffold(
      appBar: AppBar(
        title: const Text("MVVM Architecture"),
        actions: [
          IconButton(onPressed:(){
           showDialog(context: (context), builder:(BuildContext context){
             return const AlertingBox(action: "Add");
           });
          },
              icon: const Icon(Icons.add)
          ),
          IconButton(onPressed:(){
            showDialog(context: (context), builder: (BuildContext context){
              return const AlertingBox(action: "Edit");
            });
          },
              icon: const Icon(Icons.edit)),
          IconButton(onPressed:(){
            showDialog(context: (context), builder: (BuildContext context){
              return const AlertingBox(action: "Delete");
            });
          },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: userList.isEmpty?const Center(
        child: CircularProgressIndicator(),
      ):ListView.builder(
          itemCount:userList.length ,
          itemBuilder:(context,index){
           return Container(
             height: 150,
             width: double.infinity,
             margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
               Expanded(
                 child: ClipRRect(
                   borderRadius: const BorderRadius.only(topLeft: Radius.circular(50),bottomRight: Radius.circular(100)),
                   child: Image.network(userList[index].image!,fit: BoxFit.cover,),
                 ),
               ),
                const SizedBox(width: 8,),
                Expanded(
                    child: Text(userList[index].firstName! + userList[index].lastName!,
                    style: const TextStyle(fontSize: 20),))
            ],
          ),
        );
      }),
    );
  }
}
