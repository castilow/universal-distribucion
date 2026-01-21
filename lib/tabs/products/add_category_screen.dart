import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:chat_messenger/controllers/product_controller.dart';
import 'package:chat_messenger/api/category_api.dart';
import 'package:chat_messenger/media/helpers/media_helper.dart';
import 'package:chat_messenger/helpers/permission_helper.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/cached_image_with_retry.dart';

class AddCategoryScreen extends StatefulWidget {
  final Map<String, dynamic>? category;
  
  const AddCategoryScreen({Key? key, this.category}) : super(key: key);

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final ProductController productController = Get.find();
  
  final _nameController = TextEditingController();
  File? _imageFile;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!['name'] ?? '';
      _existingImageUrl = widget.category!['image'] ?? widget.category!['imageUrl'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final List<File>? files = await MediaHelper.getAssets(
        maxAssets: 1,
        requestType: RequestType.image,
      );

      if (files != null && files.isNotEmpty) {
        setState(() {
          _imageFile = files.first;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _saveCategory() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor ingresa el nombre de la categoría',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final isEditing = widget.category != null;
    
    if (!isEditing && _imageFile == null) {
      Get.snackbar(
        'Error',
        'Por favor selecciona una imagen para la categoría',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (isEditing) {
        await CategoryApi.updateCategory(
          categoryId: widget.category!['id'] ?? widget.category!['categoryId'],
          name: _nameController.text.trim(),
          imageFile: _imageFile, // Opcional al editar
        );

        Get.snackbar(
          'Éxito',
          'Categoría actualizada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        await CategoryApi.addCategory(
          name: _nameController.text.trim(),
          imageFile: _imageFile!,
        );

        Get.snackbar(
          'Éxito',
          'Categoría creada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }

      // Refrescar categorías
      await productController.refreshProducts();

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al ${isEditing ? 'actualizar' : 'crear'} la categoría: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const goldColor = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF000000) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        elevation: 0,
        title: Text(
          widget.category != null ? 'Editar Categoría' : 'Nueva Categoría',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen de categoría
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: goldColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : _existingImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CachedImageWithRetry(
                              imageUrl: _existingImageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    IconlyLight.image,
                                    size: 48,
                                    color: isDarkMode ? Colors.white54 : Colors.grey[600],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Toca para cambiar imagen',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white54 : Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                IconlyLight.image,
                                size: 48,
                                color: isDarkMode ? Colors.white54 : Colors.grey[600],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Toca para seleccionar imagen',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white54 : Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Campo de nombre
            TextField(
              controller: _nameController,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: 'Nombre de la categoría',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.grey[600],
                ),
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: goldColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: goldColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: goldColor,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  IconlyLight.category,
                  color: goldColor,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botón guardar
            ElevatedButton(
              onPressed: _isLoading ? null : _saveCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      widget.category != null ? 'Actualizar Categoría' : 'Crear Categoría',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
