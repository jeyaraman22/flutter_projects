import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/roommodel.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;

class TermsAndConditions extends StatefulWidget {
  final String name;
  final Room roomPolicy;
  TermsAndConditions(this.name,this.roomPolicy);
  _TermsAndConditionsState createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {

  var cancelStr;
  var guaranteeStr;
  var petStr = "";
  var familyStr="";
  var groupStr="";
  var roomPolicy;

  @override
  void initState() {
    super.initState();
    roomPolicy = widget.roomPolicy.roomDetail;
    cancelStr = roomPolicy["cancelPolicyDescription"];
    guaranteeStr = roomPolicy["guaranteeDescription"];
    petStr = roomPolicy["petPolicyDescription"]!=null?roomPolicy["petPolicyDescription"]:Strings.petsTextStr;
    familyStr = roomPolicy["familyPolicyDescription"]!=null?roomPolicy["familyPolicyDescription"]:Strings.familyTextStr;
    groupStr = roomPolicy["groupPolicyDescription"]!=null?roomPolicy["groupPolicyDescription"]:Strings.groupTextStr;
    guaranteeStr = AppUtility().parseHtmlString(guaranteeStr);
    cancelStr = AppUtility().parseHtmlString(cancelStr);
  }
  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).size.height*0.015;
    var leftPadding = MediaQuery.of(context).size.width*0.03;
    return GestureDetector(
        onTap: () async {
          // var url = GlobalState.termsAndConditionUrl != null ? GlobalState
          //     .termsAndConditionUrl : "";
          // if (await canLaunch(url)) {
          //   await launch(
          //     url,
          //     forceSafariVC: false,
          //     forceWebView: false,
          //     headers: <String, String>{'my_header_key': 'my_header_value'},
          //   );
          // } else {
          //   throw 'Could not launch';
          // }
        },
        child: Container(
          alignment: Alignment.topLeft,
          child: Container(
            //  height: MediaQuery.of(context).size.height*(AppUtility().isTablet(context)?0.075:0.06),
         //   width: MediaQuery.of(context).size.width * 1,
            padding: EdgeInsets.only(left:leftPadding,
                right: leftPadding),
            decoration: BoxDecoration(
              //  borderRadius: BorderRadius.circular(10),
              border: border,
              boxShadow: boxShadow,
              color: Colors.white,
            ),
            child: Column(
              //  mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: EdgeInsets.only(top: topPadding,),
                      child: Text(
                        Strings.policyStr,
                        style: expansionTitleStyle,
                      )),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Container(padding: EdgeInsets.only(left: 20,top: 20),
                  //         child: Text(
                  //           widget.name,
                  //           style: expansionTitleStyle,
                  //         )),
                  //   ],
                  // ),
                  if(guaranteeStr!="")
                  Container(
                    padding: EdgeInsets.only(top: topPadding,),
                      child: Text(
                        Strings.guaranteePolicyStr,
                        style: expansionTitleStyle,
                      )
                  ),
                  if(guaranteeStr!="")
                    Container(
                        padding: EdgeInsets.only(top: topPadding,),
                        child: Text(
                          guaranteeStr,
                          style: descTextStyle,
                        )
                    ),
                  if(familyStr!="")
                    Container(
                        padding: EdgeInsets.only(top: topPadding,),
                        child: Text(
                          Strings.familyPolicyStr,
                          style: expansionTitleStyle,
                        )
                    ),
                  if(familyStr!="")
                    Container(
                        padding: EdgeInsets.only(top: topPadding,),
                        child: Text(
                          familyStr,
                          style: descTextStyle,
                        )
                    ),
                  if(groupStr!="")
                    Container(
                        padding: EdgeInsets.only(top: topPadding,),
                        child: Text(
                          Strings.groupPolicyStr,
                          style: expansionTitleStyle,
                        )
                    ),
                  if(groupStr!="")
                    Container(
                        padding: EdgeInsets.only(top: topPadding,),
                        child: Text(
                          Strings.groupTextStr,
                          style: descTextStyle,
                        )
                    ),
                  if(petStr!="")
                    Container(
                        padding: EdgeInsets.only(top: topPadding,),
                        child: Text(
                          Strings.petsPolicyStr,
                          style: expansionTitleStyle,
                        )
                    ),
                  if(petStr!="")
                    Container(
                        padding: EdgeInsets.only(top: topPadding,),
                        child: Text(
                          petStr,
                          style: descTextStyle,
                        )
                    ),
                  if(cancelStr!="")
                    Container(
                        padding: EdgeInsets.only(top: topPadding,),
                        child: Text(
                          Strings.cancelPolicyStr,
                          style: expansionTitleStyle,
                        )
                    ),
                  if(cancelStr!="")
                    Container(
                        padding: EdgeInsets.only(top: topPadding,bottom: topPadding),
                        child: Text(
                          cancelStr,
                          style: descTextStyle,
                        )
                    ),
                  //  Container(
                  //      padding: EdgeInsets.only(right: 5),
                  //      child: IconButton(
                  //   icon: Icon(
                  //     Icons.arrow_forward_ios,
                  //     color: Uicolors.buttonbg,
                  //     size: backIconSize,
                  //   ),
                  //   onPressed: () {},
                  // )),
                ]),
          ),
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.02,
              left: widget.name == Strings.termsStr
                  ? MediaQuery.of(context).size.width * 0.04
                  : 0,
              right: widget.name == Strings.termsStr
                  ? MediaQuery.of(context).size.width * 0.04
                  : 0,
              bottom: 20),
        ));
  }
}
