import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/helpers/image_filters_helper.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

/// Pantalla para editar fotos con filtros (estilo Instagram)
class EditPhotoScreen extends StatefulWidget {
  final File imageFile;
  final Function(File?) onSave;

  const EditPhotoScreen({
    super.key,
    required this.imageFile,
    required this.onSave,
  });

  @override
  State<EditPhotoScreen> createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> {
  String _selectedFilter = 'original';
  File? _filteredImage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _filteredImage = widget.imageFile;
  }

  Future<void> _applyFilter(String filterName) async {
    if (filterName == 'original') {
      setState(() {
        _selectedFilter = filterName;
        _filteredImage = widget.imageFile;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _selectedFilter = filterName;
    });

    try {
      final File? filtered = await ImageFiltersHelper.applyFilter(
        imageFile: widget.imageFile,
        filterName: filterName,
        intensity: 1.0,
      );

      if (filtered != null && mounted) {
        setState(() {
          _filteredImage = filtered;
          _isProcessing = false;
        });
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        Get.snackbar(
          'Error',
          'Error al aplicar filtro: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void _savePhoto() {
    widget.onSave(_filteredImage);
    Get.back(result: _filteredImage);
  }

  @override
  Widget build(BuildContext context) {
    final filters = ImageFiltersHelper.getAvailableFilters();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(IconlyLight.arrowLeft2, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Editar Foto',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _savePhoto,
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview de la imagen con filtro
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: _isProcessing
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _filteredImage != null
                      ? Center(
                          child: Image.file(
                            _filteredImage!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.image, size: 64, color: Colors.white),
                        ),
            ),
          ),

          // Selector de filtros (estilo Instagram)
          Container(
            height: 120,
            color: Colors.black,
            child: Column(
              children: [
                // Barra de filtros horizontal
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: filters.length,
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      final isSelected = _selectedFilter == filter['name'];
                      
                      return GestureDetector(
                        onTap: () => _applyFilter(filter['name'] as String),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 80,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Preview del filtro en miniatura
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Imagen de preview con filtro
                                      Image.file(
                                        widget.imageFile,
                                        fit: BoxFit.cover,
                                        cacheWidth: 70,
                                        cacheHeight: 70,
                                      ),
                                      // Overlay del filtro (simplificado)
                                      if (filter['name'] != 'original')
                                        Container(
                                          decoration: BoxDecoration(
                                            color: _getFilterOverlayColor(
                                              filter['name'] as String,
                                            ).withOpacity(0.5),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Nombre del filtro
                              Text(
                                filter['label'] as String,
                                style: TextStyle(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Color overlay para preview de filtros (simplificado)
  Color _getFilterOverlayColor(String filterName) {
    switch (filterName.toLowerCase()) {
      case 'grayscale':
      case 'blackwhite':
        return Colors.grey;
      case 'sepia':
        return const Color(0xFF8B6914);
      case 'vintage':
        return const Color(0xFF8B6914);
      case 'brightness':
        return Colors.yellow;
      case 'contrast':
        return Colors.blue;
      case 'saturation':
        return Colors.purple;
      case 'blur':
        return Colors.white;
      case 'invert':
        return Colors.cyan;
      default:
        return Colors.transparent;
    }
  }
}

