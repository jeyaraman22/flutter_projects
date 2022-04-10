import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/countries.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaz_app/helper/graphqlconnectivity/constants.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/user/user.dart';
import 'package:jaz_app/screens/booking/as_guest1.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:jaz_app/utils/strings.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditProfileState();
}

final _formKey2 = GlobalKey<FormState>();

class _EditProfileState extends State<EditProfilePage> {
  ScrollController _controllerOne = ScrollController();
  TextEditingController _salutationTxt = TextEditingController();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _phoneCode = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  TextEditingController _countryTxt = TextEditingController();

  bool isExpanded = false;
  int selectedRadio = 0;
  var selectedCountry = "";
  var selectedSalutation = "";
  bool checkValidate = false;
  AppUtility appUtility = AppUtility();
  String roomName = "";
  var salutationList = ["Mr.", "Mrs."];
  double bottomSpace = 20;
  bool enableSaveRooms = true;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final picker = ImagePicker();
  File? profileImage;
  String profileUrl = "";

  BuildContext? dialogContext;

  @override
  void initState() {
    super.initState();
    appUtility = AppUtility();
    _controllerOne =
        ScrollController(keepScrollOffset: true, initialScrollOffset: 0.0);
    getUserDatas();
  }

  bool validateAndSave() {
    final FormState? form = _formKey2.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    final leftPadding = overAllWidth * 0.035;
    final topPadding = overAllHeight * 0.015;
    var boxHeight =
        overAllHeight * (AppUtility().isTablet(context) ? 0.055 : 0.055);
    final boxWidth = overAllWidth * 0.7;
    var borderRadius = fieldBorderRadius;
    var summaryToppadding = overAllHeight * 0.025;
    final dropDownBottomPadding =
        overAllHeight * (AppUtility().isTablet(context) ? 0.5 : 0);
    if (boxHeight < 40) {
      boxHeight = 45;
    }

    return Scaffold(
      backgroundColor: Uicolors.backgroundColor,
      appBar: _appBarData(context),
      body: Form(
        key: _formKey2,
        child: StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            setSelectedRadio(int val) {
              setState(() {
                selectedRadio = val;
              });
            }

            return Scrollbar(
              controller: _controllerOne,
              //  thickness: 6,
              showTrackOnHover: true,
              //   hoverThickness: 12,
              isAlwaysShown: true,
              child: Padding(
                  padding: EdgeInsets.all(0),
                  child: ListView(
                    controller: _controllerOne,
                    children: [
                      GestureDetector(
                        onTap: () {
                          optionsBottomSheet(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              left: leftPadding,
                              right: leftPadding,
                              top: summaryToppadding),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white),
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(top: 5, bottom: 5),
                                padding: EdgeInsets.fromLTRB(
                                    MediaQuery.of(context).size.height * 0.02,
                                    MediaQuery.of(context).size.height * 0.02,
                                    0,
                                    MediaQuery.of(context).size.height * 0.02),
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: overAllWidth * 0.08,
                                      backgroundColor: Uicolors.buttonbg,
                                      child: ClipOval(
                                        child: SizedBox(
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: profileImage != null
                                                ? Image.file(
                                                    profileImage!,
                                                    width: double.maxFinite,
                                                    height: double.maxFinite,
                                                    fit: BoxFit.fill,
                                                  )
                                                : profileUrl.length > 0
                                                    ? OptimizedCacheImage(
                                                        imageUrl: profileUrl,
                                                        width: double.maxFinite,
                                                        height: double.maxFinite,
                                                        placeholder: (context,
                                                                url) =>
                                                            Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          valueColor:
                                                              AlwaysStoppedAnimation(
                                                                  Theme.of(
                                                                          context)
                                                                      .primaryColor),
                                                        )), //new Icon(Icons.error),
                                                        fit: BoxFit.fill,
                                                      )
                                                    : Text(
                                                        "${_firstName.text != null && _firstName.text.length > 0 ? _firstName.text.substring(0, 1) : ""}",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontFamily:
                                                                'Popins-regular'),
                                                      ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                        0,
                                        0,
                                        0),
                                    child: Text(
                                      "EDIT",
                                      style: dropDownStyle,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                        MediaQuery.of(context).size.height *
                                            0.01,
                                        0,
                                        0),
                                    child: Text(
                                      "PROFILE PICTURE",
                                      style: dropDownStyle,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        child: Container(
                            alignment: Alignment.centerLeft,
                            height: boxHeight,
                            //     width: boxWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(borderRadius),
                              color: Colors.white,
                                border: border

                            ),
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Padding(
                                  child: TypeAheadFormField(
                                      noItemsFoundBuilder: (context) =>
                                          ListTile(
                                              title: Text(
                                            Strings.noOption,
                                            textAlign: TextAlign.center,
                                            style: placeHolderStyle,
                                          )),
                                      transitionBuilder: (context,
                                              suggestionsBox,
                                              animationController) =>
                                          suggestionsBox,
                                      textFieldConfiguration:
                                          TextFieldConfiguration(
                                              keyboardType: TextInputType.name,
                                              enableInteractiveSelection: true,
                                              controller: this._salutationTxt,
                                              style: guestTextFieldStyle,
                                              decoration: InputDecoration(
                                                isCollapsed: true,
                                                errorStyle: errorTextStyle,
                                                border: InputBorder.none,
                                                hintText: Strings.salutationStr,
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                        0,
                                                        0,
                                                        0),
                                                hintStyle:
                                                    guestHintTextFieldStyle,
                                              )),
                                      itemBuilder: (context, String itemData) {
                                        return Container(
                                          width: 500,
                                          child: ListTile(
                                            title: Text(
                                              itemData,
                                              style: saluDropTextStyle,
                                            ),
                                          ),
                                        );
                                      },
                                      onSuggestionSelected: (String items) {
                                        this._salutationTxt.text = items;
                                      },
                                      suggestionsCallback: (pattern) {
                                        if (pattern.length > 0) {
                                          return salutationList
                                              .where((element) => element
                                                  .toLowerCase()
                                                  .contains(
                                                      pattern.toLowerCase()))
                                              .toList();
                                        } else {
                                          return salutationList;
                                        }
                                      },
                                      validator: (args) {
                                        if (args.toString().isNotEmpty) {
                                          return null;
                                        } else {
                                          return 'Salutation is required';
                                        }
                                      }),
                                  padding: EdgeInsets.only(
                                      // left: MediaQuery.of(context).size.width *
                                      //     0.05,
                                      // top: MediaQuery.of(context).size.height *
                                      //     0.02
                                      ),
                                ),
                                Align(
                                  child: Container(
                                    child: IconButton(
                                      icon: Image.asset(
                                        "assets/images/down-arrow.png",
                                        height: backIconSize,
                                        width: backIconSize,
                                        color: Uicolors.buttonbg,
                                      ),
                                      onPressed: () {},
                                    ),
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.02,
                                      //     0.02
                                    ),
                                  ),
                                  alignment: Alignment.centerRight,
                                )
                              ],
                            )),
                        padding: EdgeInsets.only(
                            top: topPadding,
                            left: leftPadding,
                            right: leftPadding),
                      ),
                      Padding(
                        child: Container(
                            alignment: Alignment.centerLeft,
                            height: boxHeight,
                            //  width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(borderRadius),
                              color: Colors.white,
                                border: border

                            ),
                            child: Padding(
                              child: TextFormField(
                                style: guestTextFieldStyle,
                                autovalidateMode: checkValidate
                                    ? AutovalidateMode.onUserInteraction
                                    : AutovalidateMode.onUserInteraction,
                                controller: _firstName,
                                cursorColor: Uicolors.titleText,
                                // cursorHeight: 18,
                                decoration: InputDecoration(
                                  // errorStyle: TextStyle(height: 0.5),
                                  //  fillColor: Uicolors.titleText,
                                  isCollapsed: true,
                                  errorStyle: errorTextStyle,
                                  hintText: Strings.firstStr,
                                  hintStyle: guestHintTextFieldStyle,
                                  border: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  //   contentPadding: EdgeInsets.only(bottom: 5),
                                ),
                                keyboardType: TextInputType.name,
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                    RegExp(emojiRegexp),
                                  ), new LengthLimitingTextInputFormatter(
                                      30),
                                ],
                                validator: (args) {
                                  if (args!.trim().toString().isNotEmpty && args.trim().toString().length<=30) {
                                    return null;
                                  } else if (args.toString().length>30){
                                    return 'First Name should not exceed 30 characters';
                                 }else {
                                    return 'First Name is required';
                                  }
                                },
                              ),
                              padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.05,
                                // top:
                                //     MediaQuery.of(context).size.height * 0.02
                              ),
                            )),
                        padding: EdgeInsets.only(
                            top: topPadding,
                            left: leftPadding,
                            right: leftPadding),
                      ),
                      Padding(
                        child: Container(
                            alignment: Alignment.centerLeft,
                            height: boxHeight,
                            //   width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(borderRadius),
                              color: Colors.white,
                                border: border

                            ),
                            child: Padding(
                              child: TextFormField(
                                style: guestTextFieldStyle,
                                scrollPadding: EdgeInsets.only(bottom: 40),
                                autovalidateMode: checkValidate
                                    ? AutovalidateMode.onUserInteraction
                                    : AutovalidateMode.onUserInteraction,
                                controller: _lastName,
                                cursorColor: Uicolors.titleText,
                                // cursorHeight: 18,
                                decoration: InputDecoration(
                                  // errorStyle: TextStyle(height: 0.5),
                                  isCollapsed: true,
                                  errorStyle: errorTextStyle,
                                  fillColor: Uicolors.titleText,
                                  hintText: Strings.lastStr,
                                  hintStyle: guestHintTextFieldStyle,
                                  border: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  //contentPadding: EdgeInsets.only(bottom: 5),
                                ),
                                keyboardType: TextInputType.name,
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                    RegExp(emojiRegexp),
                                  ), new LengthLimitingTextInputFormatter(
                                      30),
                                ],
                                validator: (args) {
                                  if (args!.trim().toString().isNotEmpty&& args.trim().toString().length<=30) {
                                    return null;
                                  } else if (args.toString().length>30){
                                    return 'Last Name should not exceed 30 characters';
                                  }else{
                                    return 'Last Name is required';
                                  }
                                },
                              ),
                              padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.05,
                                // top:
                                //     MediaQuery.of(context).size.height * 0.01
                              ),
                            )),
                        padding: EdgeInsets.only(
                            top: topPadding,
                            left: leftPadding,
                            right: leftPadding),
                      ),
                      Padding(
                        child: Container(
                            alignment: Alignment.centerLeft,
                            height: boxHeight,
                            // width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(borderRadius),
                              color: Colors.white,
                                border: border

                            ),
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                TypeAheadFormField(
                                    noItemsFoundBuilder: (context) => ListTile(
                                            title: Text(
                                          Strings.noOption,
                                          textAlign: TextAlign.center,
                                          style: placeHolderStyle,
                                        )),
                                    transitionBuilder: (context, suggestionsBox,
                                            animationController) =>
                                        suggestionsBox,
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                            // onTap: () {
                                            //   this.setState(() {
                                            //     bottomSpace = 200;
                                            //   });
                                            //   _controllerOne.position
                                            //       .jumpTo(bottomSpace);
                                            // },
                                            // onEditingComplete: () {
                                            //   this.setState(() {
                                            //     bottomSpace = 0;
                                            //   });
                                            // },
                                            keyboardType: TextInputType.name,
                                            enableInteractiveSelection: true,
                                            controller: this._countryTxt,
                                            style: guestTextFieldStyle,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: Strings.countryStr,
                                              isCollapsed: true,
                                              errorStyle: errorTextStyle,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05,
                                                      0,
                                                      0,
                                                      0),
                                              hintStyle:
                                                  guestHintTextFieldStyle,
                                            )),
                                    itemBuilder: (context, Country itemData) {
                                      return Container(
                                        width: 500,
                                        child: ListTile(
                                          title: Text(
                                            itemData.name,
                                            style: saluDropTextStyle,
                                          ),
                                        ),
                                      );
                                    },
                                    onSuggestionSelected: (Country items) {
                                      this.setState(() {
                                        bottomSpace = 0;
                                      });
                                      this._countryTxt.text = items.name;
                                      this._phoneCode.text =
                                          "+" + items.phoneCode;
                                    },
                                    suggestionsCallback: (pattern) {
                                      if (pattern.length > 0) {
                                        return countryList
                                            .where((element) => element.name
                                                .toLowerCase()
                                                .contains(
                                                    pattern.toLowerCase()))
                                            .toList();
                                      } else {
                                        return countryList;
                                      }
                                    },
                                    validator: (args) {
                                      if (args.toString().isNotEmpty) {
                                        return null;
                                      } else {
                                        return 'Country is required';
                                      }
                                    }),
                                Align(
                                  child: Padding(
                                    child: IconButton(
                                      icon: Image.asset(
                                        "assets/images/down-arrow.png",
                                        height: backIconSize,
                                        width: backIconSize,
                                        color: Uicolors.buttonbg,
                                      ),
                                      onPressed: () {},
                                    ),
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.02,
                                    ),
                                  ),
                                  alignment: Alignment.centerRight,
                                )
                              ],
                            )),
                        padding: EdgeInsets.only(
                            top: topPadding,
                            left: leftPadding,
                            right: leftPadding),
                      ),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Padding(
                            child: Container(
                                height: boxHeight,
                                width: MediaQuery.of(context).size.width * 0.26,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(borderRadius),
                                  color: Colors.white,
                                    border: border
                                ),
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    TypeAheadFormField(
                                      noItemsFoundBuilder: (context) =>
                                          ListTile(
                                              title: Text(
                                        Strings.noOption,
                                        textAlign: TextAlign.center,
                                        style: placeHolderStyle,
                                      )),
                                      transitionBuilder: (context,
                                              suggestionsBox,
                                              animationController) =>
                                          suggestionsBox,
                                      textFieldConfiguration:
                                          TextFieldConfiguration(
                                              // onTap: () {
                                              //   this.setState(() {
                                              //     bottomSpace = 200;
                                              //   });
                                              //   _controllerOne.position
                                              //       .jumpTo(bottomSpace);
                                              // },
                                              // onEditingComplete: () {
                                              //   this.setState(() {
                                              //     bottomSpace = 0;
                                              //   });
                                              // },
                                              keyboardType:
                                                  TextInputType.number,
                                              enableInteractiveSelection: true,
                                              controller: this._phoneCode,
                                              style: guestTextFieldStyle,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: "+XX",
                                                isCollapsed: true,
                                                errorStyle: errorTextStyle,
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                        0,
                                                        0,
                                                        0),
                                                hintStyle:
                                                    guestHintTextFieldStyle,
                                              )),
                                      itemBuilder: (context, Country itemData) {
                                        var codeText = itemData.phoneCode;
                                        if (codeText != "No Options") {
                                          codeText = "+" + itemData.phoneCode;
                                        }
                                        return Container(
                                            width: 500,
                                            padding: EdgeInsets.only(
                                                top: 5, bottom: 5, left: 10),
                                            child: Row(
                                              children: [
                                                CountryPickerUtils
                                                    .getDefaultFlagImage(
                                                        itemData),
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(left: 10),
                                                  child: Text(
                                                    codeText,
                                                    style: saluDropTextStyle,
                                                  ),
                                                ),
                                              ],
                                            ));
                                      },
                                      onSuggestionSelected: (Country items) {
                                        this.setState(() {
                                          bottomSpace = 0;
                                        });
                                        this._phoneCode.text =
                                            "+" + items.phoneCode;
                                        this._countryTxt.text = items.name;
                                      },
                                      suggestionsCallback: (pattern) {
                                        if (pattern.contains("+")) {
                                          pattern = pattern.replaceAll(
                                              RegExp(r'\+'), "");
                                        }

                                        if (pattern.length > 0) {
                                          return countryList
                                              .where((element) => element
                                                  .phoneCode
                                                  .toLowerCase()
                                                  .contains(
                                                      pattern.toLowerCase()))
                                              .toList();
                                        } else {
                                          return countryList;
                                        }
                                      },
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        child: IconButton(
                                          icon: Image.asset(
                                            "assets/images/down-arrow.png",
                                            height: backIconSize,
                                            width: backIconSize,
                                            color: Uicolors.buttonbg,
                                          ),
                                          onPressed: () {},
                                        ),
                                        padding: EdgeInsets.only(
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02,
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                            padding: EdgeInsets.only(
                                top: topPadding,
                                left: leftPadding,
                                right: leftPadding),
                          ),
                          Padding(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              height: boxHeight,
                              //  width: MediaQuery.of(context).size.width * 0.64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(borderRadius),
                                color: Colors.white,
                                  border: border

                              ),
                              child: Padding(
                                child: TextFormField(
                                  style: textFieldStyle,
                                  autovalidateMode: checkValidate
                                      ? AutovalidateMode.onUserInteraction
                                      : AutovalidateMode.onUserInteraction,
                                  controller: _phoneNumber,
                                  cursorColor: Uicolors.titleText,
                                  // cursorHeight: 18,
                                  decoration: InputDecoration(
                                      // errorStyle: TextStyle(height: 0.5),
                                      fillColor: Uicolors.titleText,
                                      hintText: Strings.phoneNoStr,
                                      hintStyle: guestHintTextFieldStyle,
                                      border: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      isCollapsed: true,
                                      errorStyle: errorTextStyle

                                      //   contentPadding: EdgeInsets.only(bottom: 5),
                                      ),
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                      RegExp(emojiRegexp),
                                    ),
                                  ],
                                  validator: (args) {
                                    if (args!.trim().toString().isNotEmpty) {
                                      if (args.toString().length > 16) {
                                        return 'Only allowed 16 digit';
                                      } else {
                                        return null;
                                      }
                                    } else {
                                      return 'Phone Number is required';
                                    }
                                  },
                                ),
                                padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.05,
                                  // top: MediaQuery.of(context).size.height *
                                  //     0.01
                                ),
                              ),
                            ),
                            padding: EdgeInsets.only(
                                top: topPadding,
                                left: MediaQuery.of(context).size.width * 0.31,
                                right: leftPadding),
                          ),
                        ],
                      ),
                      Padding(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          height: boxHeight,
                          //  width: MediaQuery.of(context).size.width * 0.80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRadius),
                            color: Colors.white,
                              border: border

                          ),
                          child: Padding(
                            child: TextFormField(
                              style: guestTextFieldStyle,
                              autovalidateMode: checkValidate
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.onUserInteraction,
                              controller: _email,
                              cursorColor: Uicolors.titleText,
                              // cursorHeight: 18,
                              decoration: InputDecoration(
                                  // errorStyle: TextStyle(height: 0.5),
                                  enabled: false,
                                  fillColor: Colors.black,
                                  hintText: Strings.emailStr,
                                  hintStyle: guestHintTextFieldStyle,
                                  border: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  isCollapsed: true,
                                  errorStyle: errorTextStyle

                                  //    contentPadding: EdgeInsets.only(bottom: 5),
                                  ),
                              keyboardType: TextInputType.emailAddress,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp(emojiRegexp),
                                ),
                              ],
                              validator: (args) {
                                if (args.toString().isNotEmpty) {
                                  if (!appUtility
                                      .validateEmail(args.toString())) {
                                    return 'Please provide valid email address';
                                  } else {
                                    return null;
                                  }
                                } else {
                                  return 'Email is required';
                                }
                              },
                            ),
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.05,
                              // top: MediaQuery.of(context).size.height * 0.01
                            ),
                          ),
                        ),
                        padding: EdgeInsets.only(
                            top: topPadding,
                            left: leftPadding,
                            right: leftPadding),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            top: topPadding,
                            left: leftPadding,
                            right: leftPadding,
                            bottom: MediaQuery.of(context).size.height * 0.02),
                      ),
                      _nextButton(context),
                    ],
                  )),
            );
          },
        ),
      ),
    );
  }

  AppBar _appBarData(BuildContext context) {
    return AppBar(
        toolbarHeight: AppUtility().isTablet(context)?80:AppBar().preferredSize.height,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Container(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width * 0.005, 0, 0, 0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Uicolors.buttonbg,
                        size: backIconSize,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: Text(Strings.back, style: backStyle),
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.015),
                    child: Text(
                      Strings.editProfileStr,
                      style: summaryTextStyle,
                    )),
              ),
            ],
          ),
        ));
  }

  Widget _nextButton(BuildContext context) {
    var overallHeight =MediaQuery.of(context).size.height;
    var buttonHeight = overallHeight * (AppUtility().isTablet(context)?0.075:0.055);
    String value = "Save";
    return Align(
        alignment: Alignment.center,
        child: Container(
            height: buttonHeight,
            width: MediaQuery.of(context).size.width * 0.80,
            decoration: BoxDecoration(
              color: Uicolors.buttonbg,
              borderRadius: BorderRadius.all(Radius.circular(
                  buttonHeight / 2) //
                  ),
            ),
            child: MaterialButton(
              color: Uicolors.buttonbg,
              child: Text(
                value.toUpperCase(),
                style: buttonStyle,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonHeight/2),
              ),
              onPressed: () {
                if (validateAndSave()) {
                  if (this._phoneCode.text != "") {
                    HashMap<String, dynamic> guestDetails = HashMap();
                    guestDetails.putIfAbsent(
                        "salutation", () => this._salutationTxt.text);
                    guestDetails.putIfAbsent(
                        "firstName", () => this._firstName.text);
                    guestDetails.putIfAbsent(
                        "lastName", () => this._lastName.text);
                    guestDetails.putIfAbsent(
                        "country", () => this._countryTxt.text);
                    guestDetails.putIfAbsent(
                        "phoneCode", () => this._phoneCode.text);
                    guestDetails.putIfAbsent(
                        "phoneNumber", () => this._phoneNumber.text);
                    guestDetails.putIfAbsent("email", () => this._email.text);


                    updateUserDetails();
                  }
                  //    Navigator.push(context, MaterialPageRoute(builder: (_)=>AsGuestSummery()));
                }
              },
            )));
  }

  void updateUserDetails() {
    Contact contact = Contact();
    contact.emailAddress = _email.text;
    contact.phoneNumbers = _phoneNumber.text;
    contact.countryCode = _phoneCode.text;

    Name name = Name();
    name.firstName = _firstName.text;
    name.lastName = _lastName.text;
    name.fullName = _firstName.text + " " + _lastName.text;

    Address address = Address();
    address.country = _countryTxt.text;

    UserModel userModel =
        UserModel(address: address, contact: contact, name: name);
    userModel.title = _salutationTxt.text;

    CollectionReference userDetails =
        FirebaseFirestore.instance.collection('users');
    final User? user = auth.currentUser;
    if (user != null) {
      var userId = user.uid;
      EasyLoading.show();
      // AppUtility().showProgressDialog(context,type:null,dismissDialog:(value){
      //   dialogContext = value;
      // });
      if (profileImage != null) {
        uploadFile(profileImage!).then((value) {
          value.whenComplete(() {
            value.snapshot.ref.getDownloadURL().then((value) {
              userModel.name.profileImage = value;

              updateUserStore(userDetails, userModel, userId);
            });
          });
        });
      } else {
        userModel.name.profileImage = profileUrl;

        updateUserStore(userDetails, userModel, userId);
      }
    }
  }

  Future<void> getUserDatas() async {
    CollectionReference userDetails =
        FirebaseFirestore.instance.collection('users');
    final User? user = auth.currentUser;
    if (user != null) {
      var userId = user.uid;
      EasyLoading.show();
      // BuildContext? dialogContext;
      // await Future.delayed(Duration.zero);
      // appUtility.showProgressDialog(context,type:null,dismissDialog:(value){
      //   dialogContext = value;
      // });
      await userDetails.doc(userId).get().then((value) async {
        EasyLoading.dismiss();
        // await new Future.delayed(const Duration(milliseconds: 500));
        // appUtility.dismissDialog(dialogContext!);
        UserModel users =
            UserModel.fromJson(value.data() as Map<String, dynamic>);
        if (users != null) {
          setUserDetails(users);
        }
      });
    }
  }

  void setUserDetails(UserModel users) {
    setState(() {
      _salutationTxt.text = users.title != null ? users.title : "";
      _firstName.text = users.name.firstName != ""
          ? users.name.firstName
          : users.name.fullName;
      _lastName.text = users.name.lastName != null ? users.name.lastName : "";
      _phoneCode.text =
          users.contact.countryCode != null ? users.contact.countryCode : "";
      _email.text =
          users.contact.emailAddress != null ? users.contact.emailAddress : "";
      _phoneNumber.text =
          users.contact.phoneNumbers != null ? users.contact.phoneNumbers : "";
      _countryTxt.text =
          users.address.country != null ? users.address.country : "";
      profileUrl =
          users.name.profileImage != null ? users.name.profileImage : "";
    });
  }

  /// show bottom sheet popup for the options to pick the profile pics
  void optionsBottomSheet(context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        context: context,
        builder: (BuildContext buildContext) {
          return Container(
            height: 200.0,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Wrap(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 20.0, top: 10.0),
                    child: new Text("Upload Using",
                        style: TextStyle(
                            color: Uicolors.loginBoldText,
                            fontSize: 16,
                            fontFamily: 'Popins-regular'))),
                new ListTile(
                  onTap: () async {
                    //Navigator.of(context).pop();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    var image1 = File(pickedFile!.path);
                    Navigator.of(context).pop();
                    setState(() {
                      profileImage = image1;
                    });
                  },
                  leading: new Icon(
                    Icons.panorama,
                    color: Theme.of(context).primaryColor,
                    size: 24.0,
                  ),
                  title: new Text('Gallery',
                      style: TextStyle(
                          color: Uicolors.loginBoldText,
                          fontSize: 14,
                          fontFamily: 'Popins-regular')),
                ),
                new ListTile(
                  onTap: () async {
                    Navigator.of(context).pop();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.camera);
                    var image1 = File(pickedFile!.path);
                    setState(() {
                      profileImage = image1;
                    });
                  },
                  leading: new Icon(
                    Icons.camera_alt,
                    color: Theme.of(context).primaryColor,
                    size: 24.0,
                  ),
                  title: new Text('Camera',
                      style: TextStyle(
                          color: Uicolors.loginBoldText,
                          fontSize: 14,
                          fontFamily: 'Popins-regular')),
                )
              ],
            ),
          );
        });
  }

  /// The user selects a file, and the task is added to the list.
  Future<firebase_storage.UploadTask> uploadFile(File file) async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file was selected'),
      ));
      //return null;
    }

    firebase_storage.UploadTask uploadTask;

    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .refFromURL(firebaseStorageUrl)
        .child('profile')
        .child(
            '/profile${auth.currentUser!.uid}${DateTime.now().millisecondsSinceEpoch}.jpg');

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': file.path});

    uploadTask = ref.putFile(File(file.path), metadata);

    return Future.value(uploadTask);
  }

  void updateUserStore(CollectionReference<Object?> userDetails,
      UserModel userModel, String userId) {
    userDetails.doc(userId).update(userModel.toJson()).then((value) async {
      EasyLoading.dismiss();
      // await new Future.delayed(const Duration(milliseconds: 500));
      // AppUtility().dismissDialog(dialogContext!);
      Navigator.of(context).pop();
    });
  }
}
