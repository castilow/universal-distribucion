import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:flutter/material.dart';

abstract class PdfImportHistoryApi {
  // PDF Import History collection reference
  static final CollectionReference<Map<String, dynamic>> historyRef =
      FirebaseFirestore.instance.collection('PdfImportHistory');

  // Guardar historial de importación
  static Future<void> saveImportHistory({
    required String pdfFileName,
    required String category,
    required int productsCount,
    required String defaultImageUrl,
  }) async {
    try {
      debugPrint('📋 [PDF_IMPORT_HISTORY] Guardando historial de importación');
      
      final currentUser = AuthController.instance.currentUser;
      final now = DateTime.now();
      final importId = AppHelper.generateID;
      
      final historyData = {
        'importId': importId,
        'userId': currentUser.userId,
        'pdfFileName': pdfFileName,
        'category': category,
        'productsCount': productsCount,
        'defaultImageUrl': defaultImageUrl,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };
      
      await historyRef.doc(importId).set(historyData);
      
      debugPrint('✅ [PDF_IMPORT_HISTORY] Historial guardado exitosamente');
    } catch (e) {
      debugPrint('❌ [PDF_IMPORT_HISTORY] Error guardando historial: $e');
      // No relanzar el error para no interrumpir la importación
    }
  }

  // Obtener historial de importaciones (stream)
  static Stream<List<Map<String, dynamic>>> getImportHistoryStream() {
    final currentUser = AuthController.instance.currentUser;
    
    return historyRef
        .where('userId', isEqualTo: currentUser.userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Obtener historial de importaciones (future)
  static Future<List<Map<String, dynamic>>> getImportHistory() async {
    try {
      final currentUser = AuthController.instance.currentUser;
      
      final snapshot = await historyRef
          .where('userId', isEqualTo: currentUser.userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('❌ [PDF_IMPORT_HISTORY] Error obteniendo historial: $e');
      return [];
    }
  }

  // Eliminar entrada del historial
  static Future<void> deleteImportHistory(String importId) async {
    try {
      debugPrint('🗑️ [PDF_IMPORT_HISTORY] Eliminando historial: $importId');
      
      final currentUser = AuthController.instance.currentUser;
      
      // Verificar que el usuario es el dueño
      final historyDoc = await historyRef.doc(importId).get();
      if (!historyDoc.exists) {
        throw Exception('Registro no encontrado');
      }
      
      final historyData = historyDoc.data();
      if (historyData?['userId'] != currentUser.userId) {
        throw Exception('No tienes permiso para eliminar este registro');
      }
      
      await historyRef.doc(importId).delete();
      debugPrint('✅ [PDF_IMPORT_HISTORY] Historial eliminado: $importId');
    } catch (e) {
      debugPrint('❌ [PDF_IMPORT_HISTORY] Error eliminando historial: $e');
      rethrow;
    }
  }
}

