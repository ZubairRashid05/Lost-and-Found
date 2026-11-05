class Product {
  final String name;
  final String description;
  final String category;
  final String subcategory;
  final String username;
  final String location;
  final String imageUrl;
  final bool isFound;

  Product({
    required this.name,
    required this.description,
    this.category = "n/a",
    this.subcategory = "n/a",
    this.username = "n/a",
    this.location = "n/a",
    this.imageUrl = "lib/assets/images/images.jpeg",
    this.isFound = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      username: json['username'] as String,
      location: json['location'] as String,
      imageUrl: json['imageUrl'] as String,
      isFound: json['isFound'] as bool,
    );
  }
}
