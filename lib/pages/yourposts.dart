import 'package:flutter/material.dart';

class YourPosts extends StatefulWidget {
  const YourPosts({super.key});

  @override
  State<YourPosts> createState() => _YourPostsState();
}

class _YourPostsState extends State<YourPosts>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Your Posts")),
      backgroundColor: Colors.red,
    );
  }
}