import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'home_page.dart';



void main() async {
  await Hive.initFlutter();
  await Hive.openBox('weatherBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:const HomePage(),
    );
  }
}
