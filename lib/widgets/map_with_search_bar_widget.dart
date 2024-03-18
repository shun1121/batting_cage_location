import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_place/google_place.dart';

class MapWithSearchBarWidget extends StatefulWidget {
  const MapWithSearchBarWidget({Key? key}) : super(key: key);

  @override
  _MapWithSearchBarWidgetState createState() => _MapWithSearchBarWidgetState();
}

class _MapWithSearchBarWidgetState extends State<MapWithSearchBarWidget> {
  late GooglePlace googlePlace;
  List<AutocompletePrediction> searchPredictions = [];
  Position? currentPosition;
  late StreamSubscription<Position> positionStream;
  late GoogleMapController mapController;

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

    String apiKey = FlutterConfig.get("PLACES_API_KEY");
    googlePlace = GooglePlace(apiKey);
  }

  void startListeningToLocationUpdates() {
    // 現在位置を更新し続ける
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) {
      setState(() {
        currentPosition = position;
      });
      print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        searchPredictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map with Search Bar'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              onTap: (LatLng latLang) {
                print('Clicked: $latLang');
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10.0,
                            spreadRadius: 1.0,
                            offset: Offset(10, 10))
                        ],
                      ),
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            autoCompleteSearch(value);
                          } else {
                            if (searchPredictions.length > 0 && mounted) {
                              setState(() {
                                searchPredictions = [];
                              });
                            }
                          }
                        },
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                            color: Colors.grey[500],
                            icon: const Icon(Icons.arrow_back_ios_new),
                            onPressed: () {
                              // Navigator.pop(context);
                            },
                          ),
                          hintText: 'バッティングセンター',
                          hintStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchPredictions.length, // 検索結果の配列の長さを指定,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(searchPredictions[index].description.toString()),
                              onTap: () async {
                                // Handle onTap
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}