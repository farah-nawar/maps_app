import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName='home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Location location=Location();

  late PermissionStatus permissionStatus;

  bool serviceEnabled= false;

  late LocationData? locationData;
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    getUserLocation();
    return  Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );;
  }
  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<bool> isPermissionGranted() async {
    permissionStatus= await location.hasPermission();
    if(permissionStatus == PermissionStatus.denied){
      permissionStatus= await location.requestPermission();
    }
    return permissionStatus == PermissionStatus.granted;
  }

  Future<bool> isServiceEnabled() async{
    serviceEnabled=await  location.serviceEnabled();
    if(serviceEnabled == false){
      serviceEnabled = await location.requestService();
    }
    return serviceEnabled;
  }

  void getUserLocation() async{
    var permissinGranted= await isPermissionGranted();
    if(permissinGranted==false) return; // user denied
    var gpsEnabled = await isServiceEnabled();
    if(gpsEnabled == false) return;
    if(gpsEnabled && permissinGranted){
      locationData= await location.getLocation();
      location.onLocationChanged.listen((newLocationData) {  // tracking user location
        locationData=newLocationData;
      });
      print('${locationData?.latitude ?? 0} and ${locationData?.longitude?? 0}'  );
    }

  }
}
