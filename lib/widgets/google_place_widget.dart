import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_config/flutter_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  runApp(GooglePlaceWidget());
}

class GooglePlaceWidget extends StatefulWidget {
  const GooglePlaceWidget({super.key});

  @override
  _GooglePlaceWidget createState() => _GooglePlaceWidget();
}

class _GooglePlaceWidget extends State<GooglePlaceWidget> {
  late GooglePlace googlePlace;
  List<AutocompletePrediction> searchPredictions = [];

  @override
  void initState() {
    String apiKey = FlutterConfig.get("PLACES_API_KEY");
    googlePlace = GooglePlace(apiKey);
    super.initState();
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
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        alignment: Alignment.centerLeft,
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
                            hintText: 'バッティングセンターを検索',
                            hintStyle: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                            border: InputBorder.none,
                          ),
                        )
                      )
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchPredictions.length, // 検索結果の配列の長さを指定,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(searchPredictions[index].description.toString()),
                        onTap: () async {},
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
