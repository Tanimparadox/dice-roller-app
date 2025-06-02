import 'package:first_app/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:first_app/gradient_container.dart';
import 'package:first_app/welcome_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: WelcomScreen()),
    ),
  );
}
