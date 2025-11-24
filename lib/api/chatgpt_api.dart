import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// API para comunicarse con ChatGPT usando Firebase Functions (seguro)
abstract class ChatGPTApi {
  static final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  /// Envía un mensaje a ChatGPT a través de Firebase Functions
  static Future<String?> sendMessage({
    required String message,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      debugPrint('🤖 ChatGPT: Enviando mensaje a Firebase Functions...');
      debugPrint('🤖 ChatGPT: Mensaje: $message');
      debugPrint('🤖 ChatGPT: Historial length: ${conversationHistory?.length ?? 0}');
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        debugPrint('🤖 ChatGPT: Primer mensaje del historial: ${conversationHistory.first}');
      }

      // Llamar a la función de Firebase
      final result = await _functions
          .httpsCallable('chatWithAssistant')
          .call({
        'message': message,
        'conversationHistory': conversationHistory ?? [],
      }).timeout(
        const Duration(seconds: 35),
        onTimeout: () {
          debugPrint('🤖 ChatGPT: Timeout después de 35 segundos');
          throw TimeoutException('La petición tardó demasiado');
        },
      );

      debugPrint('🤖 ChatGPT: Respuesta recibida de Firebase');
      debugPrint('🤖 ChatGPT: Result data keys: ${(result.data as Map<String, dynamic>).keys}');
      debugPrint('🤖 ChatGPT: Result data: ${result.data}');

      // Extraer la respuesta
      final data = result.data as Map<String, dynamic>;
      final response = data['response'] as String?;
      final success = data['success'] as bool? ?? false;
      
      if (response != null) {
        final previewLength = response.length > 100 ? 100 : response.length;
        debugPrint('🤖 ChatGPT: Response: ${response.substring(0, previewLength)}...');
      }
      debugPrint('🤖 ChatGPT: Success: $success');

      if (success && response != null && response.isNotEmpty) {
        debugPrint('✅ ChatGPT: Respuesta exitosa');
        return response;
      } else {
        debugPrint('❌ ChatGPT: Respuesta sin éxito');
        return response ?? 'Lo siento, no pude procesar tu solicitud.';
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error al comunicarse con ChatGPT: $e');
      debugPrint('StackTrace: $stackTrace');
      
      // Mensajes de error amigables
      if (e.toString().contains('timeout') || e is TimeoutException) {
        return 'La respuesta está tardando demasiado. Por favor, inténtalo de nuevo.';
      } else if (e.toString().contains('unauthenticated')) {
        return 'Debes iniciar sesión para usar el asistente.';
      } else if (e.toString().contains('network')) {
        return 'Error de conexión. Verifica tu internet e inténtalo de nuevo.';
      }
      
      return 'Lo siento, ocurrió un error. Por favor, inténtalo más tarde.';
    }
  }

  /// Obtiene una respuesta rápida (sin historial)
  static Future<String?> getQuickResponse(String message) async {
    return await sendMessage(message: message);
  }

  /// Stream para respuestas en tiempo real (simulado)
  static Stream<String> sendMessageStream({
    required String message,
    List<Map<String, String>>? conversationHistory,
  }) async* {
    try {
      final response = await sendMessage(
        message: message,
        conversationHistory: conversationHistory,
      );
      
      if (response != null) {
        // Simular escritura progresiva
        final words = response.split(' ');
        String partial = '';
        
        for (int i = 0; i < words.length; i++) {
          partial += '${words[i]} ';
          yield partial.trim();
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
    } catch (e) {
      debugPrint('❌ Error en stream: $e');
    }
  }
}
