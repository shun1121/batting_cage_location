import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_place/google_place.dart';
import 'package:geocoding/geocoding.dart';

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
  Completer _controller = Completer();

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
    String apiKey = FlutterConfig.get("PLACES_API_KEY");
    googlePlace = GooglePlace(apiKey);
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
      setState(() {
        currentPosition = position;
      });
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
  }

  void autoCompleteSearch(String value, String category) async {
    var result = await googlePlace.autocomplete
        .get(value, types: category, language: 'ja');
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        searchPredictions = result.predictions!;
      });
    }
  }

  Future<void> _animateCamera(List<double> position) async {
    final mapController = await _controller.future;
    await mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position[0], position[1]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    List<double> LatLng = [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map with Search Bar'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      width: screenWidth * 0.9,
                      height: 40,
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
                            autoCompleteSearch(value, 'gym');
                          } else {
                            if (searchPredictions.isNotEmpty && mounted) {
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
                          hintStyle: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchPredictions.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(searchPredictions[index]
                                  .description
                                  .toString()),
                              onTap: () async {
                                List? locations = await locationFromAddress(
                                    searchPredictions[index]
                                        .description
                                        .toString());
                                setState(() {
                                  LatLng.add(locations.first.latitude);
                                  LatLng.add(locations.first.longitude);
                                });
                                _animateCamera(LatLng);
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
