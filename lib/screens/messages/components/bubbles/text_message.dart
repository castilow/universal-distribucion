import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_messenger/components/message_badge.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/helpers/date_helper.dart';
import 'package:chat_messenger/controllers/preferences_controller.dart';
import 'package:get/get.dart';
import '../rich_text_message.dart';

class TextMessage extends StatefulWidget {
  const TextMessage(this.message, {super.key, this.backgroundColor});

  final Message message;
  final Color? backgroundColor; // Color de fondo de la burbuja para calcular contraste

  @override
  State<TextMessage> createState() => _TextMessageState();
}

class _TextMessageState extends State<TextMessage> {
  bool _showOriginal = false;

  // Obtener el texto a mostrar (traducido o original)
  String _getDisplayText() {
    // Si el usuario quiere ver el original, mostrarlo
    if (_showOriginal) {
      return widget.message.textMsg;
    }
    
    // Obtener el idioma preferido del usuario
    final userLang = PreferencesController.instance.locale.value.languageCode;
    
    // Si hay traducción disponible, usarla
    if (widget.message.hasTranslation(userLang)) {
      final translated = widget.message.getTranslatedText(userLang);
      debugPrint('TextMessage _getDisplayText() -> Using translation for ${widget.message.msgId}: "$translated"');
      return translated;
    }
    
    // Si no, mostrar el original
    debugPrint('TextMessage _getDisplayText() -> Using original for ${widget.message.msgId}: "${widget.message.textMsg}"');
    return widget.message.textMsg;
  }

  // Verificar si el mensaje fue traducido
  bool _isTranslated() {
    if (_showOriginal) return false;
    final userLang = PreferencesController.instance.locale.value.languageCode;
    return widget.message.hasTranslation(userLang);
  }

  @override
  Widget build(BuildContext context) {
    // Log message rendering for debugging
    debugPrint('TextMessage build() -> Message ID: ${widget.message.msgId}, IsDeleted: ${widget.message.isDeleted}, Text: "${widget.message.textMsg}"');
    
    return Container(
      padding: const EdgeInsets.only(bottom: 6, right: 8), // Padding aún más fino
      constraints: const BoxConstraints(
        minWidth: 45,
        maxWidth: 280,
      ),
      child: widget.message.isDeleted
          ? MessageDeleted(
              isSender: widget.message.isSender,
              iconColor: widget.message.isSender ? Colors.white : greyColor,
              style: TextStyle(
                fontSize: PreferencesController.instance.getScaledFontSize(15),
                fontStyle: FontStyle.italic,
                color: widget.message.isSender 
                    ? (widget.backgroundColor != null
                        ? PreferencesController.getContrastTextColor(widget.backgroundColor!).withOpacity(0.9)
                        : Colors.white.withOpacity(0.9))
                    : Colors.grey[600],
              ),
            )
          : widget.message.textMsg.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '[Mensaje vacío]',
                    style: TextStyle(
                      fontSize: PreferencesController.instance.getScaledFontSize(13),
                      fontStyle: FontStyle.italic,
                      color: widget.message.isSender 
                          ? (widget.backgroundColor != null
                              ? PreferencesController.getContrastTextColor(widget.backgroundColor!).withOpacity(0.7)
                              : Colors.white.withOpacity(0.7))
                          : Colors.grey[500],
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicador de traducción
                    if (_isTranslated())
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.translate,
                              size: 12,
                              color: widget.backgroundColor != null
                                  ? PreferencesController.getContrastTextColor(widget.backgroundColor!).withOpacity(0.7)
                                  : (widget.message.isSender 
                                      ? Colors.white.withOpacity(0.7) 
                                      : Colors.grey[600]),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'translated'.tr,
                              style: TextStyle(
                                fontSize: PreferencesController.instance.getScaledFontSize(10),
                                fontStyle: FontStyle.italic,
                                color: widget.backgroundColor != null
                                    ? PreferencesController.getContrastTextColor(widget.backgroundColor!).withOpacity(0.7)
                                    : (widget.message.isSender 
                                        ? Colors.white.withOpacity(0.7) 
                                        : Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Mensaje de texto
                    _buildTextWithTime(),
                    // Botón para ver original
                    if (_isTranslated())
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showOriginal = !_showOriginal;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _showOriginal ? 'show_translation'.tr : 'show_original'.tr,
                            style: TextStyle(
                              fontSize: PreferencesController.instance.getScaledFontSize(11),
                              fontWeight: FontWeight.w500,
                              color: widget.backgroundColor != null
                                  ? PreferencesController.getContrastTextColor(widget.backgroundColor!).withOpacity(0.9)
                                  : (widget.message.isSender 
                                      ? Colors.white.withOpacity(0.9)
                                      : const Color(0xFF00F7FF)),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildTextWithTime() {
    final displayText = _getDisplayText();
    final prefController = PreferencesController.instance;
    
    // Calcular color de texto automático basado en el color de fondo
    final Color textColor;
    if (widget.backgroundColor != null) {
      textColor = PreferencesController.getContrastTextColor(widget.backgroundColor!);
    } else {
      // Fallback: usar color basado en si es sender
      textColor = widget.message.isSender ? Colors.white : Colors.black87;
    }
    
    // Obtener tamaño de texto personalizado
    final double baseFontSize = 13;
    final double fontSize = prefController.getScaledFontSize(baseFontSize);
    
    // Determinar si es un mensaje corto o largo
    final bool isShortMessage = displayText.length <= 25; // Umbral más bajo para mensajes cortos
    
    if (isShortMessage) {
      // Mensaje corto: hora y checkmark al lado derecho (diseño compacto)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Texto principal
          Flexible(
            child: RichTexMessage(
              text: displayText,
              defaultStyle: GoogleFonts.inter(
                fontSize: fontSize, // Usar tamaño personalizado
                height: 1.2, // Altura de línea muy compacta
                letterSpacing: 0.05, // Espaciado mínimo
                color: textColor, // Usar color calculado automáticamente
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          
          const SizedBox(width: 6), // Espaciado reducido
          
          // Hora y checkmark al lado derecho
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hora
              Text(
                widget.message.isDeleted
                    ? widget.message.updatedAt?.formatMsgTime ?? ''
                    : widget.message.sentAt?.formatMsgTime ?? '',
                style: TextStyle(
                  fontSize: 11, // Hora más pequeña
                  color: const Color(0xFF4CAF50),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 3), // Espaciado reducido
              // Checkmark
              if (widget.message.isSender)
                Icon(
                  widget.message.isRead ? Icons.done_all : Icons.done,
                  size: 12, // Checkmark más pequeño
                  color: const Color(0xFF4CAF50),
                ),
            ],
          ),
        ],
      );
    } else {
      // Mensaje largo: hora y checkmark abajo a la derecha (diseño moderno)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Texto principal
          RichTexMessage(
            text: displayText,
            defaultStyle: GoogleFonts.inter(
              fontSize: prefController.getScaledFontSize(14), // Usar tamaño personalizado
              height: 1.25, // Altura de línea optimizada para textos largos
              letterSpacing: 0.08, // Espaciado moderado
              color: textColor, // Usar color calculado automáticamente
              fontWeight: FontWeight.w400,
            ),
          ),
          
          // Hora y checkmark abajo a la derecha
          Padding(
            padding: const EdgeInsets.only(top: 3), // Espaciado ligeramente mayor
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Hora
                Text(
                  widget.message.isDeleted
                      ? widget.message.updatedAt?.formatMsgTime ?? ''
                      : widget.message.sentAt?.formatMsgTime ?? '',
                  style: TextStyle(
                    fontSize: prefController.getScaledFontSize(11), // Hora más pequeña con tamaño personalizado
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 3), // Espaciado reducido
                // Checkmark
                if (widget.message.isSender)
                  Icon(
                    widget.message.isRead ? Icons.done_all : Icons.done,
                    size: 12, // Checkmark más pequeño
                    color: const Color(0xFF4CAF50),
                  ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
