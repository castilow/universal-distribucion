import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:flutter/material.dart';

abstract class CategoryApi {
  // Categories collection reference
  static final CollectionReference<Map<String, dynamic>> categoriesRef =
      FirebaseFirestore.instance.collection('Categories');

  // Add category
  static Future<void> addCategory({
    required String name,
    required File imageFile,
  }) async {
    try {
      debugPrint('📦 [CATEGORY_API] Iniciando agregar categoría: $name');
      
      final currentUser = AuthController.instance.currentUser;

      // Subir imagen a Firebase Storage
      debugPrint('📤 [CATEGORY_API] Subiendo imagen de categoría...');
      final String imageUrl = await AppHelper.uploadFile(
        file: imageFile,
        userId: currentUser.userId,
      );
      debugPrint('✅ [CATEGORY_API] Imagen subida exitosamente: $imageUrl');

      // Crear documento de categoría en Firestore
      final String categoryId = AppHelper.generateID;
      final now = DateTime.now();
      final categoryData = {
        'categoryId': categoryId,
        'userId': currentUser.userId,
        'name': name,
        'image': imageUrl, // Using 'image' key to match existing structure
        'createdAt': Timestamp.fromDate(now),
      };

      await categoriesRef.doc(categoryId).set(categoryData);
      debugPrint('✅ [CATEGORY_API] Categoría guardada en Firestore: $categoryId');

    } catch (e) {
      debugPrint('❌ [CATEGORY_API] Error al agregar categoría: $e');
      rethrow;
    }
  }

  // Get categories stream
  static Stream<List<Map<String, dynamic>>> getCategoriesStream() {
    // Usar consulta simple sin orderBy para evitar problemas con índices
    // El ordenamiento se hace localmente
    return categoriesRef
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
          
          // Ordenar localmente por createdAt (más reciente primero)
          docs.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });
          
          return docs;
        })
        .handleError((error) {
          debugPrint('❌ [CATEGORY_API] Error en getCategoriesStream: $error');
          debugPrint('❌ Tipo de error: ${error.runtimeType}');
          // Retornar lista vacía en caso de error
          return <Map<String, dynamic>>[];
        });
  }

  // Update category
  static Future<void> updateCategory({
    required String categoryId,
    required String name,
    File? imageFile,
  }) async {
    try {
      debugPrint('📦 [CATEGORY_API] Iniciando actualización de categoría: $categoryId');
      
      final currentUser = AuthController.instance.currentUser;
      
      // Verificar que el usuario es el propietario
      final categoryDoc = await categoriesRef.doc(categoryId).get();
      if (!categoryDoc.exists || categoryDoc.data()?['userId'] != currentUser.userId) {
        throw Exception('No tienes permiso para actualizar esta categoría');
      }

      Map<String, dynamic> updateData = {
        'name': name,
      };

      // Si se proporciona una nueva imagen, subirla
      if (imageFile != null) {
        debugPrint('📤 [CATEGORY_API] Subiendo nueva imagen de categoría...');
        final String imageUrl = await AppHelper.uploadFile(
          file: imageFile,
          userId: currentUser.userId,
        );
        updateData['image'] = imageUrl;
        debugPrint('✅ [CATEGORY_API] Nueva imagen subida: $imageUrl');
      }

      await categoriesRef.doc(categoryId).update(updateData);
      debugPrint('✅ [CATEGORY_API] Categoría actualizada en Firestore: $categoryId');

    } catch (e) {
      debugPrint('❌ [CATEGORY_API] Error al actualizar categoría: $e');
      rethrow;
    }
  }

  // Delete category
  static Future<void> deleteCategory(String categoryId) async {
    try {
      debugPrint('📦 [CATEGORY_API] Iniciando eliminación de categoría: $categoryId');
      
      final currentUser = AuthController.instance.currentUser;
      
      // Verificar que el usuario es el propietario
      final categoryDoc = await categoriesRef.doc(categoryId).get();
      if (!categoryDoc.exists || categoryDoc.data()?['userId'] != currentUser.userId) {
        throw Exception('No tienes permiso para eliminar esta categoría');
      }

      await categoriesRef.doc(categoryId).delete();
      debugPrint('✅ [CATEGORY_API] Categoría eliminada de Firestore: $categoryId');

    } catch (e) {
      debugPrint('❌ [CATEGORY_API] Error al eliminar categoría: $e');
      rethrow;
    }
  }
}
