import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfImportService {
  /// Lee el PDF y extrae: código de artículo, precio y descripción
  static Future<List<Map<String, dynamic>>> parseProductsFromPdf(File pdfFile) async {
    PdfDocument? document;
    try {
      debugPrint('📄 [PDF_IMPORT] Leyendo PDF: ${pdfFile.path}');
      
      // Validar que el archivo existe
      if (!await pdfFile.exists()) {
        throw Exception('El archivo PDF no existe');
      }
      
      // Validar tamaño del archivo
      // NOTA IMPORTANTE: PDFs grandes (>50 MB) pueden causar problemas de memoria en dispositivos móviles
      // porque Syncfusion carga todo el PDF en memoria. Se recomienda comprimir PDFs grandes antes de importarlos.
      final fileSize = await pdfFile.length();
      const maxRecommendedSize = 50 * 1024 * 1024; // 50 MB recomendado
      const maxSize = 100 * 1024 * 1024; // 100 MB máximo absoluto
      
      if (fileSize > maxSize) {
        throw Exception('El archivo PDF es demasiado grande (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB). El tamaño máximo permitido es 100 MB. Por favor, comprime o divide el PDF antes de importarlo.');
      }
      
      if (fileSize > maxRecommendedSize) {
        debugPrint('⚠️ [PDF_IMPORT] ADVERTENCIA: PDF grande detectado (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB). Puede causar problemas de memoria en dispositivos móviles.');
      }
      
      debugPrint('📄 [PDF_IMPORT] Tamaño del archivo: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      
      // Leer el PDF usando syncfusion
      final bytes = await pdfFile.readAsBytes();
      document = PdfDocument(inputBytes: bytes);
      
      if (document.pages.count == 0) {
        throw Exception('El PDF no tiene páginas');
      }
      
      final totalPages = document.pages.count;
      debugPrint('📄 [PDF_IMPORT] Total de páginas: $totalPages');
      
      List<Map<String, dynamic>> allProducts = [];
      
      // Procesar PDF página por página para evitar problemas de memoria con PDFs grandes
      final textExtractor = PdfTextExtractor(document);
      const int batchSize = 10; // Procesar 10 páginas a la vez
      
      for (int startPage = 0; startPage < totalPages; startPage += batchSize) {
        final endPage = (startPage + batchSize - 1 < totalPages) 
            ? startPage + batchSize - 1 
            : totalPages - 1;
        
        debugPrint('📄 [PDF_IMPORT] Procesando páginas ${startPage + 1}-${endPage + 1} de $totalPages');
        
        // Extraer texto de este lote de páginas
        final text = textExtractor.extractText(startPageIndex: startPage, endPageIndex: endPage);
        
        if (text.trim().isNotEmpty) {
          // Extraer productos del texto de estas páginas
          final products = _extractProductsFromText(text);
          allProducts.addAll(products);
          debugPrint('📄 [PDF_IMPORT] Productos encontrados en páginas ${startPage + 1}-${endPage + 1}: ${products.length}');
        }
        
        // Forzar garbage collection periódicamente para liberar memoria
        if (startPage % (batchSize * 3) == 0) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
      
      if (allProducts.isEmpty) {
        throw Exception('No se pudo extraer texto del PDF. El PDF podría estar protegido o ser una imagen escaneada');
      }
      
      debugPrint('📄 [PDF_IMPORT] Total productos encontrados: ${allProducts.length}');
      
      document.dispose();
      document = null;
      
      debugPrint('✅ [PDF_IMPORT] Total productos encontrados: ${allProducts.length}');
      return allProducts;
    } catch (e, stackTrace) {
      debugPrint('❌ [PDF_IMPORT] Error parseando PDF: $e');
      debugPrint('❌ [PDF_IMPORT] Stack trace: $stackTrace');
      
      // Asegurarse de liberar el documento incluso si hay error
      try {
        document?.dispose();
      } catch (_) {
        // Ignorar errores al liberar
      }
      
      // Convertir errores técnicos en mensajes más amigables
      String errorMessage = e.toString();
      if (errorMessage.contains('PdfDocument') || errorMessage.contains('PDF')) {
        errorMessage = 'El archivo PDF está dañado o no es válido';
      } else if (errorMessage.contains('memory') || errorMessage.contains('Memory')) {
        errorMessage = 'El PDF es muy grande. Intenta con un archivo más pequeño';
      }
      
      throw Exception(errorMessage);
    }
  }
  
  /// Parsea productos directamente desde texto (sin archivo PDF)
  /// Útil cuando ya tienes el texto extraído del PDF
  static Future<List<Map<String, dynamic>>> parseProductsFromText(String text) async {
    try {
      debugPrint('📄 [PDF_IMPORT] Parseando productos desde texto');
      debugPrint('📄 [PDF_IMPORT] Longitud del texto: ${text.length} caracteres');
      
      final products = _extractProductsFromText(text);
      
      debugPrint('✅ [PDF_IMPORT] Total productos encontrados: ${products.length}');
      return products;
    } catch (e, stackTrace) {
      debugPrint('❌ [PDF_IMPORT] Error parseando texto: $e');
      debugPrint('❌ [PDF_IMPORT] Stack trace: $stackTrace');
      throw Exception('Error al procesar el texto: ${e.toString()}');
    }
  }

  /// Extrae productos del texto del PDF
  /// Busca: Código de artículo, Precio, Descripción
  /// Formato esperado: "CODIGO DESCRIPCION PRECIO" (separado por espacios)
  /// Ejemplo: "123456 BOX SCHWEPPES CITRICOS 33CL 0,00"
  static List<Map<String, dynamic>> _extractProductsFromText(String text) {
    List<Map<String, dynamic>> products = [];
    
    // Dividir en líneas
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    
    // Filtrar líneas de encabezado, páginas y líneas inválidas
    final headerPattern = RegExp(r'(COD\.ARTICULO|DESCRIPCIÓN|PRECIO|Página \d+ de \d+|Listado de Articulos|LA ARDOSA)', caseSensitive: false);
    final invalidLinePattern = RegExp(r'^[\s\-]+$|^[\-]{1,3}\s*\d*$|^\d+\s*[\-]{1,3}$'); // Líneas solo con guiones o números con guiones
    
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      // Saltar líneas de encabezado y páginas
      if (headerPattern.hasMatch(line)) continue;
      
      // Saltar líneas inválidas (solo guiones, solo números con guiones, etc.)
      if (invalidLinePattern.hasMatch(line)) continue;
      
      // FORMATO PRINCIPAL: Tabla con código, descripción y precio
      // Formato: "CODIGO DESCRIPCION PRECIO"
      // Ejemplo: "123456 BOX SCHWEPPES CITRICOS 33CL 0,00"
      
      // Buscar precio al final de la línea (formato más común)
      // El precio tiene formato: número, número o número. número (siempre al final)
      final pricePattern = RegExp(r'(\d+[.,]\d{2,})$');
      final priceMatch = pricePattern.firstMatch(line);
      
      if (priceMatch != null) {
        final priceStr = priceMatch.group(1)!;
        final price = _parsePrice(priceStr);
        
        if (price != null) {
          // El precio está al final, todo lo anterior es código + descripción
          final beforePrice = line.substring(0, priceMatch.start).trim();
          
          if (beforePrice.isNotEmpty && beforePrice.length > 2) {
            String code = '';
            String description = '';
            
            // Intentar primero con espacios múltiples (formato de tabla)
            final partsWithMultipleSpaces = beforePrice.split(RegExp(r'\s{2,}'));
            
            if (partsWithMultipleSpaces.length >= 2) {
              // Formato: "CODIGO    DESCRIPCION"
              code = partsWithMultipleSpaces[0].trim();
              description = partsWithMultipleSpaces.sublist(1).join(' ').trim();
            } else {
              // Si no hay espacios múltiples, buscar código al inicio
              // El código puede ser: numérico (123456), alfanumérico (IVA02), o más largo (051526)
              // Patrón: código al inicio seguido de espacio(s) y luego descripción
              
              // Intentar con patrón más flexible para código (1-20 caracteres alfanuméricos)
              final codeMatch = RegExp(r'^([A-Z0-9\-]{1,20})\s+(.+)$').firstMatch(beforePrice);
              
              if (codeMatch != null) {
                code = codeMatch.group(1)!.trim();
                description = codeMatch.group(2)!.trim();
              } else {
                // Si el patrón anterior no funciona, intentar separar por el primer espacio
                final firstSpaceIndex = beforePrice.indexOf(' ');
                if (firstSpaceIndex > 0 && firstSpaceIndex < beforePrice.length - 1) {
                  code = beforePrice.substring(0, firstSpaceIndex).trim();
                  description = beforePrice.substring(firstSpaceIndex + 1).trim();
                } else {
                  // Si no hay espacio, usar toda la línea como código (caso raro)
                  code = beforePrice;
                  description = beforePrice;
                }
              }
            }
            
            // Validar código: debe tener al menos 1 carácter y no ser solo espacios
            code = code.trim();
            if (code.isNotEmpty && code.length <= 50) {
              // Limpiar descripción
              description = description.trim();
              
              // Si la descripción está vacía, usar el código como descripción
              if (description.isEmpty) {
                description = code;
              }
              
              products.add({
                'articleCode': code,
                'price': price,
                'description': description,
                'name': description,
              });
              continue;
            }
          }
        }
      }
      
      // FORMATO ALTERNATIVO: Separado por | o ; o tab (no usar - porque puede estar en descripciones)
      if (RegExp(r'[|\t;]').hasMatch(line)) {
        final parts = line.split(RegExp(r'[|\t;]'))
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .toList();
        
        if (parts.length >= 2) {
          final code = parts[0];
          double? price;
          String description = '';
          
          // Buscar precio (número con decimales)
          for (int i = parts.length - 1; i >= 1; i--) {
            final potentialPrice = _parsePrice(parts[i]);
            if (potentialPrice != null) {
              price = potentialPrice;
              if (i > 1) {
                description = parts.sublist(1, i).join(' ').trim();
              } else if (i == 1 && parts.length == 2) {
                // Solo código y precio, sin descripción
                description = code;
              }
              break;
            }
          }
          
          if (code.isNotEmpty && price != null) {
            products.add({
              'articleCode': code,
              'price': price,
              'description': description.isNotEmpty ? description : code,
              'name': description.isNotEmpty ? description : code,
            });
            continue;
          }
        }
      }
    }
    
    return products;
  }
  
  /// Convierte texto de precio a número
  /// Acepta formatos: "0,00", "1,59", "15.50", "1234.56"
  static double? _parsePrice(String priceStr) {
    try {
      // Limpiar: quitar símbolos €$£, espacios
      var cleaned = priceStr.replaceAll(RegExp(r'[€$£¥\s]'), '');
      
      // Manejar formato español (coma como decimal): "0,00" -> "0.00"
      // Manejar formato internacional (punto como decimal): "0.00" -> "0.00"
      // Si tiene coma, asumir formato español y convertir
      if (cleaned.contains(',')) {
        cleaned = cleaned.replaceAll(',', '.');
      }
      
      final price = double.tryParse(cleaned);
      
      // Validar que sea un precio razonable (entre 0.00 y 99999.99)
      // Aceptamos 0.00 ya que es un precio válido
      if (price != null && price >= 0.0 && price <= 99999.99) {
        return price;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}

