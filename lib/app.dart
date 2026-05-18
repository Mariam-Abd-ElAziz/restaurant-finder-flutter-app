import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant_app/models/restaurant.dart';

import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'services/repository.dart';
import 'cubits/restaurant_cubit.dart';
import 'cubits/product_cubit.dart';
import 'cubits/search_cubit.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/restaurants_screen.dart';
import 'screens/products_screen.dart';
import 'screens/search_screen.dart';
import 'screens/directions_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = Repository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Repository>(create: (_) => repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RestaurantCubit>(
            create: (_) => RestaurantCubit(repository),
          ),
          BlocProvider<ProductCubit>(
            create: (_) => ProductCubit(repository),
          ),
          BlocProvider<SearchCubit>(
            create: (_) => SearchCubit(repository),
          ),
        ],
        child: MaterialApp(
  title: AppConstants.appName,
  debugShowCheckedModeBanner: false,
  theme: AppTheme.theme,
  initialRoute: AppRoutes.login,

  onGenerateRoute: (settings) {
    switch (settings.name) {

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case AppRoutes.restaurants:
        return MaterialPageRoute(builder: (_) => const RestaurantsScreen());

      case AppRoutes.products:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());

      case AppRoutes.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      case AppRoutes.directions:
          final restaurant = settings.arguments as Restaurant;       
           return MaterialPageRoute(
          builder: (_) => DirectionsScreen(restaurant: restaurant),
        );
    }

    return null;
  },
)
      ),
    );
  }
} 