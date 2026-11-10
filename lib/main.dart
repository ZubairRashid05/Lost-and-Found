import 'package:flutter/material.dart';
import 'package:lost_and_found/pages/login.dart';
import 'package:lost_and_found/widgets/navbar.dart';
import 'package:lost_and_found/pages/draft.dart';
import 'package:lost_and_found/pages/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// controller to manage dark and light mode
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase credentials
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
    // Changes the theme based on the current mode
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Lost and Found',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          // Light Mode Theme
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            fontFamily: 'HelveticaNeue',
          ),
          // Dark Mode Theme
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            fontFamily: 'HelveticaNeue',
          ),
          home: const AuthGate(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const SignupPage(),
            '/homepage': (context) => const HomePage(),
            '/drafts': (context) => const DraftPage(),
          },
        );
      },
    );
  }
}

// Check if the user is signed in or not
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return session == null ? const LoginPage() : const HomePage();
  }
}
