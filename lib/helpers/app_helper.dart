import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/media/helpers/media_helper.dart';
import 'package:chat_messenger/models/location.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'dialog_helper.dart';

abstract class AppHelper {
  ///
  /// App Helper Methods
  ///

  /// Generate unique ID.
  static String get generateID => const Uuid().v4();

  // Upload file to firebase storage
  static Future<String> uploadFile({
    required File file,
    required String userId,
  }) async {
    try {
      // Verificar autenticación antes de subir
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception(
          'Usuario no autenticado. Inicia sesión para subir archivos.',
        );
      }

      if (firebaseUser.uid != userId) {
        throw Exception(
          'ID de usuario no coincide con el usuario autenticado.',
        );
      }

      debugPrint('🔑 Usuario autenticado: ${firebaseUser.uid}');
      debugPrint('🔑 UserId recibido: $userId');
      debugPrint('🔑 Coinciden: ${firebaseUser.uid == userId}');
      debugPrint('📁 Subiendo archivo: ${file.path}');
      debugPrint('📁 Archivo existe: ${await file.exists()}');
      debugPrint('📁 Tamaño del archivo: ${await file.length()} bytes');

      // File name with timestamp to avoid conflicts
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final String filePath = 'uploads/$userId/$fileName';

      debugPrint('📂 Ruta de destino: $filePath');
      debugPrint('📂 Ruta completa: uploads/$userId/$fileName');

      // Verificar que el archivo existe y es válido
      if (!await file.exists()) {
        throw Exception('El archivo no existe: ${file.path}');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('El archivo está vacío');
      }

      debugPrint('📤 Iniciando subida de archivo (${fileSize} bytes)...');

      // Upload file
      final UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child(filePath)
          .putFile(
            file,
            SettableMetadata(
              contentType: 'image/jpeg', // Asegurar tipo de contenido
              customMetadata: {
                'uploadedBy': firebaseUser.uid,
                'uploadedAt': DateTime.now().toIso8601String(),
              },
            ),
          );

      // Monitor progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint(
          '📤 Progreso de subida: ${(progress * 100).toStringAsFixed(1)}%',
        );
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String url = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Archivo subido exitosamente: $url');
      return url;
    } catch (e) {
      debugPrint('❌ Error subiendo archivo: $e');

      // Verificar tipos específicos de error
      if (e.toString().contains('unauthorized')) {
        throw Exception(
          'Error de permisos: Verifica las reglas de Firebase Storage. Error: $e',
        );
      } else if (e.toString().contains('network')) {
        throw Exception(
          'Error de red: Verifica tu conexión a internet. Error: $e',
        );
      } else {
        throw Exception('Error al subir archivo: $e');
      }
    }
  }

  static Future<void> deleteFile(String fileUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(fileUrl).delete();
      debugPrint('deleteFile() -> success, fileUrl: $fileUrl');
    } catch (e) {
      debugPrint('deleteFile() -> error: $e');
    }
  }

  // Regenerate Firebase Storage download URL from old URL
  // This is useful when tokens expire (412 error)
  static Future<String?> regenerateImageUrl(String oldUrl) async {
    try {
      debugPrint('🔄 [REGENERATE_URL] Regenerando URL para: $oldUrl');
      
      // First, try to extract path manually from URL
      // Format: https://firebasestorage.googleapis.com/v0/b/BUCKET/o/encodedPath?alt=media&token=...
      final uri = Uri.parse(oldUrl);
      
      // Find the path after /o/
      final pathIndex = uri.path.indexOf('/o/');
      if (pathIndex != -1) {
        // Get the encoded path after /o/
        final encodedPath = uri.path.substring(pathIndex + 3); // +3 to skip "/o/"
        // Decode URL encoding (%2F -> /)
        final decodedPath = Uri.decodeComponent(encodedPath);
        
        debugPrint('🔄 [REGENERATE_URL] Path extraído: $decodedPath');
        
        // Create reference from path and get fresh URL
        final ref = FirebaseStorage.instance.ref().child(decodedPath);
        final newUrl = await ref.getDownloadURL();
        
        debugPrint('✅ [REGENERATE_URL] Nueva URL generada: $newUrl');
        return newUrl;
      }
      
      // Fallback: try refFromURL (may fail with expired tokens)
      debugPrint('⚠️ [REGENERATE_URL] Intentando refFromURL como fallback');
      final ref = FirebaseStorage.instance.refFromURL(oldUrl);
      final newUrl = await ref.getDownloadURL();
      debugPrint('✅ [REGENERATE_URL] Nueva URL generada con refFromURL');
      return newUrl;
    } catch (e) {
      final errorStr = e.toString();
      debugPrint('❌ [REGENERATE_URL] Error regenerando URL: $e');
      
      // Check if it's a service account permissions error (412)
      if (errorStr.contains('412') || errorStr.contains('service account') || 
          errorStr.contains('missing necessary permissions')) {
        debugPrint('⚠️ [REGENERATE_URL] Error de permisos de cuenta de servicio. '
                   'Necesitas re-vincular el bucket en Firebase Console.');
      }
      
      return null;
    }
  }

  // Delete the storage files by path
  static Future<void> deleteStorageFiles(String path) async {
    try {
      final ListResult listResult = await FirebaseStorage.instance
          .ref()
          .child(path)
          .listAll();
      final List<Future<void>> references = listResult.items
          .map((e) => e.delete())
          .toList();
      // Check result
      if (references.isNotEmpty) {
        await Future.wait(references);
        debugPrint('deleteStorageFiles() -> success');
        return;
      }
      debugPrint('deleteStorageFiles() -> no files');
    } catch (e) {
      debugPrint('deleteStorageFiles() -> error: $e');
    }
  }

  static Future<String> _getStoragePath() async {
    // To check storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // Request permission
      await Permission.storage.request();
    }
    Directory directory = Directory("");
    if (Platform.isAndroid) {
      // Redirects it to download folder in android
      directory = Directory("/storage/emulated/0/Download");
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    await Directory(directory.path).create(recursive: true);
    return directory.path;
  }

  static Future<void> downloadFile(String fileUrl) async {
    try {
      DialogHelper.showProcessingDialog(
        title: 'downloading'.tr,
        barrierDismissible: false,
      );

      final response = await http.get(Uri.parse(fileUrl));

      if (response.statusCode == 200) {
        final String fileName = MediaHelper.getFirebaseFileName(fileUrl);
        final String externalDir = await _getStoragePath();
        final String savePath = '$externalDir/$fileName';

        final File file = File(savePath);

        await file.writeAsBytes(response.bodyBytes);
        // File is now saved to external storage in the Downloads directory
        DialogHelper.closeDialog();
        DialogHelper.showSnackbarMessage(
          SnackMsgType.success,
          'file_downloaded_successfully'.tr,
        );
      } else {
        DialogHelper.closeDialog();
        DialogHelper.showSnackbarMessage(
          SnackMsgType.error,
          'failed_to_download_file'.trParams({'error': response.body}),
        );
      }
    } catch (e) {
      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(SnackMsgType.error, e.toString());
      debugPrint('downloadFile() -> error: $e');
    }
  }

  // Clean the username
  static String sanitizeUsername(String text) {
    return text.trim().replaceAll(' ', '_').toLowerCase();
  }

  static String? usernameValidator(String? username) {
    if (username == null || username.trim().isEmpty) {
      return "enter_your_username".tr;
    }
    return null;
  }

  // Format the username
  static List<TextInputFormatter> get usernameFormatter {
    return [
      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9._]')),
      TextInputFormatter.withFunction((oldValue, newValue) {
        return TextEditingValue(
          text: sanitizeUsername(newValue.text),
          selection: newValue.selection,
        );
      }),
    ];
  }

  static Future<Location?> getUserCurrentLocation() async {
    LocationPermission permission;

    DialogHelper.showProcessingDialog(barrierDismissible: false);

    // Check location services are enabled.
    if (!await Geolocator.isLocationServiceEnabled()) {
      DialogHelper.closeDialog();

      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        'location_services_are_disabled'.tr,
      );
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        DialogHelper.closeDialog();

        DialogHelper.showAlertDialog(
          titleColor: errorColor,
          title: Text('permission_denied'.tr),
          content: Text('location_permission_denied'.tr),
          actionText: 'open_settings'.tr,
          action: () {
            Get.back();
            Geolocator.openLocationSettings();
          },
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      DialogHelper.closeDialog();

      DialogHelper.showAlertDialog(
        titleColor: errorColor,
        title: Text('permission_denied'.tr),
        content: Text('location_permission_denied'.tr),
        actionText: 'open_settings'.tr,
        action: () {
          Get.back();
          Geolocator.openLocationSettings();
        },
      );

      return null;
    }
    // When we reach here, permissions are granted.
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    DialogHelper.closeDialog();

    return Location(latitude: position.latitude, longitude: position.longitude);
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_enter_your_password'.tr;
    } else if (value.length < 6) {
      return 'password_must_have_at_least_6_characters'.tr;
    }
    return null;
  }

  // Get Store URL => Google Play / App Store
  static String get _storeUrl {
    // Check platform
    if (Platform.isAndroid) {
      return "https://play.google.com/store/apps/details?id=${AppConfig.androidPackageName}";
    }
    return "https://apps.apple.com/app/id${AppConfig.iOsAppId}";
  }

  /// Share app with friends
  static Future<void> shareApp() async {
    final String username = AuthController.instance.currentUser.username;

    Share.share(
      'invite_friend_message'.trParams({
        'appName': AppConfig.appName,
        'username': '@$username',
        'storeName': Platform.isAndroid ? 'Google Play' : 'App Store',
        'storeUrl': _storeUrl,
      }),
    );
  }

  /// Rate app on Google Play / App Store
  static Future<void> rateApp() async {
    // Get Store Link
    final String storeLink = Platform.isIOS
        ? "$_storeUrl?action=write-review"
        : _storeUrl;
    await openUrl(storeLink);
  }

  /// Open email app to contact support
  static Future<void> openMailApp(String subject) =>
      openUrl("mailto:${AppConfig.appEmail}?subject=$subject");

  /// Open Terms of Services page in Browser
  static Future<void> openTermsPage() => openUrl(AppConfig.termsOfServiceUrl);

  /// Open Privacy Policy page in Browser
  static Future<void> openPrivacyPage() async {
    // Get Privacy URL
    final Uri uri = Uri.parse(AppConfig.privacyPolicyUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw "Could not launch url: $uri";
    }
  }

  static Future<void> openGoogleMaps(double latitude, double longitude) async {
    final String mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    await openUrl(mapsUrl).onError(
      (error, stackTrace) => DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        'failed_to_open_the_google_maps_url',
      ),
    );
  }

  // Open Link
  static Future<void> openUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        debugPrint('Could not launch url: $url');
      }
    } catch (e) {
      debugPrint('openUrl() -> error: $e');
    }
  }
}
