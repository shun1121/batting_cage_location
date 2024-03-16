import 'package:batting_cage_location/screens/authentication_widget.dart';
import 'package:batting_cage_location/widgets/favorite_widget.dart';
import 'package:batting_cage_location/widgets/google_map_widget.dart';
import 'package:batting_cage_location/widgets/google_place_widget.dart';
import 'package:batting_cage_location/widgets/message_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
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
        page = const GooglePlaceWidget();
        break;
      case 1:
        page = const GoogleMapWidget();
        break;
      case 2:
        page = Message();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if(snapshot.hasData) {
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
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('ホーム'),
            ),
            body: const AuthenticationWidget()
          );
        }
      });
  }
}