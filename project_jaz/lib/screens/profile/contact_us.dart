import 'package:flutter/material.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  var contactInfoList;
  var linksList;
  var addressList;
  var overAllHeight;
  var overAllWidth;
  var menuButtonPadding;
  var titleLeftPadding;
  var titleTopPadding;
  var titleDescPadding;
  var contentTopPadding;
  var contentLeftPadding;
  var contectContentLeftPadding;
  var iconLeftPading;
  var administrativeContact;

  List titleContents = [];

  Widget build(BuildContext context) {
    overAllHeight = MediaQuery.of(context).size.height;
    overAllWidth = MediaQuery.of(context).size.width;
    menuButtonPadding = overAllWidth * 0.04;
    titleLeftPadding = overAllWidth * 0.035;
    titleTopPadding = overAllHeight * 0.015;
    titleDescPadding = overAllHeight * 0.007;

    contentTopPadding = overAllHeight * 0.04;
    contentLeftPadding = overAllWidth * 0.04;
    contectContentLeftPadding = overAllWidth * 0.025;
    iconLeftPading = overAllWidth * 0.005;
    //Second Container

    return Scaffold(
      backgroundColor: Uicolors.backgroundbg,
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
                      Navigator.of(context, rootNavigator: true).pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: iconLeftPading),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Uicolors.backText,
                        size: backIconSize,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 0, top: 0),
                      child: Text(Strings.back, style: backStyle),
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                    margin: EdgeInsets.only(
                      right: iconLeftPading,
                    ),
                    child: Text(
                      contactInfoList['title'] != null
                          ? contactInfoList['title']
                          : Strings.jazHotelGroup,
                      style: welcomJazStyle,
                    )),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left:titleLeftPadding,top:titleTopPadding ,
                  right:titleLeftPadding),
              child: Text(
                contactInfoList['title'] != null
                    ? contactInfoList['title']
                    : Strings.jazHotelGroup,
                style: loginAccountStyle,
              ),
            ),
            linksList != null && linksList.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: linksList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return linksList[index]["title"]
                                      .toString()
                                      .toLowerCase() ==
                                  Strings.add ||
                              linksList[index]["title"]
                                      .toString()
                                      .toLowerCase() ==
                                  Strings.email.toLowerCase()
                          ? Container(
                              width: overAllWidth,
                              margin: EdgeInsets.fromLTRB(titleLeftPadding,
                                  titleTopPadding, titleLeftPadding, 0),
                              padding: EdgeInsets.fromLTRB(
                                  contentLeftPadding,
                                  titleTopPadding,
                                  contentLeftPadding,
                                  titleTopPadding),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                // border: Border.all(color: Colors.white, width: 1),
                                borderRadius:
                                    BorderRadius.circular(fieldBorderRadius),
                                shape: BoxShape.rectangle,
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (linksList[index]["title"]
                                          .toString()
                                          .toLowerCase() ==
                                      Strings.email.toLowerCase()) {
                                    AppUtility().launchURL(
                                        "mailto:" + linksList[index]["label"]);
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      linksList[index]["label"] != null
                                          ? linksList[index]["label"]
                                          : "",
                                      style: descTextStyle,
                                    )
                                  ],
                                ),
                              ))
                          : Container();
                    },
                  )
                : Container(),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left:titleLeftPadding, top:titleTopPadding,
                  right:titleLeftPadding),
              child: Text(
                Strings.contactNumbers,
                style: contactUsTitles,
              ),
            ),
            linksList != null && linksList.isNotEmpty
                ? Container(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: linksList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return linksList[index]["title"]
                                        .toString()
                                        .toLowerCase() !=
                                    Strings.add &&
                                linksList[index]["title"]
                                        .toString()
                                        .toLowerCase() !=
                                    Strings.email.toLowerCase()
                            ? showContactNumberUi(index)
                            : Container();
                      },
                    ),
                    margin: EdgeInsets.all(overAllWidth * 0.04),
                    padding: EdgeInsets.all(overAllWidth * 0.004),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(fieldBorderRadius),
                      shape: BoxShape.rectangle,
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (GlobalState.contactUsLinks != null) {
      contactInfoList = GlobalState.contactUsLinks;
      print("contact info list ${contactInfoList.toString()}");
      setState(() {
        linksList = contactInfoList["links"];
      });
    }
  }

  showContactNumberUi(int index) {
    var assetPath;
    if (linksList[index]['type'].toString().toLowerCase() == Strings.phone) {
      assetPath = "assets/images/telephone-icon.png";
    } else {
      assetPath = "assets/images/whatsapp-icon.png";
    }

    return Container(
        child: InkWell(
            onTap: () {
              if (linksList[index]['title'].toString().toLowerCase() ==
                  Strings.phone) {
                AppUtility()
                    .launchURL("tel://" + linksList[index]['label'].toString());
              } else if (linksList[index]['title'].toString().toLowerCase() ==
                  Strings.wapp) {
                AppUtility().launchURL("whatsapp://send?phone=" +
                    linksList[index]['label'].toString());
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      assetPath,
                      width: backIconSize,
                      height: backIconSize,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                    ),
                    Expanded(
                        child: Text(
                      linksList[index]["label"] != null
                          ? linksList[index]["label"].replaceAll(" ", '')
                          : "",
                      style: descTextStyle,
                    ))
                  ],
                )
              ],
            )),
        width: overAllWidth,
        padding: EdgeInsets.fromLTRB(contentLeftPadding, titleTopPadding,
            contentLeftPadding, titleTopPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          // border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(fieldBorderRadius),
          shape: BoxShape.rectangle,
        ));
  }
}
