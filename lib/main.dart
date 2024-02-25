import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var favoriteList = List.generate(10, (index) => 'test $index');

    return Center(
      child: ListView(
        children: favoriteList.map((list) => Text(list.toString())).toList(),
      ),
    );
  }
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _controller = TextEditingController();

  int selectedIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GoogleMap('Home');
        break;
      case 1:
        page = const GoogleMap('GoogleMap');
        break;
      case 2:
        page = Message();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'GoogleMap'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Message'),
        ],
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        backgroundColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class GoogleMap extends StatelessWidget {
  final String pageName;
  const GoogleMap(this.pageName, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          pageName,
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}

class Message extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  Message({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                height: double.infinity,
                alignment: Alignment.topCenter,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('dream')
                      .orderBy('createdAt')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('エラーが発生しました');
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final list = snapshot.requireData.docs
                        .map<String>((DocumentSnapshot document) {
                      final documentData =
                          document.data()! as Map<String, dynamic>;
                      return documentData['content']! as String;
                    }).toList();

                    final reverseList = list.reversed.toList();

                    return ListView.builder(
                      itemCount: reverseList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Center(
                          child: Text(
                            reverseList[index],
                            style: const TextStyle(fontSize: 20),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final document = <String, dynamic>{
                      'content': _controller.text,
                      'createdAt': Timestamp.fromDate(DateTime.now()),
                    };
                    FirebaseFirestore.instance
                        .collection('dream')
                        .doc()
                        .set(document);
                    _controller.clear();
                  },
                  child: const Text('送信'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
