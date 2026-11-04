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
  int _crossAxisCount = 2;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final loadedProducts = await loadProducts();

      setState(() {
        products = loadedProducts;
      });
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  void updateCrossAxisCount() {
    if (_crossAxisCount == 3) {
      setState(() {
        _crossAxisCount = 1;
      });
    } else {
      setState(() {
        _crossAxisCount += 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_column),
            onPressed: () => updateCrossAxisCount(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: GridView.builder(
                shrinkWrap: true, // Ensures GridView takes only the height it needs inside SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // Disables GridView's internal scroll (outer SingleChildScrollView handles scrolling)
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _crossAxisCount, // <-- Dynamic crossAxisCount
                  crossAxisSpacing: 12.0, // Space between columns
                  mainAxisSpacing: 12.0, // Space between rows
                  childAspectRatio: _crossAxisCount == 1
                      ? 2.2
                      : (_crossAxisCount == 2 ? 0.75 : 0.6),
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
