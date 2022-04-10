import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/screens/onboarding/signin.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import '../homebottombar.dart';
import 'signup.dart';

class PrivacyPolicy extends StatefulWidget {
  final String redirectName;
  PrivacyPolicy(this.redirectName);
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {

    final double overAllWidth = MediaQuery.of(context).size.width;

    var privacyPolicyTopPadding = MediaQuery.of(context).size.height * 0.03;
    var privacyPolicyLeftpadding = MediaQuery.of(context).size.width * 0.05;
    var textLeftPadding = MediaQuery.of(context).size.width * 0.055;
    var textTopPadding =  MediaQuery.of(context).size.height * 0.015;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: AppUtility().isTablet(context)?80:AppBar().preferredSize.height,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
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
                      pushNewScreen(
                        context,
                        screen: HomeBottomBarScreen(3),
                        withNavBar: true, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.height * 0.005, 5, 0, 0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Uicolors.buttonbg,
                        size: backIconSize,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      pushNewScreen(
                        context,
                        screen: HomeBottomBarScreen(3),
                        withNavBar: true, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(Strings.backtosign,
                          style: backSigninGreenStyle),
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.height * 0.015),
                  child: Image.asset(
                    "assets/images/JHG_logo.png",
                    width: AppUtility().isTablet(context)?180:120,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.fromLTRB(
                        privacyPolicyLeftpadding,
                        privacyPolicyTopPadding,
                        privacyPolicyLeftpadding,
                        0),
                    child: Container(
                      alignment: Alignment.centerLeft,
                   //   height: MediaQuery.of(context).size.height * 0.05,
                      child: Text(
                        Strings.privacypolicy,
                        style: privacyTitleTextStyle,
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(
                        textLeftPadding,
                       textTopPadding,
                        textLeftPadding,
                        0),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Strings.privacypolicydes,
                        style: privacyTextStyle,
                      ),
                    )),

                // GestureDetector(
                //   child: Padding(
                //     padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height*0.03,MediaQuery.of(context).size.height*0.02,MediaQuery.of(context).size.height*0.04,0),
                //     child: Container(
                //       width: MediaQuery.of(context).size.width/1.1,
                //       height: MediaQuery.of(context).size.height*0.05,
                //       decoration: BoxDecoration(
                //         border: Border.all(
                //             color: Colors.grey, width: 2),
                //         borderRadius: BorderRadius.circular(10.0),
                //         shape: BoxShape.rectangle,
                //       ),
                //      child: Row(
                //        crossAxisAlignment: CrossAxisAlignment.start,
                //        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //        children: <Widget>[
                //         Align(
                //           alignment: Alignment.centerLeft,
                //           child: Container(
                //             padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.03,0,0,0),
                //             child: Text(
                //                 Strings.informationandcollections,
                //                 style: TextStyle(
                //                     color: Colors.black45,
                //                     fontSize: 14,fontFamily: 'Popins'
                //                 )
                //             ),
                //           ),
                //         ),
                //          Align(
                //            alignment: Alignment.centerRight,
                //            child: Container
                //              (
                //              padding: EdgeInsets.fromLTRB(0,0,MediaQuery.of(context).size.width*0.03,0),
                //              child: Icon(Icons.arrow_forward,color: Uicolors.buttonbg,),
                //            ),
                //            //
                //          ),
                //        ],
                //      ),
                //     ),
                //   ),
                // ),
                // GestureDetector(
                //   child: Padding(
                //     padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height*0.03,MediaQuery.of(context).size.height*0.02,MediaQuery.of(context).size.height*0.04,0),
                //     child: Container(
                //       width: MediaQuery.of(context).size.width/1.1,
                //       height: MediaQuery.of(context).size.height*0.05,
                //       decoration: BoxDecoration(
                //         border: Border.all(
                //             color: Colors.grey, width: 2),
                //         borderRadius: BorderRadius.circular(10.0),
                //         shape: BoxShape.rectangle,
                //       ),
                //       child: Row(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: <Widget>[
                //           Align(
                //             alignment: Alignment.centerLeft,
                //             child: Container(
                //               padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.03,0,0,0),
                //               child: Text(
                //                   Strings.logdata,
                //                   style: TextStyle(
                //                       color: Colors.black45,
                //                       fontSize: 14,fontFamily: 'Popins'
                //                   )
                //               ),
                //             ),
                //           ),
                //           Align(
                //             alignment: Alignment.centerRight,
                //             child: Container
                //               (
                //               padding: EdgeInsets.fromLTRB(0,0,MediaQuery.of(context).size.width*0.03,0),
                //               child: Icon(Icons.arrow_forward,color: Uicolors.buttonbg,),
                //             ),
                //             //
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // GestureDetector(
                //   child: Padding(
                //     padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height*0.03,MediaQuery.of(context).size.height*0.02,MediaQuery.of(context).size.height*0.04,0),
                //     child: Container(
                //       width: MediaQuery.of(context).size.width/1.1,
                //       height: MediaQuery.of(context).size.height*0.05,
                //       decoration: BoxDecoration(
                //         border: Border.all(
                //             color: Colors.grey, width: 2),
                //         borderRadius: BorderRadius.circular(10.0),
                //         shape: BoxShape.rectangle,
                //       ),
                //       child: Row(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: <Widget>[
                //           Align(
                //             alignment: Alignment.centerLeft,
                //             child: Container(
                //               padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.03,0,0,0),
                //               child: Text(
                //                   Strings.cookies,
                //                   style: TextStyle(
                //                       color: Colors.black45,
                //                       fontSize: 14,fontFamily: 'Popins'
                //                   )
                //               ),
                //             ),
                //           ),
                //           Align(
                //             alignment: Alignment.centerRight,
                //             child: Container
                //               (
                //               padding: EdgeInsets.fromLTRB(0,0,MediaQuery.of(context).size.width*0.03,0),
                //               child: Icon(Icons.arrow_forward,color: Uicolors.buttonbg,),
                //             ),
                //             //
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // GestureDetector(
                //   child: Padding(
                //     padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height*0.03,MediaQuery.of(context).size.height*0.02,MediaQuery.of(context).size.height*0.04,0),
                //     child: Container(
                //       width: MediaQuery.of(context).size.width/1.1,
                //       height: MediaQuery.of(context).size.height*0.05,
                //       decoration: BoxDecoration(
                //         border: Border.all(
                //             color: Colors.grey, width: 2),
                //         borderRadius: BorderRadius.circular(10.0),
                //         shape: BoxShape.rectangle,
                //       ),
                //       child: Row(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: <Widget>[
                //           Align(
                //             alignment: Alignment.centerLeft,
                //             child: Container(
                //               padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.03,0,0,0),
                //               child: Text(
                //                   Strings.serviceproviders,
                //                   style: TextStyle(
                //                       color: Colors.black45,
                //                       fontSize: 14,fontFamily: 'Popins'
                //                   )
                //               ),
                //             ),
                //           ),
                //           Align(
                //             alignment: Alignment.centerRight,
                //             child: Container
                //               (
                //               padding: EdgeInsets.fromLTRB(0,0,MediaQuery.of(context).size.width*0.03,0),
                //               child: Icon(Icons.arrow_forward,color: Uicolors.buttonbg,),
                //             ),
                //             //
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // GestureDetector(
                //   child: Padding(
                //     padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height*0.03,MediaQuery.of(context).size.height*0.02,MediaQuery.of(context).size.height*0.04,0),
                //     child: Container(
                //       width: MediaQuery.of(context).size.width/1.1,
                //       height: MediaQuery.of(context).size.height*0.05,
                //       decoration: BoxDecoration(
                //         border: Border.all(
                //             color: Colors.grey, width: 2),
                //         borderRadius: BorderRadius.circular(10.0),
                //         shape: BoxShape.rectangle,
                //       ),
                //       child: Row(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: <Widget>[
                //           Align(
                //             alignment: Alignment.centerLeft,
                //             child: Container(
                //               padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.03,0,0,0),
                //               child: Text(
                //                   Strings.security,
                //                   style: TextStyle(
                //                       color: Colors.black45,
                //                       fontSize: 14,fontFamily: 'Popins'
                //                   )
                //               ),
                //             ),
                //           ),
                //           Align(
                //             alignment: Alignment.centerRight,
                //             child: Container
                //               (
                //               padding: EdgeInsets.fromLTRB(0,0,MediaQuery.of(context).size.width*0.03,0),
                //               child: Icon(Icons.arrow_forward,color: Uicolors.buttonbg,),
                //             ),
                //             //
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // GestureDetector(
                //   child: Padding(
                //     padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height*0.03,MediaQuery.of(context).size.height*0.02,MediaQuery.of(context).size.height*0.04,0),
                //     child: Container(
                //       width: MediaQuery.of(context).size.width/1.1,
                //       height: MediaQuery.of(context).size.height*0.05,
                //       decoration: BoxDecoration(
                //         border: Border.all(
                //             color: Colors.grey, width: 2),
                //         borderRadius: BorderRadius.circular(10.0),
                //         shape: BoxShape.rectangle,
                //       ),
                //       child: Row(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: <Widget>[
                //           Align(
                //             alignment: Alignment.centerLeft,
                //             child: Container(
                //               padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.03,0,0,0),
                //               child: Text(
                //                   Strings.linkothers,
                //                   style: TextStyle(
                //                       color: Colors.black45,
                //                       fontSize: 14,fontFamily: 'Popins'
                //                   )
                //               ),
                //             ),
                //           ),
                //           Align(
                //             alignment: Alignment.centerRight,
                //             child: Container
                //               (
                //               padding: EdgeInsets.fromLTRB(0,0,MediaQuery.of(context).size.width*0.03,0),
                //               child: Icon(Icons.arrow_forward,color: Uicolors.buttonbg,),
                //             ),
                //             //
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // GestureDetector(
                //   child: Padding(
                //     padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height*0.03,MediaQuery.of(context).size.height*0.02,MediaQuery.of(context).size.height*0.04,0),
                //     child: Container(
                //       width: MediaQuery.of(context).size.width/1.1,
                //       height: MediaQuery.of(context).size.height*0.05,
                //       decoration: BoxDecoration(
                //         border: Border.all(
                //             color: Colors.grey, width: 2),
                //         borderRadius: BorderRadius.circular(10.0),
                //         shape: BoxShape.rectangle,
                //       ),
                //       child: Row(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: <Widget>[
                //           Align(
                //             alignment: Alignment.centerLeft,
                //             child: Container(
                //               padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.03,0,0,0),
                //               child: Text(
                //                   Strings.childrenprivacy,
                //                   style: TextStyle(
                //                       color: Colors.black45,
                //                       fontSize: 14,fontFamily: 'Popins'
                //                   )
                //               ),
                //             ),
                //           ),
                //           Align(
                //             alignment: Alignment.centerRight,
                //             child: Container
                //               (
                //               padding: EdgeInsets.fromLTRB(0,0,MediaQuery.of(context).size.width*0.03,0),
                //               child: Icon(Icons.arrow_forward,color: Uicolors.buttonbg,),
                //             ),
                //             //
                //           ),
                //         ],
                //       ),
                //
                //     ),
                //   ),
                // ),
                // GestureDetector(
                //   child: Padding(
                //     padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height*0.03,MediaQuery.of(context).size.height*0.02,MediaQuery.of(context).size.height*0.04,0),
                //     child: Container(
                //       width: MediaQuery.of(context).size.width/1.1,
                //       height: MediaQuery.of(context).size.height*0.05,
                //       decoration: BoxDecoration(
                //         border: Border.all(
                //             color: Colors.grey, width: 2),
                //         borderRadius: BorderRadius.circular(10.0),
                //         shape: BoxShape.rectangle,
                //       ),
                //       child: Row(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: <Widget>[
                //           Align(
                //             alignment: Alignment.centerLeft,
                //             child: Container(
                //               padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.03,0,0,0),
                //               child: Text(
                //                   Strings.changeprivacypolicy,
                //                   style: TextStyle(
                //                       color: Colors.black45,
                //                       fontSize: 14,fontFamily: 'Popins'
                //                   )
                //               ),
                //             ),
                //           ),
                //           Align(
                //             alignment: Alignment.centerRight,
                //             child: Container
                //               (
                //               padding: EdgeInsets.fromLTRB(0,0,MediaQuery.of(context).size.width*0.03,0),
                //               child: Icon(Icons.arrow_forward,color: Uicolors.buttonbg,),
                //             ),
                //             //
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                Padding(
                    padding: EdgeInsets.fromLTRB(
                        privacyPolicyLeftpadding,
                       privacyPolicyTopPadding,
                        privacyPolicyLeftpadding,
                        0),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      //height: MediaQuery.of(context).size.height * 0.05,
                      child: Text(
                        Strings.contactus,
                        style: privacyTitleTextStyle,
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(
                        textLeftPadding,
                        textTopPadding,
                        textLeftPadding,
                        0),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Strings.questionsuggestion,
                        style: privacyTextStyle,
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(
                        textLeftPadding,
                        textTopPadding,
                         textLeftPadding,
                        0),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Strings.address,
                        style: privacyTextStyle,
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(
                        textLeftPadding,
                       textTopPadding,
                        textLeftPadding,
                        0),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "",
                        style: privacyTextStyle,
                      ),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
