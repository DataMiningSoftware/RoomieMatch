import 'package:flutter/material.dart';

// Define the decoration styles for the text fields
class AppTextStyles {
  static const InputDecoration textFieldDecoration = InputDecoration(
    labelText: 'Username',
    filled: true, // Enables the background color
    fillColor: Color.fromARGB(228, 228, 228, 228), // Set background to white
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)), // Oval border
    ),
  );

  static const InputDecoration passwordFieldDecoration = InputDecoration(
    labelText: 'Password',
    filled: true, // Enables the background color
    fillColor: Color.fromARGB(228, 228, 228, 228), // Set background to white
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)), // Oval border
    ),
  );
}
