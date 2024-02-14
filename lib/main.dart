import 'package:flutter/material.dart';
import 'package:maps_app/map_sample.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: MapSample.routeName,
      routes: {
        MapSample.routeName:(context)=> MapSample(),
      },
    );
  }
}
