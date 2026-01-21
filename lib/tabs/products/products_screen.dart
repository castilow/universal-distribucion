import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_messenger/components/cached_image_with_retry.dart';

import 'package:chat_messenger/tabs/products/category_products_screen.dart';
import 'package:chat_messenger/tabs/products/add_product_screen.dart';
import 'package:chat_messenger/tabs/products/add_category_screen.dart';
import 'package:chat_messenger/tabs/products/manage_categories_screen.dart';
import 'package:chat_messenger/tabs/products/import_products_screen.dart';
import 'package:chat_messenger/tabs/products/pdf_import_history_screen.dart';
import 'package:chat_messenger/controllers/product_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:google_fonts/google_fonts.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // _isAdminMode state moved to ProductController
  
  // Lista Top 5 Categorías con estilo 3D
  // Lista Top 5 Categorías con estilo 3D (DEFAULTS)
  final List<Map<String, String>> _defaultCategories = [
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

  // Dynamic Categories Getter - Solo categorías de Firestore
  List<Map<String, String>> get _categories {
    final ProductController productController = Get.find<ProductController>();
    final customCats = productController.customCategories;
    
    // Solo usar categorías de Firestore y categorías que tienen productos
    final List<Map<String, String>> categories = [];
    
    // Obtener categorías únicas de productos existentes en Firestore
    final productCategories = productController.allProducts
        .map((p) => p['category'] ?? 'Otros')
        .toSet()
        .toList();
    
    // Agregar categorías que tienen productos
    for (var catName in productCategories) {
      if (catName.toString().isNotEmpty && catName != 'Otros') {
        // Buscar si hay imagen personalizada en customCategories
        Map<String, dynamic>? customCat;
        try {
          customCat = customCats.firstWhere((c) => c['name'] == catName);
        } catch (e) {
          customCat = null;
        }
        categories.add({
          'name': catName.toString(),
          'image': customCat?['image'] ?? 'assets/images/categories/3d_scents.png'
        });
      }
    }
    
    // Agregar categorías custom que no tienen productos aún
    for (var custom in customCats) {
      if (!categories.any((c) => c['name'] == custom['name'])) {
        categories.add({
          'name': custom['name'], 
          'image': custom['image'] ?? 'assets/images/categories/3d_scents.png'
        });
      }
    }
    
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    final isDarkMode = AppTheme.of(context).isDarkMode;
    final ProductController productController = Get.find<ProductController>();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Obx(() => Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: null,
        body: Column(
          children: [
            const SizedBox(height: 85), // Clear floating AppBar (80 + 5 buffer)
            // Header con botón de administrador
            // Header con botón de administrador (Solo visible en modo Categorías)
            if (!productController.isAdminMode.value)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categorías',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    Row(
                      children: [
                        // Botón de modo administrador
                        GestureDetector(
                          onTap: () {
                            productController.isAdminMode.toggle();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.grey[200],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: goldColor.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              IconlyLight.setting,
                              color: goldColor,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.grey[200],
                            shape: BoxShape.circle,
                            border: Border.all(color: goldColor.withOpacity(0.3)),
                          ),
                          child: Icon(IconlyLight.bag, color: goldColor, size: 24),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            // Contenido según el modo
            Expanded(
              child: productController.isAdminMode.value
                  ? Builder(
                      builder: (context) {
                        debugPrint('🔧 [BUILD] Modo admin activo, construyendo vista admin');
                        return _buildAdminView(productController, isDarkMode);
                      },
                    )
                  : GridView.builder(
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
                        return _buildCategoryCard(category, isDarkMode);
                      },
                    ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildCategoryImage(String imagePath, Color goldColor) {
    // Detectar si es una URL (empieza con http) o un asset local
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return CachedImageWithRetry(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              color: goldColor,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: Container(
          color: Colors.grey[300],
          child: Icon(
            IconlyLight.image,
            color: Colors.grey[600],
            size: 48,
          ),
        ),
      );
    } else {
      // Es un asset local
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: Icon(
            IconlyLight.image,
            color: Colors.grey[600],
            size: 48,
          ),
        ),
      );
    }
  }

  Widget _buildCategoryCard(Map<String, String> category, bool isDarkMode) {
    const goldColor = Color(0xFFD4AF37);
    
    return GestureDetector(
      onTap: () {
        Get.to(() => CategoryProductsScreen(categoryName: category['name']!));
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
          boxShadow: isDarkMode ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ] : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
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
                  color: isDarkMode ? Colors.black : Colors.grey[100],
                ),
                  child: _buildCategoryImage(category['image']!, goldColor)
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
                  color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  category['name']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
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


  Widget _buildStockSection(ProductController productController, bool isDarkMode) {
    // Premium Admin Card Design - Iteration 2 (Elegant/Platinum)
    const goldColor = Color(0xFFD4AF37); // Classic Gold
    
    // Subtle gradient for "Platinum/Paper" feel
    final cardDecoration = BoxDecoration(
        gradient: isDarkMode 
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF8F8F8)], // Very subtle shift
            ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: goldColor.withOpacity(isDarkMode ? 0.15 : 0.2), // Warm Gold Glow
            blurRadius: 40, 
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
          width: 0.8,
        ),
      );

    final textColor = isDarkMode ? Colors.white : const Color(0xFF1A1A1A); // Softer black
    final secondaryTextColor = isDarkMode ? Colors.white54 : Colors.grey[500];

    return Obx(() {
      final allProducts = productController.allProducts;
      final totalProducts = allProducts.length;
      final totalCategories = allProducts.map((p) => p['category']).toSet().length;
      
      double totalValue = 0;
      for (var product in allProducts) {
        if (product['price'] != null) {
          totalValue += (product['price'] as num).toDouble();
        }
      }
      
      // Calculate Stock Quantity if available
       int totalQuantity = 0;
       for (var product in allProducts) {
          if (product['quantity'] != null) {
            totalQuantity += (product['quantity'] as int);
          }
       }

      return Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        height: 380,
        padding: const EdgeInsets.all(0),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Background Base
                Positioned.fill(
                   child: Container(color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white),
                ),
            


            // 1. Content Layer
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: goldColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(IconlyBold.shieldDone, color: goldColor, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Universal Admin',
                                style: GoogleFonts.inter(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Panel de Control',
                                style: GoogleFonts.inter(
                                  color: secondaryTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => productController.isAdminMode.value = false,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.close, color: secondaryTextColor, size: 20),
                        ),
                      ),
                    ],
                  ),
                  
                  // Inventory Value (Animated)
                  Column(
                    children: [
                      Text(
                        'VALOR TOTAL INVENTARIO',
                        style: GoogleFonts.poppins(
                          color: secondaryTextColor,
                          fontSize: 11, 
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0, 
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '€',
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 36,
                              fontWeight: FontWeight.w400, 
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Animated Number
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: totalValue),
                            duration: 2000.ms,
                            curve: Curves.easeOutExpo,
                            builder: (context, value, child) {
                              return Text(
                                value.toStringAsFixed(2),
                                style: GoogleFonts.inter(
                                  color: textColor,
                                  fontSize: 56,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -1.0,
                                  height: 1.0,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                   
                  // Stats Row (Animated)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Expanded(
                            child: _buildAnimatedStat(
                              totalProducts, 
                              'Productos', 
                              IconlyLight.bag,
                              textColor, 
                              secondaryTextColor!,
                              goldColor,
                              delay: 200,
                            ),
                          ),
                         Container(
                          height: 40,
                          width: 1,
                          color: isDarkMode ? Colors.white10 : Colors.grey[200], 
                        ),
                         Expanded(
                            child: _buildAnimatedStat(
                              totalCategories, 
                              'Categorías', 
                              IconlyLight.category,
                              textColor, 
                              secondaryTextColor!,
                              goldColor,
                              delay: 400,
                            ),
                          ),
                           Container(
                          height: 40,
                          width: 1,
                          color: isDarkMode ? Colors.white10 : Colors.grey[200], 
                        ),
                         Expanded(
                            child: _buildAnimatedStat(
                              totalQuantity, 
                              'Stock Total', 
                              IconlyLight.chart,
                              textColor, 
                              secondaryTextColor!,
                              goldColor,
                              delay: 600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Botón Importar desde PDF
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey[200],
                            border: Border.all(
                              color: goldColor.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: goldColor.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Get.to(() => const ImportProductsScreen()),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(IconlyBold.document, size: 16, color: goldColor),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Importar PDF',
                                          style: GoogleFonts.inter(
                                            color: goldColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón Crear Categoría
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey[200],
                          border: Border.all(
                            color: goldColor.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Get.to(() => const ManageCategoriesScreen()),
                            borderRadius: BorderRadius.circular(16),
                            child: const Center(
                              child: Icon(IconlyBold.category, size: 20, color: goldColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón Añadir Producto
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16), // Squircles
                            color: goldColor,
                            boxShadow: [
                              BoxShadow(
                                color: goldColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Get.to(() => const AddProductScreen()),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(IconlyBold.plus, size: 16, color: Colors.black),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Añadir Nuevo Producto',
                                          style: GoogleFonts.inter(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Botón Historial
                  const SizedBox(height: 12),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey[100],
                      border: Border.all(
                        color: goldColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Get.to(() => const PdfImportHistoryScreen()),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(IconlyBold.timeCircle, size: 18, color: goldColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Ver Historial de Importaciones',
                                  style: GoogleFonts.inter(
                                    color: goldColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Border Overlay REMOVED - Using Outer Container Gradient (implemented in next step if this tool handles button only)
            // Wait, I should do the button first, then the card border.
          ],
        ),
      ),
    ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart);
    });
  }

  Widget _buildAnimatedStat(int value, String label, IconData icon, Color textColor, Color secondaryColor, Color iconColor, {int delay = 0}) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24).animate().scale(delay: delay.ms, duration: 400.ms, curve: Curves.elasticOut), 
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.toDouble()),
          duration: 2000.ms,
          curve: Curves.easeOutExpo,
          builder: (context, val, child) {
             return Text(
              val.toInt().toString(),
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: secondaryColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


  

  
  Widget _buildMiniMetric(String label, String value, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActionChip(String label, IconData icon, Color color, bool isActive) {
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
       decoration: BoxDecoration(
         color: isActive ? color.withOpacity(0.1) : Colors.transparent,
         borderRadius: BorderRadius.circular(25),
         border: Border.all(
           color: isActive ? color : Colors.grey.withOpacity(0.3),
           width: 1.5
         ),
       ),
       child: Center(
         child: Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             Icon(icon, color: isActive ? color : Colors.grey, size: 18),
             const SizedBox(width: 8),
             Text(
               label,
               style: TextStyle(
                 color: isActive ? color : Colors.grey,
                 fontSize: 13,
                 fontWeight: FontWeight.w600,
               ),
             ),
           ],
         ),
       ),
     );
  }
  
  // Unused helper for old design
 

  Widget _buildAdminView(ProductController productController, bool isDarkMode) {
    debugPrint('🔧 [ADMIN_VIEW] Construyendo vista de administrador');
    
    return CustomScrollView(
      cacheExtent: 500, // Cache de 500px para mejor rendimiento
      slivers: [
        // 1. STOCK SECTION (Non-sticky)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0), 
            child: _buildStockSection(productController, isDarkMode),
          ),
        ),

        // 2. SEARCH BAR
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: _buildSearchBar(productController, isDarkMode),
          ),
        ),

        // 3. LIST TITLE
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Obx(() {
                  final searchQuery = productController.searchQuery.value;
                  final productCount = searchQuery.isEmpty 
                    ? productController.allProducts.length
                    : productController.filteredProducts.length;
                  
                  return Text(
                    searchQuery.isEmpty 
                      ? 'LISTADO DE PRODUCTOS'
                      : 'RESULTADOS DE BÚSQUEDA',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  );
                }),
                const Spacer(),
                Obx(() {
                  final searchQuery = productController.searchQuery.value;
                  if (searchQuery.isEmpty) {
                    // Mostrar botón de refresh cuando no hay búsqueda (sin número)
                    return GestureDetector(
                      onTap: () async {
                        await productController.refreshProducts();
                        Get.snackbar(
                          'Actualizado',
                          'Productos refrescados',
                          snackPosition: SnackPosition.TOP,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.refresh,
                          size: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    );
                  }
                  
                  // No mostrar el contador cuando hay búsqueda
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),

        // 4. PRODUCT LIST (Sliver)
        _buildAdminProductsListSliver(productController, isDarkMode),
        
        // Loading indicator cuando se cargan más productos
        Obx(() {
          if (productController.isLoadingPage.value) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ),
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }),
        
        // Controles de paginación
        SliverToBoxAdapter(
          child: _buildPaginationControls(productController, isDarkMode),
        ),
        
        // Bottom Padding
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildSearchBar(ProductController productController, bool isDarkMode) {
    const goldColor = Color(0xFFD4AF37);
    
    return Obx(() => Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          productController.setSearchQuery(value);
        },
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white38 : Colors.grey[400],
            fontSize: 15,
          ),
          prefixIcon: Icon(
            IconlyLight.search,
            color: isDarkMode ? Colors.white54 : Colors.grey[600],
            size: 20,
          ),
          suffixIcon: productController.searchQuery.value.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: isDarkMode ? Colors.white54 : Colors.grey[600],
                  size: 20,
                ),
                onPressed: () {
                  _searchController.clear();
                  productController.clearSearch();
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ));
  }

  Widget _buildAdminProductsListSliver(ProductController productController, bool isDarkMode) {
    const goldColor = Color(0xFFD4AF37);
    
    return Obx(() {
      // Usar productos filtrados si hay búsqueda activa, sino todos los productos
      final productsToShow = productController.searchQuery.value.isEmpty 
        ? productController.allProducts 
        : productController.filteredProducts;
      
      if (productsToShow.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  productController.searchQuery.value.isEmpty 
                    ? IconlyLight.bag 
                    : IconlyLight.search,
                  size: 60, 
                  color: isDarkMode ? Colors.white24 : Colors.black26
                ),
                const SizedBox(height: 16),
                Text(
                  productController.searchQuery.value.isEmpty
                    ? 'No hay productos'
                    : 'No se encontraron productos',
                  style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black45, fontSize: 16),
                ),
                if (productController.searchQuery.value.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Intenta con otra búsqueda',
                    style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black38, fontSize: 14),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(),
        );
      }

      // Si hay búsqueda activa, mostrar todos los productos encontrados
      if (productController.searchQuery.value.isNotEmpty) {
        // Mostrar indicador de carga mientras busca
        if (productController.isLoadingSearch.value) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: goldColor),
                  const SizedBox(height: 16),
                  Text(
                    'Buscando productos...',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.black45,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = productsToShow[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: _buildAdminProductCard(product, isDarkMode, productController),
              );
            },
            childCount: productsToShow.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            addSemanticIndexes: false,
          ),
        );
      }

      // Group products by category (solo cuando no hay búsqueda)
      final Map<String, List<Map<String, dynamic>>> groupedProducts = {};
      for (var product in productsToShow) {
        final category = product['category'] ?? 'Otros';
        if (!groupedProducts.containsKey(category)) {
          groupedProducts[category] = [];
        }
        groupedProducts[category]!.add(product);
      }
      
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Verificar que el índice sea válido
            if (index >= groupedProducts.length) {
              return const SizedBox.shrink();
            }
            
            final category = groupedProducts.keys.elementAt(index);
            final products = groupedProducts[category]!;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CATEGORY HEADER
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 12, left: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: goldColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category.toUpperCase(),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                             color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                             borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${products.length}',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // PRODUCT LIST FOR CATEGORY (optimizado sin animaciones pesadas)
                  ...products.take(20).map((product) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAdminProductCard(product, isDarkMode, productController),
                    );
                  }).toList(),
                  
                  // Mostrar indicador si hay más productos en la categoría
                  if (products.length > 20)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        '+${products.length - 20} productos más',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black45,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                ],
              ),
            );
          },
          childCount: groupedProducts.length + (productController.isLoadingMore ? 1 : 0),
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          addSemanticIndexes: false,
        ),
      );
    });
  }

  Widget _buildAdminProductCard(
    Map<String, dynamic> product,
    bool isDarkMode,
    ProductController productController,
  ) {
    // Updated List Design
    return GestureDetector(
      onTap: () => _showProductPreview(product, productController, isDarkMode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(24), // Softer corners
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.03), // Very subtle
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 70, // Larger Image
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDarkMode ? Colors.black : Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                 child: product['image'] != null && product['image'].toString().isNotEmpty
                    ? (product['image'].toString().startsWith('http')
                        ? CachedImageWithRetry(
                            imageUrl: product['image'],
                            fit: BoxFit.cover,
                            errorWidget: const Icon(IconlyLight.image),
                          )
                        : Image.file(File(product['image']), fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(IconlyLight.image)))
                    : Icon(IconlyLight.image, color: Colors.grey[400]),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    product['name'] ?? 'Producto',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                   Text(
                      '€${(product['price'] ?? 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37), // Gold Price
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                      ),
                    ),
                ],
              ),
            ),
            
            // Action (Clean)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showDeleteConfirmation(product, productController),
              icon: Icon(IconlyLight.delete, color: isDarkMode ? Colors.white30 : Colors.grey[400], size: 22),
            ),
             const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    Map<String, dynamic> product,
    ProductController productController,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text(
          'Eliminar Producto',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${product['name']}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await productController.deleteProduct(product['productId']);
                Get.snackbar(
                  'Éxito',
                  'Producto eliminado correctamente',
                  backgroundColor: const Color(0xFFD4AF37),
                  colorText: Colors.black,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Error al eliminar el producto: $e',
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductPreview(
    Map<String, dynamic> product,
    ProductController productController,
    bool isDarkMode,
  ) {
    const goldColor = Color(0xFFD4AF37);
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: goldColor.withOpacity(0.3),
              width: 1,
            ),
             boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header Image Section
              Stack(
                children: [
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(31)),
                      color: isDarkMode ? Colors.black : Colors.grey[100],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: product['image'] != null && product['image'].toString().isNotEmpty
                          ? (product['image'].toString().startsWith('http')
                              ? CachedImageWithRetry(
                                  imageUrl: product['image'],
                                  fit: BoxFit.contain,
                                  errorWidget: const Icon(IconlyLight.image, size: 50),
                                )
                              : Image.file(File(product['image']), fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(IconlyLight.image, size: 50)))
                          : Icon(IconlyLight.image, color: Colors.grey[400], size: 60),
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  ),
                  
                  // Close Button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              
              // 2. Info Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  children: [
                    Text(
                      product['category']?.toString().toUpperCase() ?? 'OTROS',
                      style: GoogleFonts.inter(
                        color: goldColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product['name'] ?? 'Producto Sin Nombre',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: goldColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: goldColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        '€${(product['price'] ?? 0.0).toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          color: goldColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                     
                    const SizedBox(height: 32),
                    
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPreviewStat(
                          'Stock',
                          '${product['quantity'] ?? 0}',
                          IconlyLight.chart,
                          isDarkMode,
                        ),
                         Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                        _buildPreviewStat(
                          'Código',
                          '#${product['productId']?.toString().substring(0, 4) ?? "---"}',
                          IconlyLight.scan,
                          isDarkMode,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Edit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back(); // Close dialog first
                          Get.to(() => AddProductScreen(product: product));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldColor,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(IconlyBold.edit, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Editar Producto',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: 300.ms,
      transitionCurve: Curves.easeOutExpo,
    );
  }

  Widget _buildPreviewStat(String label, String value, IconData icon, bool isDarkMode) {
    return Column(
      children: [
        Icon(icon, color: isDarkMode ? Colors.white54 : Colors.grey[500], size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white38 : Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPaginationControls(ProductController productController, bool isDarkMode) {
    const goldColor = Color(0xFFD4AF37);
    
    return Obx(() {
      final currentPage = productController.currentPage.value;
      final hasPrevious = productController.hasPreviousPage;
      final hasMore = productController.hasMoreProducts;
      final isLoading = productController.isLoadingPage.value;
      final totalProducts = productController.allProducts.length;
      
      // Solo mostrar controles si no hay búsqueda activa
      if (productController.searchQuery.value.isNotEmpty) {
        return const SizedBox.shrink();
      }
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botón Anterior
            Flexible(
              child: ElevatedButton.icon(
                onPressed: hasPrevious && !isLoading
                    ? () => productController.previousPage()
                    : null,
                icon: const Icon(Icons.arrow_back_ios, size: 14),
                label: const Text('Anterior', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasPrevious && !isLoading
                      ? goldColor
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Información de página
            Flexible(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Página $currentPage',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalProducts productos',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Botón Siguiente
            Flexible(
              child: ElevatedButton.icon(
                onPressed: hasMore && !isLoading
                    ? () => productController.nextPage()
                    : null,
                icon: const Icon(Icons.arrow_forward_ios, size: 14),
                label: const Text('Siguiente', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasMore && !isLoading
                      ? goldColor
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
