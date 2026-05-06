import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'utils/constants.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/restaurants_screen.dart';
import 'screens/products_screen.dart';
import 'screens/search_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login:       (_) => const LoginScreen(),
        AppRoutes.signup:      (_) => const SignupScreen(),
        AppRoutes.restaurants: (_) => const RestaurantsScreen(),
        AppRoutes.products:    (_) => const ProductsScreen(),
        AppRoutes.search:      (_) => const SearchScreen(),
      },
    );
  }
}