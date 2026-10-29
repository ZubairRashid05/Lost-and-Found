import 'package:flutter/material.dart';
import 'package:lost_and_found/pages/settings.dart';
import 'package:lost_and_found/pages/login.dart';
import 'package:lost_and_found/pages/signup.dart';
import 'package:lost_and_found/pages/yourposts.dart';
import 'package:lost_and_found/pages/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nzhvcimukrvdpraghymh.supabase.co',
    publishableKey: 'sb_publishable_SX0tAi9EkrbSaHEf1nyl9w_VLXVQbiR',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'HelveticaNeue',
      ),
      home: const LoginPage(),
      routes: {
        '/signup': (context) => const SignupPage(),
        '/homepage': (context) => const HomePage(),
        // '/yourposts': (context) => const YourPosts(),
      },
    );
  }
}
