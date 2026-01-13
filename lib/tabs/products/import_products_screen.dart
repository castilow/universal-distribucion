import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:chat_messenger/services/pdf_import_service.dart';
import 'package:chat_messenger/api/product_api.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/media/helpers/media_helper.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class ImportProductsScreen extends StatefulWidget {
  const ImportProductsScreen({Key? key}) : super(key: key);

  @override
  State<ImportProductsScreen> createState() => _ImportProductsScreenState();
}

class _ImportProductsScreenState extends State<ImportProductsScreen> {
  File? _pdfFile;
  File? _defaultImageFile;
  List<Map<String, dynamic>> _parsedProducts = [];
  bool _isProcessing = false;
  int _currentProgress = 0;
  int _totalProducts = 0;
  String _selectedCategory = 'Otros';
  final TextEditingController _textController = TextEditingController();
  bool _showTextInput = false;

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      
      if (result != null && result.files.single.path != null) {
        setState(() {
          _pdfFile = File(result.files.single.path!);
          _parsedProducts = [];
        });
        
        // Parsear PDF automáticamente
        await _parsePdf();
      }
    } catch (e) {
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        'Error seleccionando PDF: $e',
      );
    }
  }

  Future<void> _parsePdf() async {
    if (_pdfFile == null) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    bool dialogShown = false;
    
    try {
      DialogHelper.showProcessingDialog(
        title: 'Leyendo PDF...',
        barrierDismissible: false,
      );
      dialogShown = true;
      
      final products = await PdfImportService.parseProductsFromPdf(_pdfFile!);
      
      // Cerrar diálogo
      if (dialogShown) {
        DialogHelper.closeDialog();
        dialogShown = false;
      }
      
      setState(() {
        _parsedProducts = products;
        _isProcessing = false;
      });
      
      if (products.isEmpty) {
        DialogHelper.showSnackbarMessage(
          SnackMsgType.error,
          'No se encontraron productos en el PDF. Verifica el formato.',
        );
      } else {
        DialogHelper.showSnackbarMessage(
          SnackMsgType.success,
          'Se encontraron ${products.length} productos',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error en _parsePdf: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      // Cerrar diálogo si está abierto
      if (dialogShown) {
        try {
          DialogHelper.closeDialog();
        } catch (_) {
          // Ignorar errores al cerrar diálogo
        }
      }
      
      setState(() {
        _isProcessing = false;
        _parsedProducts = [];
      });
      
      String errorMessage = 'Error leyendo PDF';
      if (e.toString().contains('no existe')) {
        errorMessage = 'El archivo PDF no existe';
      } else if (e.toString().contains('muy grande')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      } else if (e.toString().contains('dañado') || e.toString().contains('válido')) {
        errorMessage = 'El archivo PDF está dañado o no es válido';
      } else if (e.toString().contains('protegido') || e.toString().contains('imagen escaneada')) {
        errorMessage = 'No se pudo extraer texto del PDF. Puede estar protegido o ser una imagen escaneada';
      } else {
        errorMessage = 'Error al procesar el PDF: ${e.toString().replaceAll('Exception: ', '')}';
      }
      
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        errorMessage,
      );
    }
  }

  Future<void> _parseText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        'El texto está vacío',
      );
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });
    
    bool dialogShown = false;
    
    try {
      DialogHelper.showProcessingDialog(
        title: 'Procesando texto...',
        barrierDismissible: false,
      );
      dialogShown = true;
      
      final products = await PdfImportService.parseProductsFromText(text);
      
      // Cerrar diálogo
      if (dialogShown) {
        DialogHelper.closeDialog();
        dialogShown = false;
      }
      
      setState(() {
        _parsedProducts = products;
        _isProcessing = false;
      });
      
      if (products.isEmpty) {
        DialogHelper.showSnackbarMessage(
          SnackMsgType.error,
          'No se encontraron productos en el texto. Verifica el formato.',
        );
      } else {
        DialogHelper.showSnackbarMessage(
          SnackMsgType.success,
          'Se encontraron ${products.length} productos',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error en _parseText: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      // Cerrar diálogo si está abierto
      if (dialogShown) {
        try {
          DialogHelper.closeDialog();
        } catch (_) {
          // Ignorar errores al cerrar diálogo
        }
      }
      
      setState(() {
        _isProcessing = false;
        _parsedProducts = [];
      });
      
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        'Error al procesar el texto: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  Future<void> _pickDefaultImage() async {
    try {
      final files = await MediaHelper.getAssets(
        maxAssets: 1,
        requestType: RequestType.image,
      );
      
      if (files != null && files.isNotEmpty) {
        setState(() {
          _defaultImageFile = files.first;
        });
      }
    } catch (e) {
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        'Error seleccionando imagen: $e',
      );
    }
  }

  Future<void> _importProducts() async {
    debugPrint('🚀 [IMPORT_SCREEN] _importProducts llamado');
    
    if (_parsedProducts.isEmpty) {
      debugPrint('❌ [IMPORT_SCREEN] No hay productos para importar');
      Get.snackbar(
        'Error',
        'No hay productos para importar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    if (_selectedCategory.trim().isEmpty || _selectedCategory.trim() == 'Otros') {
      debugPrint('❌ [IMPORT_SCREEN] Categoría vacía o por defecto');
      Get.snackbar(
        'Error',
        'Ingresa un nombre de categoría',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    debugPrint('✅ [IMPORT_SCREEN] Validaciones pasadas');
    debugPrint('📦 [IMPORT_SCREEN] Productos: ${_parsedProducts.length}');
    debugPrint('📦 [IMPORT_SCREEN] Categoría: ${_selectedCategory.trim()}');
    if (_defaultImageFile != null) {
      debugPrint('📦 [IMPORT_SCREEN] Imagen: ${_defaultImageFile!.path}');
    } else {
      debugPrint('📦 [IMPORT_SCREEN] Sin imagen (opcional)');
    }
    
    setState(() {
      _isProcessing = true;
      _currentProgress = 0;
      _totalProducts = _parsedProducts.length;
    });
    
    try {
      debugPrint('🔄 [IMPORT_SCREEN] Preparando productos...');
      
      // Agregar categoría a cada producto
      final productsWithCategory = _parsedProducts.map((p) {
        p['category'] = _selectedCategory.trim();
        p['quantity'] = 1; // Cantidad por defecto
        return p;
      }).toList();
      
      debugPrint('🔄 [IMPORT_SCREEN] Llamando a ProductApi.addProductsBatch...');
      
      await ProductApi.addProductsBatch(
        products: productsWithCategory,
        defaultImageFile: _defaultImageFile,
        category: _selectedCategory.trim(),
        pdfFileName: _pdfFile?.path.split('/').last ?? (_textController.text.isNotEmpty ? 'importacion_texto.pdf' : 'importacion.pdf'),
        onProgress: (current, total) {
          debugPrint('📊 [IMPORT_SCREEN] Progreso: $current/$total');
          setState(() {
            _currentProgress = current;
          });
        },
      );
      
      debugPrint('✅ [IMPORT_SCREEN] Importación completada exitosamente');
      
      Get.back(); // Volver a la pantalla anterior
      
      Get.snackbar(
        'Éxito',
        '${_parsedProducts.length} productos importados exitosamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [IMPORT_SCREEN] Error en _importProducts: $e');
      debugPrint('❌ [IMPORT_SCREEN] Stack trace: $stackTrace');
      
      setState(() {
        _isProcessing = false;
      });
      
      Get.snackbar(
        'Error',
        'Error importando productos: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Importar desde PDF',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: goldColor, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seleccionar PDF o pegar texto
            _buildSectionCard(
              icon: IconlyBold.document,
              title: '1. Seleccionar PDF o pegar texto',
              child: Column(
                children: [
                  // Toggle entre PDF y texto
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernButton(
                          onPressed: _isProcessing ? null : () {
                            setState(() {
                              _showTextInput = false;
                              _pdfFile = null;
                              _parsedProducts = [];
                            });
                          },
                          icon: IconlyBold.document,
                          label: 'PDF',
                          color: _showTextInput ? Colors.grey : goldColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernButton(
                          onPressed: _isProcessing ? null : () {
                            setState(() {
                              _showTextInput = true;
                              _pdfFile = null;
                              _parsedProducts = [];
                            });
                          },
                          icon: IconlyBold.edit,
                          label: 'Pegar Texto',
                          color: _showTextInput ? goldColor : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (!_showTextInput) ...[
                    // Opción PDF
                    if (_pdfFile != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: goldColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: goldColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: goldColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(IconlyBold.document, color: goldColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Archivo seleccionado',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _pdfFile!.path.split('/').last,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildModernButton(
                      onPressed: _isProcessing ? null : _pickPdf,
                      icon: IconlyBold.document,
                      label: 'Seleccionar PDF',
                      color: goldColor,
                    ),
                  ] else ...[
                    // Opción pegar texto
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: goldColor.withOpacity(0.5)),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        cursorColor: goldColor,
                        decoration: InputDecoration(
                          hintText: 'Pega aquí el texto del PDF...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildModernButton(
                      onPressed: _isProcessing ? null : _parseText,
                      icon: IconlyBold.tickSquare,
                      label: 'Procesar Texto',
                      color: goldColor,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Seleccionar categoría
            _buildSectionCard(
              icon: IconlyBold.category,
              title: '2. Categoría',
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Nombre de la categoría',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: Icon(IconlyLight.category, color: goldColor.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: goldColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value.trim().isEmpty ? 'Otros' : value.trim();
                  });
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Seleccionar imagen por defecto
              _buildSectionCard(
                icon: IconlyBold.image,
                title: '3. Imagen por defecto (opcional)',
                child: Column(
                children: [
                  if (_defaultImageFile != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: goldColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.file(
                              _defaultImageFile!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  IconlyBold.tickSquare,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  _buildModernButton(
                    onPressed: _pickDefaultImage,
                    icon: IconlyBold.image,
                    label: 'Seleccionar Imagen',
                    color: goldColor,
                  ),
                ],
              ),
            ),
            
            if (_parsedProducts.isNotEmpty) ...[
              const SizedBox(height: 20),
              
              // Vista previa de productos
              _buildSectionCard(
                icon: IconlyBold.document,
                title: '4. Vista previa',
                subtitle: '${_parsedProducts.length} productos encontrados',
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.02),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: _parsedProducts.length > 15 ? 15 : _parsedProducts.length,
                    itemBuilder: (context, index) {
                      final product = _parsedProducts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: goldColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: goldColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['articleCode'] ?? 'N/A',
                                    style: const TextStyle(
                                      color: goldColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product['description'] ?? product['name'] ?? 'Sin descripción',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '€${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Botón de importar
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: goldColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _importProducts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isProcessing) ...[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Importando $_currentProgress/$_totalProducts',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ] else ...[
                        const Icon(IconlyBold.upload, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'IMPORTAR ${_parsedProducts.length} PRODUCTOS',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    const goldColor = Color(0xFFD4AF37);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: goldColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: goldColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildModernButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.black, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

