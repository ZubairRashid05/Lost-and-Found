import 'package:flutter/material.dart';
import 'package:lost_and_found/main.dart';
import 'package:lost_and_found/model/product.dart';
import 'package:lost_and_found/pages/settings.dart';
import 'package:lost_and_found/services/product_service.dart';
import 'package:lost_and_found/services/user_service.dart';
import 'package:lost_and_found/widgets/product_card.dart';

import '../widgets/product_page.dart';

// Main home screen displaying posts, location filters, and search bar.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // list of products retrieved from Supabase.
  List<Product> _allProducts = [];

  // Filtered list
  List<Product> _filteredProducts = [];
  int _crossAxisCount = 2;
  String _searchQuery = '';
  String _selectedLocation = 'All';
  String _selectedCategory = 'All';
  String _selectedSubcategory = 'All';
  bool _isLoading = false;

  final List<String> _locations = [
    'All',
    'Library',
    'Business Building',
    'Science Building',
    'Energy & Research Building',
    'SIRC',
    'Shawenjigewining Hall',
    'Engineering Building',
    'Recreation Centre',
  ];

  final Map<String, List<String>> _subcategories = {
    'All': ['All'],
    'Electronics': ['All', 'Phone', 'Laptop', 'Headphones', 'Other'],
    'Clothing': ['All', 'Shirt', 'Jacket', 'Pants', 'Shoes', 'Other'],
    'Accessories': ['All', 'Wallet', 'Keys', 'Watch', 'Other'],
    'Jewellery': ['All', 'Necklace', 'Ring', 'Bracelet', 'Other'],
    'Student Essentials': ['All', 'Textbooks', 'Notebooks', 'Other'],
    'Other': ['All', 'Other'],
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load products and updates widget state.
  Future<void> _loadData() async {
    if (_isLoading) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final loadedProducts = await ProductService.getLostProducts();
      if (!mounted) return;
      setState(() {
        _allProducts = loadedProducts;
      });
      _applyFilter();
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Filters products
  void _applyFilter() {
    final query = _searchQuery.toLowerCase();
    final filteredProducts = _allProducts.where((product) {
      final matchesQuery =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);

      final matchesLocation =
          _selectedLocation == 'All' ||
          product.location.toLowerCase().contains(
            _selectedLocation.toLowerCase(),
          );

      final matchesCategory =
          _selectedCategory == 'All' ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesSubcategory =
          _selectedSubcategory == 'All' ||
          product.subcategory.toLowerCase() ==
              _selectedSubcategory.toLowerCase();

      return matchesQuery &&
          matchesLocation &&
          matchesCategory &&
          matchesSubcategory;
    }).toList();

    if (!mounted) return;
    setState(() => _filteredProducts = filteredProducts);
  }

  // Change grid view layout
  void _updateCrossAxisCount() {
    setState(() {
      _crossAxisCount = (_crossAxisCount % 3) + 1;
    });
  }

  Future<void> _showFilterDialog() async {
    var temporaryLocation = _selectedLocation;
    var temporaryCategory = _selectedCategory;
    var temporarySubcategory = _selectedSubcategory;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final subcategories =
                _subcategories[temporaryCategory] ?? const ['All'];

            return AlertDialog(
              title: const Text('Filter products'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: temporaryLocation,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: _locations
                          .map(
                            (location) => DropdownMenuItem(
                              value: location,
                              child: Text(location),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => temporaryLocation = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: temporaryCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _subcategories.keys
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          temporaryCategory = value;
                          temporarySubcategory = 'All';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: ValueKey(temporaryCategory),
                      initialValue: subcategories.contains(temporarySubcategory)
                          ? temporarySubcategory
                          : 'All',
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Subcategory',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      items: subcategories
                          .map(
                            (subcategory) => DropdownMenuItem(
                              value: subcategory,
                              child: Text(subcategory),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => temporarySubcategory = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedLocation = 'All';
                      _selectedCategory = 'All';
                      _selectedSubcategory = 'All';
                    });
                    _applyFilter();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Clear'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _selectedLocation = temporaryLocation;
                      _selectedCategory = temporaryCategory;
                      _selectedSubcategory = temporarySubcategory;
                    });
                    _applyFilter();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
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

  // Displays dialog with app guidelines.
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
    final currentUser = UserService.currentUser;
    final userEmail = currentUser?.email ?? 'Guest user';
    final userUsername = currentUser?.username.isNotEmpty == true
        ? currentUser!.username
        : 'Guest';

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
                  await UserService.signOut();
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

      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search and product filters in one row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          _searchQuery = value;
                          _applyFilter();
                        },
                        decoration: InputDecoration(
                          hintText: "Search items...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey.shade900
                              : Colors.blueGrey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _showFilterDialog,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Icon(
                        size: 30,
                        _selectedLocation == 'All' &&
                                _selectedCategory == 'All' &&
                                _selectedSubcategory == 'All'
                            ? Icons.filter_list_off
                            : Icons.filter_list_outlined,
                      ),
                    ),
                  ],
                ),
              ),

              // Products Grid
              SafeArea(
                child: _isLoading && _allProducts.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _filteredProducts.isEmpty
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredProducts.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Displays the details for the selected product
  void showProductDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ProductPage(product: product),
      ),
    );
  }
}
