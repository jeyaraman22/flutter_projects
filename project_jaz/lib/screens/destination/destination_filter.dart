import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';

class DestinationFilter extends StatefulWidget {
  _DestinationFilterState createState() => _DestinationFilterState();
}

class _DestinationFilterState extends State<DestinationFilter> {
  int radioValue = 1;

  void _handleRadioValueChange(int? value) {
    setState(() {
      radioValue = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var containerTopPadding = overAllHeight * 0.03;
    var containerLeftPadding = overAllWidth * 0.035;
    var containerHeightPadding = overAllHeight*0.55;
    var containerWidthPadding = overAllWidth * 1;
    var titleTopPadding = overAllHeight * 0.02;
    var titleLeftPadding = overAllWidth * 0.05;
    var dividerBottomPadding = overAllHeight * 0.01;
    var buttonHeight = overAllHeight * 0.05;
    var titleBottomPadding = overAllHeight * 0.02;
    var subTitleLeftPadding = overAllWidth * 0.055;
    var buttonWidth =  overAllWidth * 0.75;

    return Scaffold(
        backgroundColor: Uicolors.backgroundbg,
        appBar: AppBar(
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
                          size: 15,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 0),
                        child: Text(Strings.backToDestination,
                            style: backSigninGreenStyle),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: containerTopPadding,
                  left: containerLeftPadding,
                  right: containerLeftPadding),
              child: Container(
                  width: containerWidthPadding,
                  height: containerHeightPadding,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(containerBorderRadius),
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(
                            left: titleLeftPadding,
                            right: titleLeftPadding,
                            top: titleTopPadding,
                          //  bottom: titleBottomPadding
                        ),
                        child: Text(
                          Strings.findPerfectMatch,
                          style: findMatchTextStyle,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: containerLeftPadding,
                            right: containerLeftPadding,
                            top: titleBottomPadding,
                            bottom: titleBottomPadding
                        ),
                        child: Divider(
                          color:Uicolors.desText,
                          thickness: 0.5,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: titleLeftPadding,
                            right: titleLeftPadding,
                           // bottom: titleBottomPadding
                        ),
                        child:
                            Text(Strings.perfectMatchDes, style: descTextStyle),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: subTitleLeftPadding,
                            right: subTitleLeftPadding,
                            top: titleTopPadding
                        ),
                        alignment: Alignment.topLeft,
                        child: Text(
                          Strings.iWantTo,
                          style: findMatchTextStyle,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: subTitleLeftPadding),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child:
                                  new Text(Strings.relax, style: descTextStyle),
                            ),
                            Expanded(
                              child: Container(
                                child: Radio(
                                  value: 1,
                                  groupValue: radioValue,
                                  onChanged: _handleRadioValueChange,
                                  activeColor: Uicolors.buttonbg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: containerLeftPadding,
                            right: containerLeftPadding),
                        child: Divider(
                          color: Uicolors.desText,
                          thickness: 0.5,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: subTitleLeftPadding),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: new Text(Strings.adventureHoliday,
                                  style: descTextStyle),
                            ),
                            Expanded(
                              child: Container(
                                child: Radio(
                                  value: 2,
                                  groupValue: radioValue,
                                  onChanged: _handleRadioValueChange,
                                  activeColor: Uicolors.buttonbg,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: containerLeftPadding,
                            right: containerLeftPadding),
                        child: Divider(
                          color:Uicolors.desText,
                          thickness: 0.5,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: subTitleLeftPadding),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child:  Text(Strings.memorableVacation,
                                  style: descTextStyle),
                            ),
                            Expanded(
                              child: Container(
                                child: Radio(
                                  value: 3,
                                  groupValue: radioValue,
                                  onChanged: _handleRadioValueChange,
                                  activeColor: Uicolors.buttonbg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(top: overAllHeight * 0.3),
              child: Center(
                child: MaterialButton(
                  color: Uicolors.buttonbg,
                  minWidth:buttonWidth,
                  height: buttonHeight,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(buttonHeight / 2),
                  ),
                  child: Text(
                    Strings.apply.toUpperCase(),
                    style: buttonStyle,
                  ),
                  onPressed: () {},
                ),
              ),
            )
          ],
        ));
  }
}
