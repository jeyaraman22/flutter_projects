import 'package:flutter/material.dart';
import 'package:g_sign_bloc/constatnts/spaces.dart';
import 'package:g_sign_bloc/home/views/UserProfile/usermodelclass.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class UserprofileScreen extends StatefulWidget {
  const UserprofileScreen({Key? key}) : super(key: key);

  @override
  _UserprofileScreenState createState() => _UserprofileScreenState();
}

class _UserprofileScreenState extends State<UserprofileScreen> {
  ScrollController scrollcontrol = ScrollController();
  List<bool>? selectedValue;
  bool builder = true;
  List<apiData> UserData =[];
  List<apiData> checkData =[];
  int page = 1;

  @override
  void initState(){
    super.initState();
    getuserProfile(page).then((value){
      UserData.addAll(value);
      checkData =value;
      print("checkdata-length${checkData.length}");
    });
    scrollcontrol.addListener(() {
      if (scrollcontrol.position.pixels
          == scrollcontrol.position.maxScrollExtent) {
        loadNextpage();
      }
    });
    selectedValue = [true,false];
  }

  loadNextpage(){
    print("crosscheck${checkData.length}");
    if(checkData.isNotEmpty) {
      ++page;
      print("loading next page");
      getuserProfile(page).then((value) {
        print("Value-length${value.length}");
        setState(() {
          checkData = value;
        });
        if (value.isNotEmpty) {
          setState(() {
            UserData.addAll(value);
          });
        }else {
          print("data not available");
        }
      });
    }

  }

  Future<List<apiData>> getuserProfile(int pageNumber)async{
    List<apiData> requiredData =[];
    http.Response response = await http.get(
        Uri.parse('https://reqres.in/api/users?page=$pageNumber'));
    print("The Status response ---- ${response.statusCode}");
    var result = jsonDecode(response.body);
    requiredData = result['data'].map<apiData>((json)=>apiData.fromJson(json)).toList();
    setState(() {});
    return requiredData;
  }

  @override
  void dispose() {
    scrollcontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 20,
        // leading: Padding(
        //   padding:  EdgeInsets.only(left: 10),
        //   child: GestureDetector(
        //     onTap: ()=> Navigator.of(context).pop(),
        //     child: Icon(Icons.arrow_back_ios,
        //       color: Color(0xff008078),
        //       size: 18,),
        //   ),
        // ),
        backgroundColor: Colors.white,
        title: Text("User's count:${UserData.length}",
         style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: fontSize.contentText,
            color: Colors.black
        ),
        ),
        actions: [
          Padding(padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ToggleButtons(
              selectedColor: Colors.white,
              borderRadius: BorderRadius.circular(15),
              color:Colors.black54,
              fillColor: Colors.teal.shade400,
              children: [
               Icon(Icons.list),
               Icon(Icons.grid_view)
          ],
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < selectedValue!.length; i++) {
                    selectedValue![i] = (i == index);
                  }
                  if(index == 0){
                    builder = true;
                  }else{
                    builder = false;
                  }
                });
              },
              isSelected: selectedValue!
          ),
          ),
        ],
      ),
      body: Padding(
        padding: Paddings.wholePadding*1.3,
      child: builder ? ListView.builder(
          controller: scrollcontrol,
          itemCount: UserData.length,
          itemBuilder: (context,index){
            return Column(
              children: [
                Container(
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle
                            ),
                            child: Image.network(UserData[index].photoUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(UserData[index].firstName!+UserData[index].lastName!,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700
                            ),),
                            SizedBox(height:5),
                            Text(UserData[index].email!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500
                            ),)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 10),
              ],
            );
          }
      )
          : GridView.builder(
        controller: scrollcontrol,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
          ),
          itemCount: UserData.length,
          itemBuilder: ( context ,index){
            return Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                Container(
                height: 200,
                //color: Colors.transparent,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  image: DecorationImage(image: NetworkImage(UserData[index].photoUrl!),
                  fit: BoxFit.cover)
                ), ),
                Container(
                  alignment: AlignmentDirectional.bottomStart,
                  height: 40,
                  color: Colors.black26,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(UserData[index].firstName!+UserData[index].lastName!,
                                style: TextStyle(
                                  color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700
                                ),),
                            ),
                            Expanded(
                              child: Text(UserData[index].email!,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500
                                ),),
                            )
                          ],
                        ),
                      ),
                    )
                ],
            );
          }
    ),
      ),
    );
  }
}
