import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat_messenger/config/app_config.dart';

/// API para aplicar filtros profesionales a imágenes
/// Soporta múltiples servicios: Cloudinary, Imgix, y APIs personalizadas
class FiltersApi {
  // ==================== CLOUDINARY ====================
  static const String cloudinaryCloudName = AppConfig.cloudinaryCloudName;
  static const String cloudinaryApiKey = AppConfig.cloudinaryApiKey;
  static const String cloudinaryApiSecret = AppConfig.cloudinaryApiSecret;
  static const String cloudinaryBaseUrl = 'https://api.cloudinary.com/v1_1/$cloudinaryCloudName';

  // ==================== IMGIX ====================
  static const String imgixDomain = AppConfig.imgixDomain;
  static const String imgixApiKey = AppConfig.imgixApiKey;

  // ==================== OTROS SERVICIOS ====================
  static const String customFiltersApiUrl = AppConfig.customFiltersApiUrl;

  /// Aplicar filtro profesional a una imagen usando API externa
  /// 
  /// [imageFile] - Archivo de imagen a procesar
  /// [filterName] - Nombre del filtro a aplicar
  /// [intensity] - Intensidad del filtro (0.0 a 1.0)
  /// [service] - Servicio a usar: 'cloudinary', 'imgix', o 'custom'
  /// 
  /// Retorna la URL de la imagen procesada o el archivo local
  static Future<File?> applyFilter({
    required File imageFile,
    required String filterName,
    double intensity = 1.0,
    String service = 'cloudinary',
  }) async {
    switch (service.toLowerCase()) {
      case 'cloudinary':
        return await _applyFilterCloudinary(imageFile, filterName, intensity);
      case 'imgix':
        return await _applyFilterImgix(imageFile, filterName, intensity);
      case 'custom':
        return await _applyFilterCustom(imageFile, filterName, intensity);
      default:
        throw Exception('Servicio no soportado: $service');
    }
  }

  /// Aplicar filtro usando Cloudinary (recomendado - muchos filtros profesionales)
  static Future<File?> _applyFilterCloudinary(
    File imageFile,
    String filterName,
    double intensity,
  ) async {
    try {
      // Subir imagen a Cloudinary
      final uploadUrl = '$cloudinaryBaseUrl/image/upload';
      
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields.addAll({
        'api_key': cloudinaryApiKey,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      
      // Agregar archivo
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Aplicar filtro según el nombre
      String transformation = _getCloudinaryTransformation(filterName, intensity);
      if (transformation.isNotEmpty) {
        request.fields['transformation'] = transformation;
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        final String imageUrl = data['secure_url'] ?? data['url'];
        
        // Descargar imagen procesada y guardarla localmente
        final http.Response imageResponse = await http.get(Uri.parse(imageUrl));
        final String outputPath = imageFile.path.replaceAll(
          RegExp(r'\.[^.]+$'),
          '_filtered_$filterName.jpg',
        );
        final File outputFile = File(outputPath);
        await outputFile.writeAsBytes(imageResponse.bodyBytes);
        
        return outputFile;
      } else {
        throw Exception('Error al aplicar filtro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al aplicar filtro Cloudinary: $e');
    }
  }

  /// Aplicar filtro usando Imgix (rápido y eficiente)
  static Future<File?> _applyFilterImgix(
    File imageFile,
    String filterName,
    double intensity,
  ) async {
    try {
      // Subir imagen primero (o usar URL si ya está en la nube)
      // Para Imgix, necesitas tener la imagen en un servicio compatible
      // o subirla primero a un bucket compatible
      
      // Esta es una implementación simplificada
      // En producción, necesitarías subir la imagen a S3/Cloud Storage primero
      throw UnimplementedError('Imgix requiere configuración adicional de storage');
    } catch (e) {
      throw Exception('Error al aplicar filtro Imgix: $e');
    }
  }

  /// Aplicar filtro usando API personalizada
  static Future<File?> _applyFilterCustom(
    File imageFile,
    String filterName,
    double intensity,
  ) async {
    try {
      if (customFiltersApiUrl.isEmpty) {
        throw Exception('URL de API personalizada no configurada');
      }

      final request = http.MultipartRequest('POST', Uri.parse(customFiltersApiUrl));
      
      // Agregar archivo
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      // Agregar parámetros
      request.fields.addAll({
        'filter': filterName,
        'intensity': intensity.toString(),
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        final String? imageUrl = data['url'] ?? data['image_url'];
        
        if (imageUrl != null) {
          // Descargar imagen procesada
          final http.Response imageResponse = await http.get(Uri.parse(imageUrl));
          final String outputPath = imageFile.path.replaceAll(
            RegExp(r'\.[^.]+$'),
            '_filtered_$filterName.jpg',
          );
          final File outputFile = File(outputPath);
          await outputFile.writeAsBytes(imageResponse.bodyBytes);
          
          return outputFile;
        }
      }
      
      throw Exception('Error al aplicar filtro: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error al aplicar filtro personalizado: $e');
    }
  }

  /// Obtener transformación de Cloudinary según el filtro
  /// Cloudinary tiene muchos filtros profesionales predefinidos
  static String _getCloudinaryTransformation(String filterName, double intensity) {
    switch (filterName.toLowerCase()) {
      case 'vintage':
        return 'e_sepia:${(intensity * 100).toInt()}';
      case 'blackwhite':
      case 'grayscale':
        return 'e_grayscale';
      case 'sepia':
        return 'e_sepia:${(intensity * 100).toInt()}';
      case 'brightness':
        return 'e_brightness:${((intensity - 0.5) * 100).toInt()}';
      case 'contrast':
        return 'e_contrast:${((intensity - 0.5) * 100).toInt()}';
      case 'saturation':
        return 'e_saturation:${((intensity - 0.5) * 100).toInt()}';
      case 'blur':
        return 'e_blur:${(intensity * 1000).toInt()}';
      case 'sharpen':
        return 'e_sharpen:${(intensity * 100).toInt()}';
      case 'artistic':
        return 'e_art:zorro';
      case 'cartoon':
        return 'e_cartoonify';
      // Filtros profesionales adicionales de Cloudinary
      case 'oil_paint':
        return 'e_oil_paint:${(intensity * 10).toInt()}';
      case 'pixelate':
        return 'e_pixelate:${(intensity * 20).toInt()}';
      case 'vignette':
        return 'e_vignette:${(intensity * 100).toInt()}';
      case 'saturation_boost':
        return 'e_saturation:${(intensity * 200).toInt()}';
      case 'hue_shift':
        return 'e_hue:${(intensity * 360).toInt()}';
      case 'gamma':
        return 'e_gamma:${intensity}';
      case 'red_eye':
        return 'e_redeye';
      case 'improve':
        return 'e_improve';
      case 'auto_contrast':
        return 'e_auto_contrast';
      case 'auto_brightness':
        return 'e_auto_brightness';
      case 'auto_color':
        return 'e_auto_color';
      default:
        return '';
    }
  }

  /// Lista de filtros profesionales disponibles
  /// Incluye filtros básicos y avanzados de Cloudinary
  static List<Map<String, dynamic>> getAvailableFilters({String service = 'cloudinary'}) {
    if (service == 'cloudinary') {
      return [
        {'name': 'original', 'label': 'Original', 'icon': '🎨', 'category': 'basic'},
        {'name': 'vintage', 'label': 'Vintage', 'icon': '📷', 'category': 'style'},
        {'name': 'blackwhite', 'label': 'Blanco y Negro', 'icon': '⚫', 'category': 'style'},
        {'name': 'sepia', 'label': 'Sepia', 'icon': '🟤', 'category': 'style'},
        {'name': 'brightness', 'label': 'Brillo', 'icon': '☀️', 'category': 'adjust'},
        {'name': 'contrast', 'label': 'Contraste', 'icon': '🔆', 'category': 'adjust'},
        {'name': 'saturation', 'label': 'Saturación', 'icon': '🌈', 'category': 'adjust'},
        {'name': 'blur', 'label': 'Desenfoque', 'icon': '💫', 'category': 'effect'},
        {'name': 'sharpen', 'label': 'Nitidez', 'icon': '✨', 'category': 'adjust'},
        {'name': 'artistic', 'label': 'Artístico', 'icon': '🎭', 'category': 'artistic'},
        {'name': 'cartoon', 'label': 'Caricatura', 'icon': '🎨', 'category': 'artistic'},
        {'name': 'oil_paint', 'label': 'Pintura al Óleo', 'icon': '🖼️', 'category': 'artistic'},
        {'name': 'pixelate', 'label': 'Pixelado', 'icon': '🔲', 'category': 'effect'},
        {'name': 'vignette', 'label': 'Viñeta', 'icon': '⭕', 'category': 'effect'},
        {'name': 'saturation_boost', 'label': 'Saturación Boost', 'icon': '🌈', 'category': 'adjust'},
        {'name': 'improve', 'label': 'Mejorar Auto', 'icon': '✨', 'category': 'auto'},
        {'name': 'auto_contrast', 'label': 'Contraste Auto', 'icon': '⚡', 'category': 'auto'},
        {'name': 'auto_brightness', 'label': 'Brillo Auto', 'icon': '💡', 'category': 'auto'},
        {'name': 'auto_color', 'label': 'Color Auto', 'icon': '🎨', 'category': 'auto'},
      ];
    }
    
    // Filtros básicos para otros servicios
    return [
      {'name': 'original', 'label': 'Original', 'icon': '🎨'},
      {'name': 'vintage', 'label': 'Vintage', 'icon': '📷'},
      {'name': 'blackwhite', 'label': 'Blanco y Negro', 'icon': '⚫'},
      {'name': 'sepia', 'label': 'Sepia', 'icon': '🟤'},
    ];
  }

  /// Obtener información sobre los servicios disponibles
  static Map<String, dynamic> getServiceInfo() {
    return {
      'cloudinary': {
        'name': 'Cloudinary',
        'description': 'Servicio profesional con más de 100 filtros y efectos',
        'features': [
          'Filtros artísticos avanzados',
          'Ajustes automáticos',
          'Efectos especiales',
          'Procesamiento en la nube',
        ],
        'pricing': 'Plan gratuito disponible',
        'website': 'https://cloudinary.com',
      },
      'imgix': {
        'name': 'Imgix',
        'description': 'CDN con transformaciones de imagen en tiempo real',
        'features': [
          'Transformaciones rápidas',
          'CDN global',
          'Optimización automática',
        ],
        'pricing': 'Plan gratuito disponible',
        'website': 'https://imgix.com',
      },
      'custom': {
        'name': 'API Personalizada',
        'description': 'Conecta tu propia API de filtros',
        'features': [
          'Control total',
          'Filtros personalizados',
        ],
        'pricing': 'Depende de tu infraestructura',
        'website': null,
      },
    };
  }
}

