import 'dart:async';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  Position? currentPosition;
  late StreamSubscription<Position> positionStream;

  //初期位置
  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(
      double.parse(FlutterConfig.get("CURRENT_LATITUDE")),
      double.parse(FlutterConfig.get("CURRENT_LONGITUDE")),
    ),
    zoom: 14,
  );

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();
    // 位置情報が許可されていない時に許可をリクエストする
    Future(() async {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
        // 位置情報の取得を開始する
        startListeningToLocationUpdates();
      } else {
        // 位置情報の取得を開始する
        startListeningToLocationUpdates();
      }
    });
  }

  void startListeningToLocationUpdates() {
    // 現在位置を更新し続ける
    positionStream =
      Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      currentPosition = position;
      print(position == null
        ? 'Unknown'
        : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        myLocationEnabled: true,
        onMapCreated: (GoogleMapController controller) {},
        onTap: (LatLng latLang) {
          print('Clicked: $latLang');
        },
      ),
    );
  }
}
