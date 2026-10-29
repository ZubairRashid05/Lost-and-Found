import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lost_and_found/pages/settings.dart';
import 'package:lost_and_found/model/product.dart';
import 'package:lost_and_found/widgets/product_card.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _Profile();
}

Future<List<Product>> loadProducts() async {
  final String response = await rootBundle.loadString(
    'lib/assets/database/data.json',
  );
  final Map<String, dynamic> data = jsonDecode(response);
  final List<dynamic> productList = data['products'];

  // Convert the raw dynamic list into a typed list of User objects
  return productList.map((jsonItem) => Product.fromJson(jsonItem)).toList();
}

class _Profile extends State<Profile> {
  List<Product> products = [];

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
      debugPrint("Error loading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Profile")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Email@gmail.com',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Settings()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1),
          const SizedBox(height: 16),
          const Text(
            "Your posts",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              spacing: 15,
              children: [
                for (var x in products)
                  Stack(
                    children: [
                      ProductCard(product: x),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: ElevatedButton(
                          onPressed: () {
                            const snackBar = SnackBar(
                              content: Text('Pressed edit'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Edit",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                // for (var x in products) ProductCard(product: x),
                SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
