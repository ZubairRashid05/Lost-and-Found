import 'package:flutter/material.dart';
import 'package:lost_and_found/pages/settings.dart';
import 'package:lost_and_found/model/product.dart';
import 'package:lost_and_found/widgets/product_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// User profile screen showing current user details and user-created posts.
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _Profile();
}

// Fetch user's posts from Supabase
Future<List<Product>> loadProducts() async {
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser == null) return [];

  final rows = await Supabase.instance.client
      .from('products')
      .select(
        'name, description, category, subcategory, last_location, '
        'image1_url, image2_url, user_name, is_found',
      )
      .eq('user_id', currentUser.id);

  return (rows as List).map((row) {
    final imageUrl = row['image1_url'] as String?;

    return Product(
      name: row['name'] as String? ?? 'Unnamed item',
      description: row['description'] as String? ?? '',
      category: row['category'] as String? ?? 'n/a',
      subcategory: row['subcategory'] as String? ?? 'n/a',
      username: row['user_name'] as String? ?? 'n/a',
      location: row['last_location'] as String? ?? 'n/a',
      imageUrl: imageUrl?.isNotEmpty == true
          ? imageUrl!
          : 'lib/assets/images/images.jpeg',
      isFound: row['is_found'] as bool? ?? false,
    );
  }).toList();
}

class _Profile extends State<Profile> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final loadedProducts = await loadProducts();

      if (mounted) {
        setState(() {
          products = loadedProducts;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userEmail = currentUser?.email ?? 'No email found';
    final userUsername =
        currentUser?.userMetadata?['username'] ?? 'No username found';

    return Scaffold(
      appBar: AppBar(title: const Text("Your Profile")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile User Info Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.lightBlueAccent.shade700,
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
          isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              : products.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "You haven't posted any items yet.",
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
