import 'package:easebuzz_flutter_sdk_example/product_json.dart';
import 'package:flutter/material.dart';

import 'models/product.dart';
import 'screens/product_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final products = productJson.map((json) => Product.fromJson(json)).toList();

    return MaterialApp(
      title: 'Product Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: ProductListScreen(products: products),
    );
  }
}
