import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

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