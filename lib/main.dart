import 'package:flutter/material.dart';
import 'package:projek_uts_mbr/cardDetail.dart';
import 'package:projek_uts_mbr/category.dart';
import 'package:projek_uts_mbr/home/home.dart';
import 'package:projek_uts_mbr/profile/vendorProfile.dart';
import 'package:projek_uts_mbr/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Vendorprofile(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
