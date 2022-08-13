import 'package:flutter/material.dart';
import 'pages/homePage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main () async{
  await dotenv.load(fileName: ".env");
  runApp(const HomePage());
}

