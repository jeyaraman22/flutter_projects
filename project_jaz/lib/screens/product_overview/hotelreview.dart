// import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter_bloc/graphql_flutter_bloc.dart';
import 'package:jaz_app/bloc/get_hotel_review_bloc.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/models/reviewPageModel.dart';
import 'package:jaz_app/screens/bottomnavigation/bottombar.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/carousel.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/strings.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/uiconstants.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../graphql_provider.dart';
// import 'package:url_launcher/url_launcher.dart';

class HotelReview extends StatefulWidget {
  final ProductsQuery$Query$Products$PackageProducts product;

  HotelReview(this.product);

  _HotelReviewState createState() => _HotelReviewState();
}

class _HotelReviewState extends State<HotelReview> {
  var timeDetails;
  List ratingList = [];
  late GetHotelReviewBloc bloc;
  late ProductsQuery$Query$Products$PackageProducts product;
  bool descTextShowFlag = false;
  var ratingProductId;
  var logoUrl;
  double avgRating = 0;

  void initState() {
    super.initState();
    product = widget.product;
    widget.product.hotel!.ratings!.forEach((element) {
      ratingProductId = element.providerProductId.toString();
      ratingList.addAll(element.rating!);
    });
    product.hotelContent!.logo!.sizes!.forEach((element) {
      logoUrl = element!.url;
    });

    product.hotel!.ratings?.forEach((e) => e.rating!.forEach((rating) {
          if (rating.name == "averageRating") {
            avgRating = rating.value;
          }
        }));
    ReviewsFilter filter = ReviewsFilter();
    filter.ratingProductId = ratingProductId;
    PagingInput paging = PagingInput(resultsPerPage: 5, page: 1);
    GetHotelReviewsArguments args =
        GetHotelReviewsArguments(filter: filter, paging: paging);

    bloc = GetHotelReviewBloc(client: client)..run(variables: args.toJson());
  }

  @override
  Widget build(BuildContext context) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;

    //Fist container
    var backImageheight = overAllHeight * 0.5;
    var iconLeftPadding = overAllWidth * 0.005;
    var iconOwlLeftPadding = overAllWidth * 0.035;
    var iconOwlTopPadding = overAllHeight * 0.02;
    var iconRatingLeftPadding = overAllWidth * 0.015;
    var contentTopPadding = overAllHeight * 0.01;
    var imageContainerTopTextPadding = overAllHeight * 0.42;
    var commonContainerWidthPadding = overAllWidth * 0.035;
    var logoTopPadding = overAllHeight * 0.35;

    var owlLeftToRightTextPadding = overAllWidth * 0.21;
    var contentFieldRightPadding = overAllWidth * 0.05;
    var containerTopTextPadding = overAllHeight * 0.405;

    var leftPadding = overAllWidth * 0.033;
    var bottomHeight = overAllHeight * 0.03;

    var indicatorSize = AppUtility().indicaorSize(context);
    var currentIndicatorSize = AppUtility().currentIndicatorSize(context);

    return Scaffold(
      backgroundColor: Uicolors.backgroundColor,
      appBar: AppBar(
        toolbarHeight:
            AppUtility().isTablet(context) ? 80 : AppBar().preferredSize.height,
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
                      padding: EdgeInsets.only(
                        left: iconLeftPadding,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Uicolors.buttonbg,
                        size: backIconSize,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop(context);
                    },
                    child: Text(Strings.back, style: backStyle),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: new Stack(
          children: <Widget>[
            Container(
              height: backImageheight,
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                  child: Stack(
                children: [
                  Carousel(
                    images: product.hotelContent!.images!
                        .map((e) =>
                  AppUtility().loadNetworkImage(e!.default2x!.url.toString()))
                        .toList(),
                    indicatorSize: Size.square(indicatorSize),
                    indicatorActiveSize:
                        Size(currentIndicatorSize, indicatorSize),
                    indicatorColor: Colors.grey,
                    indicatorActiveColor: Colors.white,
                    animationCurve: Curves.easeIn,
                    contentMode: BoxFit.cover,
                    autoPlay: false,
                    indicatorBackgroundColor: Colors.transparent,
                    bottomPadding: backImageheight / 4,
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(
                  //       left: iconRatingLeftPadding, top: logoTopPadding),
                  //   child: Image.network(
                  //     logoUrl,
                  //     //color: Colors.white,
                  //     height: 50,
                  //     width: 100,
                  //   ),
                  // ),
                ],
              )),
            ),
            new Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                      top: imageContainerTopTextPadding,
                      left: commonContainerWidthPadding,
                      right: commonContainerWidthPadding,
                      bottom: iconOwlTopPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(color: Colors.white, width: 1),
                    // borderRadius: BorderRadius.circular(containerBorderRadius),
                    boxShadow: boxShadow,
                    shape: BoxShape.rectangle,
                  ),
                  child: Container(
                    // height: firstContainerTopTextPadding,
                    child: Column(
                      // physics: NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: iconOwlLeftPadding,
                                right: iconOwlLeftPadding,
                                top: iconOwlTopPadding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                    child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/images/owl.png",
                                      width: iconSize,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: iconRatingLeftPadding,
                                      ),
                                      child: RatingBar(
                                        ignoreGestures: true,
                                        initialRating: avgRating,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: backIconSize,
                                        ratingWidget: RatingWidget(
                                          full: _image(
                                              'assets/images/fullround.png'),
                                          half: _image(
                                              'assets/images/halfround.png'),
                                          empty: _image(
                                              'assets/images/greyround.png'),
                                        ),
                                        itemPadding: EdgeInsets.symmetric(
                                            horizontal: 1.0),
                                        onRatingUpdate: (rating) {
                                          setState(() {
                                            // here update the rating
                                          });
                                        },
                                        updateOnDrag: true,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: iconRatingLeftPadding),
                                      child: Text(avgRating.toString(),
                                          style: avgRatingTextStyle),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child:
                                          Text("/5", style: overallRatingStyle),
                                    ),
                                  ],
                                )),
                                Container(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/owl.png",
                                          width: iconSize,
                                        ),
                                        Text(Strings.tripAdviser,
                                            style: tripAdvisorTextStyle)
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(
                              bottom: bottomHeight,
                            ),
                            // height: containerTopTextPadding,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: ratingList.length,
                              itemBuilder: (BuildContext context, int index) {
                                // bool check = index == subTitles.length - 1;
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(
                                          top: contentTopPadding,
                                          right: commonContainerWidthPadding,
                                          left: commonContainerWidthPadding,
                                          bottom: contentTopPadding,
                                        ),
                                        child: Divider(
                                          color: Uicolors.greyText,
                                          thickness: 0.5,
                                        )),
                                    Stack(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Align(
                                          child: Stack(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                    left: iconOwlLeftPadding),
                                                child: Text(
                                                    ratingList[index]
                                                        .name
                                                        .toString()
                                                        .capitalize(),
                                                    style: overallRatingStyle),
                                              ),
                                              //   if (check == true)
                                              //     Container(height: bottomHeight),
                                            ],
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                        Align(
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                right:
                                                    contentFieldRightPadding),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: iconRatingLeftPadding,
                                                  ),
                                                  child: RatingBar(
                                                    ignoreGestures: true,
                                                    initialRating:
                                                        ratingList[index].value,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemSize: backIconSize,
                                                    ratingWidget: RatingWidget(
                                                      full: _image(
                                                          'assets/images/fullround.png'),
                                                      half: _image(
                                                          'assets/images/halfround.png'),
                                                      empty: _image(
                                                          'assets/images/greyround.png'),
                                                    ),
                                                    itemPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 1.0),
                                                    onRatingUpdate: (rating) {
                                                      setState(() {
                                                        // here update the rating
                                                      });
                                                    },
                                                    updateOnDrag: false,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left:
                                                          iconRatingLeftPadding),
                                                  child: Text(
                                                      ratingList[index]
                                                          .value
                                                          .toString(),
                                                      style: descTextStyle),
                                                ),
                                              ],
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                            ),
                                          ),
                                          alignment: Alignment.topRight,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            )),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      bottom: bottomHeight,
                      left: leftPadding,
                      right: leftPadding),
                  child: BlocBuilder<GetHotelReviewBloc,
                      QueryState<GetHotelReviews$Query>>(
                    bloc: bloc,
                    builder: (_, state) {
                      // if (state is! QueryStateRefetch) {
                      //   _handleRefreshEnd();
                      // }
                      return state.when(
                        initial: () => Container(),
                        loading: (_) =>
                            Center(child: CircularProgressIndicator()),
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
                        loaded: _displayResult,
                        refetch: _displayResult,
                        fetchMore: _displayResult,
                      );
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: bottomHeight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayResult(
    GetHotelReviews$Query? data,
    QueryResult? result,
  ) {
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    double avgRating = 0;
    //Fist container
    var iconOwlLeftPadding = overAllWidth * 0.035;
    var iconOwlTopPadding = overAllHeight * 0.02;
    var iconRatingLeftPadding = overAllWidth * 0.015;
    var contentTopPadding = overAllHeight * 0.01;
    var bottomHeight = overAllHeight * 0.03;
    //List container
    var titleLeftTextPadding = overAllWidth * 0.01;
    var reviewedTextPadding = overAllWidth * 0.18;
    if (data == null) {
      return Container();
    } else {
      var item = data.reviews!.list;
      if (item!.length == 0) {
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
        return Container(
            child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                // scrollDirection: Axis.vertical,
                itemCount: item.length,
                itemBuilder: (context, index) {
                  final reviewData = item[index];
                  return Container(
                      margin: EdgeInsets.only(
                          top: contentTopPadding,
                          // left: commonContainerWidthPadding,
                          // right: commonContainerWidthPadding,
                          bottom: iconOwlTopPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // border: Border.all(color: Colors.white, width: 1),
                        // borderRadius:
                        //     BorderRadius.circular(containerBorderRadius),
                        boxShadow: boxShadow,
                        shape: BoxShape.rectangle,
                      ),
                      child: Column(
                        children: [
                          Container(
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: iconOwlLeftPadding,
                                    right: iconOwlLeftPadding,
                                    top: iconOwlTopPadding),
                                child: Column(
                                  children: [
                                    Container(
                                        child: Container(
                                            child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            children: <Widget>[
                                              Image.asset(
                                                "assets/images/owl.png",
                                                width: iconSize,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: iconRatingLeftPadding,
                                                ),
                                                child: RatingBar(
                                                  ignoreGestures: true,
                                                  initialRating: double.parse(
                                                      reviewData!.ratingAllOver
                                                          .toString()),
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: true,
                                                  itemCount: 5,
                                                  itemSize: backIconSize,
                                                  ratingWidget: RatingWidget(
                                                    full: _image(
                                                        'assets/images/fullround.png'),
                                                    half: _image(
                                                        'assets/images/halfround.png'),
                                                    empty: _image(
                                                        'assets/images/greyround.png'),
                                                  ),
                                                  itemPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 1.0),
                                                  onRatingUpdate: (rating) {
                                                    setState(() {
                                                      // here update the rating
                                                    });
                                                  },
                                                  updateOnDrag: true,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left:
                                                        iconRatingLeftPadding),
                                                child: Text(
                                                    reviewData.ratingAllOver
                                                        .toString(),
                                                    style: avgRatingTextStyle),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 0, 0),
                                                child: Text("/5",
                                                    style: overallRatingStyle),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                            alignment: Alignment.centerRight,
                                            // padding: EdgeInsets.only(
                                            //     left:
                                            //     reviewedTextPadding),
                                            child: Text(
                                                Strings.reviewed +
                                                    '\t' +
                                                    reviewData.monthOfTravel
                                                        .toString() +
                                                    "." +
                                                    reviewData.yearOfTravel
                                                        .toString(),
                                                style: descTextStyle)),
                                      ],
                                    ))),
                                    Container(
                                        margin: EdgeInsets.only(
                                          top: contentTopPadding,
                                        ),
                                        child: Divider(
                                          color: Uicolors.greyText,
                                          thickness: 0.5,
                                        )),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          left: titleLeftTextPadding),
                                      child: Text(
                                          reviewData.firstName.toString(),
                                          style: hotelNameStyle),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          left: titleLeftTextPadding, top: 0),
                                      child: Text(
                                          reviewData.headline.toString(),
                                          style: subTitleTextStyle),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          left: titleLeftTextPadding,
                                          bottom: bottomHeight,
                                          top: contentTopPadding,
                                          right: titleLeftTextPadding),
                                      child: Text(
                                          reviewData.conclusion.toString(),
                                          style: descTextStyle),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 0,
                                          right: 0,
                                          top: 0,
                                          bottom: iconOwlTopPadding),
                                      alignment: Alignment.topRight,
                                      child: GestureDetector(
                                        onTap: () async {
                                          var url = reviewData.fullReviewUrl
                                              .toString();
                                          if (await canLaunch(url)) {
                                            await launch(
                                              url,
                                              forceSafariVC: false,
                                              forceWebView: false,
                                              headers: <String, String>{
                                                'my_header_key':
                                                    'my_header_value'
                                              },
                                            );
                                          } else {
                                            throw 'Could not launch';
                                          }
                                        },
                                        child: Text(
                                          Strings.readMore,
                                          style: viewMore,
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ));
                }));
      }
    }
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
}
