import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Text('Home Screen'),
    );

  }

  AppBar appBar(){
    return AppBar(
      title: Text('image'),
    );

  }
}