import 'package:flutter/material.dart';
import 'package:lost_and_found/model/product.dart';
import 'package:lost_and_found/model/user.dart';
import 'package:lost_and_found/widgets/product_card.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _Home();
}

Future<List<User>> loadUsers() async {
  final String response = await rootBundle.loadString(
    'lib/assets/database/data.json',
  );
  final Map<String, dynamic> data = jsonDecode(response);
  final List<dynamic> userList = data['users'];

  // Convert the raw dynamic list into a typed list of User objects
  return userList.map((jsonItem) => User.fromJson(jsonItem)).toList();
}

Future<List<Product>> loadProducts() async {
  final String response = await rootBundle.loadString(
    'lib/assets/database/data.json',
  );
  final Map<String, dynamic> data = jsonDecode(response);
  final List<dynamic> productList = data['products'];
  ;

  // Convert the raw dynamic list into a typed list of User objects
  return productList.map((jsonItem) => Product.fromJson(jsonItem)).toList();
}

class _Home extends State<Home> {
  List<User> users = [];
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final loadedUsers = await loadUsers();
      final loadedProducts = await loadProducts();

      setState(() {
        users = loadedUsers;
        products = loadedProducts;
      });
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                spacing: 15,
                children: [for (var x in products) ProductCard(product: x)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
