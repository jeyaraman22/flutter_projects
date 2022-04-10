import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:graphql/client.dart';
import 'package:jaz_app/helper/graphqlconnectivity/constants.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/screens/search/search.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../graphql_provider.dart';
import 'destination_list.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jaz_app/utils/http_client.dart';

class RecentSearch extends StatefulWidget {
  final Function(Destinations$Query$Options$Destinations,String selectionType) destinationValue;
  final TextEditingController typeAheadController;
  final HashMap<String, dynamic> getLocationAvailabilityParam;

  RecentSearch(
  {required this.destinationValue, required this.typeAheadController, required this.getLocationAvailabilityParam});

  @override
  _RecentSearchState createState() => _RecentSearchState();
}

class _RecentSearchState extends State<RecentSearch> {
  bool isScrollDown = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  var size;
  double height = 0.0;
  double blockSize = 0.0;
  double blockSizeVertical = 0.0;
  double boxHeight = 0.0;
  double topSpace = 0.0;
  double destinationTopSpace = 0.0;
  double searchTopSpace = 0.0;
  double searchBottomSpace = 0.0;
  double searchHeight = 0.0;
  double width = 0.0;
  double boxWidth = 0.0;
  double leftPadding = 0.0;
  double textLeftPadding = 0.0;
  double titleLeftPadding = 0.0;
  double logoSize = 0.0;
  double imageAndNameWidthPadding = 0.0;
  bool isCachedImage = false;
  String destinationValue = "";
  String destinationLabel = "";
  bool isClearDestination = false;
  String hotelNodeCode = "";
  final TextEditingController typeAheadController = TextEditingController();
  List<Destinations$Query$Options$Destinations> recentSearchList = [];
  List<Destinations$Query$Options$Destinations> recentViewedList = [];
  String lat="";
  String lng ="";
  String currentCountry  = "";
  HttpClient httpClient = HttpClient();
  List<Destinations$Query$Options$Destinations> destinationList = [];

  void initState() {
    super.initState();
    print(widget.getLocationAvailabilityParam);
    getDestinationList();
    getRecentSearchDetails();
  }
  getDestinationList() async {
    destinationList = [];
    List<Future<dynamic>> requestQuery = [client.query(
      QueryOptions(
          document: DESTINATIONS_QUERY_DOCUMENT,
          variables:DestinationsArguments(bookingType: BookingTypeEnum.hotelOnly).toJson()
      ),
    )];
    var allResponse = await Future.wait(requestQuery);
    QueryResult queryResult = allResponse[0];
    Destinations$Query result =
    Destinations$Query.fromJson(queryResult.data ?? {});
    result.options!.destinations!.forEach((country) {
      country.children!.forEach((city) {
        Destinations$Query$Options$Destinations dest =
        Destinations$Query$Options$Destinations();
        dest.label = '${city.label}, ${country.label}';
        dest.value = city.value;
        if(city.children!.length==1){
          dest.nodeCode = city.children![0].value;
        }
        destinationList.add(dest);
        city.children!.forEach((e) {
          Destinations$Query$Options$Destinations dest =
          Destinations$Query$Options$Destinations();
          dest.label = '${e.label}, ${city.label}, ${country.label}';
          dest.value = e.value;
          dest.nodeCode = e.value;
          destinationList.add(dest);
        });
      });
    });
  }
  getLocationAvailability() async {
    EasyLoading.show();
    try {
      List<Future<dynamic>> locationRequestQuery = [Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)];
      Future.wait(locationRequestQuery).then((value) async {
        var currentLocation = value[0];
      print("lat $value");
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          currentLocation.latitude, currentLocation.longitude);
      Placemark place = placeMarks[0];
      lat = currentLocation.latitude.toString();
      lng = currentLocation.longitude.toString();
      currentCountry = place.country!;
      HashMap<String, dynamic> params = HashMap();
      params = widget.getLocationAvailabilityParam;
      params.putIfAbsent("lat", () => lat);
      params.putIfAbsent("long", () => lng);
      print(params);
      List<String> nearbyHotelList = [];
      var response = await httpClient.getData(params, "/check_location_availability", null);
      if (response.statusCode == 200 && json.decode(response.body) != null) {
        var result = json.decode(response.body);
        var roomStays = result["OTA_HotelAvailRS"]["RoomStays"];
        print("roomstays $roomStays");
        if(roomStays==null){
          AppUtility().showToastView(Strings.noLocation, context);
          Navigator.pop(context);
        }else {
          if (roomStays["RoomStay"].length > 1) {
            result["OTA_HotelAvailRS"]["RoomStays"]["RoomStay"].forEach((
                roomStay) {
              String hotelName = roomStay["BasicPropertyInfo"]["_attributes"]["HotelName"]
                  .toString();
              String hotelCity = roomStay["BasicPropertyInfo"]["Address"]["CityName"]["_text"]
                  .toString();
              String hotelData = "$hotelCity, $currentCountry";
              if (!nearbyHotelList.contains(hotelData)) {
                nearbyHotelList.add("$hotelCity, $currentCountry");
              }
            });
          }
          else if (roomStays["RoomStay"].length == 1) {
            String hotelName = result["OTA_HotelAvailRS"]["RoomStays"]["RoomStay"]["BasicPropertyInfo"]["_attributes"]["HotelName"]
                .toString();
            String hotelCity = result["OTA_HotelAvailRS"]["RoomStays"]["RoomStay"]["BasicPropertyInfo"]["Address"]["CityName"]["_text"]
                .toString();
            nearbyHotelList.add("$hotelName, $hotelCity, $currentCountry");
          } else {
            // print("ksjdhkjdsf");
          }
        }
        print("destinationList$nearbyHotelList");
        if(nearbyHotelList.length>0){
        destinationList.forEach((element) {
          if(element.label == nearbyHotelList[0]){
            widget.destinationValue.call(element,"location");
            Navigator.pop(context);
          }
        });
      }}
        EasyLoading.dismiss();
      });
    } on SocketException catch (e) {
      print(e);
      EasyLoading.dismiss();
      AppUtility().showToastView(Strings.noInternet, context);
    } catch (e) {
      EasyLoading.dismiss();
      print(e);
    }
  }

  getRecentSearchDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList("recentSearches") != null) {
      recentSearchList = prefs
          .getStringList("recentSearches")!
          .map((e) =>
              Destinations$Query$Options$Destinations.fromJson(jsonDecode(e)))
          .toList();
    }
    if (prefs.getStringList("recentViewed") != null) {
      recentViewedList = prefs
          .getStringList("recentViewed")!
          .map((e) =>
          Destinations$Query$Options$Destinations.fromJson(jsonDecode(e)))
          .toList();
    }
    //  recentSearchList = recentSearchList.reversed.toList();
    //  print(recentSearchList.reversed);
  }

  @override
  didChangeDependencies() {
    Future.wait(searchImageUrls.map((element) {
      return AppUtility().cacheImage(context, element.toString());
    })).then((value) {
      setState(() {
        isCachedImage = true;
      });
    }).catchError((onError) {
      print(onError);
    });
    var size = MediaQuery.of(context).size;
    var data = MediaQuery.of(context).textScaleFactor;
    getContext(size, context, data);
    var height = MediaQuery.of(context).size.height;
    var blockSize = MediaQuery.of(context).size.width / 100;
    var blockSizeVertical = height / 100;

    boxHeight = height * 0.055;
    topSpace = height * 0.02;
    destinationTopSpace = height * 0.02;
    searchTopSpace = height * 0.04;
    searchBottomSpace = height * 0.025;
    searchHeight = height * 0.055;
    width = MediaQuery.of(context).size.width;
    boxWidth = width * 0.9;
    leftPadding = width * 0.038;
    textLeftPadding = width * 0.013;
    titleLeftPadding = width * 0.05;
    logoSize = (AppUtility().isTablet(context) ? 200.0 : 130.0);
    if (boxHeight < 40) {
      boxHeight = 45;
      searchHeight = 45;
    }
    imageAndNameWidthPadding = width * 0.025;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 600) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0.0,
          title: Container(
            child:destinationWidget(
                leftPadding, width*0.6, boxHeight, topSpace),
          ),
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(leftPadding,0.0, 0.0, 0.0),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container(
                    //   // padding: EdgeInsets.only(left: titleLeftPadding),
                    //   child: Text(
                    //     Strings.whereNext,
                    //     style: summaryTextStyle,
                    //   ),
                    // ),
                    Container(
                      margin: EdgeInsets.only(top: topSpace),
                      child: GestureDetector(
                        onTap: () async {
                          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                          if (!serviceEnabled) {
                               AppUtility().showToastView(Strings.locationEnableString, context);
                            //   return Future.error('Location services are disabled.');
                          }else{
                            if(await AppUtility().determinePosition()){
                              getLocationAvailability();
                            }
                          }
                          },
                        child:
                      Container(
                        height: 30,
                       child: Row(
                          children: [
                            Container(
                              child: Icon(Icons.place,
                                  size: backIconSize, color: Uicolors.buttonbg),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                left: textLeftPadding, right: textLeftPadding,),
                              width: width * 0.85,
                              child: Text(Strings.currentLocation,
                                  style: orTextStyle,
                                  overflow: TextOverflow.ellipsis, // default is .clip
                                  maxLines: 2),
                            ),
                          ],
                        ),
                      )
                      ),),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    left:leftPadding, top:topSpace),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // padding: EdgeInsets.only(left: titleLeftPadding),
                      child: Text(
                        Strings.recentSearches,
                        style: summaryTextStyle,
                      ),
                    ),
                    Container(
                      child: DividerLine(),
                    ),
                    Container(
                        margin: EdgeInsets.only(top:topSpace),
                        child: recentSearchList.length == 0
                            ? Container()
                            : Container(
                                alignment: Alignment.topLeft,
                                child: ListView.builder(
                                    reverse: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: recentSearchList.length,
                                    itemBuilder: (context, index) {
                                      return RecentList(
                                          index, recentSearchList[index]);
                                    }))),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left:leftPadding),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // padding: EdgeInsets.only(left: titleLeftPadding),
                      child: Text(
                        Strings.recentViewed,
                        style: summaryTextStyle,
                      ),
                    ),
                    Container(
                      child: DividerLine(),
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(0.0, topSpace, 0.0, 0.0),
                        child: recentViewedList.length == 0
                            ? Container()
                            : Container(
                                alignment: Alignment.topLeft,
                                child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    reverse: true,
                                    itemCount: recentViewedList.length,
                                    itemBuilder: (context, index) {
                                      return RecentList(
                                          index,
                                          recentViewedList[index]);
                                    }))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget destinationWidget(leftPadding, boxWidth, boxHeight, topSpace) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: GestureDetector(
              child:Icon(Icons.close,
                size : iconSize,
                color: Uicolors.textFieldIcon,),
              onTap: (){
                Navigator.pop(context);
              }
          ),
        ),
        Container(
            alignment: Alignment.centerRight,
            height: boxHeight,
            width: width*0.84,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(fieldBorderRadius),
                ),
                border: border,
                color: Uicolors.searchBackColor),
            child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
              Positioned(
                  left: leftPadding,
                  child: Container(
                    child: Image.asset(
                      "assets/images/search.png",
                      width: iconSize,
                      height: iconSize,
                      color: Uicolors.textFieldIcon,
                    ),
                  )),
              Container(
                // width: boxWidth,
                alignment: Alignment.center,
                 child: destinationTextField(leftPadding + (AppUtility().isTablet(context) ? 60 : 38)),
                // child: DestinationList(
                //     isClearDestination,
                //     leftPadding + (AppUtility().isTablet(context) ? 60 : 38),
                //     boxHeight,
                //     destinationValue: (value, nodeCode, destination) async {
                //       print("destinationvalue");
                //
                //   if (nodeCode != "null" && nodeCode != "") {
                //     hotelNodeCode = nodeCode.toString();
                //   }
                //   destination.nodeCode = nodeCode;
                //   addRecentSearch(destination);
                // }, typeAheadController: typeAheadController),
              ),
              if(typeAheadController.text!="")
              Positioned(
                  right: 0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: IconButton(
                        icon:Icon(Icons.close,
                          size : backIconSize,
                          color: Colors.white,),
                        onPressed: (){
                          setState(() {
                            isClearDestination = true;
                            typeAheadController.text = "";
                          });
                        }
                    ),
                  )),
            ])),
      ],
    );
  }
  destinationTextField(double leftPadding){
    return TypeAheadFormField(
      noItemsFoundBuilder: (context)=> ListTile(title: Text(Strings.noOption,
        textAlign: TextAlign.center,style: placeHolderStyle,)),
      textFieldConfiguration: TextFieldConfiguration(
        // autofocus: true,
          controller: this.typeAheadController,
          style: textFieldStyle,
          onChanged: (content) {
            setState(() {
            });
            destinationList.forEach((e) {
              if(!e.label!.contains(typeAheadController.text)){
                // print("content" + e.label.toString());
                // GlobalState.destinationValue = "";
                //    widget.destinationValue.call("","",Destinations$Query$Options$Destinations());
              }
            });
          },
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: Strings.whereDoYouString,
            contentPadding: EdgeInsets.fromLTRB(leftPadding, 0, leftPadding, 0),
            hintStyle: placeHolderStyle,
          )),
      itemBuilder:
          (context, Destinations$Query$Options$Destinations? itemData) {
        return
          Container(
            width: 500,
            child: ListTile(
              title: Text(
                itemData!.label ?? "No Options",
                style: textFieldStyle,
              ),
            ),
          );
      },
      onSuggestionSelected: (Destinations$Query$Options$Destinations items) {
        this.typeAheadController.text = items.label!;
        setState(() {
          isClearDestination = false;
        });
        if (items.nodeCode != "null" && items.nodeCode != "") {
              hotelNodeCode = items.nodeCode.toString();
            }
            //destination.nodeCode = items.nodeCode;
            addRecentSearch(items);

      //  widget.destinationValue.call(items.value.toString(),items.nodeCode.toString(),items);
      },
      suggestionsCallback: (pattern) {
        List<Destinations$Query$Options$Destinations> a = [];
        if (pattern.length > 0) {
          return destinationList
              .where((element) =>
              element.label!.toLowerCase().contains(pattern.toLowerCase()))
              .toList();
        } else {
          return a;
        }
      },
      transitionBuilder: (context, suggestionsBox, animationController) =>
      suggestionsBox,

    );
  }
  addRecentSearch(Destinations$Query$Options$Destinations destination) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    for (int i = 0; i <= recentSearchList.length - 1; i++) {
      if (recentSearchList[i].value == destination.value) {
        recentSearchList.removeAt(i);
      }
    }
    recentSearchList.add(destination);
    if(recentSearchList.length>5){
      recentSearchList.removeAt(0);
    }
    List<String> recentSearchEncoded = recentSearchList
        .map((recentSearch) => jsonEncode(recentSearch))
        .toList();
    sharedPreferences.setStringList(
        'recentSearches', recentSearchEncoded);
    widget.destinationValue.call(destination,"");
    Navigator.pop(context);
  }

  Widget RecentList(int index, var item) {
    return Container(
      margin: EdgeInsets.only(bottom: topSpace),
      child: GestureDetector(
        onTap: () {
          print("onclick");
          addRecentSearch(item);
        },
        child: Row(
          children: [
            Container(
              child: Icon(Icons.access_time,
                  size: backIconSize, color: Uicolors.buttonbg),
            ),
            Container(
              padding: EdgeInsets.only(
                  left: textLeftPadding, right: textLeftPadding),
              width: width * 0.9,
              child: Text(item.label.toString(),
                  style: orTextStyle,
                  overflow: TextOverflow.ellipsis, // default is .clip
                  maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget DividerLine() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Divider(
        height: 0.1,
        color: Uicolors.bottomTextColor,
      ),
    );
  }
}

