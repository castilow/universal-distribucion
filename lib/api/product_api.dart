import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/api/pdf_import_history_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class ProductApi {
  // Products collection reference
  static final CollectionReference<Map<String, dynamic>> productsRef =
      FirebaseFirestore.instance.collection('Products');

  // Add product
  static Future<void> addProduct({
    required String category,
    required String name,
    required String description,
    required double price,
    required int quantity, // Nuevo campo
    required File imageFile,
    String? articleCode, // Código de artículo
  }) async {
    try {
      debugPrint('📦 [PRODUCT_API] Iniciando agregar producto');
      debugPrint('📦 [PRODUCT_API] Categoría: $category');
      debugPrint('📦 [PRODUCT_API] Nombre: $name');
      debugPrint('📦 [PRODUCT_API] Precio: $price');
      debugPrint('📦 [PRODUCT_API] Cantidad: $quantity');
      
      final currentUser = AuthController.instance.currentUser;
      debugPrint('📦 [PRODUCT_API] Usuario: ${currentUser.userId}');

      // Mostrar diálogo de procesamiento
      DialogHelper.showProcessingDialog(
        title: 'Guardando producto...',
        barrierDismissible: false,
      );

      // Subir imagen a Firebase Storage
      debugPrint('📤 [PRODUCT_API] Subiendo imagen a Firebase Storage...');
      final String imageUrl = await AppHelper.uploadFile(
        file: imageFile,
        userId: currentUser.userId,
      );
      debugPrint('✅ [PRODUCT_API] Imagen subida exitosamente: $imageUrl');

      // Crear documento de producto en Firestore
      final String productId = AppHelper.generateID;
      final now = DateTime.now();
      final productData = {
        'productId': productId,
        'userId': currentUser.userId,
        'category': category,
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity, // Guardar cantidad
        'articleCode': articleCode ?? '', // Código de artículo
        'imageUrl': imageUrl,
        'image': imageUrl, // Añadir también el campo 'image' para compatibilidad
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      await productsRef.doc(productId).set(productData);
      debugPrint('✅ [PRODUCT_API] Producto guardado en Firestore: $productId');

      // Cerrar diálogo
      DialogHelper.closeDialog();

      // Mostrar mensaje de éxito
      DialogHelper.showSnackbarMessage(
        SnackMsgType.success,
        'Producto agregado exitosamente',
      );
    } catch (e) {
      debugPrint('❌ [PRODUCT_API] Error al agregar producto: $e');
      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        'Error al agregar producto: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Delete product
  static Future<void> deleteProduct(String productId) async {
    try {
      debugPrint('🗑️ [PRODUCT_API] Eliminando producto: $productId');
      
      final currentUser = AuthController.instance.currentUser;
      
      // Verificar que el usuario es el dueño del producto
      final productDoc = await productsRef.doc(productId).get();
      if (!productDoc.exists) {
        throw Exception('Producto no encontrado');
      }
      
      final productData = productDoc.data();
      if (productData?['userId'] != currentUser.userId) {
        throw Exception('No tienes permiso para eliminar este producto');
      }

      // Eliminar de Firestore
      await productsRef.doc(productId).delete();
      debugPrint('✅ [PRODUCT_API] Producto eliminado: $productId');

      DialogHelper.showSnackbarMessage(
        SnackMsgType.success,
        'Producto eliminado exitosamente',
      );
    } catch (e) {
      debugPrint('❌ [PRODUCT_API] Error al eliminar producto: $e');
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        'Error al eliminar producto: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Update product
  static Future<void> updateProduct(String productId, Map<String, dynamic> data, File? imageFile) async {
    try {
      debugPrint('📝 [PRODUCT_API] Actualizando producto: $productId');
      
      final currentUser = AuthController.instance.currentUser;
      
      DialogHelper.showProcessingDialog(
        title: 'Actualizando...',
        barrierDismissible: false,
      );

      // Si hay nueva imagen, subirla primero
      if (imageFile != null) {
        debugPrint('📤 [PRODUCT_API] Subiendo nueva imagen...');
        final String imageUrl = await AppHelper.uploadFile(
          file: imageFile,
          userId: currentUser.userId,
        );
        data['imageUrl'] = imageUrl;
      }

      data['updatedAt'] = Timestamp.now();

      // Actualizar en Firestore
      await productsRef.doc(productId).update(data);
      debugPrint('✅ [PRODUCT_API] Producto actualizado exitosamente');

      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(
        SnackMsgType.success,
        'Producto actualizado correctamente',
      );
    } catch (e) {
      debugPrint('❌ [PRODUCT_API] Error al actualizar producto: $e');
      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        'Error al actualizar: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Get products stream con límite inicial para optimización
  static Stream<List<Map<String, dynamic>>> getProductsStream({String? category, int limit = 100}) {
    try {
      if (category != null && category.isNotEmpty) {
        return productsRef
            .where('category', isEqualTo: category)
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .snapshots()
            .map((snapshot) {
              debugPrint('📦 [PRODUCT_API] Stream actualizado: ${snapshot.docs.length} productos en categoría $category (límite: $limit)');
              return snapshot.docs.map((doc) => doc.data()).toList();
            })
            .handleError((error) {
              debugPrint('❌ [PRODUCT_API] Error en stream de categoría: $error');
              // Intentar sin orderBy si falla por índice
              return productsRef
                  .where('category', isEqualTo: category)
                  .limit(limit)
                  .snapshots()
                  .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
            });
      }
      // Límite inicial de 100 productos para mejorar rendimiento
      return productsRef
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
            debugPrint('📦 [PRODUCT_API] Stream actualizado: ${snapshot.docs.length} productos totales (límite: $limit)');
            return snapshot.docs.map((doc) => doc.data()).toList();
          })
          .handleError((error) {
            debugPrint('❌ [PRODUCT_API] Error en stream: $error');
            // Si falla por índice, intentar sin orderBy pero con límite
            return productsRef
                .limit(limit)
                .snapshots()
                .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
          });
    } catch (e) {
      debugPrint('❌ [PRODUCT_API] Error creando stream: $e');
      // Devolver stream vacío en caso de error
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }
  
  // Cargar página de productos (paginación basada en documentos)
  static Future<Map<String, dynamic>> loadProductsPage({
    String? category,
    DocumentSnapshot? startAfter,
    int pageSize = 50,
  }) async {
    try {
      Query<Map<String, dynamic>> query;
      
      if (category != null && category.isNotEmpty) {
        query = productsRef
            .where('category', isEqualTo: category)
            .orderBy('createdAt', descending: true);
      } else {
        query = productsRef.orderBy('createdAt', descending: true);
      }
      
      // Paginación basada en cursor (más eficiente)
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      // Cargar una página más para verificar si hay más páginas
      final snapshot = await query.limit(pageSize + 1).get();
      
      final docs = snapshot.docs;
      final hasMore = docs.length > pageSize;
      final products = docs.take(pageSize).map((doc) => doc.data()).toList();
      final lastDocument = hasMore ? docs[pageSize - 1] : null;
      
      debugPrint('📦 [PRODUCT_API] Página cargada: ${products.length} productos, hay más: $hasMore');
      
      return {
        'products': products,
        'lastDocument': lastDocument,
        'hasMore': hasMore,
      };
    } catch (e) {
      debugPrint('❌ [PRODUCT_API] Error cargando página de productos: $e');
      return {
        'products': <Map<String, dynamic>>[],
        'lastDocument': null,
        'hasMore': false,
      };
    }
  }
  
  // Obtener total de productos (para mostrar información)
  // Nota: Firestore no tiene count() nativo en esta versión
  // Para obtener el conteo real, necesitarías usar Cloud Functions
  // Por ahora, retornamos 0 ya que no es crítico para la paginación
  static Future<int> getTotalProductsCount({String? category}) async {
    // El conteo no es necesario para la paginación por páginas
    // Se puede implementar con Cloud Functions si es necesario en el futuro
    return 0;
  }

  // Get products by category
  static Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      
      if (category.isNotEmpty) {
        snapshot = await productsRef
            .where('category', isEqualTo: category)
            .orderBy('createdAt', descending: true)
            .get();
      } else {
        // Si category está vacío, obtener todos los productos
        snapshot = await productsRef
            .orderBy('createdAt', descending: true)
            .get();
      }
      
      debugPrint('📦 [PRODUCT_API] getProductsByCategory: ${snapshot.docs.length} productos');
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('❌ [PRODUCT_API] Error obteniendo productos: $e');
      // Intentar sin orderBy si falla
      try {
        QuerySnapshot<Map<String, dynamic>> snapshot;
        if (category.isNotEmpty) {
          snapshot = await productsRef
              .where('category', isEqualTo: category)
              .get();
        } else {
          snapshot = await productsRef.get();
        }
        debugPrint('📦 [PRODUCT_API] Productos obtenidos sin orderBy: ${snapshot.docs.length}');
        return snapshot.docs.map((doc) => doc.data()).toList();
      } catch (e2) {
        debugPrint('❌ [PRODUCT_API] Error incluso sin orderBy: $e2');
        return [];
      }
    }
  }

  // Importación masiva de productos desde PDF
  static Future<void> addProductsBatch({
    required List<Map<String, dynamic>> products,
    File? defaultImageFile,
    required String category,
    String? pdfFileName,
    Function(int current, int total)? onProgress,
  }) async {
    try {
      debugPrint('📦 [PRODUCT_API] Iniciando importación masiva: ${products.length} productos');
      
      final currentUser = AuthController.instance.currentUser;
      
      String defaultImageUrl = '';
      
      // Subir imagen por defecto solo si se proporciona
      if (defaultImageFile != null) {
        DialogHelper.showProcessingDialog(
          title: 'Subiendo imagen...',
          barrierDismissible: false,
        );
        
        defaultImageUrl = await AppHelper.uploadFile(
          file: defaultImageFile,
          userId: currentUser.userId,
        );
        
        Get.back(); // Cerrar diálogo de imagen
      }
      
      DialogHelper.showProcessingDialog(
        title: 'Importando productos...',
        barrierDismissible: false,
      );
      
      // Firestore tiene un límite de 500 documentos por batch
      // Dividir en múltiples batches si es necesario
      const int batchLimit = 500;
      final now = DateTime.now();
      int totalProcessed = 0;
      
      for (int batchStart = 0; batchStart < products.length; batchStart += batchLimit) {
        final batchEnd = (batchStart + batchLimit < products.length) 
            ? batchStart + batchLimit 
            : products.length;
        
        final batch = FirebaseFirestore.instance.batch();
        debugPrint('📦 [PRODUCT_API] Procesando batch ${(batchStart ~/ batchLimit) + 1}: productos ${batchStart + 1}-$batchEnd de ${products.length}');
        
        for (int i = batchStart; i < batchEnd; i++) {
          final productId = AppHelper.generateID;
          final productData = {
            'productId': productId,
            'userId': currentUser.userId,
            'category': category,
            'name': products[i]['name'] ?? products[i]['description'] ?? '',
            'description': products[i]['description'] ?? '',
            'price': products[i]['price'] ?? 0.0,
            'quantity': products[i]['quantity'] ?? 1,
            'articleCode': products[i]['articleCode'] ?? '',
            'imageUrl': defaultImageUrl,
            'image': defaultImageUrl, // Añadir también el campo 'image' para compatibilidad
            'createdAt': Timestamp.fromDate(now),
            'updatedAt': Timestamp.fromDate(now),
          };
          
          batch.set(productsRef.doc(productId), productData);
        }
        
        // Ejecutar este batch
        await batch.commit();
        totalProcessed = batchEnd;
        
        // Actualizar progreso
        onProgress?.call(totalProcessed, products.length);
        
        // Pequeña pausa entre batches para no sobrecargar
        if (batchEnd < products.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      
      Get.back(); // Cerrar diálogo
      
      debugPrint('✅ [PRODUCT_API] ${products.length} productos importados exitosamente');
      
      // Guardar en historial si se proporciona el nombre del PDF
      if (pdfFileName != null && pdfFileName.isNotEmpty) {
        try {
          await PdfImportHistoryApi.saveImportHistory(
            pdfFileName: pdfFileName,
            category: category,
            productsCount: products.length,
            defaultImageUrl: defaultImageUrl,
          );
        } catch (e) {
          debugPrint('⚠️ [PRODUCT_API] Error guardando historial: $e');
          // No interrumpir el flujo si falla el historial
        }
      }
      
      DialogHelper.showSnackbarMessage(
        SnackMsgType.success,
        '${products.length} productos importados correctamente',
      );
    } catch (e) {
      Get.back();
      debugPrint('❌ [PRODUCT_API] Error en importación masiva: $e');
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        'Error importando productos: ${e.toString()}',
      );
      rethrow;
    }
  }
}

