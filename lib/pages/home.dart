import 'package:flutter/material.dart';
import 'package:lost_and_found/main.dart';
import 'package:lost_and_found/model/product.dart';
import 'package:lost_and_found/pages/settings.dart';
import 'package:lost_and_found/widgets/product_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/product_pop_up.dart';

// Main home screen displaying posts, location filters, and search bar.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

// Asynchronously fetches all products
Future<List<Product>> loadProducts() async {
  // connect to supabase to grab all the products
  final rows = await Supabase.instance.client
      .from('products')
      .select(
        'name, description, category, subcategory, last_location, '
        'image1_url, image2_url, user_name, is_found', // 1. Include column in select
      )
      .eq('is_found', false); // 2. Filter rows where is_found is false

  return (rows as List).map((row) {
    final img1 = row['image1_url'] as String?;
    final img2 = row['image2_url'] as String?;

    // Collect all valid image URLs
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
      isFound: row['is_found'] as bool? ?? false, // 3. Read value from row data
    );
  }).toList();
}

class _HomeState extends State<Home> {
  // list of products retrieved from Supabase.
  List<Product> _allProducts = [];

  // Filtered list
  List<Product> _filteredProducts = [];
  int _crossAxisCount = 2;
  String _searchQuery = '';
  String _selectedLocation = 'All';

  final List<String> _locations = [
    'Library',
    'Business Building',
    'Science Building',
    'Energy & Research Building',
    'SIRC',
    'Shawenjigewining Hall',
    'Engineering Building',
    'Recreation Centre',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load products and updates widget state.
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

  // Filters products
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

  // Change grid view layout
  void _updateCrossAxisCount() {
    setState(() {
      _crossAxisCount = (_crossAxisCount % 3) + 1;
    });
  }

  // Displays dialog with contact details and office location
  void _showCampusSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.lightBlueAccent),
            SizedBox(width: 8),
            Expanded(child: Text("Box Location", maxLines: 2, softWrap: true)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Where to find the Lost and Found Box?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text("First floor of the library, near the scanner."),
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

  /// Displays dialog with app guidelines.
  void _showHelpFaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.lightBlueAccent),
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
            Text(
              "Post it on the Create page or drop it at lost and found box.",
            ),
            SizedBox(height: 8),
            Text(
              "2. Lost an item?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Search the campus lost and found box or search on the Home screen.",
            ),
            SizedBox(height: 8),
            Text(
              "3. How to claim?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Claim by conversing with the finder or admin"),
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
    final userEmail = currentUser?.email ?? 'Guest user';
    final userUsername = currentUser?.userMetadata?['username'] ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lost & Found"),
        actions: [
          // Toggle grid layout
          IconButton(
            icon: Icon(Icons.view_column),
            onPressed: _updateCrossAxisCount,
            tooltip: 'Change Grid View',
          ),
        ],
      ),

      // Navigation Drawer
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
                child: Icon(
                  Icons.person,
                  size: 36,
                  color: Colors.lightBlueAccent,
                ),
              ),
              decoration: BoxDecoration(color: Colors.lightBlueAccent),
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
                    color: isDarkMode ? Colors.white : Colors.lightBlueAccent,
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
              leading: const Icon(
                Icons.location_on,
                color: Colors.lightBlueAccent,
              ),
              title: const Text("Location"),
              subtitle: const Text("Where to pick up lost items"),
              onTap: () {
                Navigator.pop(context);
                _showCampusSecurityDialog(context);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.help_outline,
                color: Colors.lightBlueAccent,
              ),
              title: const Text("Help & Guidelines"),
              subtitle: const Text("How to report & claim items"),
              onTap: () {
                Navigator.pop(context);
                _showHelpFaqDialog(context);
              },
            ),

            if (currentUser == null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.login, color: Colors.lightBlueAccent),
                title: const Text('Sign In'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(
                  Icons.settings_outlined,
                  color: Colors.lightBlueAccent,
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

  // Displays the details for the selected product
  void showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductPopUp(product: product),
    );
  }
}
