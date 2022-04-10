import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';
import 'package:jaz_app/helper/graphqlconnectivity/constants.dart';
import 'package:jaz_app/helper/search_service.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/models/user/user.dart';
import 'package:jaz_app/screens/bottomnavigation/bottombar.dart';
import 'package:jaz_app/screens/search/hotel_list.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:jaz_app/utils/http_client.dart';

import '../../graphql_provider.dart';
import '../homebottombar.dart';

class SavedListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SavedListState();
}

class _SavedListState extends State<SavedListPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<dynamic> savedList = [];
  StreamController savedListController = new StreamController();
  HttpClient httpClient = HttpClient();
  var isResult = false;
  List<dynamic> favList = [];

  @override
  void initState() {
    super.initState();
    getSavedList();
  }

  getSavedList() async {
    EasyLoading.show();
    final User? user = auth.currentUser;
    if (user != null) {
      final userId = user.uid;
      var document = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      UserModel users =
          UserModel.fromJson(document.data() as Map<String, dynamic>);
      EasyLoading.dismiss();
      if(users.favourites!=null&&users.favourites.length>0) {
        favList = users.favourites;
        GlobalState.favList = favList;
        DateTime startDate = DateTime.now().add(const Duration(days: 3));
        DateTime endDate = DateTime.now().add(const Duration(days: 6));
        List<TravellerFilterInput> roomRefType = [
          TravellerFilterInput(age: 25, refId: 1)
        ];
        List<TravellersRoomInput> roomRef = [
          TravellersRoomInput(refIds: [1])
        ];
        String promoCode = "";
        // if (GlobalState.promoCode != null && GlobalState.promoCode != "") {
        //   promoCode = GlobalState.promoCode;
        // }
        // if(GlobalState.promoCode != null && GlobalState.promoCode != "" && GlobalState.promoCode !=membershipCode){
        //      promoCode = GlobalState.promoCode;
        // }else if(GlobalState.promoCode ==membershipCode && GlobalState.offerStartStr == Strings.offers){
        //   GlobalState.promoCode = "";
        // }
        ProductsQueryArguments args = SearchService().getProductQueryArguments(
            startDate,
            endDate,
            "",
            "",
            roomRef,
            roomRefType,
            promoCode);
        args.productSearch.nodeCodes = List<String>.from(favList);
        args.resultsPerPage = favList.length;
        QueryResult queryResult = await client.query(
          QueryOptions(
              document: PRODUCTS_QUERY_QUERY_DOCUMENT,
              variables: args.toJson()),
        );
        String errorMessage = "";
        final exception = queryResult.hasException.hashCode;
        if (queryResult.hasException) {
          if (exception is NetworkException) {
            errorMessage = Strings.noInternet;
          } else {
            errorMessage = Strings.errorMessage;
          }
          AppUtility().showToastView(errorMessage, context);
        } else {
          ProductsQuery$Query products =
          ProductsQuery$Query.fromJson(queryResult.data ?? {});
          products.products!.packageProducts!.forEach((product) {
            product.topOffer.isInFavorites = true;
            product.topOffer.isInFavoritesCheck = true;
            product.hotel!.description =
            "Situated within a few minutes’ drive from the airport, this resort is one of Hurghada’s best kept secrets.";
            setState(() {
              savedList.add(product);
            });
          });
        }
      }
        setState(() {
          savedListController.add(savedList);
          if (savedList.length == 0) {
            isResult = true;
          } else {
            isResult = false;
          }
        });

    }else{
      isResult=false;
      EasyLoading.dismiss();
    }
  }

  void getSavedList1() async {
    EasyLoading.show();
    // BuildContext? dialogContext;
    // await Future.delayed(Duration.zero);
    // AppUtility().showProgressDialog(context,type:null,dismissDialog:(value){
    //   dialogContext = value;
    // });
    CollectionReference addToFavoritesDetails =
        FirebaseFirestore.instance.collection('users');
    final User? user = auth.currentUser;
    if (user != null) {
      final userId = user.uid;
      var document = await addToFavoritesDetails.get();
      for (var product in document.docs) {
        bool isFav = false;
        List<dynamic> favUsers = [];
        if (product['favUsers'] != null) {
          print(
              "favUsers:${product['favUsers']}, id:${product['hotel']['giataId']}");
          favUsers = product['favUsers'];
          setState(() {
            isResult = true;
          });
        }
        setState(() {
          isResult = true;
        });
        isFav = favUsers.contains(userId);
        var datas = ProductsQuery$Query$Products$PackageProducts.fromJson(
            product.data() as Map<String, dynamic>);
        if (isFav) {
          datas.topOffer.isInFavorites = isFav;
          datas.topOffer.isInFavoritesCheck = true;
          datas.hotel!.description =
              "Situated within a few minutes’ drive from the airport, this resort is one of Hurghada’s best kept secrets.";
          setState(() {
            savedList.add(datas);
          });
        }
      }
      savedListController.add(savedList);
      EasyLoading.dismiss();
      // await new Future.delayed(const Duration(milliseconds: 500));
      // AppUtility().dismissDialog(dialogContext!);
    } else {
      EasyLoading.dismiss();
      // await new Future.delayed(const Duration(milliseconds: 500));
      // AppUtility().dismissDialog(dialogContext!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    var topHeight = height * 0.18;
    var topSpace = height * 0.1;
    var backTopSpace = 0.0;
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
            padding: EdgeInsets.only(left: 0, top: backTopSpace),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child: Container(
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Uicolors.backText,
                      size: backIconSize,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 0),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Text(Strings.backtosearch, style: backStyle),
                  ),
                ),
              ],
            ),
          )),
      body: Stack(
        children: [
          if (savedList.length == 0)
            Container(
              child: Container(
                width: width,
                height: height,
                color: Colors.white,
                alignment: Alignment.center,
                child: Text(
                  isResult?Strings.noShortList:"",
                  style: errorMessageStyle,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          StreamBuilder(
              stream: savedListController.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                if (snapshot.hasData) {
                  return snapshot.data != null
                      ? showLists(snapshot.data)
                      : Container(
                    width: width,
                    height: height,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: Text(
                      Strings.noShortList,
                      style: errorMessageStyle,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Container(
                );
              })
        ],
      ),
    );
  }

  showLists(List savedList) {
    return  AppUtility().isTablet(context) ?
    GridView.count(
        crossAxisCount: 2,
        childAspectRatio: MediaQuery.of(context).orientation == Orientation.landscape ?
        (MediaQuery.of(context).size.width /MediaQuery.of(context).size.height) / 1.2: (MediaQuery.of(context).size.width /(MediaQuery.of(context).size.height))/1.02,
        children: List.generate(savedList.length , (index) {
          return showFavListWidget(index);

        })) : ListView.builder(
        itemCount: savedList.length,
        itemBuilder: (BuildContext context, int index) {
          return showFavListWidget(index);
        });
  }

  void updateHotelFavState(int index, bool isFav) {
    setState(() {
      savedList.removeAt(index);
      savedListController.add(savedList);
    });
  }

  getOverView(ProductsQuery$Query$Products$PackageProducts product,
      String giataId) async {
    HashMap<String, dynamic> params = HashMap();
    //widget.product.hotel!.giataId.toString()
    params.putIfAbsent("renderPage", () => "/hoteldetail/" + giataId);
    params.putIfAbsent("_locale", () => "en-gb");
    var response;
    EasyLoading.show();

    response = await httpClient.getRenderData(params, "/api/renders", null);
    if (response.statusCode == 200 && json.decode(response.body) != null) {
      EasyLoading.dismiss();
      // await new Future.delayed(const Duration(milliseconds: 500));
      // AppUtility().dismissDialog(dialogContext!);
      var result = json.decode(response.body);
      var pages = result["content"]["hoteldetailNavigation"]["children"][0]
          ["module"]["result"]["pages"];
      HashMap<String, String> listPage = HashMap();
      pages.forEach((page) {
        setState(() {
          listPage.putIfAbsent(page["name"], () => page["resource"]);
        });
      });
      GlobalState.destinationString = product.hotel!.name.toString();
      GlobalState.destinationValue = product.hotel!.giataId.toString();
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
            builder: (context) => new HomeBottomBarScreen(0) /*BottomBar()*/),
      );

    } else {
      EasyLoading.dismiss();
      // await new Future.delayed(const Duration(milliseconds: 500));
      // AppUtility().dismissDialog(dialogContext!);
    }
  }

  showFavListWidget(index) {
    return GestureDetector(
        child: HotelList(savedList[index], favoritesFunc: (values) {
          updateHotelFavState(index, values);
        }),
        onTap: ()  {
          // getOverView(savedList[index],
          //     savedList[index].hotel!.giataId.toString()),
          //
          GlobalState.destinationString = savedList[index].hotel!.name.toString();
          GlobalState.destinationValue = savedList[index].hotel!.giataId.toString();
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
                builder: (context) => new HomeBottomBarScreen(0) /*BottomBar()*/),
          );
        });
  }
}
