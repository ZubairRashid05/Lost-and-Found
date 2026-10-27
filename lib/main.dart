import 'package:flutter/material.dart';
import 'package:lost_and_found/pages/yourposts.dart';
import 'package:lost_and_found/pages/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'HelveticaNeue',
      ),
      home: const HomePage(),
      routes: {
        '/homepage': (context) => const HomePage(),
        '/yourposts': (context) => const YourPosts(),
      },
    );
  }

}
