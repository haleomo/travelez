
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'screens/home_screen.dart';

void main() async {
  //final envPath = '${Directory.current.path}/.env';
  print('Loading .env from: ${Directory.current.path}/.env');
  await dotenv.load(fileName: '${Directory.current.path}/.env');
  runApp(TravelEZApp());
}


class TravelEZApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelEZ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
