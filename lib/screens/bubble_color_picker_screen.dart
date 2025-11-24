import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/controllers/preferences_controller.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class BubbleColorPickerScreen extends StatefulWidget {
  const BubbleColorPickerScreen({super.key});

  @override
  State<BubbleColorPickerScreen> createState() => _BubbleColorPickerScreenState();
}

class _BubbleColorPickerScreenState extends State<BubbleColorPickerScreen> {
  final PreferencesController prefController = Get.find();
  late Color _sentColor;
  late Color _receivedColor;
  bool _hasChanges = false;

  // Colores predefinidos populares (estilo WhatsApp)
  final List<Color> _presetColors = [
    const Color(0xFFDCF8C6), // Verde claro (WhatsApp default)
    const Color(0xFFFFF9C4), // Amarillo claro
    const Color(0xFFE1BEE7), // Morado claro
    const Color(0xFFBBDEFB), // Azul claro
    const Color(0xFFC5E1A5), // Verde menta
    const Color(0xFFFFCCBC), // Naranja claro
    const Color(0xFFF8BBD0), // Rosa claro
    const Color(0xFFB2DFDB), // Turquesa claro
    const Color(0xFFFFE0B2), // Melocotón
    const Color(0xFFD1C4E9), // Lavanda
    const Color(0xFFFFFFFF), // Blanco
    const Color(0xFF2A2A2A), // Gris oscuro
  ];

  @override
  void initState() {
    super.initState();
    _sentColor = prefController.customSentBubbleColor.value;
    _receivedColor = prefController.customReceivedBubbleColor.value;
  }

  void _onSentColorChanged(Color color) {
    setState(() {
      _sentColor = color;
      _hasChanges = true;
    });
  }

  void _onReceivedColorChanged(Color color) {
    setState(() {
      _receivedColor = color;
      _hasChanges = true;
    });
  }

  Future<void> _saveColors() async {
    await prefController.setSentBubbleColor(_sentColor);
    await prefController.setReceivedBubbleColor(_receivedColor);
    setState(() {
      _hasChanges = false;
    });
    Get.back();
    Get.snackbar(
      'Colores guardados',
      'Los colores de las burbujas se han actualizado',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _resetColors() async {
    await prefController.resetBubbleColors();
    setState(() {
      _sentColor = prefController.customSentBubbleColor.value;
      _receivedColor = prefController.customReceivedBubbleColor.value;
      _hasChanges = false;
    });
    Get.snackbar(
      'Colores restablecidos',
      'Se han restablecido los colores por defecto',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
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
          'Colores de burbujas',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveColors,
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
                    // Preview de mensajes
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
                                color: _receivedColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Mensaje recibido',
                                style: TextStyle(
                                  color: _getContrastColor(_receivedColor),
                                  fontSize: 14,
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
                                color: _sentColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Mensaje enviado',
                                style: TextStyle(
                                  color: _getContrastColor(_sentColor),
                                  fontSize: 14,
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

              // Color de mensajes enviados
              _buildColorSection(
                context: context,
                isDarkMode: isDarkMode,
                title: 'Mensajes enviados',
                subtitle: 'Color de tus mensajes',
                currentColor: _sentColor,
                onColorChanged: _onSentColorChanged,
              ),

              const SizedBox(height: 24),

              // Color de mensajes recibidos
              _buildColorSection(
                context: context,
                isDarkMode: isDarkMode,
                title: 'Mensajes recibidos',
                subtitle: 'Color de los mensajes que recibes',
                currentColor: _receivedColor,
                onColorChanged: _onReceivedColorChanged,
              ),

              const SizedBox(height: 24),

              // Botón de resetear
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _resetColors,
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
                    'Restablecer colores por defecto',
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

  Widget _buildColorSection({
    required BuildContext context,
    required bool isDarkMode,
    required String title,
    required String subtitle,
    required Color currentColor,
    required ValueChanged<Color> onColorChanged,
  }) {
    return Container(
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Muestra del color actual
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: currentColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: currentColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Colores predefinidos
          Text(
            'Colores predefinidos',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _presetColors.map((color) {
              final isSelected = color.value == currentColor.value;
              return GestureDetector(
                onTap: () => onColorChanged(color),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? (isDarkMode ? Colors.white : Colors.black)
                          : (isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // Selector de color personalizado
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showColorPicker(context, isDarkMode, currentColor, onColorChanged),
              icon: const Icon(Icons.color_lens),
              label: const Text('Elegir color personalizado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    bool isDarkMode,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) {
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text(
            'Seleccionar color',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              availableColors: const [
                Color(0xFF000000), // Negro
                Color(0xFFFFFFFF), // Blanco
                Color(0xFFDCF8C6), // Verde claro
                Color(0xFFFFF9C4), // Amarillo
                Color(0xFFE1BEE7), // Morado
                Color(0xFFBBDEFB), // Azul
                Color(0xFFC5E1A5), // Verde menta
                Color(0xFFFFCCBC), // Naranja
                Color(0xFFF8BBD0), // Rosa
                Color(0xFFB2DFDB), // Turquesa
                Color(0xFFFFE0B2), // Melocotón
                Color(0xFFD1C4E9), // Lavanda
                Color(0xFF90CAF9), // Azul cielo
                Color(0xFFA5D6A7), // Verde
                Color(0xFFFFE082), // Amarillo
                Color(0xFFCE93D8), // Morado
                Color(0xFFFFAB91), // Coral
                Color(0xFF80CBC4), // Verde agua
                Color(0xFF9FA8DA), // Índigo
                Color(0xFFFFCC80), // Naranja claro
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                onColorChanged(pickerColor);
                Navigator.of(context).pop();
              },
              child: Text(
                'Aceptar',
                style: TextStyle(
                  color: isDarkMode ? Colors.blue[400] : Colors.blue[600],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    // Calcular el brillo del color de fondo
    final double luminance = backgroundColor.computeLuminance();
    // Si el fondo es oscuro, usar texto blanco, sino negro
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}




