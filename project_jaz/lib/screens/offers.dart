import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';
import 'package:jaz_app/helper/graphqlconnectivity/constants.dart';
import 'package:jaz_app/helper/search_service.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/models/user/user.dart';
import 'package:jaz_app/screens/destination/destination_list.dart';
import 'package:jaz_app/screens/search/searchdetailpage.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/widgets/appbar.dart';
import 'package:jaz_app/widgets/member_list.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../graphql_provider.dart';

class Offers extends StatefulWidget {
  final Function(String) onBack;
  Offers({required this.onBack});

  _Offers createState() => _Offers();
}

class _Offers extends State<Offers> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var contentHeightPadding =
        overAllHeight * (AppUtility().isTablet(context) ? 0.50 : 0.35);
    var contentWidthPadding = overAllWidth * 1;
    var listLeftPadding = overAllWidth * 0.045;
    var destinationTopSpace = overAllHeight * 0.02;

    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        child: Column(children: [
          Container(
              margin: EdgeInsets.only(
                top: overAllHeight * 0.02,
              )),

          // Container(
          //   color: Uicolors.appbarBlueBg,
          //   padding:EdgeInsets.only(top
          //       : 5,bottom: 5) ,
          //   alignment: Alignment.center,
          //   margin: EdgeInsets.only(top: destinationTopSpace,bottom: destinationTopSpace),
          //   child: Text(
          //     Strings.exploreOffers,
          //     style: exploreOfferStyle,
          //     maxLines: 2,
          //   ),
          // ),
          Expanded(
            child: AppUtility().isTablet(context)
                ? GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? (MediaQuery.of(context).size.width + 48.0) /
                            (MediaQuery.of(context).size.height + 68.0)
                        : MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.height),
                    children: List.generate(searchImageUrls.length, (index) {
                      return showOfferWidget(index);
                    }))
                : ListView.builder(
                    //  physics: NeverScrollableScrollPhysics(),
                    itemCount: searchImageUrls.length,
                    itemBuilder: (BuildContext context, int index) {
                      return showOfferWidget(index);
                      // return DestinationList();
                    },
                    // itemBuilder: (context, index) => SearchDetail(context)
                  ),
          )
        ]),
      ),
    );
  }

  showOfferWidget(int index) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var contentHeightPadding =
        overAllHeight * (AppUtility().isTablet(context) ? 0.5 : 0.35);
    var listLeftPadding = overAllWidth * 0.045;

    return InkWell(
      onTap: (){
        searchOnClick(membershipCode);
      },
      child: Container(
        margin: AppUtility().isTablet(context)
            ? EdgeInsets.only(
                left: listLeftPadding,
                right: listLeftPadding,
                top: 5,
                bottom: overAllHeight * 0.02)
            : EdgeInsets.only(
                left: listLeftPadding,
                right: listLeftPadding,
                top: 5,
                bottom: overAllHeight * 0.02),
        //height: contentHeightPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          boxShadow: boxShadow,
        ),
        child: ClipRRect(
            // borderRadius: BorderRadius.all(Radius.circular(containerBorderRadius)),
            child: Column(
          children: [
            Image.network(
              searchImageUrls[index],
              fit: BoxFit.cover,
              height:
                  overAllHeight * (AppUtility().isTablet(context) ? 0.5 : 0.35),
              width: overAllWidth,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              color: Uicolors.buttonbg,
              child: Text("Book Now! Save 15% Offer Till 25th December",
                  style: buttonStyle, maxLines: 2),
            )
          ],
        )),
      ),
    );
  }

  searchOnClick(String promoCode) async {
    DateTime startDate = DateTime.now().add(const Duration(days: 3));
    DateTime endDate = DateTime.now().add(const Duration(days: 6));
    List<TravellerFilterInput> roomRefType = [
      TravellerFilterInput(age: 25, refId: 1),
      TravellerFilterInput(age: 25, refId: 1)
    ];
    List<TravellersRoomInput> roomRef = [
      TravellersRoomInput(refIds: [1])
    ];
    String _personDetails = "2 Person - 1 Room";
    GlobalState.checkInDate = startDate;
    GlobalState.checkOutDate = endDate;
    GlobalState.personDetails = _personDetails;
    GlobalState.destinationValue = "";
    GlobalState.themeValue = "";
    GlobalState.selectedRoomRef = roomRef;
    GlobalState.selectedRoomRefType = roomRefType;
    GlobalState.promoCode = promoCode;
    EasyLoading.show();
    ProductsQueryArguments args = SearchService().getProductQueryArguments(
        startDate, endDate, "", "", roomRef, roomRefType, promoCode);
    var errorMessage = "";
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    //print("user:${user}");
    try {
      List<Future<dynamic>> requestQuery = [
        client.query(
          QueryOptions(
              document: PRODUCTS_QUERY_QUERY_DOCUMENT,
              variables: args.toJson()),
        ),
      ];
      if (user != null) {
        final userId = user.uid;
        requestQuery.add(
            FirebaseFirestore.instance.collection('users').doc(userId).get());
      }
      List allResponse;
      allResponse = await Future.wait(requestQuery);
      EasyLoading.dismiss();
      QueryResult queryResult = allResponse[0];
      if (user != null) {
        UserModel users = UserModel.fromJson(
            (allResponse[1] as DocumentSnapshot).data()
                as Map<String, dynamic>);
        GlobalState.favList = users.favourites;
      }
      final exception = queryResult.hasException.hashCode;
      if (queryResult.hasException) {
        if (exception is NetworkException) {
          errorMessage = Strings.noInternet;
        } else {
          errorMessage = Strings.errorMessage;
        }
        AppUtility().showToastView(errorMessage, context);
      } else {
        ProductsQuery$Query product =
            ProductsQuery$Query.fromJson(queryResult.data ?? {});
        pushNewScreen(
          context,
          screen: SearchDetail(context, "", "", startDate, endDate, roomRefType,
              roomRef, promoCode, _personDetails, product, HashMap()),
          withNavBar: false, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      }
    } catch (e) {
      AppUtility().showToastView(Strings.errorMessage, context);
    }
    EasyLoading.dismiss();
  }
}
