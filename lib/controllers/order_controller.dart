import 'package:get/get.dart';
import 'package:flutter/material.dart';

class OrderController extends GetxController {
  // Lista de productos en el carrito/pedidos
  final RxList<Map<String, dynamic>> cart = <Map<String, dynamic>>[].obs;

  // Calcular total
  double get total => cart.fold(0, (sum, item) => sum + (item['price'] as double));

  // Añadir al carrito
  void addToCart(Map<String, dynamic> product) {
    cart.add(product);
    
    // Feedback visual
    Get.snackbar(
      'Producto Agregado',
      '${product['name']} se ha añadido a tus pedidos',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFD4AF37), // Gold
      colorText: Colors.black,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.black),
    );
  }

  // Eliminar del carrito
  void removeFromCart(int index) {
    cart.removeAt(index);
  }

  // Simular Checkout
  void checkout() {
    if (cart.isEmpty) return;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Compra Exitosa', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tu pedido ha sido procesado correctamente.\n¡Gracias por tu compra!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              cart.clear(); // Vaciar carrito
              Get.back(); // Cerrar diálogo
            },
            child: const Text('Aceptar', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }
}
