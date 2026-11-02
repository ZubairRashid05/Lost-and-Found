import 'package:flutter/material.dart';
import 'package:lost_and_found/pages/login.dart';
import 'package:lost_and_found/pages/homepage.dart';
import 'package:lost_and_found/pages/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
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
      title: 'Lost and Found',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'HelveticaNeue',
      ),
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/homepage': (context) => const HomePage(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return session == null ? const LoginPage() : const HomePage();
  }
}
