import 'package:flutter/material.dart';
import 'package:lost_and_found/main.dart';
import 'package:lost_and_found/model/product.dart';
import 'package:lost_and_found/pages/settings.dart';
import 'package:lost_and_found/widgets/product_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/product_pop_up.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

Future<List<Product>> loadProducts() async {
  final rows = await Supabase.instance.client
      .from('products')
      .select(
        'name, description, category, subcategory, last_location, '
        'image1_url, image2_url, user_name',
      );

  return (rows as List).map((row) {
    final img1 = row['image1_url'] as String?;
    final img2 = row['image2_url'] as String?;

    final List<String> urls = [];
    if (img1 != null && img1.trim().isNotEmpty) urls.add(img1);
    if (img2 != null && img2.trim().isNotEmpty) urls.add(img2);
    if (urls.isEmpty) urls.add('lib/assets/images/images.jpeg');

    return Product(
      name: row['name'] as String? ?? 'Unnamed item',
      description: row['description'] as String? ?? '',
      category: row['category'] as String? ?? 'n/a',
      subcategory: row['subcategory'] as String? ?? 'n/a',
      username: row['user_name'] as String? ?? 'n/a',
      location: row['last_location'] as String? ?? 'n/a',
      imageUrl: urls.first,
      imageUrls: urls,
      isFound: false,
    );
  }).toList();
}

class _HomeState extends State<Home> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  int _crossAxisCount = 2;
  String _searchQuery = '';
  String _selectedLocation = 'All';

  final List<String> _locations = [
    'All',
    'Library',
    'SIRC',
    'Business Building',
    'Science Building',
    'Engineering Building',
    'Recreation Centre',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final loadedProducts = await loadProducts();
      if (!mounted) return;
      setState(() {
        _allProducts = loadedProducts;
        _applyFilter();
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final matchesQuery =
            _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        final matchesLocation =
            _selectedLocation == 'All' ||
            product.location.toLowerCase().contains(
              _selectedLocation.toLowerCase(),
            );

        return matchesQuery && matchesLocation;
      }).toList();
    });
  }

  void _updateCrossAxisCount() {
    setState(() {
      _crossAxisCount = (_crossAxisCount % 3) + 1;
    });
  }

  void _showCampusSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text("Campus Security"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Central Lost & Found Office",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text("Location: SIRC Building, Room 102"),
            SizedBox(height: 8),
            Text("Emergency Phone: (905) 721-2000 ext. 2400"),
            SizedBox(height: 4),
            Text("Hours: Mon - Fri (8:00 AM - 6:00 PM)"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showHelpFaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text("Help & Guidelines"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "1. Found an item?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Post it on the Create page or drop it at Campus Security."),
            SizedBox(height: 8),
            Text(
              "2. Lost an item?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Search by location chips or keywords on the Home screen."),
            SizedBox(height: 8),
            Text(
              "3. How to claim?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Message the finder or contact security with verification proof.",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = Supabase.instance.client.auth.currentUser;
    final userEmail = currentUser?.email ?? 'user@campus.edu';
    final userUsername =
        currentUser?.userMetadata?['username'] ?? 'Campus User';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lost & Found"),
        actions: [
          IconButton(
            icon: Icon(
              _crossAxisCount == 1
                  ? Icons.grid_view
                  : (_crossAxisCount == 2
                        ? Icons.view_module
                        : Icons.view_list),
            ),
            onPressed: _updateCrossAxisCount,
            tooltip: 'Change Grid View',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                userUsername,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              accountEmail: Text(userEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 36, color: Colors.deepPurple),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            // Dark Mode Toggle Switch
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentMode, child) {
                final isDarkMode = currentMode == ThemeMode.dark;
                return SwitchListTile(
                  title: const Text("Dark Mode"),
                  secondary: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: isDarkMode ? Colors.amber : Colors.deepPurple,
                  ),
                  value: isDarkMode,
                  onChanged: (bool value) {
                    themeNotifier.value = value
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  },
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.security, color: Colors.deepPurple),
              title: const Text("Campus Security"),
              subtitle: const Text("Lost & found office info"),
              onTap: () {
                Navigator.pop(context);
                _showCampusSecurityDialog(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.deepPurple),
              title: const Text("Help & Guidelines"),
              subtitle: const Text("How to report & claim items"),
              onTap: () {
                Navigator.pop(context);
                _showHelpFaqDialog(context);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.settings_outlined,
                color: Colors.deepPurple,
              ),
              title: const Text("Profile Settings"),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Settings()),
                );
                if (mounted) {
                  setState(() {});
                }
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Sign Out",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                Navigator.pop(context);
                await Supabase.instance.client.auth.signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (value) {
                  _searchQuery = value;
                  _applyFilter();
                },
                decoration: InputDecoration(
                  hintText: "Search items, e.g., keys, wallet...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark
                      ? Colors.grey.shade900
                      : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Location Filter Chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  final loc = _locations[index];
                  final isSelected = _selectedLocation == loc;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(loc),
                      selectedColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      onSelected: (selected) {
                        setState(() {
                          _selectedLocation = loc;
                          _applyFilter();
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Products Grid
            _filteredProducts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 60,
                            color: isDark
                                ? Colors.white38
                                : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No matching items found",
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredProducts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _crossAxisCount,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        childAspectRatio: _crossAxisCount == 1
                            ? 2.1
                            : (_crossAxisCount == 2 ? 0.78 : 0.65),
                      ),
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
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
    showDialog(
      context: context,
      builder: (context) => ProductPopUp(product: product),
    );
  }
}
