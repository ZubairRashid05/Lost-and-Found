import 'package:lost_and_found/model/product.dart';
import 'package:lost_and_found/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  static final _supabase = Supabase.instance.client;

  static const _columns =
      'id, name, description, category, subcategory, last_location, '
      'user_id, image1_url, image2_url, user_name, is_found';

  static Future<List<Product>> getLostProducts() async {
    final rows = await _supabase
        .from('products')
        .select(_columns)
        .eq('is_found', false);

    return rows.map<Product>(_fromMap).toList();
  }

  static Future<List<Product>> getCurrentUserProducts() async {
    final user = UserService.currentUser;
    if (user == null) return [];

    final rows = await _supabase
        .from('products')
        .select(_columns)
        .eq('user_id', user.id);

    return rows.map<Product>(_fromMap).toList();
  }

  static Future<void> createProduct(Map<String, dynamic> product) async {
    await _supabase.from('products').insert(product);
  }

  static Future<void> updateProduct(
    String productId,
    Map<String, dynamic> product,
  ) async {
    final user = UserService.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to update a product.');
    }

    final updatedRows = await _supabase
        .from('products')
        .update(product)
        .eq('id', productId)
        .eq('user_id', user.id)
        .select('id');

    if (updatedRows.isEmpty) {
      throw StateError(
        'The product was not updated. Check the products update policy.',
      );
    }
  }

  static Product _fromMap(Map<String, dynamic> row) {
    final imageUrls = [
      if ((row['image1_url'] as String?)?.trim().isNotEmpty == true)
        row['image1_url'] as String,
      if ((row['image2_url'] as String?)?.trim().isNotEmpty == true)
        row['image2_url'] as String,
    ];

    return Product(
      id: row['id'] as String?,
      name: row['name'] as String? ?? 'Unnamed item',
      description: row['description'] as String? ?? '',
      category: row['category'] as String? ?? 'n/a',
      subcategory: row['subcategory'] as String? ?? 'n/a',
      username: row['user_name'] as String? ?? 'n/a',
      location: row['last_location'] as String? ?? 'n/a',
      imageUrl: imageUrls.isEmpty ? '' : imageUrls.first,
      imageUrls: imageUrls,
      userId: row['user_id'] as String?,
      isFound: row['is_found'] as bool? ?? false,
    );
  }
}
