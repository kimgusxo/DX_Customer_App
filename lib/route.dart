import 'package:dx_customer_app/page/info_page.dart';
import 'package:dx_customer_app/page/map_page.dart';
import 'package:dx_customer_app/page/mine_page.dart';
import 'package:dx_customer_app/page/not_mine_page.dart';
import 'package:dx_customer_app/page/order_page.dart';
import 'package:flutter/material.dart';
import 'page/home_page.dart';
import 'page/login_page.dart';

Route<dynamic>? generateRoute(RouteSettings settings) {
  final path = settings.name ?? '/';

  switch (path) {
    case '/':
      return MaterialPageRoute(builder: (_) => const LoginPage());
    case '/home':
      return MaterialPageRoute(builder: (_) => const HomePage());
    case '/map':
      return MaterialPageRoute(builder: (_) => const MapPage());
    case '/info':
      return MaterialPageRoute(builder: (_) => const InfoPage());
    case '/mine':
      return MaterialPageRoute(builder: (_) => const MinePage());
    case '/not/mine':
      return MaterialPageRoute(builder: (_) => const NotMinePage());
    case '/order':
      // RouteSettings.arguments에서 데이터를 가져옵니다.
      final args = settings.arguments as Map<String, dynamic>?;
      if (args == null || !args.containsKey('storeName') || !args.containsKey('storeDetails')) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Invalid arguments for OrderPage')),
          ),
        );
      }

      return MaterialPageRoute(
        builder: (_) => OrderPage(
          storeName: args['storeName'],
          storeDetails: args['storeDetails'],
        ),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('Page not found: $path')),
        ),
      );
  }
}
