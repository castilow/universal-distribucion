import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:chat_messenger/api/filters_api.dart';
import 'package:chat_messenger/config/app_config.dart';

/// Helper para aplicar filtros a imágenes
/// Puede usar procesamiento local o APIs profesionales (Cloudinary, Imgix, etc.)
class ImageFiltersHelper {
  /// Preferencia: usar API si está configurada, sino usar procesamiento local
  static bool get _useApi => AppConfig.cloudinaryCloudName != "your-cloud-name" ||
                            AppConfig.customFiltersApiUrl.isNotEmpty;

  /// Aplicar filtro a una imagen
  /// 
  /// [imageFile] - Archivo de imagen
  /// [filterName] - Nombre del filtro
  /// [intensity] - Intensidad (0.0 a 1.0)
  /// [useApi] - Forzar uso de API (true) o local (false). null = automático
  /// 
  /// Retorna el archivo procesado
  static Future<File?> applyFilter({
    required File imageFile,
    required String filterName,
    double intensity = 1.0,
    bool? useApi,
  }) async {
    // Si el filtro es 'original', no procesar
    if (filterName == 'original') {
      return imageFile;
    }

    // Decidir si usar API o procesamiento local
    final bool shouldUseApi = useApi ?? _useApi;

    if (shouldUseApi) {
      try {
        // Intentar usar API profesional
        return await FiltersApi.applyFilter(
          imageFile: imageFile,
          filterName: filterName,
          intensity: intensity,
          service: 'cloudinary',
        );
      } catch (e) {
        debugPrint('Error usando API, fallback a procesamiento local: $e');
        // Fallback a procesamiento local si la API falla
        return await _applyFilterLocal(imageFile, filterName, intensity);
      }
    } else {
      // Usar procesamiento local
      return await _applyFilterLocal(imageFile, filterName, intensity);
    }
  }

  /// Aplicar filtro usando procesamiento local
  static Future<File?> _applyFilterLocal(
    File imageFile,
    String filterName,
    double intensity,
  ) async {
    try {
      // Leer imagen
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) return null;

      // Aplicar filtro según el nombre
      image = _applyLocalFilter(image, filterName, intensity);

      // Guardar imagen procesada
      final String outputPath = imageFile.path.replaceAll(
        RegExp(r'\.[^.]+$'),
        '_filtered_$filterName.jpg',
      );
      
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(img.encodeJpg(image, quality: 90));
      
      return outputFile;
    } catch (e) {
      debugPrint('Error aplicando filtro local: $e');
      return null;
    }
  }

  /// Aplicar filtro local a una imagen
  static img.Image _applyLocalFilter(
    img.Image image,
    String filterName,
    double intensity,
  ) {
    switch (filterName.toLowerCase()) {
        case 'grayscale':
        case 'blackwhite':
          return img.grayscale(image);
        case 'sepia':
          return img.sepia(image, amount: intensity);
        case 'vintage':
          return _applyVintageFilter(image, intensity);
        case 'brightness':
          return img.adjustColor(image, brightness: intensity);
        case 'contrast':
          return img.adjustColor(image, contrast: intensity);
        case 'saturation':
          return img.adjustColor(image, saturation: intensity);
        case 'blur':
          return img.gaussianBlur(image, radius: (intensity * 10).toInt());
        case 'sharpen':
          // Kernel de convolución para sharpen
          return img.convolution(
            image,
            filter: [
              0, -1, 0,
              -1, 5, -1,
              0, -1, 0,
            ],
          );
        case 'invert':
          return img.invert(image);
        case 'emboss':
          // Kernel de convolución para emboss
          return img.convolution(
            image,
            filter: [
              -2, -1, 0,
              -1, 1, 1,
              0, 1, 2,
            ],
          );
        default:
          // Sin filtro - retornar original
          return image;
      }
  }

  /// Aplicar filtro vintage (combinación de sepia y desaturación)
  static img.Image _applyVintageFilter(img.Image image, double intensity) {
    image = img.sepia(image, amount: intensity * 0.8);
    image = img.adjustColor(image, saturation: 0.5);
    return image;
  }

  /// Lista de filtros disponibles
  /// Si hay API configurada, retorna filtros profesionales adicionales
  static List<Map<String, dynamic>> getAvailableFilters() {
    if (_useApi) {
      // Usar filtros de la API (más profesionales)
      return FiltersApi.getAvailableFilters(service: 'cloudinary');
    } else {
      // Filtros locales básicos
      return [
        {'name': 'original', 'label': 'Original', 'icon': '🎨', 'category': 'basic'},
        {'name': 'grayscale', 'label': 'Blanco y Negro', 'icon': '⚫', 'category': 'style'},
        {'name': 'sepia', 'label': 'Sepia', 'icon': '🟤', 'category': 'style'},
        {'name': 'vintage', 'label': 'Vintage', 'icon': '📷', 'category': 'style'},
        {'name': 'brightness', 'label': 'Brillo', 'icon': '☀️', 'category': 'adjust'},
        {'name': 'contrast', 'label': 'Contraste', 'icon': '🔆', 'category': 'adjust'},
        {'name': 'saturation', 'label': 'Saturación', 'icon': '🌈', 'category': 'adjust'},
        {'name': 'blur', 'label': 'Desenfoque', 'icon': '💫', 'category': 'effect'},
        {'name': 'sharpen', 'label': 'Nitidez', 'icon': '✨', 'category': 'adjust'},
        {'name': 'invert', 'label': 'Invertir', 'icon': '🔄', 'category': 'effect'},
        {'name': 'emboss', 'label': 'Relieve', 'icon': '🗿', 'category': 'effect'},
      ];
    }
  }

  /// Obtener información sobre los servicios de filtros disponibles
  static Map<String, dynamic> getServiceInfo() {
    return FiltersApi.getServiceInfo();
  }
}

