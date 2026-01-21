import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

/// Widget que muestra una imagen de red con manejo de errores
/// Detecta errores 412 (permisos IAM) y muestra un widget de error apropiado
class CachedImageWithRetry extends StatefulWidget {
  const CachedImageWithRetry({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorIconColor,
    this.errorWidget,
  });

  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Color? errorIconColor;
  final Widget? errorWidget;

  @override
  State<CachedImageWithRetry> createState() => _CachedImageWithRetryState();
}

class _CachedImageWithRetryState extends State<CachedImageWithRetry> {
  String? _currentUrl;
  bool _hasAttemptedRegeneration = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(CachedImageWithRetry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _currentUrl = widget.imageUrl;
      _hasAttemptedRegeneration = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_currentUrl == null || _currentUrl!.isEmpty) {
      return widget.errorWidget ?? _defaultErrorWidget();
    }

    // Check local asset
    if (_currentUrl!.startsWith('assets')) {
      return Image.asset(_currentUrl!, fit: widget.fit);
    }

    // Get network image with retry on 412 error
    return CachedNetworkImage(
      fit: widget.fit,
      imageUrl: _currentUrl!,
      placeholder: widget.placeholder != null
          ? (context, url) => widget.placeholder!
          : (context, url) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            ),
      errorWidget: (context, url, error) {
        // Check if error is 412 (Precondition Failed - permissions issue)
        final errorString = error.toString().toLowerCase();
        final is412Error = errorString.contains('412') || 
                          errorString.contains('precondition failed') ||
                          errorString.contains('invalid statuscode: 412');

        // Si es error 412, es un problema de permisos de cuenta de servicio en IAM
        // Tanto getDownloadURL() como getData() fallan con 412
        // Este problema NO se puede resolver desde el código - requiere atención de Firebase Support
        if (is412Error && url.contains('firebasestorage.googleapis.com')) {
          // Solo loguear una vez por URL para evitar spam en logs
          if (!_hasAttemptedRegeneration) {
            debugPrint('⚠️ [CACHED_IMAGE] Error 412 - problema de permisos IAM. URL: ${url.substring(0, url.length > 100 ? 100 : url.length)}...');
            _hasAttemptedRegeneration = true;
          }
          // Mostrar widget de error directamente
          return widget.errorWidget ?? _defaultErrorWidget();
        }

        // For other errors, show error widget
        return widget.errorWidget ?? _defaultErrorWidget();
      },
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          IconlyLight.image,
          color: widget.errorIconColor ?? Colors.grey[600],
          size: 48,
        ),
      ),
    );
  }
}