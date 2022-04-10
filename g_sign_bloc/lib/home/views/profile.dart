import 'dart:io';
import 'dart:async';
import 'package:g_sign_bloc/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:g_sign_bloc/authenticaiton/bloc/authentication_bloc.dart';
import 'package:g_sign_bloc/constatnts/spaces.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:g_sign_bloc/login/views/login_main_view.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';


class profileScreen extends StatefulWidget {
  const profileScreen({Key? key}) : super(key: key);

  @override
  _profileScreenState createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  var formkey = GlobalKey<FormState>();
  var dateController = TextEditingController();
  var countryController = TextEditingController();
  var firstNamecontroller = TextEditingController();
  var lastNamecontroller = TextEditingController();
  var phonecontroller = TextEditingController();
  var emailcontroller = TextEditingController();
  var salutationController = TextEditingController();
  var countryCodecontroller = TextEditingController();
  String photoUrl = "";
  String profileUrl="";
  File? file;
  //Map<dynamic,dynamic> data ={};
  final TextInputFormatter digitsOnly =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));
  User? user = FirebaseAuth.instance.currentUser;
  Future<dynamic> fetchuserData() async {
    DocumentReference documentData =
        FirebaseFirestore.instance.collection('user').doc(user!.uid);
    await documentData.get().then((DocumentSnapshot snapshot) {
      setState(() {
        salutationController.text =
            (snapshot.data() as Map)["Salutation"] == null ? "": (snapshot.data() as Map)["Salutation"].toString();
        firstNamecontroller.text =
            (snapshot.data() as Map)["First Name"] == null ? "":  (snapshot.data() as Map)["First Name"].toString();
        lastNamecontroller.text =
            (snapshot.data() as Map)["Last Name"] == null ? "": (snapshot.data() as Map)["Last Name"].toString();
        dateController.text =
            (snapshot.data() as Map)["Dateofbirth"]  == null ? "": (snapshot.data() as Map)["Dateofbirth"].toString();
        phonecontroller.text =
            (snapshot.data() as Map)["Phonenumber"]  == null ? "": (snapshot.data() as Map)["Phonenumber"].toString();
        countryController.text = (snapshot.data() as Map)["Country"] == null ? "": (snapshot.data() as Map)["Country"].toString();
        countryCodecontroller.text =
            (snapshot.data() as Map)["PhoneCode"] == null ? "": (snapshot.data() as Map)["PhoneCode"].toString();
        emailcontroller.text = (snapshot.data() as Map)["Email"] == null ? "":  (snapshot.data() as Map)["Email"].toString();
        photoUrl = (snapshot.data() as Map)["PhotoURL"] == null ? "": (snapshot.data() as Map)["PhotoURL"].toString();
      });

      //data = snapshot.data as Map;
    });
    print("---URL---$photoUrl");
    //  firstNamecontroller.text = data["First Name"].toString();
    //  lastNamecontroller.text = data["Last Name"].toString();
    //  dateController.text = data["Dateofbirth"].toString();
    // phonecontroller.text = data["Phonenumber"].toString();
    // countryController.text = data["Country"].toString();
    // emailcontroller.text = data["Email"].toString();
    // photoUrl = data["PhotoURL"].toString();
  }

  @override
  void initState() {
    super.initState();
    fetchuserData();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
    });
  }
  @override
  void deactivate(){
     EasyLoading.dismiss();
      EasyLoading.removeAllCallbacks();
      super.deactivate();
    }
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('user');
  Future<void> updateuserDetails(
      {required String firstName,
      required String lastName,
      required String dob,
      required String nation,
      required String phno,
      required String phCode,
      required String salutation}) async {
    if (file != null) {
      print("EDITING Profile");
      profileUrl = await imageUpload();
      print("Profile--$profileUrl");
    }
    DocumentReference documentReference = _collectionReference.doc(user!.uid);
    Map<String, dynamic> userdata = <String, dynamic>{
      "Salutation": salutationController.text,
      "First Name": firstNamecontroller.text,
      "Last Name": lastNamecontroller.text,
      "Phonenumber": phonecontroller.text.toString(),
      "Dateofbirth": dateController.text.toString(),
      "Country": countryController.text,
      "PhoneCode": countryCodecontroller.text.toString(),
      "PhotoURL": profileUrl.isNotEmpty ? profileUrl
                                              : user!.photoURL.toString()

    };
    await documentReference
        .update(userdata)
        .whenComplete(() => print("Updated"))
        .catchError((err) => print(err));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      String dateFormat = DateFormat('dd-MM-yyyy').format(pickedDate);
      setState(() {
        dateController.text = dateFormat;
      });
    }
  }

  SelectImage() async {
    XFile? xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    print("file " + xfile!.path);
    File originalfile = File(xfile.path);
    final directory = await getExternalStorageDirectory();
    final imageFolder = Directory("${directory!.path}/gsignbloc");
    if (await imageFolder.exists()) {
      print("Folder exists");
    } else {
      imageFolder.create(recursive: true);
    }
    var fileName = basename(originalfile.path);
    File duplicateFile =
        await originalfile.copy("${imageFolder.path}/$fileName");
    file = File(duplicateFile.path);
    print("Imagefolder---${imageFolder.path}");
    setState(() {
      photoUrl = "";
    });

  }

  Future<String> imageUpload() async {
    var imageUrl = await FirebaseStorage.instance
        .ref()
        .child(basename(file!.path))
        .putFile(file!);
    return imageUrl.ref.getDownloadURL();
  }

  removeProfile()async{
   await FirebaseFirestore.instance.collection('user').doc(user!.uid).update({'PhotoURL':""});
    setState(() {
      photoUrl = "";
      file = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    alertingbox() {
      return showDialog(context: context,
          builder: (context) {
            return AlertDialog(
              elevation: 20,
              backgroundColor: Colors.white,
              title: const Text('Remove Profile Image'),
              actions: [
                TextButton(onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    removeProfile();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Profile removed"),
                    ),
                  );
                },
                    child: Text('Yes')),
                TextButton(onPressed: () => Navigator.of(context).pop(),
                    child: Text('No'))
              ],
            );
          });
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEEFF0),
        appBar: AppBar(
          leadingWidth: 75,
          leading: Row(
            children: [
              Padding(padding: EdgeInsets.only(left: 15)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xff008078),
                  size: 18,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  "Back",
                  style: TextStyle(color: Colors.black, fontSize: 17),
                ),
              )
            ],
          ),
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: elevationValue.contentElevation * 4,
          centerTitle: true,
          actions: [
            Padding(
              padding: Paddings.defaultPadding * 12,
              child: TextButton(
                onPressed: () {
                  BlocProvider.of<AuthenticationBloc>(context)
                      .add(AuthenticationExited());
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginMainView()),
                      (Route<dynamic> route) => false);
                },
                child: Text(
                  "Edit Profile",
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: fontSize.contentText,
                      color: Colors.black),
                ),
              ),
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.only(
              top: Paddings.topprofilepadding,
              left: Paddings.sideprofilepaddingL,
              right: Paddings.sideprofilepaddingR),
          child: SingleChildScrollView(
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  // Card(
                  //   elevation: elevationValue.contentElevation,
                  //   child: TypeAheadFormField(
                  //
                  //       onSuggestionSelected: (pattern){
                  //         List<String>? item = salutationList.Saluation;
                  //         return item!.where((e) {
                  //           return e.toLowerCase().contains(pattern.toString().toLowerCase());
                  //         },).toList();
                  //       },
                  //       itemBuilder: (context, List<String>? item){
                  //         item = salutationList.Saluation;
                  //         return Container(
                  //           child: ListTile(
                  //             title: Text(item.toString()),
                  //           ),
                  //         );
                  //       },
                  //       suggestionsCallback:
                  //   suggestionsCallback),
                  // ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12, 27, 15, 27),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: GestureDetector(
                                onTap: alertingbox,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(35),
                                  child: Container(
                                    height: 70,
                                    child: photoUrl.isNotEmpty
                                        ? Image.network(photoUrl, fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context, Widget child,
                                        ImageChunkEvent? loadingProgress){
                                          if(loadingProgress == null){
                                            return child;
                                          }
                                          return Center(child: CircularProgressIndicator(backgroundColor: Colors.white,
                                            color: Colors.black26,
                                            strokeWidth: 3.0,),);

                                    },) : file!=null ?Image.file(file!,fit: BoxFit.cover):Image.asset('images/dummyprofile.png',fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                GestureDetector(
                                  child: Text(
                                    "EDIT",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'ProximaNova',
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff008078)),
                                  ),
                                  onTap: () => SelectImage(),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "PROFILE PICTURE",
                                  style: TextStyle(
                                      fontFamily: 'ProximaNova',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff008078)),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: Heights.sizeboxHeight),
                  Card(
                    elevation: elevationValue.contentElevation,
                    child: TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: salutationController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.black26,
                                width: Widths.contentWidth),
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius.circleRadius)),
                          ),
                          border: InputBorder.none,
                          // focusedBorder: InputBorder.none,
                          // errorBorder: InputBorder.none,
                          // disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 13.0, horizontal: 20.0),
                          hintText: "Salutation",
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.keyboard_arrow_down_sharp,
                              color: Color(0xff008078),
                            ),
                            onPressed: () {
                              // List<String>? item  = salutationList.Saluation;
                              //  return ListView.builder(
                              //    itemCount: item.length,
                              //    itemBuilder: (context, int index){
                              //          item = salutationList.Saluation;
                              //              return Container(
                              //                    child: ListTile(
                              //                    title: Text(item.toString()),
                              //                 ),
                              //              );
                              //      },
                              // ),
                            },
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'enter the salutation';
                        } else {
                          return null;
                        }
                      },
                      suggestionsCallback: (pattern) {
                        List<String>? item = salutationList.Saluation;
                        return item!.where(
                          (e) {
                            return e
                                .toLowerCase()
                                .contains(pattern.toString().toLowerCase());
                          },
                        ).toList();
                      },
                      itemBuilder: (context, item) {
                        return Container(
                          child: ListTile(
                            title: Text(item.toString()),
                          ),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        this.salutationController.text = suggestion.toString();
                      },
                    ),
                  ),
                  SizedBox(height: Heights.sizeboxHeight),
                  Card(
                    // child: Container(
                    //   decoration: BoxDecoration(
                    //   color: Colors.white,
                    //   borderRadius: BorderRadius.circular(borderRadius.circleRadius)
                    //   ),
                    elevation: elevationValue.contentElevation,
                    child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter(RegExp(r'[a-zA-Z]'),
                            allow: true)
                      ],
                      controller: firstNamecontroller,
                      cursorColor: Colors.black26,
                      cursorWidth: dynamicCursor.cursorWidth,
                      cursorHeight: dynamicCursor.cursorHeight,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(fontSize: 13, height: 0.04),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black26,
                              width: Widths.contentWidth),
                          borderRadius: BorderRadius.all(
                              Radius.circular(borderRadius.circleRadius)),
                        ),
                        border: InputBorder.none,
                        // focusedBorder: InputBorder.none,
                        // errorBorder: InputBorder.none,
                        // disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 20.0),

                        hintText: "First name",
                      ),
                      onChanged: (value) {
                        firstNamecontroller = value as TextEditingController;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'First name';
                        } else {
                          return null;
                        }
                      },
                    ),
                    //),
                  ),
                  SizedBox(height: Heights.sizeboxHeight),
                  Card(
                    // child: Container(
                    //   decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(borderRadius.circleRadius)
                    //   ),
                    elevation: elevationValue.contentElevation,
                    child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter(RegExp(r'[a-zA-Z]'),
                            allow: true)
                      ],
                      controller: lastNamecontroller,
                      cursorColor: Colors.black26,
                      cursorWidth: dynamicCursor.cursorWidth,
                      cursorHeight: dynamicCursor.cursorHeight,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(fontSize: 13, height: 0.04),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black26,
                              width: Widths.contentWidth),
                          borderRadius: BorderRadius.all(
                              Radius.circular(borderRadius.circleRadius)),
                        ),
                        border: InputBorder.none,
                        // focusedBorder: InputBorder.none,
                        // errorBorder: InputBorder.none,
                        // disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: Paddings.sideprofilepaddingL * 2),

                        hintText: "Last name",
                      ),
                      onChanged: (value) {
                        lastNamecontroller.text = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Last name';
                        } else {
                          return null;
                        }
                      },
                    ),
                    // ),
                  ),
                  SizedBox(height: Heights.sizeboxHeight),
                  Card(
                    // child: Container(
                    //   decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(borderRadius.circleRadius)
                    //   ),
                    elevation: elevationValue.contentElevation,
                    child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))
                      ],
                      controller: dateController,
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.black26,
                      cursorWidth: dynamicCursor.cursorWidth,
                      cursorHeight: dynamicCursor.cursorHeight,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(fontSize: 13, height: 0.04),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black26,
                              width: Widths.contentWidth),
                          borderRadius: BorderRadius.all(
                              Radius.circular(borderRadius.circleRadius)),
                        ),
                        border: InputBorder.none,
                        // focusedBorder: InputBorder.none,
                        // errorBorder: InputBorder.none,
                        // disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 13.0, horizontal: 20.0),
                        hintText: "DateOfBirth",
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.calendar_today_rounded,
                            color: Color(0xff008078),
                          ),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'DateofBirth';
                        } else {
                          return null;
                        }
                      },
                    ),
                    //),
                  ),
                  SizedBox(height: Heights.sizeboxHeight),
                  Card(
                    // child: Container(
                    //   decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(borderRadius.circleRadius)
                    //   ),
                    elevation: elevationValue.contentElevation,
                    child: TextFormField(
                      //inputFormatters: [FilteringTextInputFormatter(RegExp(r'[a-zA-Z]'), allow: true)],
                      controller: countryController,
                      cursorColor: Colors.black26,
                      cursorWidth: dynamicCursor.cursorWidth,
                      cursorHeight: dynamicCursor.cursorHeight,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(fontSize: 13, height: 0.04),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black26,
                              width: Widths.contentWidth),
                          borderRadius: BorderRadius.all(
                              Radius.circular(borderRadius.circleRadius)),
                        ),
                        border: InputBorder.none,
                        // focusedBorder: InputBorder.none,
                        // errorBorder: InputBorder.none,
                        // disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 13.0, horizontal: 20.0),
                        hintText: "Country",
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: Color(0xff008078),
                          ),
                          onPressed: () {
                            showCountryPicker(
                              showPhoneCode: true,
                              context: context,
                              onSelect: (value) {
                                setState(() {
                                  countryController.text =
                                      value.displayNameNoCountryCode;
                                  countryCodecontroller.text = value.phoneCode;
                                });
                                //print("Selected country${value.displayNameNoCountryCode}");
                              },
                            );
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Country';
                        } else {
                          return null;
                        }
                      },
                    ),
                    //),
                  ),
                  SizedBox(height: Heights.sizeboxHeight),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Card(
                          elevation: elevationValue.contentElevation,
                          child: TextFormField(
                            controller: countryCodecontroller,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9+]'))
                            ],
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.black26,
                            cursorWidth: dynamicCursor.cursorWidth,
                            cursorHeight: dynamicCursor.cursorHeight,
                            decoration: InputDecoration(
                              prefixText: "+",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black26,
                                    width: Widths.contentWidth),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(borderRadius.circleRadius)),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 13.0, horizontal: 19.0),

                              hintText: "+xx",
                              suffixIcon: Icon(
                                Icons.keyboard_arrow_down_sharp,
                                color: Color(0xff008078),
                              ),
                              //suffixIconConstraints: BoxConstraints.tightFor()
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'CountryCode';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 2,
                          child: Card(
                            elevation: elevationValue.contentElevation,
                            child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'))
                              ],
                              controller: phonecontroller,
                              keyboardType: TextInputType.number,
                              cursorColor: Colors.black26,
                              cursorWidth: dynamicCursor.cursorWidth,
                              cursorHeight: dynamicCursor.cursorHeight,
                              decoration: InputDecoration(
                                errorStyle:
                                    TextStyle(fontSize: 13, height: 0.04),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black26,
                                      width: Widths.contentWidth),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          borderRadius.circleRadius)),
                                ),
                                border: InputBorder.none,
                                // focusedBorder: InputBorder.none,
                                // errorBorder: InputBorder.none,
                                // disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: Paddings.sideprofilepaddingL * 2),
                                hintText: "Phone Number",
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Phone Number';
                                } else if (value.length != 10) {
                                  return 'enter correct number';
                                } else if (value.length > 10) {
                                  return 'enter correct number';
                                }
                                {
                                  return null;
                                }
                              },
                            ),
                          )),
                    ],
                  ),
                  SizedBox(height: Heights.sizeboxHeight),
                  Card(
                    // child: Container(
                    //   decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(borderRadius.circleRadius)
                    //   ),
                    elevation: elevationValue.contentElevation,
                    child: TextFormField(
                      controller: emailcontroller,
                      // enabled: false,
                      readOnly: true,
                      cursorColor: Colors.black26,
                      cursorWidth: dynamicCursor.cursorWidth,
                      cursorHeight: dynamicCursor.cursorHeight,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black26,
                              width: Widths.contentWidth),
                          borderRadius: BorderRadius.all(
                              Radius.circular(borderRadius.circleRadius)),
                        ),
                        border: InputBorder.none,
                        // focusedBorder: InputBorder.none,
                        // errorBorder: InputBorder.none,
                        // disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: Paddings.sideprofilepaddingL * 2),

                        hintText: "E-mail",
                      ),
                    ),
                    // ),
                  ),
                  SizedBox(height: Heights.sizeboxHeight * 6),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xff008078),
                        shape: StadiumBorder(),
                        fixedSize: Size(
                            buttonSize.buttonWidth, buttonSize.buttonheight),
                        elevation: elevationValue.contentElevation * 4),
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        setState(() {
                          //EasyLoading.show(status: "Saving..");
                          EasyLoading.show(status: "Saving..");
                          updateuserDetails(
                              firstName: firstNamecontroller.text,
                              lastName: lastNamecontroller.text,
                              phno: phonecontroller.toString(),
                              dob: dateController.toString(),
                              nation: countryController.text,
                              salutation: salutationController.text,
                              phCode: countryCodecontroller.text).then((value) {
                                EasyLoading.showSuccess("Saved");
                          });
                          //EasyLoading.dismiss();
                        });
                        formkey.currentState!.save();
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text("Successfully updated"),
                        //   ),
                        // );
                      }
                    },
                    child: Text(
                      "SAVE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: fontSize.contentText,
                      ),
                    ),
                  ),
                  SizedBox(height: Heights.sizeboxHeight * 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
