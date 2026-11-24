// Class for the products
class Product {
  final String? id;
  // Product properties
  final String name;
  final String description;
  final String category;
  final String subcategory;
  final String username;
  final String location;
  final String imageUrl;
  final List<String> imageUrls;
  final String? userId;
  final bool isFound;

  // Constructor for the product
  Product({
    this.id,
    required this.name,
    required this.description,
    this.category = "n/a",
    this.subcategory = "n/a",
    this.username = "n/a",
    this.location = "n/a",
    this.imageUrl = "",
    List<String>? imageUrls,
    this.userId,
    this.isFound = false,
  }) : imageUrls = (imageUrls != null && imageUrls.isNotEmpty)
           ? imageUrls
           : [imageUrl];

  // factory Product.fromJson(Map<String, dynamic> json) {
  //   final rawUrls = json['imageUrls'] as List<dynamic>?;
  //   List<String> urls = rawUrls?.map((e) => e.toString()).toList() ?? [];
  //   if (urls.isEmpty && json['imageUrl'] != null) {
  //     urls = [json['imageUrl'] as String];
  //   }
  //   final primary = json['imageUrl'] as String? ??
  //       (urls.isNotEmpty ? urls.first : "");
  //
  //   return Product(
  //     name: json['name'] as String? ?? 'Unnamed item',
  //     description: json['description'] as String? ?? '',
  //     category: json['category'] as String? ?? 'n/a',
  //     subcategory: json['subcategory'] as String? ?? 'n/a',
  //     username: json['username'] as String? ?? 'n/a',
  //     location: json['location'] as String? ?? 'n/a',
  //     imageUrl: primary,
  //     imageUrls: urls,
  //     isFound: json['isFound'] as bool? ?? false,
  //   );
  // }
}
