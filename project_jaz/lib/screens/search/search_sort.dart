import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/models/pricemodel.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';

class SearchSort extends StatefulWidget {
  final Function(FilterSortingOrderEnum) sortValue;
  final FilterSortingOrderEnum sortEnum;
  SearchSort(this.sortEnum,{required this.sortValue});
  _SortSearchPage createState() => _SortSearchPage();
}

class _SortSearchPage extends State<SearchSort> {
  int radioValue = 0;
  var title="";
  List<PriceModel> priceList = [
    PriceModel(
        isClicked: false,
        id: 1,
        name: Strings.pricehighttolow,
        subName: "",
        sortStr: FilterSortingOrderEnum.priceDesc),
    PriceModel(
        isClicked: true,
        id: 2,
        name: Strings.pricelowtohigh,
        subName: "",
        sortStr: FilterSortingOrderEnum.priceAsc),
    PriceModel(
        isClicked: false,
        id: 3,
        name: Strings.byrating,
        subName: Strings.bestFirst,
        sortStr: FilterSortingOrderEnum.hotelRatingDesc),
    PriceModel(
        isClicked: false,
        id: 4,
        name: Strings.bydistance,
        subName: Strings.fromAirPort,
        sortStr: FilterSortingOrderEnum.durationDesc)
  ];
  // List priceDetails=[{isClicked: true, id: 0, name: ''}];

  @override
  void initState() {
    super.initState();
    priceList.forEach((e) {
        if(e.sortStr == widget.sortEnum){
          e.isClicked = true;
           title = e.name;
            radioValue = e.id;
        }else{
          e.isClicked = false;
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;

    var containerTopPadding = overAllHeight * 0.03;
    var containerLeftPadding = overAllWidth * 0.035;
    var containerHeightPadding = overAllHeight * 0.6;
    var containerWidthPadding = overAllWidth * 1;
    var containerFieldsHeightPadding = overAllHeight * 0.90;
    var titleTopPadding = overAllHeight * 0.03;
    var titleLeftPadding = overAllWidth * 0.05;
    var radioButtonTextPadding = overAllHeight * 0.03 / 1.5;
    var subTextTopPadding = overAllHeight * 0.03;
    var fieldHeightPadding = overAllHeight * 0.007;
    var buttonHeight = overAllHeight * (AppUtility().isTablet(context) ? 0.075 : 0.055);
    var buttonWidth = overAllWidth * 0.8;
    return Scaffold(
        backgroundColor: Uicolors.backgroundbg,
        appBar: AppBar(
          toolbarHeight: AppUtility().isTablet(context)?80:AppBar().preferredSize.height,
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
                        child: Text(Strings.backToSearchResult,
                            style: backSigninGreenStyle),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            Stack(
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
                      boxShadow: boxShadow,
                      // borderRadius:
                      //     BorderRadius.circular(containerBorderRadius),
                      color: Colors.white,
                     // border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(
                                left: titleLeftPadding,
                                right: titleLeftPadding,
                                bottom: radioButtonTextPadding,
                                top: titleTopPadding),
                            child: Text(
                              title,
                              style: priceHighGreenTextStyle,
                            ),
                          ),
                          Container(
                         //   height: containerFieldsHeightPadding,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: priceList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final clickPriceEvent = priceList[index];
                                return Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: 5,
                                          bottom: 5,
                                          left: containerLeftPadding,
                                          right: containerLeftPadding),
                                      child: Divider(
                                        color: Uicolors.confirmsearchbg,
                                        thickness: 1,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: titleLeftPadding,
                                          top: fieldHeightPadding,
                                          bottom: fieldHeightPadding),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                              flex: 3,
                                              child: new Stack(
                                                children: [
                                                  Text(clickPriceEvent.name,
                                                      style: radioButtonContextTextStyle),
                                                  if (clickPriceEvent.subName != '')
                                                    new Padding(
                                                      padding: EdgeInsets.only(
                                                          top:
                                                              subTextTopPadding),
                                                      child: Text(
                                                          clickPriceEvent
                                                              .subName,
                                                          style:
                                                              subTxtTextStyle),
                                                    ),
                                                ],
                                              )),
                                          Expanded(
                                            child: Container(
                                              child: Transform.scale(scale: (AppUtility().isTablet(context)?2.0:1.0),
                                              child: Radio(
                                                onChanged: (value) {
                                                  setState(() {
                                                    radioValue = int.parse(value.toString());
                                                    priceList.forEach((e) {
                                                      if (radioValue == e.id) {
                                                        e.isClicked = true;
                                                        title = e.name;
                                                      }else{
                                                        e.isClicked = false;
                                                      }

                                                    });
                                                  });

                                                  //  _handleRadioValueChange(value);
                                                },
                                                groupValue: radioValue,
                                                value: clickPriceEvent.id,
                                                activeColor: Uicolors.buttonbg,
                                              ),),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(children: <Widget>[
                  //first element in column is the transparent offset
                  Padding(
                    padding: EdgeInsets.only(top: overAllHeight * 0.6),
                    child: Center(
                      child: MaterialButton(
                        color: Uicolors.buttonbg,
                        minWidth: buttonWidth,
                        height: buttonHeight,
                        shape: new RoundedRectangleBorder(
                          borderRadius:
                              new BorderRadius.circular(buttonHeight / 2),
                        ),
                        child: Text(
                          Strings.confirm.toUpperCase(),
                          style: buttonStyle,
                        ),
                        onPressed: () {
                          priceList.forEach((e) {
                            if (e.isClicked) {
                              widget.sortValue.call(e.sortStr);
                            }
                          });
                          Navigator.pop(context);

                        },
                      ),
                    ),
                  )
                ])
              ],
            ),
            //for the button i create another column
          ],
        ));
  }
}
