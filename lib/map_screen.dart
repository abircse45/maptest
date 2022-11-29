import 'dart:async';

import 'package:flutter/material.dart';
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

  final Completer<GoogleMapController> _controller = Completer();

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

  var lat;
  var long;
  var dataAddress;
  Future getCurrentLocation() async {
    var postion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );



    var address = await Geocoder2.getDataFromCoordinates(
      latitude: postion.latitude,
      longitude: postion.longitude,
      googleMapApiKey: "AIzaSyD1R65QX1dpR58NlomcImBbFBQKwG9vrYc",
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
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(currentPosition));

  }

  @override
  void initState() {
    setState(() {
      getCurrentLocation();
    });
  //  _determinePosition();
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
          // zoomControlsEnabled: true,
          initialCameraPosition: _initialPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            setState(() {
              getCurrentLocation();
            });
          },
        ));
  }
}
