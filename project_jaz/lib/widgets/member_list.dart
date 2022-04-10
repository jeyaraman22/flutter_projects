import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jaz_app/helper/graphqlconnectivity/constants.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/strings.dart';

class MemberListScreen extends StatefulWidget {
  final Function(String) onBack;
  MemberListScreen({required this.onBack,required});

  @override
  _MemberListScreenState createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    var overallHeight = MediaQuery.of(context).size.height;
    var overallWidth = MediaQuery.of(context).size.width;
    var leftPadding = overallWidth*0.04;
    var topSpace = overallHeight *0.03;

    return Container(
      margin: EdgeInsets.only(left:leftPadding,right:leftPadding,bottom: topSpace,top: topSpace),
    //  width: overallWidth*0.8,
            color: Uicolors.sslEncriptionBgColor,
            child: Column(
         crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                  top: overallHeight * 0.03,left: overallWidth*0.04),
              child: Text("Membership Plan", style: alreadyMemberStyle),
            ),
            Container(
                margin: EdgeInsets.only(
                    bottom: 10,
                    left: overallWidth*0.04,
                    right: overallWidth*0.04,
                    top: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(color: Colors.white, width: 1),
                    //  borderRadius: BorderRadius.circular(20.0),
                    shape: BoxShape.rectangle,
                    boxShadow: boxShadow),
                child: Container(
                   // height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 0.9,
                    //  height: 400,

                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              height: AppUtility().isTablet(context)?overallHeight*0.55:overallHeight*0.42,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.transparent,
                              child:
                              AppUtility().loadImage(membershipImageUrl)
                          ),
                        ])))
          ],
        ));
  }
}
