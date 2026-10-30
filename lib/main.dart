import 'package:flutter/material.dart';
import 'package:lost_and_found/pages/login.dart';
import 'package:lost_and_found/pages/homepage.dart';
import 'package:lost_and_found/pages/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nzhvcimukrvdpraghymh.supabase.co',
    publishableKey: 'sb_publishable_SX0tAi9EkrbSaHEf1nyl9w_VLXVQbiR',
  );

  final prefs = SharedPreferencesAsync();
  final loggedIn = await prefs.getBool('loggedIn') ?? false;

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.loggedIn});

  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost and Found',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'HelveticaNeue',
      ),
      home: loggedIn ? const HomePage() : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/homepage': (context) => const HomePage(),
      },
    );
  }
}
