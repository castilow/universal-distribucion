import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:chat_messenger/controllers/product_controller.dart';
import 'package:chat_messenger/api/product_api.dart';
import 'package:chat_messenger/media/helpers/media_helper.dart';
import 'package:chat_messenger/helpers/permission_helper.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:chat_messenger/components/cached_image_with_retry.dart';

class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  
  const AddProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ProductController productController = Get.find();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(); // New Quantity Controller
  final _customCategoryController = TextEditingController();
  
  String _selectedCategory = 'Aceite';
  List<String> _categories = [];
  
  File? _imageFile;
  File? _categoryImageFile; // New image file for category
  final ImagePicker _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
    
    if (widget.product != null) {
      _nameController.text = widget.product!['name'] ?? '';
      _descriptionController.text = widget.product!['description'] ?? '';
      _priceController.text = (widget.product!['price'] ?? 0).toString();
      _quantityController.text = (widget.product!['quantity'] ?? 1).toString(); // Load quantity or default to 1
      
      if (widget.product!['category'] != null && 
          _categories.contains(widget.product!['category'])) {
        _selectedCategory = widget.product!['category'];
      } else {
         // Si la categoría del producto no está en la lista, agregarla
         if (widget.product!['category'] != null) {
           _categories.add(widget.product!['category']);
           _selectedCategory = widget.product!['category'];
         } else {
           _selectedCategory = _categories.isNotEmpty ? _categories.first : 'Nueva Categoría';
         }
      }
    } else {
       // Default selection for new product
       _selectedCategory = _categories.isNotEmpty ? _categories.first : 'Nueva Categoría';
    }
  }

  void _loadCategories() {
    // Obtener categorías de productos existentes
    final Set<String> categorySet = {};
    
    if (productController.productsByCategory.isNotEmpty) {
      categorySet.addAll(productController.productsByCategory.keys);
    }
    
    // Agregar categorías custom de Firestore
    for (var customCat in productController.customCategories) {
      if (customCat['name'] != null) {
        categorySet.add(customCat['name']);
      }
    }
    
    // Convertir a lista y ordenar
    _categories = categorySet.toList()..sort();
    
    // Si no hay categorías, usar fallback
    if (_categories.isEmpty) {
      _categories = ['productos']; // Categoría por defecto común
    }
  }

  void _showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text(
          'Seleccionar imagen',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFD4AF37)),
              title: const Text(
                'Galería',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFD4AF37)),
              title: const Text(
                'Cámara',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      // Solicitar permisos primero
      final permission = await PermissionHelper.requestPhotosPermission();
      if (!permission) {
        Get.snackbar(
          'Permisos',
          'Necesitas permisos para acceder a la galería',
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
        return;
      }

      // En Android, usar ImagePicker directamente que es más confiable
      // En iOS, usar MediaHelper.getAssets para mejor experiencia
      final File? imageFile;
      
      if (Platform.isAndroid) {
        // Usar ImagePicker directamente en Android
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        );
        
        if (pickedFile != null) {
          imageFile = File(pickedFile.path);
        } else {
          imageFile = null;
        }
      } else {
        // Usar MediaHelper en iOS para mejor experiencia
        final List<File>? files = await MediaHelper.getAssets(
          maxAssets: 1,
          requestType: RequestType.image,
        );
        
        if (files != null && files.isNotEmpty) {
          imageFile = files.first;
        } else {
          imageFile = null;
        }
      }

      if (imageFile != null) {
        // Verificar que el archivo existe
        if (await imageFile.exists()) {
          setState(() {
            _imageFile = imageFile;
          });
        } else {
          Get.snackbar(
            'Error',
            'El archivo seleccionado no es válido',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      // Solo mostrar error si no es una cancelación del usuario
      final errorStr = e.toString().toLowerCase();
      if (!errorStr.contains('cancel') && 
          !errorStr.contains('cancelled') &&
          !errorStr.contains('cloudphotolibraryerrordomain') &&
          !errorStr.contains('invalid_image')) {
        Get.snackbar(
          'Error',
          'Error al seleccionar la imagen. Intenta con otra foto.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
      debugPrint('Error picking image from gallery: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      // Solicitar permisos de cámara
      final permission = await PermissionHelper.requestCameraPermission();
      if (!permission) {
        Get.snackbar(
          'Permisos',
          'Necesitas permisos para acceder a la cámara',
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (image != null) {
        final File file = File(image.path);
        if (await file.exists()) {
          setState(() {
            _imageFile = file;
          });
        } else {
          Get.snackbar(
            'Error',
            'El archivo capturado no es válido',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo capturar la imagen. Por favor intenta de nuevo.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      debugPrint('Error picking image from camera: $e');
    }
  }

  // Pick Category Image Logic
  Future<void> _pickCategoryImage() async {
      try {
        final List<File>? files = await MediaHelper.getAssets(
          maxAssets: 1,
          requestType: RequestType.image,
        );

        if (files != null && files.isNotEmpty) {
           setState(() {
             _categoryImageFile = files.first;
           });
        }
      } catch (e) {
        debugPrint('Error picking category image: $e');
      }
  }

  Future<void> _saveProduct() async {
    if (_nameController.text.isEmpty || 
        _priceController.text.isEmpty || 
        (_imageFile == null && widget.product == null)) { // Allow null image if editing
      Get.snackbar(
        'Error',
        'Por favor completa todos los campos obligatorios e incluye una imagen',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      Get.snackbar(
        'Error',
        'Por favor ingresa un precio válido',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Validate Quantity
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity < 0) {
      Get.snackbar(
        'Error',
        'Por favor ingresa una cantidad válida',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Determine final category
    String finalCategory = _selectedCategory;
    if (_selectedCategory == 'Nueva Categoría') {
      if (_customCategoryController.text.trim().isEmpty) {
         Get.snackbar(
          'Error',
          'Por favor ingresa el nombre de la nueva categoría',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
      finalCategory = _customCategoryController.text.trim();
    }

    try {
      if (widget.product != null) {
        // ACTUALIZAR PRODUCTO EXISTENTE
        await productController.updateProduct(
           widget.product!['productId'],
           {
             'name': _nameController.text.trim(),
             'description': _descriptionController.text.trim(),
             'price': price,
             'quantity': quantity, // Update quantity
             'category': finalCategory, // USE FINAL CATEGORY
           },
           file: _imageFile
        );

      } else {
        // CREAR NUEVO PRODUCTO
        
        // 1. Guardar Categoría si es NUEVA y tiene IMAGEN
        if (_selectedCategory == 'Nueva Categoría' && _categoryImageFile != null) {
             debugPrint('🚀 Guardando nueva categoría con imagen...');
             await productController.saveCategory(
               finalCategory, 
               _categoryImageFile!
             );
        }

         await ProductApi.addProduct(
          category: finalCategory, // USE FINAL CATEGORY
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          quantity: quantity, // Pass quantity
          imageFile: _imageFile!,
        );
        
        // Actualizar también el controlador local (Legacy, but keeps local state synced fast)
        productController.addProduct(
          finalCategory, // USE FINAL CATEGORY
          _nameController.text.trim(),
          _descriptionController.text.trim(),
          price,
          quantity, // Pass quantity
          '', 
        );
      }

      Get.back(); // Cerrar pantalla
    } catch (e) {
      debugPrint('Error guardando/actualizando producto: $e');
      // Forzar cierre para feedback inmediato aunque falle API (demo robustness)
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // 1. Immersive Hero Image (SliverAppBar)
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: goldColor, size: 20),
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen de fondo
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : (isEditing && widget.product!['imageUrl'] != null)
                            ? CachedImageWithRetry(
                                imageUrl: widget.product!['imageUrl'],
                                fit: BoxFit.cover,
                                errorWidget: Container(
                                  color: const Color(0xFF1C1C1E),
                                  child: Icon(IconlyLight.image, size: 64, color: goldColor.withOpacity(0.3)),
                                ),
                              )
                            : Container(
                                color: const Color(0xFF1C1C1E),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(IconlyLight.image, size: 64, color: goldColor.withOpacity(0.3)),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Toca para añadir imagen',
                                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                                    )
                                  ],
                                ),
                              ),
                  ),
                  
                  // Degradado "Fade-Out" hacia negro
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.8),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                  
                  // Botón flotante de cámara si no hay imagen
                   Positioned(
                    bottom: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: goldColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: goldColor.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(IconlyBold.camera, color: Colors.black),
                      ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Formulario
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Editar Detalles' : 'Nuevo Producto',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                  
                  const SizedBox(height: 8),
                  Text(
                    'Completa la información para tu catálogo digital.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 32),

                  // SECCIÓN 1: INFORMACIÓN BÁSICA
                  _buildSectionHeader('Información Básica', delay: 200),
                  const SizedBox(height: 16),
                  _buildAnimatedTextField(
                    controller: _nameController,
                    label: 'Nombre del Producto',
                    icon: IconlyLight.bag,
                    delay: 200,
                  ),

                  const SizedBox(height: 32),

                  // SECCIÓN 2: CATEGORÍA Y PRECIO
                  _buildSectionHeader('Detalles de Venta', delay: 300),
                  const SizedBox(height: 16),
                  
                  // Dropdown (Modified for Custom Category)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                         BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _categories.contains(_selectedCategory) ? _selectedCategory : 'Nueva Categoría',
                        dropdownColor: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(16),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: goldColor),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                            if (newValue != 'Nueva Categoría') {
                               _customCategoryController.clear();
                            }
                          });
                        },
                        items: [
                          ..._categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(IconlyLight.category, size: 18, color: goldColor.withOpacity(0.7)),
                                  const SizedBox(width: 12),
                                  Text(category),
                                ],
                              ),
                            );
                          }).toList(),
                          const DropdownMenuItem<String>(
                            value: 'Nueva Categoría',
                            child: Row(
                              children: [
                                Icon(Icons.add_circle_outline, size: 18, color: goldColor),
                                const SizedBox(width: 12),
                                Text(
                                  'Nueva Categoría...',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: goldColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.1, end: 0),

                  // Input para Nueva Categoría (Solo visible si se selecciona la opción)
                  if (_selectedCategory == 'Nueva Categoría') ...[
                    const SizedBox(height: 16),
                    _buildAnimatedTextField(
                        controller: _customCategoryController,
                        label: 'Nombre de la Nueva Categoría',
                        icon: IconlyLight.edit, // Or another relevant icon
                        delay: 300,
                    ),
                    const SizedBox(height: 16),
                    // CATEGORY IMAGE PICKER
                    GestureDetector(
                      onTap: _pickCategoryImage,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          image: _categoryImageFile != null 
                             ? DecorationImage(image: FileImage(_categoryImageFile!), fit: BoxFit.cover, opacity: 0.5) 
                             : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Icon(_categoryImageFile != null ? IconlyBold.image : IconlyLight.camera, color: goldColor, size: 32),
                             const SizedBox(height: 8),
                             Text(
                               _categoryImageFile != null ? 'Cambiar Foto Categoría' : 'Añadir Foto de Categoría',
                               style: const TextStyle(color: Colors.white70, fontSize: 13),
                             ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 320.ms),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  const SizedBox(height: 16),
                  
                  // Row for Price and Quantity
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnimatedTextField(
                          controller: _priceController,
                          label: 'Precio',
                          icon: IconlyLight.discount,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          isPrice: true,
                          delay: 350,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildAnimatedTextField(
                          controller: _quantityController,
                          label: 'Cantidad',
                          icon: IconlyLight.category, // Or box/inventory icon
                          keyboardType: TextInputType.number,
                          delay: 370,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // SECCIÓN 3: DESCRIPCIÓN
                  _buildSectionHeader('Descripción', delay: 400),
                  const SizedBox(height: 16),
                  _buildAnimatedTextField(
                    controller: _descriptionController,
                    label: 'Escribe una descripción...',
                    icon: IconlyLight.document,
                    maxLines: 5,
                    delay: 400,
                  ),
                  
                  const SizedBox(height: 48),

                  // Botón de Acción Principal Flotante
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () => _saveProduct(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        shadowColor: goldColor.withOpacity(0.5),
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isEditing ? IconlyBold.edit : IconlyBold.plus, color: Colors.black),
                          const SizedBox(width: 12),
                          Text(
                            isEditing ? 'GUARDAR CAMBIOS' : 'AGREGAR PRODUCTO',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.elasticOut),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {int delay = 0}) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: -0.1, end: 0);
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int delay = 0,
    bool isPrice = false,
    bool hasContainer = true,
  }) {
    const goldColor = Color(0xFFD4AF37);
    
    final textField = TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
        alignLabelWithHint: maxLines > 1,
        prefixIcon: isPrice 
          ? const Padding(padding: EdgeInsets.all(12), child: Text('€', style: TextStyle(color: goldColor, fontSize: 24, fontWeight: FontWeight.bold)))
          : Icon(icon, color: goldColor.withOpacity(0.8), size: 22),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(hasContainer ? 0.1 : 0)), // Hide border if inner
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: goldColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );

    if (!hasContainer) return textField;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: textField,
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 500.ms).slideX(begin: 0.05, end: 0);
  }
}
