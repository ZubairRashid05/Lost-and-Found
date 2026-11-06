import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lost_and_found/pages/home.dart';
import 'package:lost_and_found/pages/request.dart';
import 'package:lost_and_found/pages/inbox.dart';
import 'package:lost_and_found/pages/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  int _selectedPage = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  final List<Widget> _pages = [
    const Home(),
    const Request(),
    const Inbox(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: 
        Supabase.instance.client.auth.currentSession == null &&
          _selectedPage !=0
        ? const SignInRequired()
        : _pages[_selectedPage],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(80),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: isDark
                  ? Colors.black.withValues(alpha: .5)
                  : Colors.black.withValues(alpha: .1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: GNav(
            color: isDark ? Colors.white70 : Colors.black,
            backgroundColor: Colors.transparent,
            activeColor: isDark
                ? Colors.lightBlueAccent.shade100
                : Colors.lightBlueAccent.shade700,
            tabBackgroundColor:
                isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            padding: const EdgeInsets.all(10),
            gap: 15,
            onTabChange: _navigateBottomBar,
            tabs: const [
              GButton(icon: Icons.home, text: "Home"),
              GButton(icon: Icons.add_circle_outline, text: "Create"),
              GButton(icon: Icons.local_post_office_outlined, text: "Inbox"),
              GButton(icon: Icons.person, text: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInRequired extends StatelessWidget {
  const SignInRequired({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign in required")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              "Sign in to use this page",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              ),
              child: const Text("Sign in"),
            ),
          ],
        ),
      ),
    );
  }
}
