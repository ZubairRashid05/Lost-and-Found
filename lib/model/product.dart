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
    this.imageUrl = "lib/images/images.jpeg",
    this.isFound = false,
  });
}