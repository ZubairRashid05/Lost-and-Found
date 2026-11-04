import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lost_and_found/pages/settings.dart';
import 'package:lost_and_found/model/product.dart';
import 'package:lost_and_found/widgets/product_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userEmail = currentUser?.email ?? 'No email found';
    final userUsername = currentUser?.userMetadata?['username'] ?? 'No username found';

    return Scaffold(
      appBar: AppBar(title: const Text("Your Profile")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userUsername,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Settings()),
                    );
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: isDark ? Colors.grey.shade800 : null),
          const SizedBox(height: 16),
          Text(
            "Your posts",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
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
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
