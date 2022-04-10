
import 'package:flutter/material.dart';
import 'package:test_app/multipledropdown/model/dropdownmodel.dart';
import 'package:test_app/multipledropdown/utils/response_data.dart';

class MultipleDropdown extends StatefulWidget {
  final Map<String,String>? editData;
  const MultipleDropdown({Key? key,this.editData}) : super(key: key);

  @override
  _MultipleDropdownState createState() => _MultipleDropdownState();
}

class _MultipleDropdownState extends State<MultipleDropdown> {


 String stateHint = "Please select your state";
  String cityHint = "Please select your city";
  String areaHint = "Please select your area";
  String pinHint = "Please select your pincode";
  Map<String,String>? dataToEdit;
  List<States> statesList =[];
  List<Cities> cityList =[];
  List<Areas> areaList =[];
  List<Pincode> pincodeList =[];
  Map<String,String>? selectedData;
  final formkey = GlobalKey<FormState>();
   States? dropValue;
   Cities? cityDropValue;
   Areas? areaDropValue;
   Pincode? pinDropValue;

   getDropDownData(){
    var resValue  = StateModel.fromJson(ResponseData.jsonData);
    print("${resValue.states}");
    for (var element in resValue.states!) {statesList.add(element);}
     print("Length=${statesList.length}");

  }


  @override
  void initState() {
    super.initState();
    getDropDownData();
    if(widget.editData != null){
      print(widget.editData);
      dataToEdit = widget.editData;
      stateHint = widget.editData!['state']!;
      cityHint = widget.editData!['city']!;
      areaHint = widget.editData!['area']!;
      pinHint = widget.editData!['pincode']!;
      loadDataToEdit();
    }
  }
  List<States> citiesDropList = [];
  List<Cities> areaDropList = [];
  List<Areas> pincodeDropList = [];
 loadDataToEdit(){
   citiesDropList = statesList.where((e) => e.statename == stateHint).toList();
   for(var element in citiesDropList) {
     cityList.addAll((element.cities)!.toList());
   }
     areaDropList = cityList.where((e) => e.name == cityHint).toList();
     for(var element in areaDropList){
       areaList.addAll((element.areas)!.toList());
     }
   pincodeDropList = areaList.where((e)=> e.name == areaHint).toList();
   for(var element in pincodeDropList){
     pincodeList.addAll((element.pincode)!.toList());
   }
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DROP-DOWN-LISTS"),),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Form(
           key: formkey,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width-20,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.place_outlined,size: 22,),
                      const SizedBox(width: 5,),
                      Expanded(
                        child: DropdownButtonFormField(
                            decoration: const InputDecoration(enabledBorder: InputBorder.none),
                          isExpanded: true,
                            hint: Text(stateHint),
                            items: statesList.map<DropdownMenuItem<States>>((States dropList) {
                                return DropdownMenuItem(
                                    value: dropList,
                                    child: Text(dropList.statename!) );}).toList(),
                            onChanged: (States? item){
                              setState(() {
                                cityList = [];
                                areaList =[];
                                pincodeList =[];
                                cityList.add(Cities(name: "Please select your city",id: " ",areas: []));
                                areaList.add(Areas(name: "Please select your area",id: " ",pincode: []));
                                pincodeList.add(Pincode(pc: "Please select your pincode",pincode: " "));
                                print("CITIES-${cityList.length}");
                                dropValue = item!;
                                cityDropValue = cityList.first;
                                areaDropValue = areaList.first;
                                pinDropValue = pincodeList.first;
                                 stateHint = (item.statename)!;
                                 print("//////////STATE- $stateHint //////");
                                 citiesDropList = statesList.where((e)
                                 {
                                   return (e.statename == stateHint);
                                 }).toList();
                                 print("CITYLIST LENGTH-${citiesDropList.length}");
                                 print(dropValue!.statename);
                                 for(var element in citiesDropList){
                                   cityList.addAll((element.cities)!.toList());
                                 }
                                stateHint = dropValue!.statename!;
                              });
                            },
                          value: dropValue,
                          validator: (States? values) {
                            if (values == null || values.statename == "Please select your state") {
                              return 'Please select valid data';
                            }
                            return null;
                          },
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15,),
                Container(
                  width: MediaQuery.of(context).size.width-20,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.location_city,size: 22,),
                      const SizedBox(width: 5,),
                      Expanded(
                        child: DropdownButtonFormField(
                            isExpanded: true,
                            decoration: const InputDecoration(enabledBorder: InputBorder.none),
                            hint: Text(cityHint),
                            items: cityList.map<DropdownMenuItem<Cities>>((Cities dropList) =>
                                DropdownMenuItem(
                                    value: dropList,child: Text(dropList.name!) )).toList(),
                            onChanged: (Cities? item){
                              areaList = [];
                              pincodeList =[];
                              setState(() {
                                cityDropValue = item!;
                                areaList.add(Areas(
                                    name: (cityDropValue?.name == "Please select your city")?"Select City":"Please select your area",id: " ",pincode: []));
                                pincodeList.add(Pincode(pc: "Please select your pincode",pincode: " "));
                                areaDropValue = areaList.first;
                                pinDropValue = pincodeList.first;
                                cityHint = item.name!;
                                areaDropList = cityList.where((e) => e.name == cityHint).toList();
                                for(var element in areaDropList){
                                  areaList.addAll((element.areas)!.toList());
                                }
                                cityHint = cityDropValue!.name!;
                              });
                            },
                          value: cityDropValue,
                          validator: (Cities? values) {
                            if (values == null || values.name == "Please select your city") {
                              return 'Please enter valid data';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15,),
                Container(
                  width: MediaQuery.of(context).size.width-20,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.place_rounded,size: 22,),
                      const SizedBox(width: 5,),
                      Expanded(
                        child:  DropdownButtonFormField(
                            isExpanded: true,
                            decoration: const InputDecoration(enabledBorder: InputBorder.none),
                            hint: Text(areaHint),
                            items: areaList.map<DropdownMenuItem<Areas>>((Areas dropList) =>
                                DropdownMenuItem(
                                    value: dropList,child: Text(dropList.name!) )).toList(),
                            onChanged: (Areas? item){
                              pincodeList = [];
                              setState(() {
                                areaDropValue = item!;
                                pincodeList.add(Pincode(
                                    pc:(areaDropValue?.name == "Please select your area")?"Select Area": "Please select your pincode",pincode: " "));
                                pinDropValue = pincodeList.first;
                                areaHint = item.name!;
                                pincodeDropList = areaList.where((e)=> e.name == areaHint).toList();
                                for(var element in pincodeDropList){
                                  pincodeList.addAll((element.pincode)!.toList());
                                }
                                areaHint = areaDropValue!.name!;
                              });
                            },
                          value: areaDropValue,
                          validator: (Areas? values) {
                            if (values == null || values.name == "Please select your area") {
                              return 'Please enter valid data';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15,),
                Container(
                  width: MediaQuery.of(context).size.width-20,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.pin_drop,size: 22,),
                      const SizedBox(width: 5,),
                      Expanded(
                        child: DropdownButtonFormField(
                            isExpanded: true,
                            decoration: const InputDecoration(enabledBorder: InputBorder.none),
                            hint: Text(pinHint),
                            items: pincodeList.map<DropdownMenuItem<Pincode>>((Pincode dropList) =>
                                DropdownMenuItem(
                                    value: dropList,child: Text(dropList.pc!) )).toList(),
                            onChanged: (Pincode? item){
                              setState(() {
                                pinDropValue = item!;
                                pinHint = pinDropValue!.pc!;
                              });
                            },
                          value: pinDropValue,
                          validator: (Pincode? values) {
                            if (values == null || values.pc == "Please select your pincode") {
                              return 'Please enter valid data';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25,),
                ElevatedButton(onPressed:(){
                  if(formkey.currentState!.validate())
                   {
                  selectedData = {"state": dropValue!.statename!,"city":cityDropValue!.name!,
                  "area":areaDropValue!.name!,"pincode":pinDropValue!.pc!};
                  Navigator.of(context).pop(selectedData);
               }
  },
                    child: const Text("OK"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
