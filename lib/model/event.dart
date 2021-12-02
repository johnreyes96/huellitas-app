
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Event {
  final String description;
  final DateTime from;
  final Color backgroundColor;

  const Event({
    required this.description,
    required this.from,
    this.backgroundColor = Colors.lightGreen,
  });
}



