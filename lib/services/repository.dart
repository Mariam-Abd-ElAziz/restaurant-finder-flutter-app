import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import '../models/product.dart';

class Repository {
  static const String _baseUrl = 'https://6a036b592afe8349b4b531d3.mockapi.io';

  Future<List<Restaurant>> fetchRestaurants() async {
    final response = await http.get(Uri.parse('$_baseUrl/eatery'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Restaurant.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load restaurants (${response.statusCode})');
  }

  Future<List<Product>> fetchProducts({int? restaurantId}) async {
    final uri = restaurantId != null
        ? Uri.parse('$_baseUrl/product?restaurant_id=$restaurantId')
        : Uri.parse('$_baseUrl/product');

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final all = data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
      // Client-side filter in case the API ignores the query param
      if (restaurantId != null) {
        final filtered = all.where((p) => p.restaurantId == restaurantId).toList();
        return filtered.isNotEmpty ? filtered : all; // fallback: return all if no match
      }
      return all;
    }
    throw Exception('Failed to load products (${response.statusCode})');
  }

  Future<List<Restaurant>> searchByProduct(String productName) async {
    final results = await Future.wait([fetchEateries(), fetchProducts()]);
    final restaurants = results[0] as List<Restaurant>;
    final products    = results[1] as List<Product>;

    final query = productName.toLowerCase().trim();

    // Find all restaurant IDs that have a matching product
    final matchingRestaurantIds = products
        .where((p) => p.name.toLowerCase().contains(query))
        .map((p) => p.restaurantId)
        .whereType<int>()
        .toSet();

    if (matchingRestaurantIds.isEmpty) {
      // If products don't have restaurantId, return all restaurants as a fallback
      return restaurants
          .where((r) => r.name.toLowerCase().contains(query) ||
              r.tags.any((t) => t.toLowerCase().contains(query)))
          .toList();
    }

    return restaurants
        .where((r) => matchingRestaurantIds.contains(r.id))
        .toList();
  }

  /// Returns all unique product names for the search dropdown.
  Future<List<String>> fetchProductNames() async {
    final products = await fetchProducts();
    final names = products.map((p) => p.name).toSet().toList()..sort();
    return names;
  }
}
