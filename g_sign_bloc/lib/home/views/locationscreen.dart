import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:g_sign_bloc/constatnts/spaces.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/src/types/polyline.dart' hide Polyline;
//import 'package:google_maps_webservice/directions.dart' hide Polyline;
import 'package:google_maps_webservice/distance.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/geolocation.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/staticmap.dart';
import 'package:google_maps_webservice/timezone.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final gAPIkey = "AIzaSyBdaSUtIFyNgu_BrIUQF2achnN4DtVI9f8";
  var locationController = TextEditingController();
  Completer<GoogleMapController> mapController = Completer();
  GoogleMapsPlaces places =
  GoogleMapsPlaces(apiKey: "AIzaSyBdaSUtIFyNgu_BrIUQF2achnN4DtVI9f8");
  var geolocator = Geolocator();
  final Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  LatLng destLocation = LatLng(9.933491, 78.127579);
  double latitude = 0.0;
  double longitude = 0.0;
  late LatLng currentLocation;
  late LatLng destinationLocation;

  @override
  void initState() {
    super.initState();
    print("-init-");
    locatePosition();
    polylinePoints = PolylinePoints();
    destinationLocation = LatLng(destLocation.latitude, destLocation.longitude);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    print("Access-GRANTED");
    return await Geolocator.getCurrentPosition();
  }

  locatePosition() async {
    print("-Getting-");
    Position position = await _determinePosition();
    // Position currentPosition = position;
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    latitude = latLngPosition.latitude;
    longitude = latLngPosition.longitude;
    print("latitude:--$latitude");
    print("longitude:--$longitude");
    //print("CurrentPosition--$currentPosition");
  }

  // final Marker marker = Marker(markerId: MarkerId(''),
  //     infoWindow: InfoWindow(title: ''),
  //     icon: BitmapDescriptor.defaultMarker,
  //     position: LatLng(latitude, longitude));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          "Map",
          style:
          TextStyle(fontWeight: FontWeight.w700, color: Colors.lightBlue),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: [
            Card(
              elevation: elevationValue.contentElevation,
              child: TextFormField(
                controller: locationController,
                cursorColor: Colors.black26,
                cursorWidth: dynamicCursor.cursorWidth,
                cursorHeight: dynamicCursor.cursorHeight,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black12,
                    size: 30,
                  ),
                  errorStyle: TextStyle(fontSize: 13, height: 0.04),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black26, width: Widths.contentWidth),
                    borderRadius: BorderRadius.all(
                        Radius.circular(borderRadius.circleRadius)),
                  ),
                  border: InputBorder.none,
                  // focusedBorder: InputBorder.none,
                  // errorBorder: InputBorder.none,
                  // disabledBorder: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),

                  hintText: "Search locations",
                ),
                onTap: () async {
                  Prediction? predictedPlaces = await PlacesAutocomplete.show(
                      context: context, apiKey: gAPIkey);
                  displayPrediction(predictedPlaces);
                },
              ),
              //),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(42.7477863,-71.1699932), zoom: 15),
                  polylines: polylines,
                  markers: {
                    Marker(
                        markerId: MarkerId(''),
                        infoWindow: InfoWindow(title: ''),
                        icon: BitmapDescriptor.defaultMarker,
                        position: LatLng(latitude, longitude))
                  },
                  onMapCreated: (GoogleMapController controller) {
                    mapController.complete(controller);
                    print("--Map-Created--");
                    print("---${polylines.length}---");
                    setPolylines();
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setPolylines() async {
    print("---setting polylinezzz---");
    currentLocation = LatLng(latitude, longitude);
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        gAPIkey,
        PointLatLng(42.7477863,-71.1699932),
        PointLatLng(42.744421,-71.1698939)
    );
    print("RESULT--RESPONSE--${result.status}");
    print("--${result.points.length}--");
    if (result.status == 'OK') {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        polylines.add(
            Polyline(
                width: 10,
                polylineId: PolylineId('polyLine'),
                color: Color(0xFF08A5CB),
                points: polylineCoordinates
            )
        );
      });
    }
  }

    Future<Null> displayPrediction(Prediction? p) async {
      if (p != null) {
        PlacesDetailsResponse detail =
        await places.getDetailsByPlaceId(p.placeId!);
        var placeId = p.placeId;
        double lat = detail.result.geometry!.location.lat;
        double lng = detail.result.geometry!.location.lng;
        print(lat);
        print(lng);
      }
    }

}
