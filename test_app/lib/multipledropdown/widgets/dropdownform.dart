import 'package:flutter/material.dart';
import 'package:test_app/multipledropdown/screen/multipledropdown.dart';

class DropdownForm extends StatefulWidget {
  Map<String,String> formList;
  DropdownForm({Key? key, required this.formList}) : super(key: key);

  @override
  _DropdownFormState createState() => _DropdownFormState();
}

class _DropdownFormState extends State<DropdownForm> {

  var stateController = TextEditingController();
  var cityController = TextEditingController();
  var areaController = TextEditingController();
  var pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    stateController.text = widget.formList['state']!;
    cityController.text = widget.formList['city']!;
    areaController.text = widget.formList['area']!;
    pinController.text = widget.formList['pincode']!;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text("State       :",textScaleFactor: 1.5,),
                SizedBox(width: 25,),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: stateController,
                    style: TextStyle(fontSize: 20,color: Colors.brown),
                    decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        )),),),
                )
                //Text((widget.formList['state'])!,textScaleFactor: 1.6)
              ],
            ),
          ),
          Container(
            height: 100,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text("City          :",textScaleFactor: 1.5,),
                SizedBox(width: 25,),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: cityController,
                    style: TextStyle(fontSize: 20,color: Colors.brown),
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          )),),),
                )
              ],
            ),
          ),
          Container(
            height: 100,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text("Area         :",textScaleFactor: 1.5,),
                SizedBox(width: 25,),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: areaController,
                    style: TextStyle(fontSize: 20,color: Colors.brown),
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          )),),),
                )
              ],
            ),
          ),
          Container(
            height: 100,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text("PinCode   :",textScaleFactor: 1.5,),
                SizedBox(width: 25,),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: pinController,
                    style: TextStyle(fontSize: 20,color: Colors.brown),
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          )),),),
                )
              ],
            ),
          ),
          Center(
            child: Container(
              height: 35,
              width: 80,
              child: ElevatedButton(onPressed:(){},
                  child: const Text("Submit")),
            ),
          )
        ],
      ),
    );
  }
}
