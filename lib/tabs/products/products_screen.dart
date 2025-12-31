import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';

import 'package:chat_messenger/tabs/products/category_products_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Lista Top 5 Categorías con estilo 3D
final List<Map<String, String>> _categories = [
    // Aceitunas - 3D Olives
    {'name': 'Aceitunas', 'image': 'assets/images/categories/3d_olives.png'},
    // Snacks - 3D Bakery
    {'name': 'Snacks', 'image': 'assets/images/categories/3d_bakery.png'},
    // Bebidas y Cocina - 3D Kitchen Tools
    {'name': 'Bebidas y Cocina', 'image': 'assets/images/categories/3d_kitchen_tools.png'},
    // Menaje - 3D Tableware
    {'name': 'Menaje', 'image': 'assets/images/categories/3d_tableware.png'},
    // Fiambreras - 3D Tupperware
    {'name': 'Fiambreras', 'image': 'assets/images/categories/3d_tupperware.png'},
    // Decoración - 3D Decoration
    {'name': 'Decoración', 'image': 'assets/images/categories/3d_decoration.png'},
    // Ambientadores - 3D Scents
    {'name': 'Ambientadores', 'image': 'assets/images/categories/3d_scents.png'},
    // Insecticidas - 3D Pest Control
    {'name': 'Insecticidas', 'image': 'assets/images/categories/3d_pest_control.png'},
    // Piscinas - 3D Pool
    {'name': 'Piscinas', 'image': 'assets/images/categories/3d_pool.png'},
  ];

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header Minimalista
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categorías',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      shape: BoxShape.circle,
                      border: Border.all(color: goldColor.withOpacity(0.3)),
                    ),
                    child: Icon(IconlyLight.bag, color: goldColor, size: 24),
                  ),
                ],
              ),
            ),
            
            // Grid 3D
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85, 
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildCategoryCard(category);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, String> category) {
    const goldColor = Color(0xFFD4AF37);
    
    return GestureDetector(
      onTap: () {
        Get.to(() => CategoryProductsScreen(categoryName: category['name']!));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // 1. Image Area with "Spotlight" Effect (Re-added for 3D feel)
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      goldColor.withOpacity(0.2), // Foco de luz
                      Colors.transparent,
                    ],
                  ),
                  color: Colors.black,
                ),
                  child: Image.asset(
                    category['image']!,
                    fit: BoxFit.cover,
                  )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scaleXY(begin: 1.0, end: 1.05, duration: 1500.ms, curve: Curves.easeInOut)
                  .moveY(begin: 0, end: -10, duration: 1500.ms, curve: Curves.easeInOut), // Efecto flotante 3D
              ),
            ),
            
            // 2. Title Area
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                ),
                alignment: Alignment.center,
                child: Text(
                  category['name']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
