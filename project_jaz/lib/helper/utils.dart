import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:jaz_app/models/roommodel.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/colors.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/http_client.dart';
import 'package:jaz_app/utils/FontSize.dart' as fontSize;
import 'package:jaz_app/utils/colors.dart' as Uicolors;
//import 'package:toast/toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtility {
  // BuildContext? dialogContext;
  static DefaultCacheManager _instance = DefaultCacheManager();

  DefaultCacheManager getInstance(){
    return _instance;
  }

  showProgressDialog(BuildContext context,
      {required String? type, required Function(BuildContext) dismissDialog}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          //dialogContext = context;
          dismissDialog.call(context);
          return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Center(
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                          child: Column(
                        children: [
                          // CircularProgressIndicator(
                          //   backgroundColor: Colors.transparent,
                          //   valueColor: AlwaysStoppedAnimation(
                          //       Theme.of(context).primaryColor),
                          // ),
                          Image.asset(
                            "assets/images/hotal_circle_loader_icon.gif",
                            height: 100.0,
                            width: 100.0,
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: 300,
                            margin: EdgeInsets.only(top: type != null ? 10 : 0),
                            child: type != null
                                ? new Text(type,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline3!
                                        .merge(TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.0)))
                                : Container(),
                          )
                        ],
                      )),
                    ],
                  ),
                  height: 100.0, //80.0
                  width: 100.0,
                ),
              ));
        });
  }

  dismissDialog(BuildContext dialogContext) {
    Navigator.pop(dialogContext);
  }

  Future<bool> onWillPop(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit the App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () =>
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> onWillLoginPop(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              Strings.appName,
              style: expansionTitleStyle,
            ),
            //  content: Text('Do you want to Favorites & UnFavorites needs to login. Proceed to login?'),
            content: Text(
              'Please login to shortlist the hotel',
              style: overallRatingStyle,
            ),
            actions: <Widget>[
              // TextButton(
              //   onPressed: () => Navigator.of(context).pop(false),
              //   child: Text('No'),
              // ),
              TextButton(
                onPressed: () {
                  //SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: welcomJazStyle,
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  bool validateEmail(String value) {
    String pattern =
        r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$";
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  bool validatePassword(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }
  String getNumberOfNight(startDate,endDate){
    final DateFormat startFormatter = DateFormat('EEE dd MMM');
    final String startFormatted = startFormatter.format(startDate);
    final String endFormatted = startFormatter.format(endDate);
    final difference = endDate.difference(startDate).inDays;
    return difference.toString();
  }
  String getNumberOfPerson(List<Room> confirmedRoomList){
    int totalPerson =0;
    confirmedRoomList.forEach((element) {
      totalPerson += element.adultList.length + element.childList.length;
    });
    return totalPerson.toString();
  }

  String getDateDiff(startDate, endDate) {
    final DateFormat startFormatter = DateFormat('EEE dd MMM');
    // final DateFormat endFormatter = DateFormat('EEE dd');
    final String startFormatted = startFormatter.format(startDate);
    final String endFormatted = startFormatter.format(endDate);
    final difference = endDate.difference(startDate).inDays;
    var nights = "";
    if (difference > 1) {
      nights = Strings.nights;
    } else {
      nights = Strings.night;
    }
    var selectedDate = startFormatted +
        " - " +
        endFormatted +
        " ( " +
        difference.toString() +
        " " +
        nights +
        " )";

    return selectedDate;
  }

  String getNumberOfDays(startDate, endDate, personList) {
    final DateFormat startFormatter = DateFormat('EEE dd MMM');
    final difference = endDate.difference(startDate).inDays;
    var nightStr = "";
    var roomStr = "";
    var adultStr = "";
    var childrenStr = "";
    int roomCount = 0;
    int adultCount = 0;
    int childCount = 0;
    for (int i = 0; i < personList.length; i++) {
      roomCount += 1;
      personList[i].adultList.forEach((adult) {
        adultCount += 1;
      });
      personList[i].childList.forEach((child) {
        childCount += 1;
      });
    }
    if (difference > 1) {
      nightStr = Strings.nights.toLowerCase();
    } else {
      nightStr = Strings.night.toLowerCase();
    }
    if (roomCount > 1) {
      roomStr = Strings.roomsStr.toLowerCase();
    } else {
      roomStr = Strings.roomStr.toLowerCase();
    }
    if (adultCount > 1) {
      adultStr = Strings.adults.toLowerCase();
    } else {
      adultStr = Strings.adult.toLowerCase();
    }
    if (childCount > 1) {
      childrenStr = Strings.childrensStr.toLowerCase();
    } else {
      childrenStr = Strings.childrenStr.toLowerCase();
    }
    return difference.toString() +
        " " +
        nightStr +
        ", " +
        adultCount.toString() +
        " " +
        adultStr +
        ", " +
        childCount.toString() +
        " " +
        childrenStr +
        ", " +
        roomCount.toString() +
        " " +
        roomStr.toLowerCase();
  }

  String getNumberOfAdults(adultList) {
    int adultCount = 0;
    for (int i = 0; i < adultList.length; i++) {
      adultList[i].adultList.forEach((adult) {
        adultCount += 1;
      });
    }
    return adultCount.toString();
  }

  String getNumberOfChildren(childrenList) {
    int childCount = 0;
    for (int i = 0; i < childrenList.length; i++) {
      childrenList[i].childList.forEach((adult) {
        childCount += 1;
      });
    }
    return childCount.toString();
  }

  String getSingleRoomDetails(startDate, endDate, personList) {
    final DateFormat startFormatter = DateFormat('EEE dd MMM');
    final difference = endDate.difference(startDate).inDays;
    var nightStr = "";
    var roomStr = "";
    var adultStr = "";
    var childrenStr = "";
    int roomCount = 0;
    int adultCount = 0;
    int childCount = 0;
    personList.adultList.forEach((adult) {
      adultCount += 1;
    });
    personList.childList.forEach((child) {
      childCount += 1;
    });

    if (difference > 1) {
      nightStr = Strings.nights.toLowerCase();
    } else {
      nightStr = Strings.night.toLowerCase();
    }
    if (roomCount > 1) {
      roomStr = Strings.roomsStr.toLowerCase();
    } else {
      roomStr = Strings.roomStr.toLowerCase();
    }
    if (adultCount > 1) {
      adultStr = Strings.adults.toLowerCase();
    } else {
      adultStr = Strings.adult.toLowerCase();
    }
    if (childCount > 1) {
      childrenStr = Strings.childrensStr.toLowerCase();
    } else {
      childrenStr = Strings.childrenStr.toLowerCase();
    }
    return difference.toString() +
        " " +
        nightStr +
        ", " +
        adultCount.toString() +
        " " +
        adultStr +
        ", " +
        childCount.toString() +
        " " +
        childrenStr +
        ", ";
  }

  confirmPop(
      BuildContext context, String title, String content) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child:AlertDialog(
            title: Text(content),
            content: Text(title),
            actions: <Widget>[
              TextButton(
                onPressed: (){
                  if(Platform.isIOS){
                    AppUtility().launchURL("https://apps.apple.com/us/app/jaz-hotel-group/id1442801960");
                  }else{
                    AppUtility().launchURL("https://play.google.com/store/apps/details?id=com.travco.jaz");
                  }
                },
                child: Text('Update'),
              ),
            ],
          ),
        ));
  }

  String getSingleRoomAdults(adultList) {
    int adultCount = 0;
    adultList.adultList.forEach((adult) {
      adultCount += 1;
    });
    return adultCount.toString();
  }

  String getSingleRoomChildren(childrenList) {
    int childCount = 0;
    childrenList.childList.forEach((adult) {
      childCount += 1;
    });
    return childCount.toString();
  }

  Future<String> getHotelDescription(String hotelCrsCode) async {
    var response;
    var hotelDesc;
    HttpClient httpClient = HttpClient();
    HashMap<String, dynamic> params = HashMap();
    params.putIfAbsent("hotel_crs_code", () => hotelCrsCode);
    response = await httpClient.getData(params, "get_hotel_info", null);
    if (response.statusCode == 200 && json.decode(response.body) != null) {
      hotelDesc = (json
          .decode(response.body)['OTA_HotelDescriptiveInfoRS']
              ['HotelDescriptiveContents']['HotelDescriptiveContent']
              ['HotelInfo']['Descriptions']['Description']
              ["MultimediaDescriptions"]["MultimediaDescription"][0]
              ["TextItems"]["TextItem"]["Description"]["_text"]
          .toString());
      //   return (json.decode(response.body) as List).;
    } else {
      // If that call was not successful, throw an error.
      //   return [];
      hotelDesc = "";
    }
    return hotelDesc;
  }

  String getAmenities(String amenities) {
    var amenitiesImage = "";
    if ((amenities.toLowerCase().toString().contains("wifi"))) {
      amenitiesImage = "assets/images/wifi.png";
    } else if (amenities
        .toLowerCase()
        .toString()
        .contains("24-hour front desk")) {
      amenitiesImage = "assets/images/24hr-frontdesk.png";
    } else if (amenities.toLowerCase().toString().contains("view")) {
      amenitiesImage = "assets/images/view-layout-icon.png";
    } else if (amenities.toLowerCase().toString().contains("service")) {
      amenitiesImage = "assets/images/room-service.png";
    } else if (amenities.toLowerCase().toString().contains("phone") ||
        amenities.toLowerCase().toString().contains("mobile") ||
        amenities.toLowerCase().toString().contains("telephone")) {
      amenitiesImage = "assets/images/phone.png";
    } else if (amenities.toLowerCase().toString().contains("onsite laundry") ||
        amenities.toLowerCase().toString().contains("laundry")) {
      amenitiesImage = "assets/images/laundry-service.png";
    } else if (amenities
        .toLowerCase()
        .toString()
        .contains("24-hour security")) {
      amenitiesImage = "assets/images/24hrs-security.png";
    } else if (amenities.toLowerCase().toString().contains("breakfast") ||
        amenities.toLowerCase().toString().contains("complimentary")) {
      amenitiesImage = "assets/images/catering.png";
    } else if (amenities
        .toLowerCase()
        .toString()
        .contains("cable television")) {
      amenitiesImage = "assets/images/cable-tv.png";
    } else if (amenities.toLowerCase().toString().contains("outdoor pool")) {
      amenitiesImage = "assets/images/outdoor-pool.png";
    } else if (amenities.toLowerCase().toString().contains("local calls") ||
        amenities.toLowerCase().toString().contains("call")) {
      amenitiesImage = "assets/images/local-call.png";
    } else if (amenities
        .toLowerCase()
        .toString()
        .contains("air conditioning")) {
      amenitiesImage = "assets/images/air-conditioner.png";
    } else if (amenities.toLowerCase().toString().contains("fax")) {
      amenitiesImage = "assets/images/fax.png";
    } else if (amenities.toLowerCase().toString().contains("late checkout")) {
      amenitiesImage = "assets/images/late-checkout.png";
    } else if (amenities.toLowerCase().toString().contains("security") ||
        amenities.toLowerCase().toString().contains("cash")) {
      amenitiesImage = "assets/images/security.png";
    } else if (amenities.toLowerCase().toString().contains("Beverage") ||
        amenities.toLowerCase().toString().contains("cocktail")) {
      amenitiesImage = "assets/images/liquor.png";
    } else if (amenities.toLowerCase().toString().contains("tv") ||
        amenities.toLowerCase().toString().contains("television")) {
      amenitiesImage = "assets/images/television-screen.png";
    } else if (amenities.toLowerCase().toString().contains("alarm")) {
      amenitiesImage = "assets/images/alarm.png";
    } else if (amenities.toLowerCase().toString().contains("welfare")) {
      amenitiesImage = "assets/images/welfare.png";
    } else if (amenities.toLowerCase().toString().contains("facilities")) {
      amenitiesImage = "assets/images/accessible-facilites.png";
    } else if (amenities.toLowerCase().toString().contains("grill") ||
        amenities.toLowerCase().toString().contains("bpq")) {
      amenitiesImage = "assets/images/bbq-grills.png";
    } else if (amenities.toLowerCase().toString().contains("pool")) {
      amenitiesImage = "assets/images/pool.png";
    } else if (amenities.toLowerCase().toString().contains("golf")) {
      amenitiesImage = "assets/images/golf-icon.png";
    } else if (amenities.toLowerCase().toString().contains("restront")) {
      amenitiesImage = "assets/images/restront.png";
    } else if (amenities.toLowerCase().toString().contains("beach")) {
      amenitiesImage = "assets/images/resort-icon.png";
    } else if (amenities.toLowerCase().toString().contains("elevator")) {
      amenitiesImage = "assets/images/elevator.png";
    } else if (amenities.toLowerCase().toString().contains("half board") ||
        amenities.toLowerCase().toString().contains("american plan") ||
        amenities.toLowerCase().toString().contains("board")) {
      amenitiesImage = "assets/images/american-football.png";
    } else if (amenities.toLowerCase().toString().contains("iron")) {
      amenitiesImage = "assets/images/print.png";
    } else if (amenities.toLowerCase().toString().contains("airport shuttle")) {
      amenitiesImage = "assets/images/airport-shuttle.png";
    } else if (amenities.toLowerCase().toString().contains("children")) {
      amenitiesImage = "assets/images/rocking-horse.png";
    } else if (amenities.toLowerCase().toString().contains("bell staff") ||
        amenities.toLowerCase().toString().contains("porter")) {
      amenitiesImage = "assets/images/bell-boy.png";
    } else if (amenities.toLowerCase().toString().contains("check out")) {
      amenitiesImage = "assets/images/check-in.png";
    } else if (amenities.toLowerCase().toString().contains("balcony") ||
        amenities.toLowerCase().toString().contains("terrace") ||
        amenities.toLowerCase().toString().contains("lanai")) {
      amenitiesImage = "assets/images/antique-balcony.png";
    } else if (amenities.toLowerCase().toString().contains("shower")) {
      amenitiesImage = "assets/images/shower.png";
    } else if (amenities.toLowerCase().toString().contains("restaurant")) {
      amenitiesImage = "assets/images/restaurant.png";
    } else if (amenities.toLowerCase().toString().contains("coffee") ||
        amenities.toLowerCase().toString().contains("tea")) {
      amenitiesImage = "assets/images/coffee-machine.png";
    } else if (amenities.toLowerCase().toString().contains("housekeeping")) {
      amenitiesImage = "assets/images/cleaning-tools.png";
    } else if (amenities.toLowerCase().toString().contains("downtown")) {
      amenitiesImage = "assets/images/cityscape.png";
    } else if (amenities.toLowerCase().toString().contains("internet")) {
      amenitiesImage = "assets/images/internet-access.png";
    } else if (amenities.toLowerCase().toString().contains("airport")) {
      amenitiesImage = "assets/images/airport-green.png";
    } else if (amenities.toLowerCase().toString().contains("safe")) {
      amenitiesImage = "assets/images/hotel.png";
    } else if (amenities.toLowerCase().toString().contains("bar")) {
      amenitiesImage = "assets/images/bar.png";
    } else if (amenities.toLowerCase().toString().contains("24-hour")) {
      amenitiesImage = "assets/images/24-hour.png";
    } else if (amenities.toLowerCase().toString().contains("resort")) {
      amenitiesImage = "assets/images/resort-icon.png";
    } else if (amenities.toLowerCase().toString().contains("stream")) {
      amenitiesImage = "assets/images/stream-icon.png";
    } else if (amenities.toLowerCase().toString().contains("tennis")) {
      amenitiesImage = "assets/images/tennis-icon.png";
    } else if (amenities.toLowerCase().toString().contains("business")) {
      amenitiesImage = "assets/images/business-center-icon.png";
    } else if (amenities.toLowerCase().toString().contains("convention")) {
      amenitiesImage = "assets/images/convention-icon.png";
    } else if (amenities.toLowerCase().toString().contains("fitness")) {
      amenitiesImage = "assets/images/fitness-icon.png";
    } else if (amenities.toLowerCase().toString().contains("highchair")) {
      amenitiesImage = "assets/images/highchair-icon.png";
    } else if (amenities.toLowerCase().toString().contains("meeting room")) {
      amenitiesImage = "assets/images/meeting-room-icon.png";
    } else if (amenities.toLowerCase().toString().contains("jaccuzzi")) {
      amenitiesImage = "assets/images/jaccuzzi-icon.png";
    } else if (amenities.toLowerCase().toString().contains("message")) {
      amenitiesImage = "assets/images/message-icon.png";
    } else if (amenities.toLowerCase().toString().contains("nosmoking")) {
      amenitiesImage = "assets/images/nosomking-icon.png";
    } else if (amenities.toLowerCase().toString().contains("tennis")) {
      amenitiesImage = "assets/images/tennis-icon.png";
    } else if (amenities.toLowerCase().toString().contains("massage") ||
        amenities.toLowerCase().toString().contains("spa")) {
      amenitiesImage = "assets/images/massage-icon.png";
    } else {
      amenitiesImage = "assets/images/24-hour.png";
    }
    return amenitiesImage;
  }

  String getFilterAmenities(String str) {
    var amenitiesImage = "";
    amenitiesImage = "assets/images/samplesvg.svg";
    return amenitiesImage;
  }

  String parseHtmlString(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    htmlString = htmlString.replaceAll(exp, '');
    var unescape = new HtmlUnescape();
    var text = unescape.convert(htmlString);
    return text;
  }

  Widget loadGifLoader() {
    return Image.asset(
      "assets/images/hotal_circle_loader_icon.gif",
      height: 100.0,
      width: 100.0,
    );
  }

  bool isTablet1() {
    // The equivalent of the "smallestWidth" qualifier on Android.
    var shortestSide =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
    // Determine if we should use mobile layout or not, 600 here is
    // a common breakpoint for a typical 7-inch tablet.
    return shortestSide.size.shortestSide > 600;
  }

  bool isTablet(BuildContext context) {
    // The equivalent of the "smallestWidth" qualifier on Android.
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    // Determine if we should use mobile layout or not, 600 here is
    // a common breakpoint for a typical 7-inch tablet.
    return shortestSide > 600;
  }

  String getProxyImage(images) {
    String image = "";
    if (images != null &&
        images["image"] != null &&
        images["image"]["proxy_images"] != null) {
      images["image"]["proxy_images"].forEach((proxyimage) {
        // if (AppUtility().isTablet1() && proxyimage["device"] == "tablet") {
        //   image = proxyimage["normal"]["url"].toString();
        // } else if (!AppUtility().isTablet1() &&
        //     proxyimage["device"] == "phone") {
        //   image = proxyimage["normal"]["url"].toString();
        // }
        if(proxyimage["device"] == "tablet"){
          image = proxyimage["normal"]["url"].toString();
        }
      });
    }
    return image;
  }

  List<String> getImages(data) {
    List<String> backgroundImages = [];
    data["module"]["result"]["images"].forEach((images) {
      var proxyImage = getProxyImage(images);
      if (proxyImage != "") {
        backgroundImages.add(proxyImage);
      }
    });
    return backgroundImages;
  }
  List<String> getGalleyViewImages(data) {
    List<String> backgroundImages = [];
    data["module"]["result"]["images"].forEach((images) {
      var proxyImage = getGalleryViewImage(images);
      if (proxyImage != "") {
        backgroundImages.add(proxyImage);
      }
    });
    return backgroundImages;
  }

  String getGalleryViewImage(images) {
    String image = "";
    if (images != null &&
        images["image"] != null &&
        images["image"]["proxy_images"] != null) {
      images["image"]["proxy_images"].forEach((proxyimage) {
        if (proxyimage["device"] == "tablet") {
          image = proxyimage["normal"]["url"].toString();
        }
      });
    }
    return image;
    // String image = "";
    // if (images != null &&
    //     images["image"] != null ) {
    //   image = images["image"]["url"].toString();
    // }
    // return image;
  }
  Future cacheImage(BuildContext context,String url){
    return precacheImage( OptimizedCacheImageProvider(url,
        cacheManager: getInstance(), cacheKey: url), context);
  }

  loadImage(url) {
    return Image(
      image: OptimizedCacheImageProvider(url,
          cacheManager: _instance, cacheKey: url,
      ),
      fit: BoxFit.cover,
    );
  }
  loadNetworkImage(url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
    );
  }

  deleteCache(){
    _instance.emptyCache();
  }

  getGalleryImages() {}
  indicaorSize(BuildContext context) {
    return AppUtility().isTablet(context) ? 12.0 : 10.0;
  }

  currentIndicatorSize(BuildContext context) {
    return AppUtility().isTablet(context) ? 45.0 : 30.0;
  }

  // showToast(String msg){
  //   Fluttertoast.showToast(
  //       msg: msg,
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.CENTER,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Uicolors.buttonbg,
  //       textColor: Colors.white,
  //       fontSize: hp(fontSize.FontSize.size15)
  //   );
  // }
  showToastView(String message, BuildContext context) {
    //   ToastView.createView(
    //       message,
    //       context,
    //       Toast.LENGTH_LONG,
    //       Toast.BOTTOM,
    //       Uicolors.buttonbg,
    //       Colors.white,
    //       3,
    //       null);
    // }
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Uicolors.buttonbg,
        textColor: Colors.white,
        fontSize: hp(fontSize.FontSize.size15));
  }

  static void saveCurrencyCode(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Strings.currencyCode, code);
  }

  static Future<String?> getCurrencyCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString(Strings.currencyCode);
    return code;
  }

  String getCurrentCurrency() {
    if (GlobalState.selectedCurrency != null &&
        GlobalState.selectedCurrency != "") {
      return GlobalState.selectedCurrency == Strings.usd
          ? Strings.us$
          : GlobalState.selectedCurrency;
    } else {
      return Strings.us$;
    }
  }

  void launchURL(_url) async {
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
  }

  Future<bool> determinePosition() async {
    try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
      //   return Future.error('Location services are disabled.');
        return false;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied||permission == LocationPermission.deniedForever) {
        LocationPermission requestPermission = await Geolocator.requestPermission();
        if(requestPermission == LocationPermission.denied||permission == LocationPermission.deniedForever){
          Geolocator.openLocationSettings();
        }
        return false;
      } else {
        return true;
      }
    }catch(e){
      print("error$e");
      return false;
    }
  }
  Future getUserLocation() async {
    try {
      print("getCurrentPosition called");
      var currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      var _center = LatLng(currentLocation.latitude, currentLocation.longitude);
      print('center $_center');
      List<Placemark> placemarks =
      await placemarkFromCoordinates(
          currentLocation.latitude, currentLocation.longitude);
      Placemark place = placemarks[0];
      var current_location = '${place.locality}, ${place
          .administrativeArea}, ${place.country}';
      print(current_location);
    }catch(e){
      print("getUserLocation");
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }

}
