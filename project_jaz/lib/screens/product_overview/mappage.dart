import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jaz_app/helper/utils.dart';
import 'package:jaz_app/models/graphql/graphql_api.graphql.dart';
import 'package:jaz_app/utils/commonutils.dart';
import 'package:jaz_app/utils/fontText.dart';
import 'package:jaz_app/utils/colors.dart' as Uicolors;
import 'package:jaz_app/utils/strings.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'overviewbottombarscreen.dart';
import 'package:flutter/gestures.dart';


class MapPage extends StatefulWidget {
  final List<ProductsQuery$Query$Products$PackageProducts> list;
  final String redirectPageName;
  final double mapHeight;

  MapPage(this.list, this.redirectPageName, this.mapHeight);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _controller;

  //late GoogleMapController googleMapController;

  bool searchTap = false;
  double zoom = 17.0;
  ui.Image? _image;
  ui.Image? _image1;
  var hotelName = "";
  var imageUrl = "";
  var pageName;
  bool isOnTap = false;
  double avgRating = 3;
  var categoryName;
  ProductsQuery$Query$Products$PackageProducts? product;

  void _onMapCreated(GoogleMapController controller) {
    //   _controller.complete(controller);
  }

  late ClusterManager _manager;

  // Completer<GoogleMapController> _controller = Completer();

  Set<Marker> markers = Set();

  var lat = 0.0;
  var lng = 0.0;
  CameraPosition _parisCameraPosition =
  CameraPosition(target: LatLng(0, 0 /*48.856613, 2.352222*/), zoom: 17);

  List<Place> items = [];
  List<String> amenities = [];

  @override
  void initState() {
    super.initState();
    pageName = widget.redirectPageName;
    this.setState(() {
      zoom = (pageName == "surroundings") ? 17.0 : 14.0;
    });
    if (widget.list != null && widget.list.length > 0) {
      lat = widget.list[0].hotel!.location!.geoCode!.latitude.toDouble();
      lng = widget.list[0].hotel!.location!.geoCode!.longitude.toDouble();
      for (var location in widget.list) {
        hotelName = location.hotel!.name.toString() +
            ", " +
            location.hotel!.location!.country.name.toString() +
            ", " +
            location.hotel!.location!.city!.name.toString();
        items.add(Place(
            name: location.hotel!.name.toString(),
            amount: location.topOffer
                .price!.amount
                .toInt()
                .toString(),
            latLng: LatLng(
                location.hotel!.location!.geoCode!.latitude.toDouble(),
                location.hotel!.location!.geoCode!.longitude.toDouble()),
            locationDetails: location));
        // priceTags.add(location.topOffer.price!.amount);
      }
    }
    _parisCameraPosition = CameraPosition(
        target: LatLng(lat, lng /*48.856613, 2.352222*/), zoom: zoom);
    _manager = _initClusterManager();
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<Place>(items, _updateMarkers,
        markerBuilder: _markerBuilder);
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      this.markers = markers;
    });
  }

  Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
          (cluster) async {
        return Marker(
          onTap: () async{
            if (pageName == "surroundings") {
              var url = "";
              var urlAppleMaps;
              var latitute = widget.list[0].hotel!.location!.geoCode!.latitude.toDouble();
              var lontitute = widget.list[0].hotel!.location!.geoCode!.longitude.toDouble();
              print("$latitute $lontitute");
              if (Platform.isAndroid) {
                url = 'https://www.google.com/maps/search/?api=1&query=$latitute,$lontitute';
              } else {
                urlAppleMaps = 'https://maps.apple.com/?q=$latitute,$lontitute';
                url =
                'comgooglemaps://?saddr=&daddr=$latitute,$lontitute&directionsmode=driving';
                if (await canLaunch(url)) {
            await launch(url);
            } else if (await canLaunch(urlAppleMaps)) {
            await launch(urlAppleMaps);
            } else {
            throw 'Could not launch $url';
            }
            }
            }else if (widget.redirectPageName == "listPage" && !cluster.isMultiple) {
              cluster.items.forEach((element) {
                product = element.locationDetails;
                hotelName = element.locationDetails.hotel!.name!;
                imageUrl = element
                    .locationDetails.hotelContent!.images![0]!.kw$default!.url!
                    .toString();
                element.locationDetails.hotel!.ratings
                    ?.forEach((e) => e.rating!.forEach((rating) {
                  if (rating.name == "averageRating") {
                    avgRating = rating.value;
                  }
                }));
                // categoryName = element.locationDetails.hotel!.category;

                List<String> amenitiesList = [];
                element.locationDetails.hotel!.hotelAttributes!.hotelAttributes!
                    .forEach((e) => amenitiesList.add(e.label!));
                element.locationDetails.hotel!.hotelAttributes!.hotelAttributes!
                    .forEach((e) {
                  amenities.add(AppUtility().getAmenities(e.label!).toString());
                });

                if (amenities.length < 5) {
                  amenities = amenities;
                } else {
                  amenities = amenities.take(5).toList();
                }
              });
              if (!isOnTap) {
                setState(() {
                  isOnTap = true;
                });
              }
            }
          },
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          visible: true,
          icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 0,
              text: cluster.isMultiple ? cluster.count.toString() : null,
              name: cluster.items),
        );
      };

  Future<BitmapDescriptor> _getMarkerBitmap(int size,
      {String? text, required Iterable<Place> name}) async {
    if (kIsWeb) size = (size / 2).floor();
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.grey;
    String tempValue = "";
    String hotelName = "";
    String categoryName = '';
    name
      ..forEach((p) {
        tempValue = p.amount;
        hotelName = p.name;
      });
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    var width = size;
    var height = size;
    double borderWidth = 10.0;
    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr,maxLines: 1);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    } else {
      var paints = Paint()
        ..color = Uicolors.buttonbg
        ..style = PaintingStyle.fill
        ..strokeWidth = borderWidth;

      width = AppUtility().isTablet(context) ? 250 : 250;
      height = AppUtility().isTablet(context) ? 165 : 165;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Offset(0, height / 2) &
              Size(width.toDouble(), height.toDouble() / 2),
              Radius.circular(15.0)),
          paints);
      //canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint2);
      // _loadImage.call();

      //TriAngle Merge
      ByteData bd1 = await rootBundle.load("assets/images/map-badge-arrow.png");
      final Uint8List bytes1 = Uint8List.view(bd1.buffer);
      final ui.Codec codec1 = await ui.instantiateImageCodec(bytes1);
      _image1 = (await codec1.getNextFrame()).image;
      canvas.drawImage(
          _image1!,
          Offset(AppUtility().isTablet(context) ? 100 : 100,
              AppUtility().isTablet(context) ? 60 : 60),
          Paint());

      //Bed Icon
      ByteData bd = await rootBundle.load("assets/images/hotel_bedImages.png");
      final Uint8List bytes = Uint8List.view(bd.buffer);
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      _image = (await codec.getNextFrame()).image;
      canvas.drawImage(
          _image!,
          Offset(width / 9.3,
              height / (AppUtility().isTablet(context) ? 1.5 : 1.55)),
          Paint());

      //show the drawable
      TextPainter painter = TextPainter(
        textAlign: TextAlign.end,
        textDirection: TextDirection.ltr,
      );
      painter.text = TextSpan(
        // text: pageName == "surroundings"
        //     ? "Hotel"
        //     :(hotelName.length>8? hotelName.substring(0,8) : hotelName)+"...",
         text: (hotelName.length>8? hotelName.substring(0,8) : hotelName)+"...",
        style: usDollarTextStyle,
      );
      Offset position = Offset(
        85,
        height / 1.55,
      );
      painter.layout();
      painter.paint(canvas, position);
    }

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final double overAllWidth = MediaQuery.of(context).size.width;
    final double overAllHeight = MediaQuery.of(context).size.height;

    Widget _image(String asset) {
      return Image.asset(asset, height: 0.5, width: 0.5);
    }
    Widget showRatingBar(){
      return  Container(
          alignment: Alignment.topLeft,

          child:
          RatingBar(
            ignoreGestures: true,
            initialRating: product!
                .hotel!.category!,
            direction:
            Axis.horizontal,
            //allowHalfRating: true,
            itemCount: 5,
            itemSize: backIconSize,
            ratingWidget:
            RatingWidget(
              full: _image(
                  'assets/images/star.png'),
              half: _image(
                  'assets/images/halfround.png'),
              empty: _image(
                  'assets/images/empty.png'),
            ),
            itemPadding: EdgeInsets.symmetric(
                horizontal: (AppUtility()
                    .isTablet(
                    context)
                    ? 1.0
                    : 1.0)),
            onRatingUpdate:
                (rating) {
              setState(() {
                // here update the rating
              });
            },
            updateOnDrag: true,
          )
      );

    }

    getOverView(ProductsQuery$Query$Products$PackageProducts product,
        String giataId) async {
      try {
        EasyLoading.show();
        HashMap<String, dynamic> overViewResponse =
        await CommonUtils().getOverView(giataId);
        EasyLoading.dismiss();
        if (overViewResponse["overViewResponseCode"] == Strings.failure ||
            overViewResponse["descResponseCode"] == Strings.failure) {
          pushNewScreen(
            context,
            screen: OverviewBottombarScreen(
                0,
                HashMap(),
                product,
                "",
                []),
            //OverViewBottomBar(0, listPage, product,description,expansionList),
            withNavBar: false,
            // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        } else {
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
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _parisCameraPosition,
          markers: markers,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          rotateGesturesEnabled: true,

          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            //     _controller.complete(controller);
            _manager.setMapId(controller.mapId);
          },
          onCameraMove: _manager.onCameraMove,
          onCameraIdle: _manager.updateMap,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
            Factory<OneSequenceGestureRecognizer>(
              // () => ScaleGestureRecognizer(),
                  () => HorizontalDragGestureRecognizer(),
            ),
          ].toSet(),
        ),
        isOnTap
            ? Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: (){
                    getOverView(
                        product!,
                        product!.hotel!
                            .giataId
                            .toString());
                  },child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // border: Border.all(color: Colors.white, width: 1),
                      // borderRadius:
                      //     BorderRadius.circular(containerBorderRadius),
                      boxShadow: boxShadow,
                      shape: BoxShape.rectangle,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: AppUtility().isTablet(context) ? overAllHeight* 0.01 : -4,
                          right: AppUtility().isTablet(context) ?  overAllHeight* 0.02 : -4,
                          child:
                          Container(

                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  isOnTap = false;
                                });
                              },
                              icon: Icon(
                                Icons.close,
                                size:AppUtility().isTablet(context) ? 25 : 18,
                              ),
                            ),
                          ),

                        ),
                        Container(
                          margin: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.03),
                          child:
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,

                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: AppUtility().isTablet(context)
                                    ? MediaQuery.of(context).size.width *
                                    0.40
                                    : MediaQuery.of(context).size.width *
                                    0.35,
                                height:
                                MediaQuery.of(context).size.height *
                                    0.25,
                                child:
                                Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                    margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                                    alignment: Alignment.center,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            child: Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                      EdgeInsets.fromLTRB(
                                                          0, 0, 0, 0),
                                                      child: Image.asset(
                                                        "assets/images/owl.png",
                                                        width: iconSize,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      EdgeInsets.fromLTRB(
                                                          MediaQuery.of(
                                                              context)
                                                              .size
                                                              .width *
                                                              0.015,
                                                          0,
                                                          0,
                                                          0),
                                                      child: RatingBar(
                                                        ignoreGestures: true,
                                                        initialRating:
                                                        avgRating,
                                                        direction:
                                                        Axis.horizontal,
                                                        allowHalfRating: true,
                                                        itemCount: 5,
                                                        itemSize: backIconSize,
                                                        ratingWidget:
                                                        RatingWidget(
                                                          full: _image(
                                                              'assets/images/fullround.png'),
                                                          half: _image(
                                                              'assets/images/halfround.png'),
                                                          empty: _image(
                                                              'assets/images/greyround.png'),
                                                        ),
                                                        itemPadding: EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                            1.0),
                                                        onRatingUpdate:
                                                            (rating) {
                                                          setState(() {
                                                            // here update the rating
                                                          });
                                                        },
                                                        updateOnDrag: true,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      EdgeInsets.fromLTRB(
                                                          MediaQuery.of(
                                                              context)
                                                              .size
                                                              .width *
                                                              0.015,
                                                          0,
                                                          0,
                                                          0),
                                                      child: Text(
                                                          avgRating.toString(),
                                                          style:
                                                          avgRatingTextStyle),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      EdgeInsets.fromLTRB(
                                                          0, 0, 0, 0),
                                                      child: Text("/5",
                                                          style:
                                                          overallRatingStyle),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            )
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.only(
                                            top: overAllHeight * 0.015,
                                          ),
                                          child: Text(hotelName,
                                              softWrap: true,
                                              maxLines: 2,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style: AppUtility()
                                                  .isTablet(context)
                                                  ? hotelNameStyle
                                                  : expansionTitleStyle),
                                        ),
                                        if (amenities.length > 0)
                                          Container(
                                            margin: EdgeInsets.only(
                                              top: overAllHeight * 0.015,
                                            ),
                                            height: iconSize,
                                            child: Row(
                                              children: [
                                                Container(
                                                    alignment: Alignment
                                                        .centerLeft,
                                                    child:
                                                    ListView.builder(
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                      Axis.horizontal,
                                                      itemCount: amenities
                                                          .length,
                                                      itemBuilder:
                                                          (BuildContext
                                                      context,
                                                          int index) {
                                                        return Container(
                                                            padding: EdgeInsets
                                                                .only(
                                                                right:
                                                                15),
                                                            child: Image
                                                                .asset(
                                                              amenities[
                                                              index],
                                                              width:
                                                              iconSize,
                                                              height:
                                                              iconSize,
                                                              color: Uicolors
                                                                  .buttonbg,
                                                            ));
                                                      },
                                                    )),
                                              ],
                                            ),
                                          ),
                                        Container(

                                          child:
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                  margin: EdgeInsets.only(
                                                    top: overAllHeight * 0.015,
                                                  ),
                                                  child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                            "Price From ",
                                                            style:
                                                            AppUtility().isTablet(context) ?   priceFromStyle : filterStyle,
                                                          ),
                                                        ),
                                                        Container(
                                                          //  padding: EdgeInsets.only(left: 0, right: 3),
                                                          child: Text(
                                                            product!
                                                                .topOffer
                                                                .price!
                                                                .discountInfo !=
                                                                null
                                                                ? product!
                                                                .topOffer
                                                                .price!
                                                                .discountInfo!
                                                                .perNightFullAmount!
                                                                .toInt()
                                                                .toString() +
                                                                " " +
                                                                AppUtility()
                                                                    .getCurrentCurrency()
                                                                    .toString()
                                                                : "",
                                                            style:
                                                            discountCrossStyle,
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Text(
                                                            product!.topOffer
                                                                .price!.amount
                                                                .toInt()
                                                                .toString(),
                                                            style:
                                                            AppUtility().isTablet(context)  ? priceTextStyle : welcomJazStyle,
                                                            softWrap: true,
                                                            textAlign:
                                                            TextAlign
                                                                .right,
                                                          ),
                                                        ),
                                                        Container(
                                                          alignment: Alignment.center,
                                                          padding: EdgeInsets.only(top: 0),
                                                          child: Text(
                                                            " " +
                                                                AppUtility()
                                                                    .getCurrentCurrency()
                                                                    .toString(),
                                                            style:
                                                            dollerStyle,
                                                          ),
                                                        )
                                                      ])
                                              ),
                                              AppUtility().isTablet(context)? Container(
                                                margin: EdgeInsets.only(
                                                  top: overAllHeight * 0.015,
                                                ),
                                                child:showRatingBar() ,
                                              )
                                                  :Container()
                                            ],
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          margin: EdgeInsets.only(
                                            top: overAllHeight * 0.015,
                                          ),
                                          padding: EdgeInsets.only(
                                              bottom: AppUtility()
                                                  .isTablet(context)
                                                  ? 0
                                                  : 8),
                                          child: Text(
                                            Strings.exclTaxesFees,
                                            style: exclTaxStyle,
                                          ),
                                        ),

                                        ! AppUtility().isTablet(context)  ? Container(
                                            margin: EdgeInsets.only(
                                              top: overAllHeight * 0.010,
                                            ),
                                            child: showRatingBar()
                                        )

                                            : Container()

                                      ],
                                    )

                                  /*descriptionWidget()*/),
                              )
                            ],
                          ),
                        )
                      ],
                    )),

                )
            ))
            : Container(),
        // if (pageName == "surroundings")
        //   Positioned.fill(
        //       top: widget.mapHeight,
        //       child: Align(
        //           alignment: Alignment.topCenter,
        //           child: Container(
        //             padding: EdgeInsets.all(7),
        //             width: overAllWidth * 0.7,
        //             decoration: BoxDecoration(
        //               boxShadow: boxShadow,
        //               color: Colors.white,
        //             ),
        //             child: Text(
        //               hotelName,
        //               style: textFieldStyle,
        //               textAlign: TextAlign.center,
        //             ),
        //           ))),
      ],
    );

    // if(widget.list.length==markers.length){
    //   print("build"+widget.list.length.toString());
    //   markers.forEach((element) {
    //     if (pageName == "surroundings") {
    //       _controller.showMarkerInfoWindow(element.markerId);
    //     }
    //   });
    // }
  }
}

class Place with ClusterItem {
  final String name;
  final LatLng latLng;
  final String amount;
  final ProductsQuery$Query$Products$PackageProducts locationDetails;

  Place(
      {required this.name,
        required this.latLng,
        required this.amount,
        required this.locationDetails});

  @override
  LatLng get location => latLng;
}
