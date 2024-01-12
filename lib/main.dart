import 'package:flutter/material.dart';
import 'package:hotel_management/login.dart';
import 'package:hotel_management/view_booking.dart';
import './homepage.dart';
import 'signup.dart';
import './view_booking.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
    '/signup': (context) => SignupScreen(),
    '/homepage':(context) => HotelManagementHomePage(),
    '/login' :(context) => LoginScreen(),
    // '/view_booking':(context) => ViewBookingScreen(),
  },
      title: 'Hotel Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}



