import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/controllers/preferences_controller.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:chat_messenger/config/theme_config.dart';

class TextSizeScreen extends StatefulWidget {
  const TextSizeScreen({super.key});

  @override
  State<TextSizeScreen> createState() => _TextSizeScreenState();
}

class _TextSizeScreenState extends State<TextSizeScreen> {
  final PreferencesController prefController = Get.find();
  late double _currentSize;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _currentSize = prefController.getTextSize();
  }

  void _onSizeChanged(double size) {
    setState(() {
      _currentSize = size;
      _hasChanges = true;
    });
  }

  Future<void> _saveSize() async {
    await prefController.setTextSize(_currentSize);
    setState(() {
      _hasChanges = false;
    });
    Get.back();
    Get.snackbar(
      'Tamaño guardado',
      'El tamaño del texto se ha actualizado',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _resetSize() async {
    await prefController.resetTextSize();
    setState(() {
      _currentSize = prefController.getTextSize();
      _hasChanges = false;
    });
    Get.snackbar(
      'Tamaño restablecido',
      'Se ha restablecido el tamaño por defecto',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  String _getSizeLabel(double size) {
    if (size <= 0.85) return 'Pequeño';
    if (size <= 0.95) return 'Mediano';
    if (size <= 1.05) return 'Normal';
    if (size <= 1.15) return 'Grande';
    return 'Muy grande';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? darkThemeBgColor : lightThemeBgColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? darkThemeBgColor : lightThemeBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : Colors.black87,
            size: 20,
          ),
          onPressed: () {
            if (_hasChanges) {
              Get.dialog(
                AlertDialog(
                  backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  title: Text(
                    '¿Descartar cambios?',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  content: Text(
                    'Tienes cambios sin guardar. ¿Quieres descartarlos?',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: isDarkMode ? Colors.blue[400] : Colors.blue[600],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back(); // Cerrar diálogo
                        Get.back(); // Cerrar pantalla
                      },
                      child: Text(
                        'Descartar',
                        style: TextStyle(
                          color: Colors.red[400],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              Get.back();
            }
          },
        ),
        title: Text(
          'Tamaño del texto',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveSize,
              child: Text(
                'Guardar',
                style: TextStyle(
                  color: isDarkMode ? Colors.blue[400] : Colors.blue[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VISTA PREVIA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Preview de mensajes con tamaño personalizado
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF000000),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/chat2.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // Mensaje recibido
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Este es un mensaje de ejemplo',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14 * _currentSize,
                                ),
                              ),
                            ),
                          ),
                          // Mensaje enviado
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCF8C6),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Mensaje con tamaño personalizado',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14 * _currentSize,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Slider Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tamaño',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          _getSizeLabel(_currentSize),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.blue[400] : Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _currentSize,
                      min: 0.7,
                      max: 1.3,
                      divisions: 12,
                      label: '${(_currentSize * 100).toStringAsFixed(0)}%',
                      activeColor: isDarkMode ? Colors.blue[400] : Colors.blue[600],
                      inactiveColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      onChanged: _onSizeChanged,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pequeño',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Normal',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Grande',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botón de resetear
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _resetSize,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Restablecer tamaño por defecto',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

