import 'package:flutter/material.dart';
import 'package:huellitas_app_flutter/screens/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
         debugShowCheckedModeBanner: false,
      title: 'Huellitas App',
      home: LoginScreen(),
    );
  }
} 