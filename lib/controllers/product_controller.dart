import 'package:get/get.dart';
import 'package:chat_messenger/api/product_api.dart';
import 'package:chat_messenger/api/category_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';

class ProductController extends GetxController {
  // Lista de todos los productos de Firestore
  final RxList<Map<String, dynamic>> allProducts = <Map<String, dynamic>>[].obs;
  
  // Modo administrador global para la pantalla de productos
  final RxBool isAdminMode = false.obs;
  
  // Búsqueda de productos
  final RxString searchQuery = ''.obs;
  
  // Stream subscription para productos
  StreamSubscription<List<Map<String, dynamic>>>? _productsSubscription;
  
  // Mapa de productos por categoría (observable)
  final RxMap<String, List<Map<String, dynamic>>> productsByCategory = <String, List<Map<String, dynamic>>>{}.obs;
  
  // Custom Categories (from Firestore)
  final RxList<Map<String, dynamic>> customCategories = <Map<String, dynamic>>[].obs;
  
  // Variables para paginación
  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 50.obs;
  final RxBool isLoadingPage = false.obs;
  bool hasMorePages = true;
  DocumentSnapshot? _lastDocument;
  
  int get loadedProductsCount => allProducts.length;
  bool get isLoadingMore => isLoadingPage.value;
  bool get hasMoreProducts => hasMorePages;
  bool get hasPreviousPage => currentPage.value > 1;

  // Productos por defecto (Hardcoded) - KEEP THIS AS BASE
  final Map<String, List<Map<String, dynamic>>> _defaultProducts = {
    'Aceitunas': [
      {'name': 'Aceituna Serpis negra sin hueso (75 g)', 'price': 1.50, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Aceituna negra de calidad superior'},
      {'name': 'Aceituna Serpis rellena de anchoa (3×130 g)', 'price': 3.99, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Clásica rellena de anchoa'},
      {'name': 'Aceituna Serpis rodajas verdes (170 g)', 'price': 1.80, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Ideal para ensaladas'},
      {'name': 'Aceituna Serpis sabor jalapeño (130 g)', 'price': 2.10, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Toque picante'},
      {'name': 'Aceituna verde Cano (bolsa)', 'price': 5.50, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Disponible con o sin hueso'},
      {'name': 'Alcaparras Asperio / La Fragua', 'price': 2.20, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Perfectas para aderezar'},
      {'name': 'Altramuces La Fragua', 'price': 1.90, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Aperitivo clásico'},
      {'name': 'Banderillas Cano y La Fragua', 'price': 3.00, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Dulces y picantes'},
      {'name': 'Berenjenas Almagreña', 'price': 4.50, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Aliñadas, embuchadas o troceadas'},
      {'name': 'Berenjenas Antonio', 'price': 4.20, 'image': 'https://images.unsplash.com/photo-1596482613008-c8752c10b784?w=600&q=80', 'description': 'Disponible en tarro y lata'},
    ],
    'Snacks': [
      {'name': 'Roscos de naranja El Dorao', 'price': 3.50, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Sin azúcar'},
      {'name': 'Sobaos Codan', 'price': 2.90, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Sin azúcares añadidos'},
      {'name': 'Tartaletas Naturceliac', 'price': 4.20, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Chocolate y frambuesa'},
      {'name': 'Tortas de aceite', 'price': 3.80, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Sin azúcar / integrales'},
      {'name': 'Palmeras y palmeritas', 'price': 2.50, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Opción sin azúcar'},
      {'name': 'Pastas Tito', 'price': 3.20, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Sin azúcar'},
      {'name': 'Molletes y bollería Naturceliac', 'price': 4.00, 'image': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80', 'description': 'Variedad sin gluten'},
    ],
    'Bebidas y Cocina': [
      {'name': 'Jarras (500 ml, 1 L, 1,5 L)', 'price': 5.00, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Varios tamaños'},
      {'name': 'Hervidor de verduras inox', 'price': 15.90, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Acero inoxidable'},
      {'name': 'Jamoneros de madera', 'price': 25.00, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Soporte robusto'},
      {'name': 'Filtros de infusión', 'price': 3.50, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Malla fina'},
      {'name': 'Flaneras', 'price': 4.00, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Moldes individuales'},
      {'name': 'Hueveras', 'price': 2.90, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Plástico resistente'},
      {'name': 'Hornillo de gas portátil', 'price': 19.99, 'image': 'https://images.unsplash.com/photo-1571208631404-b965b0e9e611?w=600&q=80', 'description': 'Ideal camping'},
    ],
    'Fiambreras': [
      {'name': 'Fiambreras redondas', 'price': 3.50, 'image': 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=600&q=80', 'description': 'Varios tamaños y litros'},
      {'name': 'Fiambreras térmicas', 'price': 12.90, 'image': 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=600&q=80', 'description': 'Mantienen temperatura'},
      {'name': 'Fiambreras rectangulares', 'price': 5.50, 'image': 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=600&q=80', 'description': 'Tamaño familiar'},
      {'name': 'Packs apilables', 'price': 8.90, 'image': 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=600&q=80', 'description': 'Ahorra espacio'},
    ],
    'Decoración': [
      {'name': 'Figuras decorativas', 'price': 9.99, 'image': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=600&q=80', 'description': 'Budas, animales, cactus, flores'},
      {'name': 'Floreros', 'price': 14.50, 'image': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=600&q=80', 'description': 'Cerámica, decorativos, animales'},
      {'name': 'Centros decorativos', 'price': 18.00, 'image': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=600&q=80', 'description': 'Elegantes'},
      {'name': 'Popurrí', 'price': 4.50, 'image': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=600&q=80', 'description': 'Sólido y líquido'},
    ],
    'Ambientadores': [
      {'name': 'Ambientadores Mikado', 'price': 6.50, 'image': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&q=80', 'description': 'Ámbar, frutas, flores'},
      {'name': 'Ambientadores spray', 'price': 2.90, 'image': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&q=80', 'description': 'Acción rápida'},
      {'name': 'Ambientadores coche', 'price': 1.99, 'image': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&q=80', 'description': 'Frescura en movimiento'},
      {'name': 'Perlas perfumadas', 'price': 3.50, 'image': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&q=80', 'description': 'Larga duración'},
      {'name': 'Esencias concentradas', 'price': 4.90, 'image': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&q=80', 'description': 'Máxima intensidad'},
    ],
    'Insecticidas': [
      {'name': 'Insecticidas Bloom', 'price': 4.50, 'image': 'https://images.unsplash.com/photo-1587049633312-d628ae50a8ae?w=600&q=80', 'description': 'Aerosol, líquido, recambios'},
      {'name': 'Antipolillas', 'price': 3.20, 'image': 'https://images.unsplash.com/photo-1587049633312-d628ae50a8ae?w=600&q=80', 'description': 'Orion / Orphea'},
      {'name': 'Cebos', 'price': 5.50, 'image': 'https://images.unsplash.com/photo-1587049633312-d628ae50a8ae?w=600&q=80', 'description': 'Para hormigas y cucarachas'},
      {'name': 'Insecticidas jardín y hogar', 'price': 6.90, 'image': 'https://images.unsplash.com/photo-1587049633312-d628ae50a8ae?w=600&q=80', 'description': 'Protección total'},
    ],
    'Piscinas': [
      {'name': 'Cloro', 'price': 12.00, 'image': 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=600&q=80', 'description': 'Tabletas, grano, choque'},
      {'name': 'Algicidas', 'price': 8.50, 'image': 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=600&q=80', 'description': 'Previene algas'},
      {'name': 'Floculantes', 'price': 7.90, 'image': 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=600&q=80', 'description': 'Clarificador'},
      {'name': 'Incrementador de pH', 'price': 6.50, 'image': 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=600&q=80', 'description': 'Equilibrio del agua'},
      {'name': 'Accesorios limpieza', 'price': 15.00, 'image': 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=600&q=80', 'description': 'Limpiafondos, mangueras, pértigas'},
      {'name': 'Kits de mantenimiento', 'price': 25.00, 'image': 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=600&q=80', 'description': 'Todo en uno'},
    ],
  };

  @override
  void onInit() {
    super.onInit();
    // 1. Inicializar con productos por defecto
    _syncProducts(allProducts);
    
    // 2. Escuchar cambios en Firestore y sincronizar
    ever(allProducts, _syncProducts);

    // 2.5 Listen to Categories
    CategoryApi.getCategoriesStream().listen((categories) {
       customCategories.assignAll(categories);
       _syncProducts(allProducts); // Re-sync to ensure empty categories appear if we want them to
    });
    
    // 3. Cargar primera página de productos (después del frame para evitar setState durante build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadPage(1);
    });
  }
  
  void _syncProducts(List<Map<String, dynamic>> firestoreProducts) {
    debugPrint('🔄 [PRODUCT_CONTROLLER] Sincronizando productos: ${firestoreProducts.length} productos');
    
    // Solo usar productos de Firestore, sin defaults
    final newMap = <String, List<Map<String, dynamic>>>{};

    // Add Custom Categories to map (initially empty lists)
    for (var cat in customCategories) {
      if (!newMap.containsKey(cat['name'])) {
        newMap[cat['name']] = [];
      }
    }
    
    // Solo productos de Firestore
    int firestoreProductsCount = 0;
    for (var product in firestoreProducts) {
      final category = product['category'] ?? 'Otros';
      if (!newMap.containsKey(category)) {
        newMap[category] = [];
      }
      // Insertar al inicio (y normalizar clave de imagen)
      final normalizedProduct = Map<String, dynamic>.from(product);
      if (normalizedProduct['image'] == null && normalizedProduct['imageUrl'] != null) {
        normalizedProduct['image'] = normalizedProduct['imageUrl'];
      }
      
      newMap[category]!.insert(0, normalizedProduct);
      firestoreProductsCount++;
    }
    
    productsByCategory.assignAll(newMap);
    debugPrint('✅ [PRODUCT_CONTROLLER] Productos sincronizados: $firestoreProductsCount de Firestore');
    debugPrint('📊 [PRODUCT_CONTROLLER] Total categorías: ${newMap.length}');
  }

  // Guardar nueva categoría
  Future<void> saveCategory(String name, File imageFile) async {
      await CategoryApi.addCategory(name: name, imageFile: imageFile);
  }

  // Añadir un nuevo producto customizado (LOCALLY DEPRECATED -> Uses Firestore now, but kept for legacy calls)
  void addProduct(String category, String name, String description, double price, int quantity, String imagePath) {
     // No action needed locally if we rely on Firestore stream
  }

  // Eliminar producto de Firestore
  Future<void> deleteProduct(String productId) async {
    try {
      await ProductApi.deleteProduct(productId);
      debugPrint('✅ Producto eliminado del controlador');
    } catch (e) {
      debugPrint('❌ Error eliminando producto: $e');
      rethrow;
    }
  }

  // Actualizar producto en Firestore
  Future<void> updateProduct(String productId, Map<String, dynamic> data, {File? file}) async {
    try {
      await ProductApi.updateProduct(productId, data, file);
      debugPrint('✅ Producto actualizado');
    } catch (e) {
      debugPrint('❌ Error actualizando producto: $e');
      rethrow;
    }
  }

  // Obtener stream de productos de Firestore
  Stream<List<Map<String, dynamic>>> getProductsStream({String? category, int limit = 100}) {
    return ProductApi.getProductsStream(category: category, limit: limit);
  }
  
  // Historial de documentos de inicio de cada página
  final List<DocumentSnapshot?> _pageStartDocuments = [];
  
  // Cargar una página específica de productos
  Future<void> loadPage(int page) async {
    if (isLoadingPage.value) {
      return;
    }
    
    isLoadingPage.value = true;
    try {
      DocumentSnapshot? startAfter;
      
      if (page == 1) {
        // Primera página - empezar desde el inicio
        startAfter = null;
        _pageStartDocuments.clear();
        _pageStartDocuments.add(null); // Documento inicial de la página 1
      } else if (page > currentPage.value) {
        // Página siguiente - usar el último documento de la página actual
        startAfter = _lastDocument;
        // Guardar el documento de inicio de esta nueva página
        if (_pageStartDocuments.length < page) {
          _pageStartDocuments.add(_lastDocument);
        }
      } else if (page < currentPage.value) {
        // Página anterior - usar el documento guardado de esa página
        if (_pageStartDocuments.length >= page && page > 0) {
          startAfter = _pageStartDocuments[page - 1];
        } else {
          // Si no tenemos el documento guardado, recargar desde el inicio
          startAfter = null;
        }
      }
      
      final result = await ProductApi.loadProductsPage(
        startAfter: startAfter,
        pageSize: pageSize.value,
      );
      
      final products = result['products'] as List<Map<String, dynamic>>;
      final lastDoc = result['lastDocument'] as DocumentSnapshot?;
      final hasMore = result['hasMore'] as bool;
      
      if (products.isEmpty) {
        debugPrint('⚠️ [PRODUCT_CONTROLLER] Página vacía');
        isLoadingPage.value = false;
        return;
      }
      
      // Normalizar productos
      final normalized = products.map((p) {
        final map = Map<String, dynamic>.from(p);
        if (map['image'] == null && map['imageUrl'] != null) {
          map['image'] = map['imageUrl'];
        }
        if (map['imageUrl'] == null && map['image'] != null) {
          map['imageUrl'] = map['image'];
        }
        return map;
      }).toList();
      
      // Reemplazar productos actuales con los de la nueva página
      allProducts.assignAll(normalized);
      
      // Actualizar estado de paginación
      _lastDocument = lastDoc;
      hasMorePages = hasMore;
      currentPage.value = page;
      
      // Asegurar que el historial tenga el documento de inicio de esta página
      while (_pageStartDocuments.length < page) {
        _pageStartDocuments.add(null);
      }
      if (_pageStartDocuments.length >= page) {
        _pageStartDocuments[page - 1] = startAfter;
      }
      
      debugPrint('✅ [PRODUCT_CONTROLLER] Página $page cargada: ${products.length} productos. Hay más: $hasMore');
    } catch (e) {
      debugPrint('❌ [PRODUCT_CONTROLLER] Error cargando página: $e');
    } finally {
      isLoadingPage.value = false;
    }
  }
  
  // Ir a la página siguiente
  Future<void> nextPage() async {
    if (hasMorePages && !isLoadingPage.value) {
      await loadPage(currentPage.value + 1);
    }
  }
  
  // Ir a la página anterior
  Future<void> previousPage() async {
    if (hasPreviousPage && !isLoadingPage.value) {
      await loadPage(currentPage.value - 1);
    }
  }
  
  // Recargar página actual
  Future<void> reloadCurrentPage() async {
    await loadPage(currentPage.value);
  }
  
  // Cargar más productos (para compatibilidad con lazy loading)
  Future<void> loadMoreProducts() async {
    await nextPage();
  }

  // Obtener productos por categoría de Firestore
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    return await ProductApi.getProductsByCategory(category);
  }

  // Filtrar productos según la búsqueda
  List<Map<String, dynamic>> get filteredProducts {
    if (searchQuery.value.isEmpty) {
      return allProducts;
    }
    
    final query = searchQuery.value.toLowerCase();
    return allProducts.where((product) {
      final name = (product['name'] ?? '').toString().toLowerCase();
      final category = (product['category'] ?? '').toString().toLowerCase();
      final description = (product['description'] ?? '').toString().toLowerCase();
      
      return name.contains(query) || 
             category.contains(query) || 
             description.contains(query);
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  // Refrescar productos manualmente
  Future<void> refreshProducts() async {
    try {
      debugPrint('🔄 [PRODUCT_CONTROLLER] Refrescando productos manualmente...');
      final products = await ProductApi.getProductsByCategory('');
      debugPrint('📦 [PRODUCT_CONTROLLER] Productos obtenidos manualmente: ${products.length}');
      
      // Normalizar y actualizar
      final normalized = products.map((p) {
        final map = Map<String, dynamic>.from(p);
        if (map['image'] == null && map['imageUrl'] != null) {
          map['image'] = map['imageUrl'];
        }
        if (map['imageUrl'] == null && map['image'] != null) {
          map['imageUrl'] = map['image'];
        }
        return map;
      }).toList();
      
      allProducts.assignAll(normalized);
      debugPrint('✅ [PRODUCT_CONTROLLER] Productos refrescados: ${allProducts.length}');
    } catch (e) {
      debugPrint('❌ [PRODUCT_CONTROLLER] Error refrescando productos: $e');
    }
  }

  @override
  void onClose() {
    _productsSubscription?.cancel();
    super.onClose();
  }
}
