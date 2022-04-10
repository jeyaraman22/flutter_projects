import 'package:flutter/material.dart';

import '../widgets/dropdownform.dart';
import 'multipledropdown.dart';

class DropDownHomePage extends StatefulWidget {
  const DropDownHomePage({Key? key}) : super(key: key);

  @override
  _DropDownHomePageState createState() => _DropDownHomePageState();
}

class _DropDownHomePageState extends State<DropDownHomePage> {

  Map<String, String> formData = {
    "state": "Select your state",
    "city": "Select your city",
    "area": "Select your area",
    "pincode": "Select your pincode"
  };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drop_Form"),
        actions: [
          IconButton(
            onPressed: () async {
              var data = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MultipleDropdown()));
              if (data != null) {
                setState(() {
                  formData = data;
                });
              }
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
              onPressed: () async {
                var data = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MultipleDropdown(
                          editData: formData,
                        )));
                if (data != null) {
                  setState(() {
                    formData = data;
                  });
                }
              },
              icon: const Icon(Icons.edit_location_outlined))
        ],
      ),
      body:Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownForm(
            formList: formData,
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
