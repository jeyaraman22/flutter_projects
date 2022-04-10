import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:jaz_app/bloc/add_favorites_bloc.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/models/user/user.dart';
import 'package:jaz_app/screens/product_overview/amenities_list.dart';
import 'package:jaz_app/screens/product_overview/galleryimageview.dart';
import 'package:jaz_app/screens/search/searchmap.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/carousel.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/graphql_provider.dart';
import 'package:jaz_app/utils/http_client.dart';
import 'package:jaz_app/utils/uiconstants.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class HotelList extends StatefulWidget {
  ProductsQuery$Query$Products$PackageProducts product;
  final Function(bool) favoritesFunc;

  HotelList(this.product, {required this.favoritesFunc});

  @override
  _HotelListState createState() => _HotelListState();
}

class _HotelListState extends State<HotelList> {
  HttpClient httpClient = HttpClient();
  late AddToFavoritesBloc addToFavoritesBloc;
  AppUtility appUtility = AppUtility();
  bool isPerformingRequest = false;
  bool isInFavorites = false;
  String descriptions = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  String locationName ="";
  String hotelContent = "";

  void initState() {
    super.initState();
    appUtility = AppUtility();
    addToFavoritesBloc = AddToFavoritesBloc(client: client);
    isInFavorites = widget.product.topOffer.isInFavorites;
    descriptions = widget.product.hotel!.description ?? "";
    locationName = (widget.product.hotel!.location!.country.name)! + " - " +
        (widget.product.hotel!.location!.city!.name)!;
    hotelContent = widget.product.hotelContent!.distanceToAirport.toString();

  }

  @override
  void dispose() {
    super.dispose();
    PaintingBinding.instance!.imageCache!.clear();
  }

  @override
  Widget build(BuildContext context) {
    return buildContainer(widget.product);
  }

  Widget buildContainer(ProductsQuery$Query$Products$PackageProducts product) {
    var indicatorSize = AppUtility().indicaorSize(context);
    var currentIndicatorSize = AppUtility().currentIndicatorSize(context);

    bool onTapped = false;
    double circleRating = 5;
    double starRating = 4.0;
    double avgRating = 0;
    product.hotel!.ratings?.forEach((e) => e.rating!.forEach((rating) {
          if (rating.name == "averageRating") {
            avgRating = rating.value;
          }
        }));
    List images = [];

    product.hotelContent!.images!.forEach((element) {
      if (images.length < 3) {
        images.add(element!.default2x!.url);
      }
    });

    List<String> amenities = [];

    List<String> amenitiesList = [];
    product.hotel!.hotelAttributes!.hotelAttributes!
        .forEach((e) => amenitiesList.add(e.label!));
    product.hotel!.hotelAttributes!.hotelAttributes!.forEach((e) {
      amenities.add(appUtility.getAmenities(e.label!).toString());
    });

    if (amenities.length < 5) {
      amenities = amenities;
    } else {
      amenities = amenities.take(5).toList();
    }
    var hotelDesc = "";

    return Container(
      // height: MediaQuery.of(context).size.height/2,
      //  height: 400,
      margin: EdgeInsets.only(bottom: 10, left: 13, right: 13, top: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          // border: Border.all(color: Colors.white, width: 1),
          //  borderRadius: BorderRadius.circular(20.0),
          shape: BoxShape.rectangle,
          boxShadow: boxShadow),
      child: Column(
        children: <Widget>[
          Container(
            child: SizedBox(
                height: AppUtility().isTablet(context)
                    ? MediaQuery.of(context).size.height * 0.25
                    : MediaQuery.of(context).size.height * 0.35,
                child: Stack(
                  children: [
                    Container(
                      // borderRadius: BorderRadius.only(
                      //     topLeft: Radius.circular(20.0),
                      //     topRight: Radius.circular(20.0)),

                      child: Container(
                          // onTap: () {
                          //   List<String> image = [];
                          //   product.hotelContent!.images!.forEach((element) {
                          //     image.add(element!.default2x!.url.toString());
                          //   });
                          // pushNewScreen(
                          //   context,
                          //   screen: GalleryImageView(image),
                          //   withNavBar:
                          //       false, // OPTIONAL VALUE. True by default.
                          //   pageTransitionAnimation:
                          //       PageTransitionAnimation.cupertino,
                          // );
                          // },
                          child: Carousel(
                              images: images
                                  .map((e) => AppUtility()
                                      .loadNetworkImage(e.toString()))
                                  .toList(),
                              indicatorSize: Size.square(indicatorSize),
                              indicatorActiveSize:
                                  Size(currentIndicatorSize, indicatorSize),
                              indicatorColor: Colors.grey,
                              indicatorActiveColor: Colors.white,
                              animationCurve: Curves.easeIn,
                              contentMode: BoxFit.cover,
                              //     contentMode: BoxFit.fitWidth,
                              autoPlay: false,
                              indicatorBackgroundColor: Colors.transparent,
                              bottomPadding: 20)),
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            left: 14,
                            right: MediaQuery.of(context).size.width * 0.01,
                            top: 13),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.transparent),
                        /*height: MediaQuery.of(context).size.height * 0.055,
                        width: MediaQuery.of(context).size.width * 0.12,*/
                        height: textFieldIconSize40,
                        width: textFieldIconSize40,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              onTapped = true;
                            });
                            if (!isInFavorites) {
                              addToFavorites(product, true);
                            } else {
                              addToFavorites(product, false);
                            }
                          },
                          child: Padding(
                              padding: EdgeInsets.all(0),
                              child: isInFavorites
                                  ? Image.asset(
                                      "assets/images/like-icon-active.png")
                                  : Image.asset(
                                      "assets/images/Like-btn-inactive.png")
                              // Icon(
                              //   product.topOffer.isInFavorites
                              //       ? Icons.favorite
                              //       : Icons.favorite_border,
                              //   color: Colors.red,
                              //   size: 20,
                              // ),
                              ),
                          // icon: Icon(
                          //   Icons.favorite,
                          //   color: onTapped != true
                          //       ? Colors.grey
                          //       : Uicolors.buttonbg,
                          // ),
                        )),
                  ],
                )),
          ),
          Container(
            child: Padding(
                padding: EdgeInsets.only(
                    left: 12,
                    right: MediaQuery.of(context).size.width * 0.005,
                    top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.01,
                              0,
                              0,
                              0),
                          child: Image.asset(
                            "assets/images/owl.png",
                            width: iconSize,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.01,
                              0,
                              0,
                              0),
                          child: RatingBar(
                            ignoreGestures: true,
                            initialRating: avgRating,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: backIconSize,
                            ratingWidget: RatingWidget(
                              full: _image('assets/images/fullround.png'),
                              half: _image('assets/images/halfround.png'),
                              empty: _image('assets/images/greyround.png'),
                            ),
                            itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                            onRatingUpdate: (rating) {
                              setState(() {
                                // here update the rating
                              });
                            },
                            updateOnDrag: true,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.01,
                              0,
                              0,
                              0),
                          child: Text(avgRating.toString(),
                              style: avgRatingTextStyle),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Text('/5', style: overallRatingStyle),
                        ),
                      ],
                    ),
                    if (product.hotel!.ratings != null)
                      Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.015),
                        child: GestureDetector(
                            onTap: () {
                              pushNewScreen(
                                context,
                                screen: AmenitiesList(gridItems: amenitiesList),
                                withNavBar: false,
                                // OPTIONAL VALUE. True by default.
                                pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                              );
                            },
                            child: Text(Strings.viewAmenities,
                                style: viewReviewStyle)),
                      )
                  ],
                )),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding:  EdgeInsets.only(left: 12, top: 8, right: 12),
            child: Text(product.hotel!.name ?? "", style: hotelNameStyle,maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 12, top: 5),
            child: Text(locationName, style: locationStyle),
          ),
          Stack(
            children: <Widget>[
              Container(
                child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      //   alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            Container(
                              padding:
                              EdgeInsets.only(left: 12),
                              child: Image.asset(
                                "assets/images/airport.png",
                                width: textFieldIconSize17,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width *
                                      0.010),
                              child: Text(
                                Strings.distanceToAirport +
                                    " - " +
                                    hotelContent +
                                    " Km",
                                style: distanceStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: AppUtility().isTablet(context)
                              ? 0
                              : 12,
                          right: AppUtility().isTablet(context)
                              ? 0
                              : 12,
                        ),
                        alignment: Alignment.center,
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
                    Align(
                      // alignment: Alignment.topRight,
                      child: GestureDetector(
                          onTap: () {
                            pushNewScreen(
                              context,
                              screen: SearchMap([product], "surroundings"),
                              withNavBar: false,
                              // OPTIONAL VALUE. True by default.
                              pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    left: AppUtility().isTablet(context)
                                        ? MediaQuery.of(context).size.width *
                                        0.001
                                        : MediaQuery.of(context).size.width *
                                        0.015,
                                    right: MediaQuery.of(context).size.width *
                                        0.020),
                                child: Image.asset(
                                  "assets/images/map.png",
                                  width: textFieldIconSize17,
                                ),
                              ),
                              Container(
                                child: Text(
                                  Strings.mapView,
                                  style: distanceStyle,
                                ),
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              )
            ],
          ),

          Container(
              // width: MediaQuery.of(context).size.width * 0.75,
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.020,
                  right: MediaQuery.of(context).size.width * 0.020,
                  bottom: 0,
                  top: MediaQuery.of(context).size.height * 0.010),
              child: Divider(
                color: Uicolors.desText,
                thickness: 0.5,
              )),
          Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.only(left: 12, right: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 0),
                  child: RatingBar(
                    ignoreGestures: true,
                    initialRating: product.hotel!.category!,
                    direction: Axis.horizontal,
                    //allowHalfRating: true,
                    itemCount: 5,
                    itemSize: backIconSize,
                    ratingWidget: RatingWidget(
                      full: _image('assets/images/star.png'),
                      half: _image('assets/images/halfround.png'),
                      empty: _image('assets/images/empty.png'),
                    ),
                    itemPadding: EdgeInsets.symmetric(
                        horizontal:
                            (AppUtility().isTablet(context) ? 2.0 : 1.0)),
                    onRatingUpdate: (rating) {
                      setState(() {
                        // here update the rating
                      });
                    },
                    updateOnDrag: true,
                  ),
                ),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.only(left: 0, right: 5),
                        alignment: Alignment.topRight,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 0, right: 3),
                                child: Text(
                                  "Price From",
                                  style: priceFromStyle,
                                ),
                              ),
                              Flexible(
                                //  padding: EdgeInsets.only(left: 0, right: 3),
                                child: Text(
                                  product.topOffer.price!.discountInfo != null
                                      ? product.topOffer.price!.discountInfo!
                                              .perNightFullAmount!
                                              .toInt()
                                              .toString() +
                                          " " +
                                          appUtility
                                              .getCurrentCurrency()
                                              .toString()
                                      : "",
                                  style: discountCrossStyle,
                                ),
                              ),
                              Container(
                                child: Text(
                                  product.topOffer.price!.amount
                                      .toInt()
                                      .toString(),
                                  style: priceTextStyle,
                                  softWrap: true,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  " " +
                                      appUtility
                                          .getCurrentCurrency()
                                          .toString(),
                                  style: dollerStyle,
                                ),
                              )
                            ]))),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                right: 12, bottom: AppUtility().isTablet(context) ? 0 : 8),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                Strings.exclTaxesFees,
                style: exclTaxStyle,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _image(String asset) {
    return Image.asset(
      asset,
      height: 0.5,
      width: 0.5,
      /*  height: 2,
      width: 2,*/
      // color: Colors.amber,
    );
  }

  void addToFavorites(
      ProductsQuery$Query$Products$PackageProducts product, bool isFav) async {
    var giataId = product.hotel!.giataId.toString();
    final User? user = auth.currentUser;
    if (user != null) {
      final userId = user.uid;
      var document = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      UserModel users =
          UserModel.fromJson(document.data() as Map<String, dynamic>);
      if (users.favourites != null && users.favourites.contains(giataId)) {
        int index =
            users.favourites.indexWhere((element) => element == giataId);
        users.favourites.removeAt(index);
      } else {
        if (users.favourites == null) {
          users.favourites = [];
        }
        users.favourites.add(giataId);
      }
      EasyLoading.show();
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(users.toJson())
          .then((value) {
        widget.favoritesFunc.call(isFav);
        widget.product.topOffer.isInFavorites = isFav;
        setState(() {
          isInFavorites = isFav;
        });
        GlobalState.favList = users.favourites;
        EasyLoading.dismiss();
      });
    } else {
      EasyLoading.dismiss();
      AppUtility().onWillLoginPop(context);
    }
  }

  void addToFavorites1(
      ProductsQuery$Query$Products$PackageProducts product, bool isFav) async {
    var proudctJson = product.toJson();
    CollectionReference addToFavoritesDetails =
        FirebaseFirestore.instance.collection('favoriteHotels');

    final User? user = auth.currentUser;
    //print("user:${user}");
    if (user != null) {
      final userId = user.uid;
      List<String> favUsers = [];
      if (proudctJson['favUsers'] != null) {
        favUsers = proudctJson['favUsers'];
      }
      if (!isFav) {
        favUsers.remove(userId.toString());
      } else {
        favUsers.add(userId.toString());
      }
      proudctJson['favUsers'] = favUsers;
      EasyLoading.show();
      // BuildContext? dialogContext;
      // AppUtility().showProgressDialog(context,type:null,dismissDialog:(value){
      //   dialogContext = value;
      // });
      await addToFavoritesDetails
          .doc(product.hotel!.giataId.toString())
          .set(proudctJson)
          .then((value) async {
        widget.favoritesFunc.call(isFav);
        widget.product.topOffer.isInFavorites = isFav;
        setState(() {
          isInFavorites = isFav;
        });
        EasyLoading.dismiss();
        // await new Future.delayed(const Duration(milliseconds: 500));
        // AppUtility().dismissDialog(dialogContext!);
      });
    } else {
      EasyLoading.dismiss();
      AppUtility().onWillLoginPop(context);
    }
  }

  @override
  void didUpdateWidget(covariant HotelList oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      isInFavorites = widget.product.topOffer.isInFavorites;
      descriptions = widget.product.hotel!.description ?? "";
    });
  }
}
