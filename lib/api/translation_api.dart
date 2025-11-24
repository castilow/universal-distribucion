import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// API para traducción de mensajes usando Google Cloud Translation
abstract class TranslationApi {
  static final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  /// Traduce un mensaje a un idioma específico
  static Future<String?> translateMessage({
    required String messageText,
    required String targetLanguage,
  }) async {
    try {
      debugPrint('[TranslationApi] Translating to: $targetLanguage');
      debugPrint('[TranslationApi] Text: $messageText');

      // Llamar a la función de Firebase
      final result = await _functions
          .httpsCallable('translateMessageOnDemand')
          .call({
        'messageText': messageText,
        'targetLanguage': targetLanguage,
      });

      debugPrint('[TranslationApi] Result: ${result.data}');

      // Extraer el texto traducido
      final data = result.data as Map<String, dynamic>;
      final translatedText = data['translatedText'] as String?;
      final wasTranslated = data['wasTranslated'] as bool? ?? false;

      if (wasTranslated && translatedText != null) {
        debugPrint('[TranslationApi] Translation successful: $translatedText');
        return translatedText;
      } else {
        debugPrint('[TranslationApi] No translation needed (same language)');
        return null; // Mismo idioma, no se tradujo
      }
    } catch (e) {
      debugPrint('[TranslationApi] Error: $e');
      return null; // En caso de error, devolver null para usar el original
    }
  }

  /// Traduce un mensaje y actualiza el objeto Message con la traducción
  static Future<Map<String, String>?> translateAndCache({
    required String messageText,
    required String targetLanguage,
  }) async {
    try {
      debugPrint('[TranslationApi] translateAndCache called');
      debugPrint('[TranslationApi] messageText: "$messageText" (length: ${messageText.length})');
      debugPrint('[TranslationApi] targetLanguage: "$targetLanguage" (length: ${targetLanguage.length})');
      
      // Validar que los parámetros no estén vacíos
      if (messageText.trim().isEmpty) {
        debugPrint('[TranslationApi] ❌ ERROR: messageText is empty');
        return null;
      }
      
      if (targetLanguage.trim().isEmpty) {
        debugPrint('[TranslationApi] ❌ ERROR: targetLanguage is empty');
        return null;
      }
      
      // Preparar los datos para la función
      final callData = {
        'messageText': messageText.trim(),
        'targetLanguage': targetLanguage.trim(),
      };
      
      debugPrint('[TranslationApi] Calling function with data: $callData');
      
      // Llamar a la función con timeout
      final result = await _functions
          .httpsCallable('translateMessageOnDemand')
          .call(callData)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('[TranslationApi] ❌ Function call timeout after 30 seconds');
              throw TimeoutException('Translation function call timed out', const Duration(seconds: 30));
            },
          );

      debugPrint('[TranslationApi] Function call completed');
      debugPrint('[TranslationApi] Result type: ${result.data.runtimeType}');
      debugPrint('[TranslationApi] Result data: ${result.data}');

      if (result.data == null) {
        debugPrint('[TranslationApi] ❌ Result data is null');
        return null;
      }

      final data = result.data as Map<String, dynamic>;
      final translatedText = data['translatedText'] as String?;
      final wasTranslated = data['wasTranslated'] as bool? ?? false;

      debugPrint('[TranslationApi] translatedText: "$translatedText"');
      debugPrint('[TranslationApi] wasTranslated: $wasTranslated');

      if (wasTranslated && translatedText != null && translatedText.isNotEmpty) {
        debugPrint('[TranslationApi] ✅ Translation successful: "$translatedText"');
        return {targetLanguage: translatedText};
      }

      debugPrint('[TranslationApi] ❌ No translation returned (wasTranslated: $wasTranslated, translatedText: ${translatedText != null ? "exists" : "null"})');
      return null;
    } catch (e, stackTrace) {
      debugPrint('[TranslationApi] ❌ translateAndCache error: $e');
      debugPrint('[TranslationApi] Error type: ${e.runtimeType}');
      debugPrint('[TranslationApi] Stack trace: $stackTrace');
      
      // Log detallado del error
      if (e.toString().contains('invalid-argument')) {
        debugPrint('[TranslationApi] ❌ INVALID ARGUMENT ERROR - Check Firebase Function logs');
      }
      
      return null;
    }
  }
}



