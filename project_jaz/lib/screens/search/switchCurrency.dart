import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/currencyModel.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/commonutils.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';

class SwitchCurrency extends StatefulWidget {
  _SortSearchPage createState() => _SortSearchPage();
}

class _SortSearchPage extends State<SwitchCurrency> {
  String selectedValue = '';
  List<Currencies> _currencyList = [];
  List<Currencies> _filterList = [];
  Currencies?_currencies ;


  @override
   initState() {
     getCurrencyList();
  }

  getCurrencyList() async {
    try {
      List responses = await Future.wait(
          [CommonUtils().readCurrencies(),
            AppUtility.getCurrencyCode()]);
      setState(() {
        _currencyList = (responses[0] as CurrencyResponse).currencies;
        selectedValue = responses[1].toString();
        changePosition();
      });
    }catch (e) {
     AppUtility().showToastView(Strings.errorMessage, context);
    }
  }
  changePosition(){
    int pos = _currencyList.indexWhere((element) =>
    element.iso == selectedValue);
    if (pos > -1) {
      Currencies c = _currencyList[pos];
      _currencyList.removeAt(pos);
      _currencyList.insert(0, c);
    }
  }

  @override
  Widget build(BuildContext context) {
    final overallHeight = MediaQuery.of(context).size.height;
    final overallWidth = MediaQuery.of(context).size.width;
    var boxLeftPadding = overallWidth * 0.055;
    var nameTopPadding = overallHeight * 0.025;
    var nameBottomPadding = overallHeight * 0.02;
    var containerHeight = overallHeight * 0.055;
    var currencyTitleLeftPadding = overallWidth * 0.1;
    var buttonLeftPadding = overallWidth * 0.10;
    var buttonTopPadding = overallHeight * 0.006;
    var buttonHeight = overallHeight * 0.055;
    var buttonWidth = overallWidth * 0.8;
    final TextEditingController typeAheadController = TextEditingController();

    List<String> suggessionList = [];
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
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
                        Navigator.pop(context,true);
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * 0.005, 0, 0, 0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Uicolors.buttonbg,
                          size: 15,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context,true);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 0),
                        child: Text(Strings.switchCurrency,
                            style: backSigninGreenStyle),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Scrollbar(
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(
                      top: nameTopPadding,
                      bottom: nameBottomPadding,
                      left: boxLeftPadding,
                      right: boxLeftPadding),
                  //width: containerWidth,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(fieldBorderRadius),
                    color: Uicolors.desSearchBg,
                  ),
                  child: TypeAheadFormField(
                      noItemsFoundBuilder: (context) => ListTile(
                          title: Text(
                            Strings.noOption,
                            textAlign: TextAlign.center,
                            style: placeHolderStyle,
                          )),
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: typeAheadController,
                          onChanged: (content) {},
                          decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.only(top: overallHeight * 0.014),
                              hintStyle: placeHolderStyle,
                              hintText: Strings.search,
                              enabledBorder: InputBorder.none,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              isCollapsed: true,
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                size: 30,
                                color: Uicolors.greyText,
                              ))),
                      itemBuilder: (context, Currencies currency) {
                        return Container(
                          child: ListTile(
                            title: Text(
                              currency.currencyName + "-" + currency.iso,
                              style: textFieldStyle,
                            ),
                          ),
                        );
                      },
                      onSuggestionSelected: (Currencies currencies) {
                        checkSelectedPosition(currencies.iso.toString());
                        changePosition();
                      },
                      suggestionsCallback: (pattern) {
                        if (pattern.length > 0) {
                          return _currencyList
                              .where((element) =>
                          element.iso
                              .toLowerCase()
                              .contains(pattern.toLowerCase()) ||
                              element.currencyName
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                              .toList();
                        } else {
                          return _currencyList;
                        }
                      },
                      transitionBuilder:
                          (context, suggestionsBox, animationController) =>
                      suggestionsBox)),
              _currencyList.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _currencyList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: currencyTitleLeftPadding,
                            top: 0,
                            bottom: 0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: new Text(
                                  _currencyList[index].currencyName +
                                      "-" +
                                      _currencyList[index].iso,
                                  style: _currencyList[index].iso ==
                                      selectedValue
                                      ? checkBoxListTextStyle
                                      : radioButtonContextTextStyle),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Radio(
                                  value: _currencyList[index].iso,
                                  groupValue: selectedValue,
                                  onChanged: (value) {
                                    checkSelectedPosition(
                                        value.toString());
                                  },
                                  activeColor: Uicolors.buttonbg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: boxLeftPadding, right: boxLeftPadding),
                        child: Divider(
                          color: Uicolors.confirmsearchbg,
                          thickness: 1,
                        ),
                      ),
                    ],
                  );
                },
              )
                  : Container(
                child: Text(Strings.noDataFound, style: textFieldStyle),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: BottomAppBar(
        //     child: Padding(
        //       padding: EdgeInsets.only(
        //           left: buttonLeftPadding,
        //           right: buttonLeftPadding,
        //           top: buttonTopPadding,
        //           bottom: buttonTopPadding),
        //       child: MaterialButton(
        //         color: Uicolors.buttonbg,
        //         minWidth: buttonWidth,
        //         height: buttonHeight,
        //         shape: new RoundedRectangleBorder(
        //           borderRadius: new BorderRadius.circular(buttonHeight / 2),
        //         ),
        //         child: Text(
        //           Strings.confirm.toUpperCase(),
        //           style: buttonStyle,
        //         ),
        //         onPressed: () {
        //           AppUtility.saveCurrencyCode(selectedValue);
        //           Navigator.pop(context, true);
        //         },
        //       ),
        //     ))
    );
  }

  void checkSelectedPosition(String value) {
    setState(() {
      selectedValue = value.toString();
    });
    AppUtility.saveCurrencyCode(selectedValue);
  }
}
