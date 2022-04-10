import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/models/surroundingModel.dart';
import 'package:jaz_app/utils/GlobalStates.dart';
import 'package:jaz_app/utils/carousel.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/http_client.dart';
import 'package:jaz_app/utils/uiconstants.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'galleryimageview.dart';
import 'mappage.dart';

class Surrounding extends StatefulWidget {
  final ProductsQuery$Query$Products$PackageProducts product;
  final String giataId;
  final String pageName;
  final String redirectionName;

  Surrounding(this.product, this.giataId, this.redirectionName, this.pageName);

  _SurroundingState createState() => _SurroundingState();
}

class _SurroundingState extends State<Surrounding>
    with TickerProviderStateMixin {
  AppUtility appUtility = AppUtility();
  HttpClient httpClient = HttpClient();
  List<SurroundingModel> surroundingList = [];
  var surroundingName = "";
  var surroundingDesc = "";

  // var backgroundImage = "";
  var initialIndexName = "";
  var initialIndexDesc = "";

  // late ProductsQuery$Query$Products$PackageProducts product;
  List<dynamic> backgroundImages = [];
  List<dynamic> descList = [];
  List<dynamic> productImages = [];
  List<dynamic> originalImages = [];
  BuildContext? dialogContext;
  int currentImageIndex = 0;
  bool isMap = false;
  late AnimationController _controller;
  var scale = 1.0;

  void initState() {
    super.initState();
    appUtility = AppUtility();
    _controller = AnimationController(
        upperBound: 0.1,
        lowerBound: 0.1,
        duration: const Duration(milliseconds: 1),
        vsync: this);
    _controller.repeat(reverse: true);
    getAppDetails();
  }

  getAppDetails() {
    getSurroundings();
    productImages =widget.product.hotelContent!.images!
        .map(
            (e) =>
            e!.default2x!.url.toString())
        .toList();
    originalImages =widget.product.hotelContent!.images!
        .map(
            (e) =>
            e!.original!.url.toString())
        .toList();

  }

  getSurroundings() async {
    setState(() {
      isMap = false;
    });
    HashMap<String, dynamic> params = HashMap();
    params.putIfAbsent("renderPage",
            () => "/hoteldetail/" + widget.giataId + "/" + widget.redirectionName);
    params.putIfAbsent("_locale", () => "en-gb");
    var response;
    EasyLoading.show(status: "Loading...");
    response = await httpClient.getRenderData(params, "/api/renders", null);
    if (response.statusCode == 200 && json.decode(response.body) != null) {
      EasyLoading.dismiss();
      var surroundingResponse = json.decode(response.body);
      convert(surroundingResponse);
    } else {
      EasyLoading.dismiss();
    }
  }

  convert(var surroundingResponse) {
    List<String> alternativeImages = [];

    setState(() {
      surroundingResponse["content"]["main"]["children"].forEach((surounding) {
        var result = surounding["module"]["result"];
        if (result["headlines"] != null || result["subheadline"] != null) {
          String headName = "";
          String headDesc = "";
          if (result["headlines"] != null && surroundingName == "") {
            //  &&surounding["module"]["result"]["subheadline"] != null) {
            surroundingName = result["headlines"]
                .map((e) => e["headline"].toString())
                .join(" & ");
          } else {
            headName = result["headlines"]
                .map((e) => e["headline"].toString())
                .join(" & ");
          }
          if (result["subheadline"] != null && surroundingDesc == "") {
            surroundingDesc =
                "<h1>" + result["subheadline"].toString() + "</h1>";
          } else {
            headDesc = result["subheadline"];
            if (headDesc == null) {
              headDesc = "";
            }
          }
          if (headDesc != "" || headName != "") {
            SurroundingModel surroundingModel = SurroundingModel(
                name: headName,
                description: "<h1>" + headDesc.toString() + "</h1>",
                imgUrls: [],
                isHeading: true);
            surroundingList.add(surroundingModel);
          }
          if (surounding["children"].length != 0) {
            if (surounding["children"][0]["module"]["result"]["text"] != null) {
              var str = surounding["children"][0]["module"]["result"]["text"]
                  .toString();
              var list = str.split("</li>");
              for (int i = 0; i < list.length; i++) {
                var str = appUtility
                    .parseHtmlString(list[i].toString())
                    .replaceAll("\n", "");
                if (str != "") {
                  descList.add(str);
                }
              }
            }
          }
        } else if (result["images"] != null &&
            result["headline"] == null &&
            result["text"] == null) {



          result["images"].forEach((imgs) {
            if (imgs["image"]["url"] != null) {
              backgroundImages
                  .add(AppUtility().getProxyImage(imgs));
              // backgroundImages
              //     .add(Uri.decodeFull(imgs["image"]["url"].toString()));

            }
          });
        } else {
          var name = result["headline"] != null ? result["headline"] : "";
          var desc = result["text"] != null ? result["text"] : "";
          List<String> imgUrls = [];
          if (result["images"] != null) {

            result["images"].forEach((subimg) {
              if (subimg["image"]["url"].toString() != "null") {
                String proxyImage = AppUtility().getProxyImage(subimg);
                imgUrls.add(proxyImage);
                alternativeImages.add(proxyImage);
                // imgUrls.add(subimg["image"]["url"].toString());
                // alternativeImages.add(subimg["image"]["url"].toString());
              }
            });
          }
          if (result["image"] != null) {
            var img = result["image"];
            if (img["url"].toString() != "null") {
              String proxyImage = AppUtility().getProxyImage(result);
              imgUrls.add(proxyImage);
              alternativeImages.add(proxyImage);
              // imgUrls.add(img["url"].toString());
              // alternativeImages.add(img["url"].toString());
            }
          }
          SurroundingModel surroundingModel = SurroundingModel(
              name: name,
              description: desc,
              imgUrls: imgUrls,
              isHeading: false);
          if (name != "" || desc != "" || imgUrls.length > 0)
            surroundingList.add(surroundingModel);
        }
      });
    });
    if (backgroundImages.length == 0 && alternativeImages.length > 0) {
      getBackgroundImages(alternativeImages);
    }
    if (surroundingList.length == 0 &&
        backgroundImages.length == 0 &&
        surroundingName == "" &&
        surroundingDesc == "") {
      isMap = true;
    } else {
      isMap = false;
      if (surroundingName == "") {
        surroundingName = widget.pageName;
      }
    }
    if (backgroundImages.length == 0 && !isMap) {
      getBackgroundImages(productImages);
    }
  }

  backRedirect() {
    Navigator.of(context, rootNavigator: true).pop(context);
  }

  @override
  dispose() {
    _controller.dispose(); // you need thissuper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.18;
    final double overAllHeight = MediaQuery.of(context).size.height;
    final double overAllWidth = MediaQuery.of(context).size.width;
    var topSpace = overAllHeight * 0.04;
    var backTopSpace = 0.0;
    var leftPadding = overAllWidth * 0.033;
    var topHeight = overAllHeight * 0.025;
    var backImageheight = overAllHeight * 0.48;
    var viewStartHeight = overAllHeight * 0.44;
    var contentLeftPadding = MediaQuery.of(context).size.width * 0.025;
    var bottomHeight = overAllHeight * 0.03;
    var camelBottomHeight = overAllHeight * 0.01;
    var imageHeight = MediaQuery.of(context).size.height * 0.35;
    var indicatorSize = AppUtility().indicaorSize(context);
    var currentIndicatorSize = AppUtility().currentIndicatorSize(context);

    return Scaffold(
      backgroundColor: Uicolors.backgroundColor,
      body: Stack(children: [
        isMap
            ? Container(
          child: MapPage([widget.product], "surroundings",overAllHeight * 0.25),
        )
            : Container(),
        !isMap
            ?
        SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ScaleTransition(
              scale: Tween(begin: 1.0, end: scale).animate(CurvedAnimation(
                  parent: _controller, curve: Curves.bounceOut)),
              child: new Stack(
                children: <Widget>[
                  backgroundImages.length > 0
                      ?
                  Container(
                    height: scale == 1
                        ? backImageheight
                        : overAllHeight * 0.58,
                    width: MediaQuery.of(context).size.width,
                    child: ClipRRect(
                        child: GestureDetector(
                          onHorizontalDragStart: (details) {
                          },
                          onVerticalDragUpdate: (dragDetails) {
                            setState(() {
                              scale = 1.2;
                              //     resetScale();
                            });
                          },
                          onVerticalDragEnd: (endDetails) {
                            setState(() {
                              scale = 1.2;
                              resetScale();
                            });
                          },
                          onTap: () {
                            List<String> image = [];
                            backgroundImages.forEach((element) {
                              image.add(element!.toString());
                            });
                            pushNewScreen(
                              context,
                              screen: GalleryImageView(
                                  image, currentImageIndex),
                              withNavBar: false,
                              // OPTIONAL VALUE. True by default.
                              pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Carousel(
                            images: backgroundImages
                                .map((e) =>
                                AppUtility().loadNetworkImage(e.toString())
                            ).toList(),
                            indicatorSize: Size.square(indicatorSize),
                            indicatorActiveSize:
                            Size(currentIndicatorSize, indicatorSize),
                            indicatorColor: Colors.grey,
                            indicatorActiveColor: Colors.white,
                            animationCurve: Curves.easeIn,
                            contentMode: BoxFit.cover,
                            autoPlay: false,
                            indicatorBackgroundColor: Colors.transparent,
                            bottomPadding: backgroundImages.length > 1
                                ? backImageheight / 8
                                : 0,
                            onImageChange: (index) {
                              currentImageIndex = index;
                            },
                          ),
                        )),
                  )
                      : Container(),
                  new Column(
                    children: [
                      surroundingName != ""
                          ? Container(
                        // height: MediaQuery.of(context).size.height/2,
                        //  height: 400,
                        margin: EdgeInsets.only(
                            top: scale == 1
                                ? viewStartHeight
                                : overAllHeight * 0.54,
                            left: leftPadding,
                            right: leftPadding,
                            bottom: descList.length > 0
                                ? bottomHeight
                                : 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: boxShadow,
                          // border: Border.all(color: Colors.white, width: 1),
                          // borderRadius:
                          //     BorderRadius.circular(containerBorderRadius),
                          // shape: BoxShape.rectangle,
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(
                                  left: contentLeftPadding,
                                  top: topHeight),
                              child: Text(surroundingName,
                                  style: hotelNameStyle),
                            ),
                            if (surroundingDesc == "")
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(
                                    left: contentLeftPadding,
                                    bottom: bottomHeight,
                                    right: contentLeftPadding),
                              ),
                            if (surroundingDesc != "")
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(
                                    left: contentLeftPadding,
                                    bottom: descList.length > 0
                                        ? 10
                                        : bottomHeight,
                                    right: contentLeftPadding),
                                child: Html(
                                  data: surroundingDesc,
                                  shrinkWrap: true,
                                  style: {
                                    "h1": h1Style,
                                    "p": paraStyle,
                                    "li": listStyle,
                                    'html': Style(
                                        textAlign: TextAlign.justify),
                                  },
                                ),
                              ),
                            if (descList.length > 0)
                              Container(
                                  margin: EdgeInsets.only(
                                      bottom: bottomHeight,
                                      left: leftPadding,
                                      right: leftPadding),
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                      NeverScrollableScrollPhysics(),
                                      // scrollDirection: Axis.vertical,
                                      itemCount: descList.length,
                                      itemBuilder: (context, index) {

                                        return Container(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .height *
                                                  0.005),
                                          child: Stack(
                                            children: [
                                              Container(
                                                alignment: Alignment
                                                    .centerLeft,
                                                padding: EdgeInsets.only(
                                                    left: MediaQuery.of(
                                                        context)
                                                        .size
                                                        .width *
                                                        0.01,
                                                    top: 7),
                                                child: Image.asset(
                                                  "assets/images/fullround.png",
                                                  width: 6,
                                                  color: Uicolors
                                                      .desText,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: MediaQuery.of(
                                                        context)
                                                        .size
                                                        .width *
                                                        0.05,
                                                    right: MediaQuery.of(
                                                        context)
                                                        .size
                                                        .width *
                                                        0.03),
                                                child: Text(
                                                    descList[index]
                                                        .toString(),
                                                    style:
                                                    descTextStyle),
                                              )
                                            ],
                                          ),
                                        );
                                      })),
                          ],
                        ),
                      )
                          : Container(),
                      surroundingName == ""
                          ? Container(
                        // height: MediaQuery.of(context).size.height/2,
                        //  height: 400,
                        margin: EdgeInsets.only(
                            top: viewStartHeight,
                            left: leftPadding,
                            right: leftPadding),
                      )
                          : Container(),
                      surroundingList.length > 0
                          ? Container(
                          margin: EdgeInsets.only(
                              bottom:
                              MediaQuery.of(context).size.height *
                                  .02,
                              left: leftPadding,
                              right: leftPadding),
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              // scrollDirection: Axis.vertical,
                              itemCount: surroundingList.length,
                              itemBuilder: (context, index) {
                                List<String> hotelImages=[];
                                var heading =
                                    surroundingList[index].name;
                                if (surroundingList[index].imgUrls!=
                                    null &&
                                    surroundingList[index]
                                        .imgUrls
                                        .length >
                                        0) {
                                  hotelImages =
                                      surroundingList[index].imgUrls;
                                } else {

                                }

                                var description =
                                    surroundingList[index].description;
                                bool isHeading =
                                    surroundingList[index].isHeading;


                                return Column(
                                  children: [
                                    isHeading
                                        ? Container(
                                      margin: EdgeInsets.only(
                                        top: topHeight,
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          heading != "" &&
                                              heading !=
                                                  "null"
                                              ? Container(
                                            color: Colors
                                                .white,
                                            alignment:
                                            Alignment
                                                .center,
                                            padding: EdgeInsets
                                                .only(
                                                top: 10,
                                                bottom:
                                                10),
                                            child: Text(
                                                heading
                                                    .toUpperCase(),
                                                style:
                                                dinnTextStyle),
                                          )
                                              : Container(),
                                          description != "" &&
                                              description !=
                                                  "null"
                                              ? Container(
                                            alignment:
                                            Alignment
                                                .center,
                                            padding: EdgeInsets.only(
                                                left:
                                                contentLeftPadding,
                                                right:
                                                contentLeftPadding),
                                            child: Html(
                                              data:
                                              description,
                                              shrinkWrap:
                                              true,
                                              style: {
                                                "h1":
                                                h1Style,
                                                "p":
                                                paraStyle,
                                                "li":
                                                listStyle,
                                                'html': Style(
                                                    textAlign:
                                                    TextAlign.justify),
                                                'ul': Style(
                                                    margin: EdgeInsets.symmetric(
                                                        horizontal:
                                                        0,
                                                        vertical:
                                                        0))
                                              },
                                            ),
                                          )
                                              : Container(),
                                        ],
                                      ),
                                    )
                                        : Container(),
                                    !isHeading
                                        ? Container(
                                      margin: EdgeInsets.only(
                                        top: topHeight,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: boxShadow,
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          heading != "" &&
                                              heading !=
                                                  "null"
                                              ? Container(
                                            alignment: Alignment
                                                .centerLeft,
                                            padding: EdgeInsets.only(
                                                left:
                                                contentLeftPadding,
                                                top:
                                                topHeight),
                                            child: Text(
                                                heading,
                                                style:
                                                hotelNameStyle),
                                          )
                                              : Container(),
                                          // if (heading != "" && heading!="null")
                                          //   Container(
                                          //     padding: EdgeInsets.only(
                                          //       left: contentLeftPadding,
                                          //       right: contentLeftPadding,
                                          //     ),
                                          //     child: Divider(
                                          //       color: Uicolors.desText,
                                          //       thickness: 0.5,
                                          //     ),
                                          //   ),
                                          description != "" &&
                                              description !=
                                                  "null"
                                              ? Container(
                                            alignment: Alignment
                                                .centerLeft,
                                            padding: EdgeInsets.only(
                                                left:
                                                contentLeftPadding,
                                                bottom: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    0.02,
                                                top: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    0.010,
                                                right:
                                                contentLeftPadding),
                                            child: Html(
                                              data:
                                              description,
                                              shrinkWrap:
                                              true,
                                              style: {
                                                "h1":
                                                h1Style,
                                                "p":
                                                paraStyle,
                                                "li":
                                                listStyle,
                                                'html': Style(
                                                    textAlign:
                                                    TextAlign.justify),
                                                'ul': Style(
                                                    margin: EdgeInsets.symmetric(
                                                        horizontal:
                                                        0,
                                                        vertical:
                                                        0))
                                              },
                                            ),
                                          )
                                              : Container(),

                                          surroundingList[
                                          index]
                                              .imgUrls != null &&
                                              surroundingList[
                                              index]
                                                  .imgUrls
                                                  .length >
                                                  0
                                              ? showHotelImages(
                                              index,
                                              imageHeight,hotelImages)
                                              : Container()
                                        ],
                                      ),
                                    )
                                        : Container(),
                                  ],
                                );
                              }))
                          : Container(),
                      surroundingName.isNotEmpty && widget.pageName=="Surroundings"?
                     SingleChildScrollView(
                      child:Container(
                        height:
                        backImageheight,
                        child: MapPage([widget.product], "surroundings",overAllHeight * 0.15),
                      )):Container()
                    ],
                  )
                ],
              ),
            ))
            : Container()
      ]),
    );
  }

  @override
  void didUpdateWidget(covariant Surrounding oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageName != widget.pageName) {
      setState(() {
        surroundingList = [];
        surroundingName = "";
        surroundingDesc = "";
        initialIndexName = "";
        initialIndexDesc = "";
        backgroundImages = [];
        descList = [];
        productImages = [];
      });
      getAppDetails();
    }
  }

  void resetScale() {
    Future.delayed(Duration(milliseconds: 20), () {
      setState(() {
        scale = 1.0;
      });
    });
  }

  void getBackgroundImages(List images) {
    images.forEach((element) {
      if (element != null && element != "null") {
        backgroundImages.add(element.toString());
      }
    });
  }

  showHotelImages(int index, imageHeight,hotelImages) {
    // List<String> hotelImages = [];
    /* if (surroundingList[index].imgUrls != null &&
        surroundingList[index].imgUrls.length > 0) {
      surroundingList[index].imgUrls.forEach((element) {
        if (element != null && element != "null") {
          hotelImages.add(Uri.encodeFull(element.toString()));
          print("hotel images uri added ${hotelImages.toString()}");
        }
      });
    }*/

    if (hotelImages != null && hotelImages.length > 0) {
      return Container(
        height: imageHeight,
        width: MediaQuery.of(context).size.width,
        child: ClipRRect(
          child: Carousel(
            images: hotelImages
                .map((e) =>
                AppUtility().loadNetworkImage(e.toString())
            )
                .toList(),
            indicatorSize: const Size.square(8.0),
            indicatorActiveSize: const Size(30.0, 8.0),
            indicatorColor: Colors.grey,
            indicatorActiveColor: Colors.white,
            animationCurve: Curves.easeIn,
            contentMode: BoxFit.cover,
            autoPlay: false,
            indicatorBackgroundColor: Colors.transparent,
            bottomPadding: 20,
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
