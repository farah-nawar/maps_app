import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapSample extends StatefulWidget {
  static const String routeName='map';

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {

  Location location=Location();

  late PermissionStatus permissionStatus;

  bool serviceEnabled= false;

  late LocationData? locationData;

  StreamSubscription<LocationData>? streamSubscription = null;

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.2326654, 29.9458551),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(31.2326654, 29.9458551),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  Set<Marker> markers={};
  double defLat=37.4219983;
  double defLon=-122.084;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var usermarker = Marker(
      markerId: MarkerId('user location'),
      position: LatLng(31.2326654, 29.9458551),
    );
    markers.add(usermarker);

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    streamSubscription?.cancel();
  }
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
        markers: markers,
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
      streamSubscription= location.onLocationChanged.listen((newLocationData) {  // tracking user location

          locationData = newLocationData;


        print('${newLocationData.latitude ?? 0} and ${newLocationData.longitude?? 0}'  );

      });
    }

  }
}