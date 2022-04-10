import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter_bloc/graphql_flutter_bloc.dart';
import 'package:jaz_app/bloc/global_types_bloc.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/amenitiesmodel.dart';
import 'package:jaz_app/models/filtermodel.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/screens/search/switchCurrency.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;

import '../../graphql_provider.dart';

class SearchFilter extends StatefulWidget {
  final Function(List<int>,  List<String>,String ) hotelAttribute;
  final  List<String> hotelAtr;
  final List<int> avgRating;
  SearchFilter(this.hotelAtr, this.avgRating, {required this.hotelAttribute});
  @override
  _SearchFilterState createState() => new _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  List<StarRatings> starRatingList = StarRatings.getUsers();
  List<Amenities> amenitiesList = [];

  double width = 0.0;
  late GlobalTypesBloc bloc;
  AppUtility appUtility = AppUtility();
  List<int> avgRat = [];
  List<String> hotelAttributes = [];
  String currencyCode = 'USD';

  @override
  void initState() {
    super.initState();

    starRatingList.forEach((e) {
      if(widget.avgRating.contains(e.value)){
        e.isCheck = true;
      }else{
        e.isCheck = false;
      }
    });
    bloc = GlobalTypesBloc(client: client)..run();
    getCurrencyCode();
  }

  backRedirect() {
    starRatingList.forEach((e) {
      if (e.isCheck) {
        avgRat.add(e.value);
      }
    });
    amenitiesList.forEach((e) {
      if (e.isClicked) {
        hotelAttributes.add(e.amenitie.value.toString());
      }
    });
    var currency =  GlobalState.selectedCurrency != null
        ? GlobalState.selectedCurrency
        : Strings.usd;
    widget.hotelAttribute.call(avgRat.length>0?avgRat:[0],hotelAttributes,currency);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final overallHeight = MediaQuery.of(context).size.height;
    final overallWidth = MediaQuery.of(context).size.width;
    var boxLeftPadding = overallWidth * 0.035;
    var boxCornerRadius = fieldBorderRadius;
    var boxTextLeftPadding = overallWidth * 0.04;
    var boxTextTopPadding = overallHeight * 0.02;
    var listTextTopPadding = overallHeight * 0.0035;
    var boxContainerTopPadding = overallHeight * 0.015;

    var nameTopPadding = overallHeight * 0.02;

    var containerListBottom = overallHeight * 0.01;
    var containerListLeft = overallWidth * 0.02;

    var containerHeight = overallHeight * (AppUtility().isTablet(context)?0.075:0.055);

    var fieldLeftPadding = overallWidth * 0.065;
    var fieldRightPadding = overallWidth * 0.025;

    var boxPadding = overallHeight * 0.005;

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
                GestureDetector(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * 0.005, 0, 0, 0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Uicolors.buttonbg,
                          size: backIconSize,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 0),
                        child: Text(Strings.backtosearch,
                            style: backSigninGreenStyle),
                      ),
                    ],
                  ),
                  onTap: () {
                    backRedirect();
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    // margin: EdgeInsets.only(
                    //     right: MediaQuery.of(context).size.height * 0.000),
                    child: Image.asset(
                      "assets/images/JHG_logo.png",
                      width: AppUtility().isTablet(context)?150:100,//100,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Scrollbar(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [

                    GestureDetector(
                      onTap: () {
                        NavigateToCurrencyScreen();
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(
                            top: nameTopPadding,
                            // bottom: nameTopPadding,
                            left: boxLeftPadding,
                            right: boxLeftPadding),
                        //width: containerWidth,
                        height: containerHeight,
                        decoration: BoxDecoration(
                          // borderRadius:
                          //     BorderRadius.circular(fieldBorderRadius),
                            boxShadow: boxShadow,
                            color: Colors.white),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding:
                              EdgeInsets.only(left: boxTextLeftPadding),
                              child: Text(Strings.currency,
                                  style: filterTextStyle),
                            ),
                            Container(
                              child: Stack(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    child: Text(currencyCode,
                                        style: checkBoxListTextStyle),
                                    padding: EdgeInsets.only(
                                        right: fieldLeftPadding,
                                        top: listTextTopPadding),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Uicolors.buttonbg,
                                      size: infoIconSize,
                                    ),
                                    padding: EdgeInsets.only(
                                        left: fieldLeftPadding +
                                            (AppUtility().isTablet(context)
                                                ? 10
                                                : 5),
                                        right: fieldRightPadding),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    
                    Container(
                      margin: EdgeInsets.only(
                          top: boxContainerTopPadding,
                          left: boxLeftPadding,
                          right: boxLeftPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        //border: Border.all(color: Colors.white, width: 1),
                      //  borderRadius: BorderRadius.circular(boxCornerRadius),
                        boxShadow: boxShadow,
                        shape: BoxShape.rectangle,
                      ),
                      child: Column(children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: boxTextLeftPadding,
                                right: boxTextLeftPadding,
                                top: boxTextTopPadding,bottom: 0),
                            child: Text(
                              Strings.starRating,
                              style: checkBoxListTextStyle,
                            ),
                          ),
                        ),
                        Container(
                            // height: 200,
                            alignment: Alignment.centerLeft,
                            height: AppUtility().isTablet(context)?150:100,
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: 2,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      Container(
                                        padding:EdgeInsets.only(left: boxTextLeftPadding,right: boxTextLeftPadding,top: AppUtility().isTablet(context)?boxTextTopPadding:boxPadding),
                                          child: new CheckboxListTile(
                                            contentPadding: EdgeInsets.all(0),
                                        activeColor: Uicolors.buttonbg,
                                        dense: true,
                                        //font change
                                        title: Row(
                                          children: [
                                            SvgPicture.asset(
                                              starRatingList[index].img,
                                              height: backIconSize,
                                              width: backIconSize,
                                              // fit: BoxFit.cover,
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(left: containerListLeft),
                                              child: Text(
                                                starRatingList[index].title,
                                                style: filterTextStyle,
                                              ),
                                            )
                                          ],
                                        ),
                                        value: starRatingList[index].isCheck,
                                        onChanged: (bool? value) {
                                          this.setState(() {
                                            starRatingList[index].isCheck = value!;
                                            // avgRat =  starRatingList[index].value;
                                            // starRatingList.forEach((e) {
                                            //   if (avgRat == e.value) {
                                            //     e.isCheck = true;
                                            //   }else{
                                            //     e.isCheck = false;
                                            //   }
                                            //
                                            // });
                                          });
                                        },
                                      ),
                                      ),
                                    ],
                                  );
                                })),
                      ]),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: boxContainerTopPadding,
                          left: boxLeftPadding,
                          right: boxLeftPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        //border: Border.all(color: Colors.white, width: 1),
                      //  borderRadius: BorderRadius.circular(boxCornerRadius),
                        boxShadow: boxShadow,
                        shape: BoxShape.rectangle,
                      ),
                      child: Column(children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: boxTextLeftPadding,
                                right: boxTextLeftPadding,
                                top: boxTextTopPadding,bottom: 0), //10
                            child: Text(
                              Strings.amenities,
                              style: checkBoxListTextStyle,
                            ),
                          ),
                        ),
                        Container(
                            // height: 200,
                            padding: EdgeInsets.only(bottom: containerListBottom),
                            alignment: Alignment.centerLeft,
                            child: Container(
                              child: BlocBuilder<GlobalTypesBloc,
                                  QueryState<GlobalTypes$Query>>(
                                bloc: bloc,
                                builder: (_, state) {
                                  return state.when(
                                    initial: () => Container(),
                                    loading: (_) => Container(),
                                    error: (error, __) {
                                      return Container();
                                    },
                                    loaded: _themeDisplayResult,
                                    refetch: _themeDisplayResult,
                                    fetchMore: _themeDisplayResult,
                                  );
                                },
                              ),
                            )),
                      ]),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget _themeDisplayResult(
    GlobalTypes$Query? data,
    QueryResult? result,
  ) {
    if (amenitiesList.length == 0) {
      data!.options!.globalTypesStatic!.forEach((e) {
        amenitiesList.add(Amenities(amenitie: e, isClicked: widget.hotelAtr.contains(e.value)));
        });
    }
    return buildContainer();
  }

  Widget buildContainer() {
    final overallWidth = MediaQuery.of(context).size.width;
    final overallHeight = MediaQuery.of(context).size.height;
    var containerListLeft = overallWidth * 0.02;
    var boxTextLeftPadding = overallWidth * 0.04;
    var boxTextTopPadding = overallHeight * 0.02;
    var boxPadding = overallHeight * 0.005;
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: amenitiesList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding:EdgeInsets.only(left: boxTextLeftPadding,right: boxTextLeftPadding,top: AppUtility().isTablet(context)?boxTextTopPadding:boxPadding),
            child: Column(
              children: [
                new CheckboxListTile(
                  contentPadding: EdgeInsets.all(0),
                  activeColor: Uicolors.buttonbg,
                  dense: true,
                  //font change
                  title: Row(
                    children: [
                      Image.asset(
                        appUtility.getAmenities(
                            amenitiesList[index].amenitie.label.toString()),
                        height: AppUtility().isTablet(context)?35:25,
                        width: AppUtility().isTablet(context)?35:25,
                        color: Uicolors.buttonbg,

                        // fit: BoxFit.cover,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: containerListLeft*(AppUtility().isTablet(context)?1.5:1.0)),
                        child: Text(
                          amenitiesList[index].amenitie.label.toString(),
                          style: filterTextStyle,
                        ),
                      )
                    ],
                  ),
                  value: amenitiesList[index].isClicked,
                  onChanged: (bool? value) {
                    this.setState(() {
                      amenitiesList[index].isClicked = value!;
                    });
                  },
                )
              ],
            ),
          );
        });
  }

  void NavigateToCurrencyScreen() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => SwitchCurrency()));
    if (result != null && result) {
      getCurrencyCode();
    }
  }

  void getCurrencyCode() {
    AppUtility.getCurrencyCode().then((value) {
      setState(() {
        if (value != null && !value.contains("null")) {
          currencyCode = value.toString();
          GlobalState.selectedCurrency = currencyCode;
        } else {
          AppUtility.saveCurrencyCode(Strings.usd);
          GlobalState.selectedCurrency = Strings.usd;
        }
      });
    });
  }

}
