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
            tooltip: '1 per row',
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
                  crossAxisCount: _crossAxisCount, // Dynamic crossAxisCount
                  crossAxisSpacing: 12.0, // Space between columns
                  mainAxisSpacing: 12.0, // Space between rows
                  childAspectRatio: _crossAxisCount == 1
                      ? 2.2
                      : (_crossAxisCount == 2 ? 0.75 : 0.6),
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () => showProductDetails(product),
                    child: ProductCard(product: product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
    void showProductDetails(Product product) {
      Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        pageBuilder: (context, animation, secondaryAnimation) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 320,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: product,
                        child: Image.asset(product.imageUrl, fit: BoxFit.cover),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black38,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 16,
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              product.location,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Chip(
                            label: Text(product.isFound ? "Found" : "Lost"),
                            backgroundColor: product.isFound
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product.description,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
