import 'package:flutter/material.dart';

import 'package:huellitas_app_flutter/screens/login_screen.dart';

void main() => runApp(MyApp());

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
         debugShowCheckedModeBanner: false,
      title: 'Huellitas App',
      home: LoginScreen(),
    );
  }
} 