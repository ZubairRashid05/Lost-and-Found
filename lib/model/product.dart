class Product {
  final String name;
  final String description;
  final String location;
  final String imageUrl;
  final bool isFound;

  Product({
    required this.name,
    required this.description,
    this.location = "n/a",
    this.imageUrl = "lib/assets/images/images.jpeg",
    this.isFound = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      imageUrl: json['imageUrl'] as String,
      isFound: json['isFound'] as bool,
    );
  }
}
