import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/models/roomdetailmodel.dart';
import 'package:jaz_app/models/roommodel.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:toast/toast.dart';
import 'package:jaz_app/utils/FontSize.dart' as fontSize;

class ConfirmSearch extends StatefulWidget {
  final Function(List<Room>) roomCallBack;
  final List<Room> confirmedRoomList;
  ConfirmSearch(this.confirmedRoomList, {required this.roomCallBack});
  _ConfirmSearchPage createState() => _ConfirmSearchPage();
}

List<int> ageList = new List<int>.generate(11, (i) => i + 1);

String _rmOneFirstChild = '<2 years';

class _ConfirmSearchPage extends State<ConfirmSearch> {
  int roomChild = 1;
  int adults = 1, adultsTwo = 1, adultsThree = 1;
  int roomOneChild = 0, roomTwoChild = 0, roomThreeChild = 0;
  String roomOneTitle = "1 adults",
      roomTwoTitle = "1 adults",
      roomThreeTitle = "1 adults";
  bool roomOneSelect = true, roomTwoSelect = false, roomThreeSelect = false;
  bool roomOneAduSelect = true,
      roomTwoAduSelect = false,
      roomThreeAduSelect = false;

  List<TravellerFilterInput> _savedRoomRefType = [];
  List<TravellersRoomInput> _saveRoomRef = [];
  int referenceId = 1;
  List<Room> roomList = [];
  late Function hp;

  void initState() {
    super.initState();
    roomList = widget.confirmedRoomList.map((e) => Room(roomNumber:e.roomNumber,adultList:List.from(e.adultList),childList:List.from(e.childList),roomDetail:e.roomDetail)).toList();
    roomChild = roomList.length;
  }

  @override
  Widget build(BuildContext context) {
    hp = Screen(MediaQuery.of(context).size,MediaQuery.of(context).orientation).hp;

    //_saveRoomDatas.add(RoomModelClass(age: 25,refId: referenceId));

    final fullWidth = MediaQuery.of(context).size.width;
    final rowWidth = fullWidth * 0.92; //90%
    final containerWidth = rowWidth / 3;
    final double height = MediaQuery.of(context).size.height * 0.065;

    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var buttonHeight =
        overAllHeight *  0.055;
    var fieldCornerRadius = fieldBorderRadius;
    var adultTopPadding = overAllHeight * 0.02;
    var adultBottomPadding = overAllHeight * 0.01;
    var boxLeftPadding = overAllWidth * 0.035;
    final boxWidth = fullWidth * 0.92; //90%
    double addMinusBoxWidth = AppUtility().isTablet(context) ? 140.0 : 120.0;

    return Scaffold(
        backgroundColor: Uicolors.backgroundColor,
        appBar: AppBar(
          toolbarHeight: AppUtility().isTablet(context)
              ? 80
              : AppBar().preferredSize.height,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Container(
            //alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 0, top: 0),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Uicolors.buttonbg,
                      size: backIconSize,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 0),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(Strings.backtosearch, style: backStyle),
                  ),
                ),
              ],
            ),
          ),

          /*Image.asset("assets/images/Back.png",
            width: 50,)*/
        ),
        body: SingleChildScrollView(
          // children: <Widget>[
          //First thing in the stack is the background
          //For the backgroud i create a column
          child: Column(
            children: <Widget>[
              Container(
                //  alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: boxLeftPadding,
                      right: boxLeftPadding,
                      top: 15,
                      bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      roomChild = 1;
                                      for (int i = 0;
                                          i <= roomList.length;
                                          i++) {
                                        if (roomList.length != 1) {
                                          roomList.removeAt(1);
                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                    color: roomList.isNotEmpty &&
                                            roomList.length == 1
                                        ? Uicolors.buttonbg
                                        : Colors.grey[100],
                                    width: containerWidth,
                                    alignment: Alignment.center,
                                    height: buttonHeight,
                                    child: Text(
                                      Strings.room1,
                                      style: TextStyle(
                                        color: roomChild == 1
                                            ? Colors.white
                                            : Colors.black,
                                        fontFamily: 'Popins-bold',
                                        fontSize: hp(fontSize.FontSize.size16),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      roomChild = 2;
                                      if (roomList.length == 1) {
                                        roomList.add(Room(
                                            childList: [],
                                            roomNumber: 2,
                                            adultList: [25],roomDetail: HashMap()));
                                      }
                                      if (roomList.length == 3) {
                                        roomList.removeAt(2);
                                      }
                                    });
                                  },
                                  child: Container(
                                    color: roomList.isNotEmpty &&
                                            roomList.length == 2
                                        ? Uicolors.buttonbg
                                        : Colors.grey[100],
                                    width: containerWidth,
                                    alignment: Alignment.center,
                                    height: buttonHeight,
                                    child: Text(
                                      Strings.room2,
                                      style: TextStyle(
                                        color: roomChild == 2
                                            ? Colors.white
                                            : Colors.black,
                                        fontFamily: 'Popins-bold',
                                        fontSize: hp(fontSize.FontSize.size16),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      roomChild = 3;

                                      if (roomList.length == 1) {
                                        roomList.add(Room(
                                            childList: [],
                                            roomNumber: 2,
                                            adultList: [25],roomDetail: HashMap()));
                                      }
                                      if (roomList.length == 2 &&
                                          roomList.length <= 2) {
                                        roomList.add(Room(
                                            childList: [],
                                            roomNumber: 3,
                                            adultList: [25],roomDetail: HashMap()));
                                      }
                                    });
                                  },
                                  child: Container(
                                    color: roomList.isNotEmpty &&
                                            roomList.length == 3
                                        ? Uicolors.buttonbg
                                        : Colors.grey[100],
                                    width: containerWidth,
                                    alignment: Alignment.center,
                                    height: buttonHeight,
                                    child: Text(
                                      Strings.room3,
                                      style: TextStyle(
                                        color: roomChild == 3
                                            ? Colors.white
                                            : Colors.black,
                                        fontFamily: 'Popins-bold',
                                        fontSize: hp(fontSize.FontSize.size16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  child: (roomChild == 1 && roomChild != 2 && roomChild != 3) ?
                  DecoratedBox(
                    decoration: BoxDecoration(
                      // borderRadius:
                      //     BorderRadius.circular(containerBorderRadius),
                        boxShadow: boxShadow,
                        color: Colors.white),
                    child: Container(
                      width: boxWidth,
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: boxLeftPadding, right: boxLeftPadding),
                          child: Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(
                                    top: adultTopPadding,
                                    bottom: adultBottomPadding),
                                child: new Text(
                                  roomList.isNotEmpty
                                      ? (roomList[0]
                                      .adultList
                                      .length
                                      .toString() +
                                      " Adults - " +
                                      roomList[0]
                                          .childList
                                          .length
                                          .toString() +
                                      " Children")
                                      : "1 Adults - 0 Children",
                                  style: numAdultStyle,
                                ),
                              ),
                              Container(
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 0.5,
                                  )),
                              Container(
                                padding: EdgeInsets.only(
                                    right:
                                    MediaQuery.of(context).size.width *
                                        0.01,
                                    left:
                                    MediaQuery.of(context).size.width *
                                        0.01,
                                    top: 15),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.only(
                                              right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.01),
                                          child: new Text(
                                            Strings.adults,
                                            style: adultStyle,
                                          ),
                                        ),
                                        Container(
                                          //alignment: Alignment.centerLeft,
                                          child: new Text(
                                            Strings.perroom,
                                            style: perRoomStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: addMinusBoxWidth, //120,
                                      height: buttonHeight,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.02),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              fieldBorderRadius),
                                          color: Uicolors.dropdowng),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            width: addMinusBoxWidth/3.8,
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                                child: Image.asset(
                                                  "assets/images/minus.png",
                                                ),
                                                onTap: () {
                                                  roomoneAdultMinus();
                                                }),
                                          ),
                                          Container(
                                            width: addMinusBoxWidth/3.8,
                                            alignment: Alignment.center,
                                            child: new Text(
                                              roomList.isNotEmpty
                                                  ? roomList[0]
                                                  .adultList
                                                  .length
                                                  .toString()
                                                  : "0",
                                              style: adultLengthStyle,
                                            ),
                                          ),
                                          Container(
                                            width: addMinusBoxWidth/3.8,
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                                child: Image.asset(
                                                  "assets/images/plus.png",
                                                ),
                                                onTap: () {
                                                  roomoneAdultAdd();
                                                }),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    right:
                                    MediaQuery.of(context).size.width *
                                        0.01,
                                    left:
                                    MediaQuery.of(context).size.width *
                                        0.01,
                                    top: 8),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.topLeft,
                                          padding: EdgeInsets.only(
                                              right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.020),
                                          child: new Text(
                                            Strings.child,
                                            style: adultStyle,
                                          ),
                                        ),
                                        Container(
                                          // alignment: Alignment.centerLeft,
                                          child: new Text(
                                            Strings.perroom,
                                            style: perRoomStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: addMinusBoxWidth, //120,
                                      height: buttonHeight,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.02),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              fieldCornerRadius),
                                          color: Uicolors.dropdowng),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            width: addMinusBoxWidth/3.8,
                                            child: GestureDetector(
                                                child: Image.asset(
                                                  "assets/images/minus.png",
                                                ),
                                                onTap: () {
                                                  roomOneChildRemove();
                                                }),
                                          ),
                                          Container(
                                            width: addMinusBoxWidth/3.8,
                                            alignment: Alignment.center,
                                            child: new Text(
                                              roomList.isNotEmpty
                                                  ? roomList[0]
                                                  .childList
                                                  .length
                                                  .toString()
                                                  : "0",
                                              style: adultLengthStyle,
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            width: addMinusBoxWidth/3.8,
                                            child: GestureDetector(
                                                child: Image.asset(
                                                  "assets/images/plus.png",
                                                ),
                                                onTap: () {
                                                  roomOneChildAdd();
                                                }),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 0.5,
                                  )),
                              Container(
                                width: MediaQuery.of(context).size.width *
                                    0.92,
                                height: roomList.isNotEmpty
                                    ? (roomList[0].childList.length *
                                    (AppUtility().isTablet(context)
                                        ? 120
                                        : 80)) //70
                                    : 40,
                                padding: EdgeInsets.only(
                                  bottom:
                                  MediaQuery.of(context).size.height *
                                      0.025,
                                ),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: roomList.isNotEmpty
                                        ? roomList[0].childList.length
                                        : 0,
                                    itemBuilder: (context, index) =>
                                        _roomOneListView(context, index)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ) :
                  (roomChild == 2 && roomChild != 1 && roomChild != 3) ?
                  DecoratedBox(
                    decoration: BoxDecoration(
                      // borderRadius:
                      //     BorderRadius.circular(containerBorderRadius),
                        boxShadow: boxShadow,
                        color: Colors.white),
                    child: Container(
                      alignment: Alignment.center,
                      width: boxWidth,
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: boxLeftPadding, right: boxLeftPadding),
                          child: Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(
                                    top: adultTopPadding,
                                    bottom: adultBottomPadding),
                                child: new Text(
                                  roomList.isNotEmpty
                                      ? (roomList[1]
                                      .adultList
                                      .length
                                      .toString() +
                                      " Adults - " +
                                      roomList[1]
                                          .childList
                                          .length
                                          .toString() +
                                      " Children")
                                      : "1 Adults - 0 Children",
                                  style: numAdultStyle,
                                ),
                              ),
                              Container(
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 0.5,
                                  )),
                              Container(
                                padding: EdgeInsets.only(
                                    right:
                                    MediaQuery.of(context).size.width *
                                        0.01,
                                    left:
                                    MediaQuery.of(context).size.width *
                                        0.01,
                                    top: 15),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.only(
                                              right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.01),
                                          child: new Text(
                                            Strings.adults,
                                            style: adultStyle,
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: new Text(
                                            Strings.perroom,
                                            style: perRoomStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: addMinusBoxWidth, //120,
                                      height: buttonHeight,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.02),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              fieldCornerRadius),
                                          color: Uicolors.dropdowng),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            width: addMinusBoxWidth/3.8,
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                                child: Image.asset(
                                                  "assets/images/minus.png",
                                                ),
                                                onTap: () {
                                                  roomTwoAdultMinus();
                                                }),
                                          ),
                                          Container(
                                            width: addMinusBoxWidth/3.8,
                                            alignment: Alignment.center,
                                            child: new Text(
                                              roomList.isNotEmpty
                                                  ? roomList[1]
                                                  .adultList
                                                  .length
                                                  .toString()
                                                  : "0",
                                              style: adultLengthStyle,
                                            ),
                                          ),
                                          Container(
                                            width: addMinusBoxWidth/3.8,
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                                child: Image.asset(
                                                  "assets/images/plus.png",
                                                ),
                                                onTap: () {
                                                  roomTwoAdultPlus();
                                                }),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    right:
                                    MediaQuery.of(context).size.width *
                                        0.01,
                                    left:
                                    MediaQuery.of(context).size.width *
                                        0.01,
                                    top: 8),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.topLeft,
                                          padding: EdgeInsets.only(
                                              right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.020),
                                          child: new Text(
                                            Strings.child,
                                            style: adultStyle,
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: new Text(
                                            Strings.perroom,
                                            style: perRoomStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: addMinusBoxWidth, //120,
                                      height: buttonHeight,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.02),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              fieldCornerRadius),
                                          color: Uicolors.dropdowng),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            width: addMinusBoxWidth/3.8,
                                            child: GestureDetector(
                                                child: Image.asset(
                                                  "assets/images/minus.png",
                                                ),
                                                onTap: () {
                                                  roomTwoChildMinus();
                                                }),
                                          ),
                                          Container(
                                            width: addMinusBoxWidth/3.8,
                                            alignment: Alignment.center,
                                            child: new Text(
                                              roomList.isNotEmpty
                                                  ? roomList[1]
                                                  .childList
                                                  .length
                                                  .toString()
                                                  : "0",
                                              style: adultLengthStyle,
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            width: addMinusBoxWidth/3.8,
                                            child: GestureDetector(
                                                child: Image.asset(
                                                  "assets/images/plus.png",
                                                ),
                                                onTap: () {
                                                  roomTwoChildPlus();
                                                }),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 0.5,
                                  )),
                              Container(
                                width: MediaQuery.of(context).size.width *
                                    0.92,
                                height: roomList.isNotEmpty
                                    ? (roomList[1].childList.length *
                                    (AppUtility().isTablet(context)
                                        ? 120
                                        : 80)) //70
                                    : 40,
                                padding: EdgeInsets.only(
                                    bottom:
                                    MediaQuery.of(context).size.height *
                                        0.025),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: roomList.isNotEmpty
                                        ? roomList[1].childList.length
                                        : 0,
                                    itemBuilder: (context, index) =>
                                        _roomTwoListView(context, index)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ) :
                  (roomChild == 3 && roomChild != 2 && roomChild != 1) ?
                  DecoratedBox(
                    decoration: BoxDecoration(
                      // borderRadius:
                      //     BorderRadius.circular(containerBorderRadius),
                        boxShadow: boxShadow,
                        color: Colors.white),
                    child: Container(
                      width: boxWidth,
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: boxLeftPadding, right: boxLeftPadding),
                          child: Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(
                                    top: adultTopPadding,
                                    bottom: adultBottomPadding),
                                child: new Text(
                                  roomList.isNotEmpty
                                      ? (roomList[2]
                                      .adultList
                                      .length
                                      .toString() +
                                      " Adults - " +
                                      roomList[2]
                                          .childList
                                          .length
                                          .toString() +
                                      " Children")
                                      : "1 Adults - 0 Children",
                                  style: numAdultStyle,
                                ),
                              ),
                              Container(
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 0.5,
                                  )),
                              Container(
                                padding: EdgeInsets.only(
                                    right:
                                    MediaQuery.of(context).size.width *
                                        0.01,
                                    left:
                                    MediaQuery.of(context).size.width *
                                        0.01,
                                    top: 15),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.only(
                                              right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.01),
                                          child: new Text(
                                            Strings.adults,
                                            style: adultStyle,
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: new Text(
                                            Strings.perroom,
                                            style: perRoomStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: addMinusBoxWidth, //120,
                                      height: buttonHeight,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.02),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              fieldCornerRadius),
                                          color: Uicolors.dropdowng),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            width: addMinusBoxWidth/3.8,
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                                child: Image.asset(
                                                  "assets/images/minus.png",
                                                ),
                                                onTap: () {
                                                  roomThreeAdultMinus();
                                                }),
                                          ),
                                          Container(
                                            width: addMinusBoxWidth/3.8,
                                            alignment: Alignment.center,
                                            child: new Text(
                                              roomList.isNotEmpty
                                                  ? roomList[2]
                                                  .adultList
                                                  .length
                                                  .toString()
                                                  : "0",
                                              style: adultLengthStyle,
                                            ),
                                          ),
                                          Container(
                                            width: addMinusBoxWidth/3.8,
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                                child: Image.asset(
                                                  "assets/images/plus.png",
                                                ),
                                                onTap: () {
                                                  roomThreeAdultPlus();
                                                }),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    right:
                                    MediaQuery.of(context).size.width *
                                        0.01,
                                    left:
                                    MediaQuery.of(context).size.width *
                                        0.01,
                                    top: 8),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.topLeft,
                                          padding: EdgeInsets.only(
                                              right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.020),
                                          child: new Text(
                                            Strings.child,
                                            style: adultStyle,
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: new Text(
                                            Strings.perroom,
                                            style: perRoomStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: addMinusBoxWidth, //120,
                                      height: buttonHeight,
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.02),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              fieldCornerRadius),
                                          color: Uicolors.dropdowng),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            width: addMinusBoxWidth/3.8,
                                            child: GestureDetector(
                                                child: Image.asset(
                                                  "assets/images/minus.png",
                                                ),
                                                onTap: () {
                                                  roomThreeChildMinus();
                                                }),
                                          ),
                                          Container(
                                            width: addMinusBoxWidth/3.8,
                                            alignment: Alignment.center,
                                            child: new Text(
                                              roomList.isNotEmpty
                                                  ? roomList[2]
                                                  .childList
                                                  .length
                                                  .toString()
                                                  : "0",
                                              style: adultLengthStyle,
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            width: addMinusBoxWidth/3.8,
                                            child: GestureDetector(
                                                child: Image.asset(
                                                  "assets/images/plus.png",
                                                ),
                                                onTap: () {
                                                  roomThreeChildPlus();
                                                }),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 0.5,
                                  )),
                              Container(
                                width: MediaQuery.of(context).size.width *
                                    0.92,
                                height: roomList.isNotEmpty
                                    ? (roomList[2].childList.length *
                                    (AppUtility().isTablet(context)
                                        ? 120
                                        : 80)) //70
                                    : 40,
                                padding: EdgeInsets.only(
                                    bottom:
                                    MediaQuery.of(context).size.height *
                                        0.025),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: roomList.isNotEmpty
                                        ? roomList[2].childList.length
                                        : 0,
                                    itemBuilder: (context, index) =>
                                        _roomThreeListView(context, index)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ) : Container(),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    bottom: MediaQuery.of(context).size.height * 0.05),
                child: FlatButton(
                  color: Uicolors.buttonbg,
                  minWidth: MediaQuery.of(context).size.width * 0.8,
                  height: buttonHeight,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(buttonHeight / 2),
                  ),
                  child: Text(
                    Strings.confirmcaps,
                    style: confirmButtonStyle,
                  ),
                  onPressed: () {
                    widget.roomCallBack.call(roomList);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ));
  }

  _roomOneListView(BuildContext context, int index) {
    var overallHeight = MediaQuery.of(context).size.height;
    var buttonHeight =
        overallHeight * (AppUtility().isTablet(context) ? 0.075 : 0.05);
    var fieldCornerRadius = fieldBorderRadius;
    double addMinusBoxWidth = AppUtility().isTablet(context) ? 180.0 : 120.0;

    return Container(
      margin: EdgeInsets.only(
          right: MediaQuery.of(context).size.width * 0.01, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.005,
                  //  right: MediaQuery.of(context).size.height * 0.050,
                  // left: MediaQuery.of(context).size.width * 0.0042,
                ),
                child: new Text(
                  Strings.room1,
                  style: roomStyle,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                padding: EdgeInsets.only(
                    //left: MediaQuery.of(context).size.width * 0.01,
                    top: MediaQuery.of(context).size.height * 0.001),
                child: new Text(
                  'Child age ' + (index + 1).toString(),
                  style: childrenStyle,
                ),
              ),
            ],
          ),
          Container(
            height: buttonHeight,
            width: addMinusBoxWidth, //120,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.035,
                right: MediaQuery.of(context).size.width * 0.015),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(fieldCornerRadius)),
                color: Uicolors.dropdowng),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                //     value: index == 0 ? _rmOneFirstChild : index == 1 ? _rmOneSecChild : index == 2 ? _rmOneThirdChild : _rmOneFourthChild,
                value: roomList[0].childList[index],
                isExpanded: true,
                itemHeight:
                    (AppUtility().isTablet(context) ? 85.0 : 50), //50.0,
                items: ageList.map((int value) {
                  return DropdownMenuItem<String>(
                    value: value.toString(),
                    child: Text(
                      (value.toString() == "1")
                          ? _rmOneFirstChild
                          : value.toString() + " years",
                      style: (AppUtility().isTablet(context)
                          ? creditCardTextStyle
                          : dropDownStyle), //dropDownStyle,
                    ),
                  );
                }).toList(),
                hint: Text(
                  "1 year",
                  style: hintStyle,
                ),
                onChanged: (String? value) {
                  setState(() {
                    roomList[0].childList[index] = value!;
                  });
                },
                style: dropTextStyle,
                icon: Container(
                    padding: EdgeInsets.only(right: 10),
                    child: Image.asset(
                      "assets/images/down-arrow.png",
                      height: backIconSize,
                      width: backIconSize,
                      color: Uicolors.buttonbg,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _roomTwoListView(BuildContext context, int index) {
    var overallHeight = MediaQuery.of(context).size.height;
    var buttonHeight =
        overallHeight * (AppUtility().isTablet(context) ? 0.075 : 0.05);
    var fieldCornerRadius = fieldBorderRadius;
    double addMinusBoxWidth = AppUtility().isTablet(context) ? 180.0 : 120.0;

    return Container(
      margin: EdgeInsets.only(
          right: MediaQuery.of(context).size.width * 0.01, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.005,
                  //  right: MediaQuery.of(context).size.height * 0.050,
                  // left: MediaQuery.of(context).size.width * 0.0042,
                ),
                child: new Text(
                  Strings.room2,
                  style: roomStyle,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                padding: EdgeInsets.only(
                    //left: MediaQuery.of(context).size.width * 0.01,
                    top: MediaQuery.of(context).size.height * 0.001),
                child: new Text(
                  'Child age ' + (index + 1).toString(),
                  style: childrenStyle,
                ),
              ),
            ],
          ),
          Container(
            height: buttonHeight,
            width: addMinusBoxWidth, //120,
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.035,
                right: MediaQuery.of(context).size.width * 0.015),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(fieldCornerRadius)),
                color: Uicolors.dropdowng),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                //  value: index == 0 ? _rmTwoFirstChild : index == 1 ? _rmTwoSecChild : index == 2 ? _rmTwoThirdChild : _rmOneFourthChild,
                value: roomList[1].childList[index],
                isExpanded: true,
                itemHeight:
                    (AppUtility().isTablet(context) ? 85.0 : 50), //50.0,
                items: ageList.map((int value) {
                  return DropdownMenuItem<String>(
                    value: value.toString(),
                    child: Text(
                      (value.toString() == "1")
                          ? _rmOneFirstChild
                          : value.toString() + " years",
                      style: (AppUtility().isTablet(context)
                          ? creditCardTextStyle
                          : dropDownStyle), //dropDownStyle,
                    ),
                  );
                }).toList(),
                hint: Text(
                  "1 year",
                  style: hintStyle,
                ),
                onChanged: (String? value) {
                  int newindex = index + 1;
                  setState(() {
                    roomList[1].childList[index] = value!;
                  });
                },
                style: dropTextStyle,

                icon: Container(
                    padding: EdgeInsets.only(right: 10),
                    child: Image.asset(
                      "assets/images/down-arrow.png",
                      height: backIconSize,
                      width: backIconSize,
                      color: Uicolors.buttonbg,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _roomThreeListView(BuildContext context, int index) {
    var overallHeight = MediaQuery.of(context).size.height;
    var buttonHeight =
        overallHeight * (AppUtility().isTablet(context) ? 0.075 : 0.05);
    var fieldCornerRadius = fieldBorderRadius;
    double addMinusBoxWidth = AppUtility().isTablet(context) ? 180.0 : 120.0;

    return Container(
      margin: EdgeInsets.only(
        right: MediaQuery.of(context).size.width * 0.01,
        top: 10,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.005,
                  //  right: MediaQuery.of(context).size.height * 0.050,
                  // left: MediaQuery.of(context).size.width * 0.0042,
                ),
                child: new Text(
                  Strings.room3,
                  style: roomStyle,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                padding: EdgeInsets.only(
                    //left: MediaQuery.of(context).size.width * 0.01,
                    top: MediaQuery.of(context).size.height * 0.001),
                child: new Text(
                  'Child age ' + (index + 1).toString(),
                  style: childrenStyle,
                ),
              ),
            ],
          ),
          Container(
            height: buttonHeight,
            width: addMinusBoxWidth, //120,
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.035,
                right: MediaQuery.of(context).size.width * 0.015),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(fieldCornerRadius)),
                color: Uicolors.dropdowng),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                //    value: index == 0 ? _rmThreeFirstChild : index == 1 ? _rmThreeSecChild : index == 2 ? _rmThreeThirdChild : _rmThreeFourthChild,
                value: roomList[2].childList[index],
                isExpanded: true,
                itemHeight:
                    (AppUtility().isTablet(context) ? 85.0 : 50), //50.0,
                items: ageList.map((int value) {
                  return DropdownMenuItem<String>(
                    value: value.toString(),
                    child: Text(
                      (value.toString() == "1")
                          ? _rmOneFirstChild
                          : value.toString() + " years",
                      style: (AppUtility().isTablet(context)
                          ? creditCardTextStyle
                          : dropDownStyle), //dropDownStyle,
                    ),
                  );
                }).toList(),
                hint: Text(
                  "1 year",
                  style: hintStyle,
                ),
                onChanged: (String? value) {
                  int newindex = 1;
                  setState(() {
                    roomList[2].childList[index] = value!;
                  });
                },
                style: dropTextStyle,
                icon: Container(
                    padding: EdgeInsets.only(right: 10),
                    child: Image.asset(
                      "assets/images/down-arrow.png",
                      height: backIconSize,
                      width: backIconSize,
                      color: Uicolors.buttonbg,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  roomoneAdultMinus() {
    Room room1 = roomList[0];
    setState(() {
      if (room1.adultList.length > 1) {
        room1.adultList.removeLast();
        childValidation(room1.childList, room1.adultList);
      }
    });
  }

  roomoneAdultAdd() {
    Room room1 = roomList[0];
    setState(() {
      if (room1.adultList.length < 4) {
        room1.adultList.add(25);
        childValidation(room1.childList, room1.adultList);
      }
    });
  }

  roomOneChildAdd() {
    Room room1 = roomList[0];
    setState(() {
      if (room1.childList.length < 4) {
        room1.childList.add("1");
        childValidation(room1.childList, room1.adultList);
      }
    });
  }

  roomOneChildRemove() {
    Room room1 = roomList[0];
    setState(() {
      room1.childList.removeLast();
    });
  }

  roomTwoAdultMinus() {
    Room room2 = roomList[1];
    setState(() {
      if (room2.adultList.length > 1) {
        room2.adultList.removeLast();
        childValidation(room2.childList, room2.adultList);
      }
    });
  }

  roomTwoAdultPlus() {
    Room room2 = roomList[1];
    setState(() {
      if (room2.adultList.length < 4) {
        room2.adultList.add(25);
        childValidation(room2.childList, room2.adultList);
      }
    });
  }

  roomTwoChildMinus() {
    Room room2 = roomList[1];
    setState(() {
      room2.childList.removeLast();
    });
  }

  roomTwoChildPlus() {
    Room room2 = roomList[1];
    setState(() {
      if (room2.childList.length < 4) {
        room2.childList.add("1");
        childValidation(room2.childList, room2.adultList);
      }
    });
  }

  roomThreeAdultMinus() {
    Room room3 = roomList[2];
    setState(() {
      if (room3.adultList.length > 1) {
        room3.adultList.removeLast();
        childValidation(room3.childList, room3.adultList);
      }
    });
  }

  roomThreeAdultPlus() {
    Room room3 = roomList[2];
    setState(() {
      if (room3.adultList.length < 4) {
        room3.adultList.add(25);
        childValidation(room3.childList, room3.adultList);
      }
    });
  }

  roomThreeChildMinus() {
    Room room3 = roomList[2];
    setState(() {
      room3.childList.removeLast();
    });
  }

  roomThreeChildPlus() {
    Room room3 = roomList[2];
    setState(() {
      if (room3.childList.length < 4) {
        room3.childList.add("1");
        childValidation(room3.childList, room3.adultList);
      }
    });
  }

  childValidation(List childlist, List adultlist) {
    if (childlist.length > adultlist.length) {
      int agecount = 0;
      childlist.forEach((age) {
        if (int.parse(age) == 1) {
          ++agecount;
        }
      });
      if (agecount > adultlist.length) {
        if (ToastView() != null) {
          ToastView.dismiss();
          AppUtility().showToastView(Strings.roomErrorToast, context);

          // ToastView.createView(
          //     Strings.roomErrorToast,
          //     context,
          //     Toast.LENGTH_LONG,
          //     Toast.BOTTOM,
          //     Uicolors.buttonbg,
          //     Colors.white,
          //     1,
          //     null);
        }
      }
    }
  }
}
