import 'package:flutter/material.dart';

class LoaderComponent extends StatelessWidget {
  final String text;

  // ignore: use_key_in_widget_constructors
  const LoaderComponent({this.text = ''});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF004489),
          borderRadius: BorderRadius.circular(10)
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const CircularProgressIndicator(),
              const SizedBox(height: 20,),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white
                )
              )
            ]
          ),
        )
      )
    );
  }
} 