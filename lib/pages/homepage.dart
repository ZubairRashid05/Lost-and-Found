import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:untitled/pages/home.dart';
import 'package:untitled/pages/yourposts.dart';
import 'package:untitled/pages/request.dart';
import 'package:untitled/pages/inbox.dart';
import 'package:untitled/pages/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage>{

  int _selectedPage = 0;

  // var backgroundColour = Colors.red;



  void _navigateBottomBar(int index){
    setState(() {
      _selectedPage = index;
    });
  }

  final List<Widget> _pages = [
    const Home(),
    const YourPosts(),
    const Request(),
    const Inbox(),
    const Profile()
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedPage],
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(80),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: .1),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: GNav(
            color: Colors.black,
            backgroundColor: Colors.transparent,
            activeColor: Colors.lightBlueAccent.shade200,
            tabBackgroundColor: Colors.grey.shade800,
            padding: const EdgeInsets.all(10),
            gap: 15,
            onTabChange: _navigateBottomBar,
            tabs: const [
              GButton(icon: Icons.home, text: "Home"),
              GButton(icon: Icons.dynamic_feed, text: "My Posts"),
              GButton(icon: Icons.add_circle_outline),
              GButton(icon: Icons.local_post_office_outlined, text: "Inbox"),
              GButton(icon: Icons.person, text: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}