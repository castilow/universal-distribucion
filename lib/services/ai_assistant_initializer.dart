import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Inicializador del usuario asistente IA en Firestore
abstract class AIAssistantInitializer {
  static final _firestore = FirebaseFirestore.instance;
  
  /// Crea o actualiza el documento del asistente IA en Firestore
  static Future<void> ensureAssistantExists() async {
    try {
      final assistantRef = _firestore.collection('Users').doc('klink_ai_assistant');
      final doc = await assistantRef.get();
      
      if (!doc.exists) {
        debugPrint('🤖 Creando usuario del asistente IA en Firestore...');
        
        await assistantRef.set({
          'userId': 'klink_ai_assistant',
          'fullname': 'Klink AI',
          'username': 'klink_ai',
          'email': 'ai@klink.app',
          'photoUrl': '', // Puedes agregar un logo del asistente
          'bio': '🤖 Soy tu asistente inteligente. Pregúntame lo que necesites.',
          'deviceToken': '',
          'isOnline': true,
          'status': 'active',
          'loginProvider': 'system',
          'createdAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
          'isTyping': false,
          'typingTo': '',
          'isRecording': false,
          'recordingTo': '',
          'mutedGroups': [],
        });
        
        debugPrint('✅ Usuario del asistente IA creado exitosamente');
      } else {
        // Actualizar última actividad
        await assistantRef.update({
          'isOnline': true,
          'lastActive': FieldValue.serverTimestamp(),
        });
        
        debugPrint('✅ Usuario del asistente IA actualizado');
      }
    } catch (e) {
      debugPrint('❌ Error al inicializar asistente IA: $e');
    }
  }
}



