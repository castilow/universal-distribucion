import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_messenger/controllers/order_controller.dart';
import 'package:chat_messenger/theme/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.find();
    const goldColor = Color(0xFFD4AF37);
    final isDarkMode = AppTheme.of(context).isDarkMode;


    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
          children: [
            const SizedBox(height: 85), // Clear floating AppBar (80 + 5 buffer)
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pedidos',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Obx(() => Text(
                      '${orderController.cart.length} Items',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ),
                ],
              ),
            ),

            // Cart List
            Expanded(
              child: Obx(() {
                if (orderController.cart.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(IconlyBroken.buy, color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2), size: 80),
                        const SizedBox(height: 16),
                        Text(
                          'Tu cesta está vacía',
                          style: TextStyle(
                            color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.5),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: orderController.cart.length,
                  itemBuilder: (context, index) {
                    final item = orderController.cart[index];
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        orderController.removeFromCart(index);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(IconlyLight.delete, color: Colors.white),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                          boxShadow: isDarkMode ? [] : [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Product Image
                            Container(
                              width: 80,
                              height: 80,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141414),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: item['image'].toString().startsWith('http') 
                                ? CachedNetworkImage(
                                    imageUrl: item['image'],
                                    fit: BoxFit.contain,
                                    errorWidget: (context, url, err) => const Icon(Icons.image, color: Colors.white24),
                                  )
                                : Image.asset(item['image'], fit: BoxFit.contain),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cantidad: 1', // Simplificado
                                    style: TextStyle(
                                      color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.5),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '€${item['price'].toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: goldColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // Checkout Section
            Obx(() {
              if (orderController.cart.isEmpty) return const SizedBox.shrink();
              
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white54 : Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '€${orderController.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => orderController.checkout(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goldColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Simular Compra',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
    );
  }
}
