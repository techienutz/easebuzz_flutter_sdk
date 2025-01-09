import 'package:flutter/material.dart';

import '../config/responsive.dart';
import '../models/product.dart';
import '../services/payment_service.dart';

class ProductListScreen extends StatelessWidget {
  final List<Product> products;
  final EaseBuzzPaymentRepository paymentService = EaseBuzzPaymentRepository();

  ProductListScreen({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          if (!Responsive.isMobile(context))
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                // Implement cart functionality
              },
            ),
          if (!Responsive.isMobile(context))
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                // Implement profile functionality
              },
            ),
        ],
      ),
      drawer: Responsive.isMobile(context)
          ? Drawer(
              child: ListView(
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      'Shop Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: const Text('Cart'),
                    onTap: () {
                      // Implement cart functionality
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    onTap: () {
                      // Implement profile functionality
                    },
                  ),
                ],
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.isDesktop(context) ? 50.0 : 16.0,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (Responsive.isDesktop(context))
                const Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Featured Products',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: products.map((product) {
                      // Calculate item width based on screen size
                      double itemWidth;
                      if (Responsive.isDesktop(context)) {
                        itemWidth = (constraints.maxWidth - (16 * 3)) /
                            4; // 4 items per row
                      } else if (Responsive.isTablet(context)) {
                        itemWidth =
                            (constraints.maxWidth - 16) / 2; // 2 items per row
                      } else {
                        itemWidth = constraints.maxWidth; // 1 item per row
                      }

                      return SizedBox(
                        width: itemWidth,
                        child: ProductListItem(
                          product: product,
                          onTap: () => _showPaymentDialog(context, product),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, Product product) {
    final isDesktop = Responsive.isDesktop(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: isDesktop ? 500 : double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop)
                    Expanded(
                      flex: 1,
                      child: Image.network(
                        product.image,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  if (isDesktop) const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Price: ₹${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          product.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await _processPayment(context, product);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Pay Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, Product product) async {
    await paymentService.initiatePayment(
      productName: product.title,
      amount: product.price,
      onSuccess: (response) {
        _showFeedbackSnackBar(
          context,
          'Payment Successful: $response',
          Colors.green,
        );
      },
      onError: (error) {
        _showFeedbackSnackBar(
          context,
          'Payment Failed: $error',
          Colors.red,
        );
      },
    );
  }

  void _showFeedbackSnackBar(
      BuildContext context, String message, Color color) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: 20,
            left: 20,
            right: 20,
            top: Responsive.isMobile(context) ? 0 : 20,
          ),
        ),
      );
    }
  }
}

class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: isDesktop ? 24 : 20,
                          ),
                          Text(
                            ' ${product.rating['rate']}',
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
