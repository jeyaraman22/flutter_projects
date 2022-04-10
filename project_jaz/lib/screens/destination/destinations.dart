import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/widgets/appbar.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'destination_detail.dart';
import 'destination_filter.dart';
import 'destination_list.dart';
import 'package:jaz_app/utils/http_client.dart';

class Destination extends StatefulWidget {
  _DestinationState createState() => _DestinationState();
}

class _DestinationState extends State<Destination> {
  HttpClient httpClient = HttpClient();
  List<dynamic> destinationList = [];

  final TextEditingController typeAheadController = TextEditingController();

  getDestination() async {
    EasyLoading.show();
    try {
      HashMap<String, dynamic> params = HashMap();
      params.putIfAbsent("renderPage", () => "/destinations");
      params.putIfAbsent("_locale", () => "en-gb");
      var response;
      // BuildContext? dialogContext;
      // AppUtility().showProgressDialog(context,type:null,dismissDialog:(value){
      //   dialogContext = value;
      // });
      response = await httpClient.getRenderData(params, "/api/renders", null);
      if (response.statusCode == 200 && json.decode(response.body) != null) {
        // await new Future.delayed(const Duration(milliseconds: 500));
        // AppUtility().dismissDialog(dialogContext!);
        var result = json.decode(response.body);
        result["content"]["main"]["children"].forEach((destination) {
          if (destination["module"]["result"]["headlines"] == null) {
            setState(() {
              destinationList.add(destination);
            });
          }
        });
      } else {
        // await new Future.delayed(const Duration(milliseconds: 500));
        // AppUtility().dismissDialog(dialogContext!);
      }
    }on SocketException catch (_) {
      AppUtility().showToastView(Strings.noInternet, context);
    }catch(e){
      AppUtility().showToastView(Strings.errorMessage, context);
    }
    EasyLoading.dismiss();

  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getDestination();
  }

  @override
  Widget build(BuildContext context) {
    if(MediaQuery.of(context).size.width > 600){
           SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
              DeviceOrientation.portraitUp,
            ]);
        }else{
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
        }
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var imageLeftPadding = overAllWidth * 0.007;
    var imageTopPadding = overAllHeight * 0.03;
    var nameTopPadding = overAllHeight * 0.02;
    var nameBottomPadding = overAllHeight * 0.02;
    var nameLeftPadding = overAllWidth * 0.045;
    var containerHeight = overAllHeight * 0.055;
    var listLeftPadding = overAllWidth * 0.045;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(),
        body: Scrollbar(
          child: Column(
            children: <Widget>[
              Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(
                      top: nameTopPadding,
                      bottom: nameBottomPadding,
                      left: nameLeftPadding,
                      right: nameLeftPadding),
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
                          onChanged: (content) {

                          },
                          decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.only(top: overAllHeight * 0.014),
                              hintStyle: placeHolderStyle,
                              hintText: Strings.whatAreYouLooking,
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
                      itemBuilder: (context, dynamic destination) {
                        return Container(
                          child: ListTile(
                            title: Text(
                              destination["module"]["result"]["header"].toString(),
                              style: textFieldStyle,
                            ),
                          ),
                        );
                      },
                      onSuggestionSelected: (dynamic destination) {

                        GlobalState.selectedRoomRefType = [];
                        GlobalState.selectedRoomRef = [];
                        GlobalState.personDetails = "";
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DestinationDetails(destination
                              ["module"]["result"]["button"]["path"]
                                  .toString())),
                        );

                      },
                      suggestionsCallback: (pattern) {
                        if (pattern.length > 0) {
                          return destinationList
                              .where((element) => element["module"]["result"]
                          ["header"]
                              .toString()
                              .toLowerCase()
                              .contains(pattern.toLowerCase()))
                              .toList();
                        } else {
                          return destinationList;
                        }
                      },
                      transitionBuilder:
                          (context, suggestionsBox, animationController) =>
                      suggestionsBox)),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(
                      bottom: imageTopPadding,
                      left: listLeftPadding,
                      right: listLeftPadding),
                  child: AppUtility().isTablet(context)
                      ? GridView.count(
                      crossAxisCount: 2,

                      //  childAspectRatio: 1/1.35,
                      childAspectRatio: MediaQuery.of(context).orientation == Orientation.landscape ?
                                          (MediaQuery.of(context).size.width + 48.0)/(MediaQuery.of(context).size.height + 68.0): MediaQuery.of(context).size.width /(MediaQuery.of(context).size.height),
                      children:
                      List.generate(destinationList.length, (index) {
                        return showDestinationWidget(index);
                      }))
                      : ListView.builder(

                    //  physics: NeverScrollableScrollPhysics(),
                    itemCount: destinationList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return showDestinationWidget(index);
                      // return DestinationList();
                    },
                    // itemBuilder: (context, index) => SearchDetail(context)
                  ),
                ),
              )
            ],
          ),
        ));
  }

  showDestinationWidget(int index) {
    return GestureDetector(
      onTap: () {
        GlobalState.selectedRoomRefType = [];
        GlobalState.selectedRoomRef = [];
        GlobalState.personDetails = "";
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DestinationDetails(destinationList[index]
              ["module"]["result"]["button"]["path"].toString())),
        );
      },
      child: DestinationList(destinationList[index]),
    );
  }
}
