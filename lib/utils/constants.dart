class AppConstants {
  static const String appName = 'FoodFinder';
  static const String appTagline = 'Find the best restaurants near you';

  // replace with your actual API base URL
  static const String baseUrl = 'https://your-api-url.com/api';

  static const String loginEndpoint       = '/auth/login';
  static const String signupEndpoint      = '/auth/register';
  static const String restaurantsEndpoint = '/restaurants';
  static const String productsEndpoint    = '/products';
  static const String searchEndpoint      = '/search/by-product';

  

  
  static const List<String> genderOptions = ['Male', 'Female'];
  static const List<int> levelOptions = [1, 2, 3, 4];

  static const List<String> restaurantCategories = [
    'All',
    'Restaurant',
    'Café',
    'Fast Food',
    'Dessert',
  ];
}

class AppRoutes {
  static const String login       = '/login';
  static const String signup      = '/signup';
  static const String restaurants = '/restaurants';
  static const String products    = '/products';
  static const String search      = '/search';
  static const String directions  = '/directions';
}