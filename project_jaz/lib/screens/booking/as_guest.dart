import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:graphql/client.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/roommodel.dart';
import 'package:jaz_app/screens/booking/as_guest1.dart';
import 'package:jaz_app/screens/booking/as_guest2.dart';
import 'package:jaz_app/screens/booking/termssandconditions.dart';
import 'package:jaz_app/screens/bottomnavigation/bottombar.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:country_pickers/countries.dart';
import 'package:jaz_app/widgets/summaryroomlist.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../homebottombar.dart';

// ignore: must_be_immutable
class AsGuest extends StatefulWidget {
  final HashMap<String, dynamic> selectedRoomdet;

  AsGuest(this.selectedRoomdet);

  @override
  _AsGuestState createState() => _AsGuestState();
}

final _formKey2 = GlobalKey<FormState>();

class _AsGuestState extends State<AsGuest> {
  ScrollController _controllerOne = ScrollController();
  TextEditingController _salutationTxt = TextEditingController();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _phoneCode = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();
  TextEditingController _countryTxt = TextEditingController();

  bool isExpanded = true;
  int selectedRadio = 0;
  var selectedCountry = "";
  var selectedSalutation = "";
  bool checkValidate = false;
  AppUtility appUtility = AppUtility();
  String roomName = "";
  var salutationList = ["Mr.", "Mrs."];
  double bottomSpace = 20;
  bool enableSaveRooms = true;
  List<Room> roomDetails =[];


  @override
  void initState() {
    super.initState();
    appUtility = AppUtility();
    roomDetails = GlobalState.selectedRoomList;
    //roomName = GlobalState.selectedBookingRoomDet["selectedRoomName"];
    _controllerOne =
        ScrollController(keepScrollOffset: true, initialScrollOffset: 0.0);


  }

  bool validateAndSave() {
    final FormState? form = _formKey2.currentState;
    var details = roomDetails.where((element) => element.roomDetail.isEmpty);
    if (details.length > 0) {
      appUtility.showToastView("Please Select Room.", context);
      return false;
    }else if (form!.validate()) {
        form.save();
        return true;
      } else {
        return false;
      }

  }

  AppBar _appBarData(BuildContext context) {
    return AppBar(
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
                      Strings.summaryStr,
                      style: summaryTextStyle,
                    )),
              ),
            ],
          ),
        ));
  }

  Widget _nextButton(BuildContext context) {
    var overAllHeight = MediaQuery.of(context).size.height;
    var buttonHeight = overAllHeight * 0.055;
    if (buttonHeight < 40) {
      buttonHeight = 45;
    }
    String value = "Next";
    return Align(
        alignment: Alignment.center,
        child: Container(
            height: buttonHeight,
            width: AppUtility().isTablet(context)
                ? MediaQuery.of(context).size.width * 0.70
                : MediaQuery.of(context).size.width * 0.80,
            decoration: BoxDecoration(
              color: Uicolors.buttonbg,
              borderRadius:
                  BorderRadius.all(Radius.circular(buttonHeight / 2) //
                      ),
            ),
            child: MaterialButton(
              color: Uicolors.buttonbg,
              child: Text(
                value.toUpperCase(),
                style: buttonStyle,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonHeight / 2),
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


                        pushNewScreen(
                          context,
                          //  [TravellersRoomInput(refIds:roomRefType.map((e) => e.refId!).toList())],
                          screen:
                          AsGuestSummery(widget.selectedRoomdet, guestDetails),
                          // screen:AsGuestSummery(selectedRoomName,roomTypeCode,roomRatePlanCode,widget.hotelCrsCode,widget.hotelName,price),
                          withNavBar: false,
                          // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                        );
                      }
                      //    Navigator.push(context, MaterialPageRoute(builder: (_)=>AsGuestSummery()))
                  }
              },
            )));
  }

  Widget _buildDropdownSelectedItemBuilder(
          Country country, double dropdownItemWidth, BuildContext context) =>
      SizedBox(
          width: dropdownItemWidth,
          child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              child: Row(
                children: <Widget>[
                  ///If its needed please turn it on
                  // CountryPickerUtils.getDefaultFlagImage(country),
                  Expanded(
                      child: Text(
                    '+${country.phoneCode}',
                    style: TextStyle(
                        color: Uicolors.titleText,
                        fontSize: 14,
                        fontFamily: 'Popins-regular'),
                  )),
                ],
              )));

  Widget _buildDropdownItemWithLongText(Country country) => SizedBox(
        //  width: MediaQuery.of(context).size.width * 0.5,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Stack(
            children: <Widget>[
              //  CountryPickerUtils.getDefaultFlagImage(country),
              Padding(
                child: Text(
                  "+${country.phoneCode}",
                ),
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.02),
              )
            ],
          ),
        ),
      );

  Widget _buildDropdownItem(Country country, double dropdownItemWidth) =>
      SizedBox(
        width: dropdownItemWidth,
        child: Row(
          children: <Widget>[
            // CountryPickerUtils.getDefaultFlagImage(country),
            SizedBox(
              width: 8.0,
            ),
            Expanded(child: Text("+${country.phoneCode}(${country.isoCode})")),
          ],
        ),
      );

  _buildCountryPickerDropdown(
      {bool filtered = true,
      bool sortedByIsoCode = false,
      bool hasPriorityList = false,
      bool hasSelectedItemBuilder = false}) {
    double dropdownButtonWidth = MediaQuery.of(context).size.width * 0.25;
    double dropdownItemWidth = dropdownButtonWidth - 30;
    double dropdownSelectedItemWidth = dropdownButtonWidth - 30;
    return Row(
      children: <Widget>[
        SizedBox(
          width: dropdownButtonWidth + 0.15,
          child: CountryPickerDropdown(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            itemHeight: null,
            isDense: false,
            selectedItemBuilder: hasSelectedItemBuilder == true
                ? (Country country) => _buildDropdownSelectedItemBuilder(
                    country, dropdownSelectedItemWidth, context)
                : null,
            itemBuilder: (Country country) => hasSelectedItemBuilder == true
                ? _buildDropdownItemWithLongText(country)
                : _buildDropdownItem(country, dropdownItemWidth),
            // initialValue: 'AR',
            isFirstDefaultIfInitialValueNotProvided: true,
            itemFilter: filtered
                ? (c) => ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode)
                : null,
            priorityList: hasPriorityList
                ? [
                    CountryPickerUtils.getCountryByIsoCode('GB'),
                    CountryPickerUtils.getCountryByIsoCode('CN'),
                  ]
                : null,
            sortComparator: sortedByIsoCode
                ? (Country a, Country b) => a.isoCode.compareTo(b.isoCode)
                : null,
            onValuePicked: (Country country) {
              setState(() {
                selectedCountry = country.name;
              });
            },
          ),
        ),
      ],
    );
  }

  expandedList() {
    Container();
  }

  arrowUp(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(right: 10),
        child: Icon(
          isExpanded
              ? Icons.keyboard_arrow_down_sharp
              : Icons.keyboard_arrow_up_sharp,
          size: infoIconSize,
          color: Uicolors.buttonbg,
        ));
  }


  @override
  Widget build(BuildContext context) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    final leftPadding = overAllWidth * 0.035;
    final topPadding = overAllHeight * 0.015;
    var boxHeight = overAllHeight * 0.055;
    final boxWidth = overAllWidth * 0.7;
    var borderRadius = fieldBorderRadius;
    var summaryToppadding = overAllHeight * 0.025;
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
                      Padding(
                        padding: EdgeInsets.only(
                            left: leftPadding,
                            right: leftPadding,
                            top: summaryToppadding),
                        child: SummaryRoomList(roomDetails,"guest", summaryCallBack: (selectedRoomList,actionName) async {
                          this.setState(() {
                            roomDetails = selectedRoomList;
                          });
                          if(actionName != "remove") {
                            int emptyRoomIndex = 0;
                            for (int i = 0; i < roomDetails.length; i++) {
                              if (roomDetails[i].roomDetail.isEmpty) {
                                emptyRoomIndex = i;
                              }
                            }
                            SharedPreferences prefs = await SharedPreferences
                                .getInstance();
                            prefs.setInt("selectedIndex", emptyRoomIndex);
                            Navigator.pop(context);
                          }
                        },
                        ),
                      ),

                      AppUtility().isTablet(context)
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: salutationWidget(
                                            boxHeight,
                                            borderRadius,
                                            topPadding,
                                            leftPadding)),
                                    Expanded(
                                      child: firstNameWidget(
                                          boxHeight,
                                          borderRadius,
                                          topPadding,
                                          leftPadding),
                                    )
                                    //salutionWidget
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: lastNameWidget(
                                            boxHeight,
                                            borderRadius,
                                            topPadding,
                                            leftPadding)),
                                    Expanded(
                                      child: countryWidget(
                                          boxHeight,
                                          borderRadius,
                                          topPadding,
                                          leftPadding),
                                    )

                                    //salutionWidget
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                            padding: EdgeInsets.only(
                                                top: topPadding,
                                                left: leftPadding,
                                                right: leftPadding),
                                            child: showCodeWidget(
                                                boxHeight, borderRadius))),
                                    Expanded(
                                        child: Container(
                                            padding: EdgeInsets.only(
                                                top: topPadding,
                                                left: leftPadding,
                                                right: leftPadding),
                                            child:
                                                showPhoneNoWidget(boxHeight))),

                                    //salutionWidget
                                  ],
                                ),
                                emailWidget(boxHeight, borderRadius, topPadding, leftPadding)
                              ],
                            )
                          : Column(
                              children: [
                                salutationWidget(boxHeight, borderRadius,
                                    topPadding, leftPadding),
                                //salutionWidget
                                firstNameWidget(boxHeight, borderRadius,
                                    topPadding, leftPadding),
                                //firstName
                                lastNameWidget(boxHeight, borderRadius,
                                    topPadding, leftPadding),
                                // last name
                                countryWidget(boxHeight, borderRadius,
                                    topPadding, leftPadding),
                                // country

                                codeAndPhoneNoWidget(boxHeight, borderRadius,
                                    topPadding, leftPadding),
                                // code&phoneWidget
                                emailWidget(boxHeight, borderRadius, topPadding,
                                    leftPadding),
                              ],
                            ),
                      // emailWidget
                      Align(
                        child: Padding(
                          child: Row(
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: Uicolors.desText,
                                ),
                                child: Transform.scale(
                                    scale: (AppUtility().isTablet(context)
                                        ? 1.8
                                        : 1.0),
                                    child: Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: Uicolors.buttonbg,
                                      value: enableSaveRooms,
                                      onChanged: (value) {
                                        setState(() {
                                          enableSaveRooms = value!;
                                        });
                                      },
                                    )),
                              ),
                              Text(
                                Strings.applyStr,
                                style: applyTextStyle,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.only(
                              top: topPadding,
                              left: leftPadding,
                              right: leftPadding,
                              bottom:
                                  MediaQuery.of(context).size.height * 0.02),
                        ),
                        alignment: Alignment.topLeft,
                      ),
                      _nextButton(context),
                Padding(
                  padding: EdgeInsets.only(
                      left: leftPadding, right: leftPadding),
                     child: TermsAndConditions(Strings.policyStr,roomDetails[0])
                )
                    ],
                  )),
            );
          },
        ),
      ),
    );
  }

  salutationWidget(boxHeight, borderRadius, topPadding, leftPadding) {
    return Padding(
      child: Container(
          alignment: Alignment.centerLeft,
          height: boxHeight,
          //     width: boxWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white,
            border: border,
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Padding(
                child: TypeAheadFormField(
                    noItemsFoundBuilder: (context) => ListTile(
                            title: Text(
                          Strings.noOption,
                          textAlign: TextAlign.center,
                          style: placeHolderStyle,
                        )),
                    textFieldConfiguration: TextFieldConfiguration(
                        keyboardType: TextInputType.name,
                        enableInteractiveSelection: true,
                        controller: this._salutationTxt,
                        style: guestTextFieldStyle,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          errorStyle: errorTextStyle,
                          border: InputBorder.none,
                          hintText: Strings.salutationStr,
                          contentPadding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.05,
                              0,
                              0,
                              0),
                          hintStyle: guestHintTextFieldStyle,
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
                                .contains(pattern.toLowerCase()))
                            .toList();
                      } else {
                        return salutationList;
                      }
                    },
                    transitionBuilder:
                        (context, suggestionsBox, animationController) =>
                            suggestionsBox,
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
                    right: MediaQuery.of(context).size.width * 0.02,
                    // top: MediaQuery.of(context).size.height *
                    //     0.01
                  ),
                ),
                alignment: Alignment.centerRight,
              )
            ],
          )),
      padding: EdgeInsets.only(
          top: topPadding, left: leftPadding, right: leftPadding),
    );
  }

  Widget firstNameWidget(boxHeight, borderRadius, topPadding, leftPadding) {
    return Padding(
      child: Container(
          alignment: Alignment.centerLeft,
          height: boxHeight,
          //  width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
            border: border,
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white,
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
                if (args!.trim().toString().isNotEmpty&& args.trim().toString().length<=30) {
                  return null;
                }else if (args.toString().length>30){
                  return 'First Name should not exceed 30 characters';
                } else {
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
          top: topPadding, left: leftPadding, right: leftPadding),
    );
  }

  Widget lastNameWidget(boxHeight, borderRadius, topPadding, leftPadding) {
    return Padding(
      child: Container(
          alignment: Alignment.centerLeft,
          height: boxHeight,
          //   width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
            border: border,
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white,
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
                }else {
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
          top: topPadding, left: leftPadding, right: leftPadding),
    );
  }

  Widget countryWidget(double boxHeight, double borderRadius, double topPadding,
      double leftPadding) {
    return Padding(
      child: Container(
          alignment: Alignment.centerLeft,
          height: boxHeight,
          // width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white,
            border: border,
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
                  textFieldConfiguration: TextFieldConfiguration(
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
                        contentPadding: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * 0.05, 0, 0, 0),
                        hintStyle: guestHintTextFieldStyle,
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
                    this._phoneCode.text = "+" + items.phoneCode;
                  },
                  suggestionsCallback: (pattern) {
                    if (pattern.length > 0) {
                      return countryList
                          .where((element) => element.name
                              .toLowerCase()
                              .contains(pattern.toLowerCase()))
                          .toList();
                    } else {
                      return countryList;
                    }
                  },
                  transitionBuilder:
                      (context, suggestionsBox, animationController) =>
                          suggestionsBox,
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
                    right: MediaQuery.of(context).size.width * 0.02,
                    // top: MediaQuery.of(context).size.height *
                    //     0.015
                  ),
                ),
                alignment: Alignment.centerRight,
              )
            ],
          )),
      padding: EdgeInsets.only(
          top: topPadding, left: leftPadding, right: leftPadding),
    );
  }

  Widget emailWidget(boxHeight, borderRadius, topPadding, leftPadding) {
    return Padding(
      child: Container(
        alignment: Alignment.centerLeft,
        height: boxHeight,
        //  width: MediaQuery.of(context).size.width * 0.80,
        decoration: BoxDecoration(
          border: border,
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.white,
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
              fillColor: Colors.black,
              hintText: Strings.emailStr,
              hintStyle: guestHintTextFieldStyle,
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              isCollapsed: true,
              errorStyle: errorTextStyle,

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
                if (!appUtility.validateEmail(args.toString())) {
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
          top: topPadding, left: leftPadding, right: leftPadding),
    );
  }

  Widget codeAndPhoneNoWidget(
      boxHeight, borderRadius, topPadding, leftPadding) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Padding(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.26,
            child: showCodeWidget(boxHeight, borderRadius),
          ),
          padding: EdgeInsets.only(
              top: topPadding, left: leftPadding, right: leftPadding),
        ),
        Padding(
          child: showPhoneNoWidget(boxHeight),
          padding: EdgeInsets.only(
              top: topPadding,
              left: MediaQuery.of(context).size.width * 0.31,
              right: leftPadding),
        ),
      ],
    );
  }

  showCodeWidget(boxHeight, borderRadius) {
    return Container(
        height: boxHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.white,
          border: border,
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
              textFieldConfiguration: TextFieldConfiguration(
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
                  keyboardType: TextInputType.number,
                  enableInteractiveSelection: true,
                  controller: this._phoneCode,
                  style: guestTextFieldStyle,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "+XX",
                    isCollapsed: true,
                    errorStyle: errorTextStyle,
                    contentPadding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width * 0.05, 0, 0, 0),
                    hintStyle: guestHintTextFieldStyle,
                  )),
              itemBuilder: (context, Country itemData) {
                var codeText = itemData.phoneCode;
                if (codeText != "No Options") {
                  codeText = "+" + itemData.phoneCode;
                }
                return Container(
                    width: 500,
                    padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
                    child: Row(
                      children: [
                        CountryPickerUtils.getDefaultFlagImage(itemData),
                        Container(
                          padding: EdgeInsets.only(left: 10),
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
                this._phoneCode.text = "+" + items.phoneCode;
                this._countryTxt.text = items.name;
              },
              transitionBuilder:
                  (context, suggestionsBox, animationController) =>
                      suggestionsBox,
              suggestionsCallback: (pattern) {
                if (pattern.contains("+")) {
                  pattern = pattern.replaceAll(RegExp(r'\+'), "");
                }

                if (pattern.length > 0) {
                  return countryList
                      .where((element) => element.phoneCode
                          .toLowerCase()
                          .contains(pattern.toLowerCase()))
                      .toList();
                } else {
                  return countryList;
                }
              },
            ),
            Positioned(
              right: 0,
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
                  right: MediaQuery.of(context).size.width * 0.02,
                  // top: MediaQuery.of(context).size.height *
                  //     0.015
                ),
              ),
            )
          ],
        ));
  }

  showPhoneNoWidget(boxHeight) {
    return Container(
      alignment: Alignment.centerLeft,
      height: boxHeight,
      //  width: MediaQuery.of(context).size.width * 0.64,
      decoration: BoxDecoration(
        border: border,
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
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
            errorStyle: errorTextStyle,

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
          left: MediaQuery.of(context).size.width * 0.05,
          // top: MediaQuery.of(context).size.height *
          //     0.01
        ),
      ),
    );
  }
}
