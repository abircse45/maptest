import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> marker = {};
  // Set<Polyline> _polylines = {};
  Set<Polyline> _polyLine = {};
  //double distance = 0.0;
  final Completer<GoogleMapController> _controller = Completer();
  
  double distance = 0.0;

  final CameraPosition _initialPosition =
      CameraPosition(target: LatLng(23.7808369, 90.4185591), zoom: 14);

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  //
  // List<LatLng>  latLong = [
  //   LatLng(23.7470499,90.3655623),
  //   LatLng(23.869466,90.3849888),
  // ];

  var lat;
  var long;
  var dataAddress;

  Future<Polyline?> getpolyLine(LatLng origin,LatLng to) async {
    List<LatLng> polyLineCordinate = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyCN8snQFg1eriDbdHIgHPWxirZKkz2PKyY",
        PointLatLng(origin.latitude, origin.longitude),
        PointLatLng(23.869466, 90.3849888),
        travelMode: TravelMode.driving,
        avoidFerries: true,
        avoidHighways: true);
    result.points.forEach((PointLatLng point) {
      polyLineCordinate.add(LatLng(point.latitude, point.longitude));
    });
    
    distance = _calcDistance(polyLineCordinate);
    

    return Polyline(
        polylineId: PolylineId(result.points.length.toString()),
        color: Colors.red,
        width: 4,
        points: polyLineCordinate);
  }

  // Future<Polyline> getPoly(LatLng latLng, LatLng to) async {
  //   // await _orderDetailsController.getData(widget.id!, widget.lat!, widget.long!);
  //   List<LatLng> polylineCoordinates = [];
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       "AIzaSyCN8snQFg1eriDbdHIgHPWxirZKkz2PKyY",
  //       PointLatLng(
  //         latLng.latitude,
  //         latLng.longitude,
  //       ),
  //       PointLatLng(23.7227447, 90.4113581),
  //       travelMode: TravelMode.driving,
  //       avoidHighways: true,
  //       avoidFerries: true,
  //       avoidTolls: true);
  //
  //   result.points.forEach((PointLatLng point) {
  //     polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //   });
  //   // distance = _calcDistance(polylineCoordinates);
  //   distance = _calcDistance(polylineCoordinates);
  //
  //   return Polyline(
  //     polylineId: PolylineId("polyline_id ${result.points.length}"),
  //     color: Colors.red,
  //     points: polylineCoordinates,
  //     width: 3,
  //   );
  //
  //   //print("DDDDD__${distance}");
  // }

  Future getCurrentLocation() async {
    Position postion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      lat = postion.latitude;
      long = postion.longitude;
    });

    var address = await Geocoder2.getDataFromCoordinates(
      latitude: postion.latitude,
      longitude: postion.longitude,
      googleMapApiKey: "AIzaSyCN8snQFg1eriDbdHIgHPWxirZKkz2PKyY",
    );
    print("Lat__${postion.latitude}");
    print("long__${postion.longitude}");
    print("Address__${dataAddress}");

    setState(() {
      marker.add(Marker(
        markerId: MarkerId("1"),
        infoWindow: InfoWindow(
          title: dataAddress.toString(),
        ),
        position: LatLng(postion.latitude, postion.longitude),
      ));
    });
    dataAddress = address.address;
    final CameraPosition currentPosition = CameraPosition(
        target: LatLng(postion.latitude, postion.longitude), zoom: 14);

    // _drawPolyline(
    //   LatLng(postion.latitude, postion.longitude),
    //   LatLng(23.7227447, 90.4113581),
    // );
    _drawPolyLine(
      LatLng(postion.latitude, postion.longitude),
      LatLng(23.869466, 90.3849888),

    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(currentPosition));
  }

  @override
  void initState() {
    setState(() {
      getCurrentLocation();
    });
    _determinePosition();

    // for(int i =0; i < latLong.length; i++){
    //   marker.add(Marker(
    //     markerId: MarkerId(i.toString()),
    //     position: latLong[i]
    //   ));
    //   setState(() {
    //
    //   });
    //   _polyLine.add(Polyline(
    //     color: Colors.red,
    //     width: 2,
    //     polylineId: PolylineId("1"),
    //     points:latLong,
    //   ));
    //
    // }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: Text(
            "$dataAddress",
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
        body: GoogleMap(
          markers: marker,
          mapType: MapType.normal,
          polylines: _polyLine,
          //polylines: _polyLine,
          //
          //polylines: _polylines,
          initialCameraPosition: _initialPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            setState(() {
              getCurrentLocation();
            });
          },
        ));
  }


  Future  _drawPolyLine(LatLng from, LatLng to)async{

    Polyline? polyline = await getpolyLine(from,to);
    _polyLine.add(polyline!);
    setmarker(from);
    setmarker(to);
    setState(() {

    });


  }

  setmarker(LatLng latLng){
    Marker _marker = Marker(
      markerId: MarkerId(latLng.toString()),
      position: latLng,
      infoWindow: InfoWindow(
        title: "${distance.toStringAsFixed(2)} Km"
      )
    );
    marker.add(_marker);
    setState(() {

    });

  }

  // Future<void> _drawPolyline(LatLng from, LatLng to) async {
  //   Polyline polyline = await getPoly(from, to);
  //
  //   _polylines.add(polyline);
  //
  //   _setMarker(from);
  //   _setMarker(to);
  //
  //   setState(() {});
  // }

  // void _setMarker(LatLng _location) {
  //   Marker newMarker = Marker(
  //     markerId: MarkerId(_location.toString()),
  //     icon: BitmapDescriptor.defaultMarker,
  //     // icon: _locationIcon,
  //     position: _location,
  //     infoWindow: InfoWindow(
  //       title: "${distance.toStringAsFixed(2)}km",
  //       // snippet: "${PolylineService().totalDistance.toDouble()}",
  //     ),
  //   );
  //   marker.add(newMarker);
  //   setState(() {});
  // }
  double _calcDistance(List<LatLng> polylineCoordinates) {

    double totalDistance = 0.0;

    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }

    print("distance = ${totalDistance.toStringAsFixed(2)} km");

    return totalDistance;
  }

  double coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
