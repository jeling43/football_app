import 'package:flutter/material.dart';

// Georgia Tech Colors
const Color gtGold = Color(0xFFFFCB05);
const Color gtNavy = Color(0xFF003057);
const Color gtWhite = Colors.white;
const Color gtGray = Color(0xFFB3B3B3);

final ThemeData georgiaTechTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: gtNavy,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: gtGold,
    primary: gtNavy,
    background: gtWhite,
    surface: gtWhite,
  ),
  scaffoldBackgroundColor: gtWhite,
  appBarTheme: AppBarTheme(
    backgroundColor: gtNavy,
    foregroundColor: gtGold,
    elevation: 4,
    titleTextStyle: TextStyle(
      color: gtGold,
      fontWeight: FontWeight.bold,
      fontSize: 22,
      letterSpacing: 1.2,
    ),
    iconTheme: IconThemeData(color: gtGold),
  ),
  cardTheme: CardThemeData(
    color: gtWhite,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: gtGold,
      foregroundColor: gtNavy,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: gtGray.withOpacity(0.1),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: gtNavy),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: gtGold, width: 2),
    ),
    labelStyle: TextStyle(color: gtNavy),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(color: gtNavy, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: gtNavy),
    bodyMedium: TextStyle(color: gtNavy),
    titleLarge: TextStyle(color: gtNavy, fontWeight: FontWeight.bold),
  ),
);
