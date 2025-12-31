import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:chat_messenger/controllers/product_controller.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ProductController productController = Get.find();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCategory = 'Aceite';
  final List<String> _categories = ['Aceite', 'Bebidas', 'Fruta', 'Snacks', 'Pan'];
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _saveProduct() {
    if (_nameController.text.isEmpty || 
        _priceController.text.isEmpty || 
        _imageFile == null) {
      Get.snackbar(
        'Error',
        'Por favor completa todos los campos obligatorios e incluye una imagen',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    productController.addProduct(
      _selectedCategory,
      _nameController.text,
      _descriptionController.text,
      double.tryParse(_priceController.text) ?? 0.0,
      _imageFile!.path, // Guardamos path local temporalmente
    );

    Get.back(); // Cerrar pantalla
    Get.snackbar(
      'Éxito',
      'Producto agregado correctamente',
      backgroundColor: const Color(0xFFD4AF37),
      colorText: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
         backgroundColor: Colors.black,
         elevation: 0,
         leading: IconButton(
           icon: const Icon(Icons.arrow_back_ios, color: goldColor),
           onPressed: () => Get.back(),
         ),
         title: const Text('Agregar Producto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
         centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _imageFile != null ? goldColor.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                    width: _imageFile != null ? 2 : 1,
                    style: _imageFile != null ? BorderStyle.solid : BorderStyle.none
                  ),
                  boxShadow: [
                    if (_imageFile != null)
                      BoxShadow(
                        color: goldColor.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    )
                  : Stack(
                      children: [
                        // Dashed border effect simulation
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: goldColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(IconlyBold.image, size: 40, color: goldColor.withOpacity(0.8)),
                              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                               .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2000.ms),
                              const SizedBox(height: 16),
                              Text(
                                'Toca para agregar imagen',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
            
            const SizedBox(height: 32),
            
            // Name
            _buildAnimatedTextField(
              controller: _nameController,
              label: 'Nombre del Producto',
              icon: IconlyLight.bag,
              delay: 100,
            ),
            
            const SizedBox(height: 20),
            
            // Price
             _buildAnimatedTextField(
              controller: _priceController,
              label: 'Precio (€)',
              icon: IconlyLight.discount,
              keyboardType: TextInputType.number,
              delay: 200,
            ),

            const SizedBox(height: 20),
            
            // Category Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(16),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: goldColor),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items: _categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(IconlyLight.category, size: 18, color: goldColor.withOpacity(0.7)),
                          const SizedBox(width: 12),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideX(begin: 0.1, end: 0),

            const SizedBox(height: 20),

            // Description
            _buildAnimatedTextField(
              controller: _descriptionController,
              label: 'Descripción (Opcional)',
              icon: IconlyLight.document,
              maxLines: 4,
              delay: 400,
            ),

            const SizedBox(height: 48),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  shadowColor: goldColor.withOpacity(0.4),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Guardar Producto',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 600.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: Curves.easeOutBack),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int delay = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFFD4AF37).withOpacity(0.8), size: 22),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 500.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}
