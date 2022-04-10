import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter_bloc/graphql_flutter_bloc.dart';
import 'package:jaz_app/bloc/product_query_bloc.dart';
import 'package:jaz_app/helper/search_service.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/screens/product_overview/overviewbottombarscreen.dart';
import 'package:jaz_app/screens/search/searchmap.dart';
import 'package:jaz_app/screens/search/search_filter.dart';
import 'package:jaz_app/screens/search/search_sort.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/commonutils.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../graphql_provider.dart';
import 'hotel_list.dart';
import 'package:jaz_app/utils/http_client.dart';

class SearchDetail extends StatefulWidget {
  final BuildContext searchDetailContext;
  final String destinationValue;
  final String themeValue;
  final DateTime startDate;
  final DateTime endDate;
  final List<TravellerFilterInput> roomRefType;
  final List<TravellersRoomInput> roomRef;
  final String promoCode;
  final String personDetails;
  final ProductsQuery$Query data;
  final HashMap<String,ProductsQuery$Query$Products$PackageProducts> memberData;

  SearchDetail(
      this.searchDetailContext,
      this.destinationValue,
      this.themeValue,
      this.startDate,
      this.endDate,
      this.roomRefType,
      this.roomRef,
      this.promoCode,
      this.personDetails,
      this.data,
      this.memberData);

  _SearchDetailState createState() => _SearchDetailState();
}

class _SearchDetailState extends State<SearchDetail> {
  var selectedDate = "";
  AppUtility appUtility = AppUtility();
  FilterSortingOrderEnum sortStr = FilterSortingOrderEnum.priceAsc;
  HttpClient httpClient = HttpClient();
  SearchService searchService = SearchService();
  late ProductQueryBloc bloc;
  ProductSearchInput productSearchInput = ProductSearchInput();
  int resultsPerPage = 10;
  int resultTotal = 0;
  int startForm = 0;
  bool isPerformingRequest = false;
  late ProductsQueryArguments args;
  int avgRatings = 0;
  List<String> hotelAttributes = [];
  List<int> avgRatingList = [];
  ProductsQuery$Query? updateDatas;
  var selectedCurrency = Strings.currency;
  ScrollController _controller = new ScrollController(initialScrollOffset: 0);
   HashMap<String,ProductsQuery$Query$Products$PackageProducts> memberShipDatas = HashMap();


  void initState() {
    super.initState();
    appUtility = AppUtility();
    memberShipDatas = widget.memberData;
    selectedCurrency = GlobalState.selectedCurrency != null
        ? GlobalState.selectedCurrency
        : Strings.usd;
    selectedDate = appUtility.getDateDiff(widget.startDate, widget.endDate);
    args = searchService.getProductQueryArguments(
        widget.startDate,
        widget.endDate,
        widget.destinationValue,
        widget.themeValue,
        widget.roomRef,
        widget.roomRefType,
        widget.promoCode);
    args.sortingOrder = sortStr;
    print(args);
    bloc = ProductQueryBloc(client: client)..run(variables: args.toJson());
    if (widget.themeValue != null && widget.themeValue != "") {
      hotelAttributes.add(widget.themeValue);
    }
    _controller = new ScrollController(initialScrollOffset: 0);
    _controller.addListener(_scrollListener);
  }
  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent && !_controller.position.outOfRange) {
       if(resultTotal!=updateDatas!.products!.packageProducts!.length) {
      loadMore();
       }else{
        this.setState(() {
          isPerformingRequest=false;
        });
      }
    }
  }

// to show progressbar while loading data in background
  Widget _buildProgressIndicator() {
    return Center(
      child: new Opacity(
        opacity: isPerformingRequest ? 1.0 : 0.0,
        child: new CircularProgressIndicator(),
      ),
    );
  }

  loadMore() {
    startForm += resultsPerPage;
    isPerformingRequest = false;
    if (bloc.shouldFetchMore(startForm, resultsPerPage)) {
      setState(() {
        isPerformingRequest = true;
      });
      args.resultsPerPage = resultsPerPage;
      args.showingResultsFrom = startForm;
      bloc.add(QueryEvent.fetchMore(
          options: FetchMoreOptions(
        variables: args.toJson(),
        updateQuery: (dynamic previousResultData, dynamic fetchMoreResultData) {
          final List<dynamic> repos = <dynamic>[
            ...previousResultData['products']['packageProducts']
                as List<dynamic>,
            ...fetchMoreResultData['products']['packageProducts']
                as List<dynamic>
          ];
          fetchMoreResultData['products']['packageProducts'] = repos;
          return fetchMoreResultData;
        },
      )));
      // setState(() {
      //   isPerformingRequest = false;
      // });
    }
  }

  filterApiIntegration() async {
    EasyLoading.show();
    HashMap<String,ProductsQuery$Query$Products$PackageProducts> memberFilter = HashMap();
    if(memberShipDatas.length>0 ){
      ProductsQueryArguments memberArgs = searchService
          .getProductQueryArguments(
          widget.startDate,
          widget.endDate,
          widget.destinationValue,
          widget.themeValue,
          widget.roomRef,
          widget.roomRefType,
          GlobalState.promoCode);
      memberArgs.resultsPerPage = 1000;
      memberArgs.showingResultsFrom = 0;
      try {
        List<Future<dynamic>> requestQuery = [
          client.query(
            QueryOptions(
                document: PRODUCTS_QUERY_QUERY_DOCUMENT,
                variables: memberArgs.toJson()),
          ),
        ];
        var allResponse = await Future.wait(requestQuery);
        QueryResult memberResult = allResponse[0];
        if (memberResult.hasException) {} else {
          ProductsQuery$Query membershipProduct = ProductsQuery$Query.fromJson(
              memberResult.data ?? {});
          membershipProduct.products!.packageProducts!.forEach((element) {
            memberFilter.putIfAbsent(
                element.hotel!.giataId.toString(), () => element);
          });
          setState(() {
            memberShipDatas = memberFilter;
          });
        }
      } on SocketException catch (_) {
        AppUtility().showToastView(Strings.noInternet, context);
      } catch (e) {
        AppUtility().showToastView(Strings.errorMessage, context);
      }
    }
    EasyLoading.dismiss();
    updateDatas = null;
    startForm = 0;
    RequestBaseHotelFilterInput hotelFilter = RequestBaseHotelFilterInput();
    HotelAttributesFilterInput hotelAttributesFilterInput =
        HotelAttributesFilterInput();
    hotelFilter.hotelAttributesFilter = hotelAttributesFilterInput;
    hotelAttributesFilterInput.hotelAttributes = hotelAttributes;
    // RatingFilterInput rating = RatingFilterInput(
    //     value: avgRatings,
    //     code: RatingFilterCodeEnum.averageRating,
    //     kw$operator: RatingFilterOperatorEnum.ge);
    // hotelFilter.ratings = [rating];
    hotelFilter.minCategory = double.parse(avgRatings.toString());
    args.productSearch.hotelFilter = hotelFilter;
    args.sortingOrder = sortStr;
    args.resultsPerPage = 10;
    args.showingResultsFrom = 0;
    args.currency = selectedCurrency;
    bloc = ProductQueryBloc(client: client)..run(variables: args.toJson());
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
    final double height = MediaQuery.of(context).size.height;
    var topHeight = height * 0.18;
    var topSpace = height * 0.1;
    var backTopSpace = 0.0;
    return Scaffold(
      backgroundColor: Uicolors.backgroundColor,
      appBar: // here the desired height
          AppBar(
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
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(topSpace),
                child: Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(
                        bottom: (AppUtility().isTablet(context) ? 5 : 0)),
                    child: Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                    top: 0, left: 22, right: 22),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        selectedDate,
                                        style: selectedDateStyle,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Text(
                                        widget.personDetails,
                                        style: selectedDateStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                  top:
                                      (AppUtility().isTablet(context) ? 5 : 0)),
                              padding:
                                  EdgeInsets.only(top: 14, left: 22, right: 22),
                              height:
                                  MediaQuery.of(context).size.height * 0.015,
                              child: Divider(
                                color: Uicolors.desText,
                                thickness: 0.5,
                              )),
                          Stack(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    top: (AppUtility().isTablet(context)
                                        ? 5
                                        : 0)),
                                padding: EdgeInsets.only(
                                    top: (AppUtility().isTablet(context)
                                        ? 5
                                        : 0),
                                    bottom: (AppUtility().isTablet(context)
                                        ? 5
                                        : 0)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        pushNewScreen(
                                          context,
                                          screen: SearchSort(sortStr,
                                              sortValue: (value) {
                                            this.setState(() {
                                              sortStr = value;
                                            });
                                            filterApiIntegration();
                                          }),
                                          withNavBar:
                                              false, // OPTIONAL VALUE. True by default.
                                          pageTransitionAnimation:
                                              PageTransitionAnimation.cupertino,
                                        );
                                      },
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          padding: EdgeInsets.only(left: 20),
                                          child: Text(
                                            Strings.sortTitle,
                                            style: sortTitleStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      child: Container(
                                        height: 45,
                                        child: VerticalDivider(
                                          color: Uicolors.desText,
                                          thickness: 0.5,
                                          indent: 10,
                                          endIndent: 10,
                                          width: 20,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        List<ProductsQuery$Query$Products$PackageProducts> mapProduct=[];
                                        if(resultTotal<updateDatas!.products!.packageProducts!.length){
                                          mapProduct = updateDatas!.products!.packageProducts!;
                                        }else {
                                          EasyLoading.show();
                                          args.resultsPerPage = resultTotal;
                                          args.showingResultsFrom = 0;
                                          args.currency = selectedCurrency;
                                          List<Future<dynamic>> requestQuery = [
                                            client.query(
                                              QueryOptions(
                                                  document:
                                                  PRODUCTS_QUERY_QUERY_DOCUMENT,
                                                  variables: args.toJson()),
                                            ),
                                          ];
                                          var allResponse =
                                          await Future.wait(requestQuery);
                                          String errorMessage = "";
                                          QueryResult queryResult =
                                          allResponse[0];
                                          final exception =
                                              queryResult.hasException.hashCode;
                                          if (queryResult.hasException) {
                                            if (exception is NetworkException) {
                                              errorMessage = Strings.noInternet;
                                            } else {
                                              errorMessage =
                                                  Strings.errorMessage;
                                            }
                                            EasyLoading.dismiss();
                                            AppUtility().showToastView(
                                                errorMessage, context);
                                          } else {
                                            EasyLoading.dismiss();
                                            ProductsQuery$Query product =
                                            ProductsQuery$Query.fromJson(
                                                queryResult.data ?? {});
                                            mapProduct = product.products!.packageProducts!;
                                            for(int i=0;i<mapProduct.length;i++){
                                              if(memberShipDatas.containsKey(mapProduct[i].hotel!.giataId.toString())){
                                                mapProduct[i] = memberShipDatas[mapProduct[i].hotel!.giataId.toString()]!;
                                                //mapProduct[i] = memberShipDatas[mapProduct[i].hotel!.giataId.toString()]!;
                                              }
                                            }
                                          }
                                        }
                                        pushNewScreen(
                                          context,
                                          screen: SearchMap(mapProduct,
                                              "listPage"),
                                          withNavBar: false,
                                          // OPTIONAL VALUE. True by default.
                                          pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                        );
                                      },
                                      child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Container(
                                            child: Text(
                                              Strings.mapTitle,
                                              style: sortTitleStyle,
                                            ),
                                          )),
                                    ),
                                    Align(
                                      // alignment: Alignment.topCenter,
                                      child: Container(
                                        height: 45,
                                        child: VerticalDivider(
                                          color: Uicolors.desText,
                                          thickness: 0.5,
                                          indent: 10,
                                          endIndent: 10,
                                          width: 20,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        EasyLoading.show();
                                        QueryResult queryResult =
                                            await client.query(
                                          QueryOptions(
                                              document:
                                                  GLOBAL_TYPES_QUERY_DOCUMENT),
                                        );
                                        EasyLoading.dismiss();
                                        String errorMessage = "";
                                        final exception =
                                            queryResult.hasException.hashCode;
                                        if (queryResult.hasException) {
                                          if (exception is NetworkException) {
                                            errorMessage = Strings.noInternet;
                                          } else {
                                            errorMessage = Strings.errorMessage;
                                          }
                                          AppUtility().showToastView(
                                              errorMessage, context);
                                        } else {
                                          GlobalTypes$Query amenitiesList =
                                          GlobalTypes$Query.fromJson(
                                              queryResult.data ?? {});
                                          pushNewScreen(
                                            context,
                                            screen: SearchFilter(
                                                hotelAttributes, avgRatingList,
                                                hotelAttribute: (avgRatingLists,
                                                    hotelAttributess,
                                                    currency) {
                                                  this.setState(() {
                                                    avgRatingList =
                                                        avgRatingLists;
                                                    avgRatings =
                                                    avgRatingLists[0];
                                                    hotelAttributes =
                                                        hotelAttributess;
                                                    selectedCurrency = currency;
                                                    filterApiIntegration();
                                                  });
                                                }),
                                            withNavBar:
                                            false,
                                            // OPTIONAL VALUE. True by default.
                                            pageTransitionAnimation:
                                            PageTransitionAnimation.cupertino,
                                          );
                                        }
                                      },
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Row(
                                          children: [
                                            Container(
                                              child: Text(
                                                Strings.filterTitle,
                                                style: sortTitleStyle,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: (AppUtility()
                                                          .isTablet(context)
                                                      ? 10
                                                      : 5),
                                                  right: 5),
                                              child: Image.asset(
                                                "assets/images/filter.png",
                                                width: backIconSize,
                                                color: Uicolors.bottomTextColor,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )),
              )),
      body: Stack(
        children: <Widget>[
          Container(
            child:
                BlocBuilder<ProductQueryBloc, QueryState<ProductsQuery$Query>>(
              bloc: bloc,
              builder: (_, state) {
                // if (state is! QueryStateRefetch) {
                //   _handleRefreshEnd();
                // }
                return state.when(
                  initial: () => Container(),
                  loading: (_) => Center(child: CircularProgressIndicator()),
                  error: (error, __) {
                    var errorMessage = "";
                    final exception = error.linkException;
                    if (exception is NetworkException) {
                      errorMessage = Strings.noInternet;
                    } else {
                      errorMessage = Strings.errorMessage;
                    }
                    return Container(
                      height: 150,
                      width: MediaQuery.of(context).size.width - 10,
                      padding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.01,
                          left: MediaQuery.of(context).size.width * 0.01,
                          top: 100),
                      alignment: Alignment.center,
                      child: Text(
                        errorMessage,
                        style: errorMessageStyle,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                  loaded: (ProductsQuery$Query? data, QueryResult? result) {
                    return _displayResult(data, result);
                  },
                  refetch: _displayResult,
                  fetchMore: (ProductsQuery$Query? data, QueryResult? result) {
                    return _displayResult(data, result);
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _displayResult(
    ProductsQuery$Query? data,
    QueryResult? result,
  ) {
    if (data == null) {
      return Container();
    }
    resultTotal = data.products!.pagination!.resultsTotal;
    updateDatas = data;
    var itemCount = updateDatas!.products!.packageProducts!.length;
    // if (itemCount > 1) {
    //   itemCount = itemCount - 1;
    // }
    if (itemCount == 0) {
      return Container(
        height: 150,
        width: MediaQuery.of(context).size.width - 10,
        padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.01,
            left: MediaQuery.of(context).size.width * 0.01,
            top: 100),
        alignment: Alignment.center,
        child: Text(
          Strings.emptyHotel,
          style: errorMessageStyle,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return
        Container(
          // onEndOfPage: () => loadMore(),
          // scrollOffset: 100,
          child:
         AppUtility().isTablet(context) ?
         GridView.count(
              crossAxisCount: 2,
              controller: _controller,
             childAspectRatio: MediaQuery.of(context).orientation == Orientation.landscape ?
                          (MediaQuery.of(context).size.width /MediaQuery.of(context).size.height) / 1.2: (MediaQuery.of(context).size.width /(MediaQuery.of(context).size.height))/1.02,

              // childAspectRatio: 1/1.50,
              children: List.generate(itemCount + 1, (index) {
                if (index == itemCount) {
                  return Container(
                      width: 50, height: 50, child: _buildProgressIndicator());
                } else {
                  //fetch the favorites details from the fireabse
                  if (!updateDatas!.products!.packageProducts![index].topOffer
                      .isInFavoritesCheck) {
                    updateDatas!.products!.packageProducts![index].topOffer
                        .isInFavoritesCheck = true;
                    updateHotelsFavorites(
                        index, updateDatas!.products!.packageProducts![index]);
                  }
                  if (updateDatas!.products!.packageProducts![index].hotel!
                          .description ==
                      null) {
                    updateDatas!.products!.packageProducts![index].hotel!
                            .description =
                        "Situated within a few minutes’ drive from the airport, this resort is one of Hurghada’s best kept secrets.";
                    //   updateDatas!.products!.packageProducts![index].hotel!.description = "";
                    //   getOverView(
                    //       updateDatas!.products!.packageProducts![index],
                    //       updateDatas!.products!.packageProducts![index].hotel!.giataId.toString(),index);
                  }
                  return
                    GestureDetector(
                      child:
                      HotelList(
                          updateDatas!.products!.packageProducts![index],
                          favoritesFunc: (values) {
                        updateHotelFavState(index, values);
                      }),
                      onTap: () {
                        getOverView(
                            updateDatas!.products!.packageProducts![index],
                            updateDatas!.products!.packageProducts![index]
                                .hotel!.giataId
                                .toString());
                      });
                }
              })) :
          ListView.builder(
            itemCount: itemCount + 1,
            controller: _controller,
            itemBuilder: (BuildContext context, int index) {
              if (index == itemCount) {
                return Container(
                    width: 50, height: 50, child: _buildProgressIndicator());
              } else {
                //fetch the favorites details from the fireabse
                if (!updateDatas!.products!.packageProducts![index].topOffer.isInFavoritesCheck) {
                  updateDatas!.products!.packageProducts![index].topOffer.isInFavoritesCheck = true;
                 updateHotelsFavorites(index, updateDatas!.products!.packageProducts![index]);
                }
                if (updateDatas!.products!.packageProducts![index].hotel!.description == null) {
                  updateDatas!.products!.packageProducts![index].hotel!.description = "Situated within a few minutes’ drive from the airport, this resort is one of Hurghada’s best kept secrets.";
                }
               if(memberShipDatas.containsKey(updateDatas!.products!.packageProducts![index].hotel!.giataId.toString())){
                 updateDatas!.products!.packageProducts![index] = memberShipDatas[updateDatas!.products!.packageProducts![index].hotel!.giataId.toString()]!;
               }
                return GestureDetector(
                    child: HotelList(
                        updateDatas!.products!.packageProducts![index],
                        favoritesFunc: (values) {
                          updateHotelFavState(index, values);
                        }),
                    onTap: () {
                      getOverView(
                          updateDatas!.products!.packageProducts![index],
                          updateDatas!.products!.packageProducts![index].hotel!
                              .giataId.toString());
                    });
              }
              //  return buildContainer(data.products!.packageProducts![index]);
            },
          )
          );
    }
  }

  getOverView(ProductsQuery$Query$Products$PackageProducts product,
      String giataId) async {
    try {
      EasyLoading.show();
      HashMap<String, dynamic> overViewResponse =
          await CommonUtils().getOverView(giataId);
      EasyLoading.dismiss();
      var selectedList = GlobalState.selectedRoomList;
      for(int i=0;i<selectedList.length;i++){
        selectedList[i].roomDetail = HashMap();
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("selectedIndex");
      GlobalState.selectedRoomList = selectedList;
      if (overViewResponse["overViewResponseCode"] == Strings.failure ||
          overViewResponse["descResponseCode"] == Strings.failure) {

    //    AppUtility().showToastView(Strings.errorMessage, context);
        pushNewScreen(
          context,
          screen: OverviewBottombarScreen(0, HashMap(), product, "", []),
          //OverViewBottomBar(0, listPage, product,description,expansionList),
          withNavBar: false,
          // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      } else {
        List<String> proxyImages =overViewResponse["proxy_images"];
        List<String> originalImages = overViewResponse["original_images"];
        pushNewScreen(
          context,
          screen: OverviewBottombarScreen(
              0,
              overViewResponse["bottomList"],
              product,
              overViewResponse["description"],
              overViewResponse["expansion"]),
          //OverViewBottomBar(0, listPage, product,description,expansionList),
          withNavBar: false,
          // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      }
    } catch (e) {
      AppUtility().showToastView(Strings.errorMessage, context);
    }
    EasyLoading.dismiss();
  }


  void updateHotelsFavorites(
      int index, ProductsQuery$Query$Products$PackageProducts product) {
    bool isFav = false;
    if (GlobalState.favList != null) {
      isFav = GlobalState.favList.contains(product.hotel!.giataId.toString());
      if (isFav) {
        updateHotelFavState(index, isFav);
      }
    }
  }

  void updateHotelFavState(int index, bool isFav) {
    // setState(() {
    updateDatas!.products!.packageProducts![index].topOffer.isInFavorites =
        isFav;
    updateDatas!.products!.packageProducts![index].topOffer.isInFavoritesCheck =
        true;
  }
}
