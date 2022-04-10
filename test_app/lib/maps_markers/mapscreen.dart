import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  GoogleMapController? _controller;
  Location _location = Location();
  double mylat = 0;
  double mylon = 0;
  final Set<Marker> markers = {};

  void _onMapCreated(GoogleMapController _cntlr)
  {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!),zoom: 15),
        ),
      );
    });
  }
getmyLocation()async{
    LocationData mylocation = await Location().getLocation();
    setState(() {
      mylat = mylocation.latitude!;
      mylon = mylocation.longitude!;
    });
}

 Set<Marker> getMarkers(){
    setState(() {
      markers.add(
          Marker(
              markerId: MarkerId("Dindigul Fort"),
              position: LatLng(10.36109,77.96167),
              infoWindow: InfoWindow(title: "Rockfort"),
              icon: BitmapDescriptor.defaultMarker
          ));
      markers.add(Marker(
          markerId: MarkerId("Vivera Grande"),
          position: LatLng(10.3666,77.9774),
          infoWindow: InfoWindow(title: "3-star Hotel",
          snippet: "Have offer Today",
          onTap: (){
            print("VIVERA GRANDE");
          }),
          icon: BitmapDescriptor.defaultMarker
      ));
    });
    return markers;
  }
@override
  void initState() {
    super.initState();
    getmyLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height-100,
        width: MediaQuery.of(context).size.width-20,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(mylat, mylon)),
              mapType: MapType.normal,
              markers: getMarkers(),
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
            ),
          ],
        ),
      ),
    );
  }


}