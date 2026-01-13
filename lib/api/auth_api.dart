import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth show User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/config/theme_config.dart';

abstract class AuthApi {
  static final AuthController _authController = AuthController.instance;
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('📧 ===== SIGNUP WITH EMAIL AND PASSWORD =====');
      debugPrint('📧 Email: $email');
      DialogHelper.showProcessingDialog();
      
      debugPrint('📧 Creando usuario en Firebase Auth...');
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('📧 ✅ Usuario creado en Firebase Auth: ${userCredential.user?.uid}');
      debugPrint('📧 Email verificado: ${userCredential.user?.emailVerified}');
      
      // Send email verification
      debugPrint('📧 Enviando verificación de email...');
      await sendEmailVerification(userCredential.user!);
      debugPrint('📧 ===== FIN SIGNUP WITH EMAIL AND PASSWORD =====');
    } catch (e, stackTrace) {
      debugPrint('📧 ❌ ===== ERROR EN SIGNUP =====');
      debugPrint('📧 Error: $e');
      debugPrint('📧 Stack trace: $stackTrace');
      DialogHelper.closeDialog();
      
      // Obtener mensaje de error más amigable
      String errorMessage = _getReadableSignUpError(e);
      
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        errorMessage,
      );
    }
  }

  static Future<void> sendEmailVerification(firebase_auth.User user) async {
    try {
      debugPrint('📧 sendEmailVerification() -> Iniciando...');
      // Check status
      if (!user.emailVerified) {
        debugPrint('📧 Email no verificado, enviando verificación...');
        await user.sendEmailVerification();
        debugPrint('📧 Email de verificación enviado');
        // Go to verify email screen
        Future(() => Get.offAllNamed(AppRoutes.verifyEmail));
        // NO hacer signOut aquí - el usuario necesita estar autenticado para crear su perfil
        // El signOut se hará solo si el usuario no verifica el email
        debugPrint('📧 Usuario mantiene sesión para poder completar perfil después');
      } else {
        debugPrint('📧 Email ya verificado, continuando...');
        // Si ya está verificado, continuar con el flujo
        await _authController.checkUserAccount();
      }
    } catch (e) {
      debugPrint('❌ Error en sendEmailVerification: $e');
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        "failed_to_send_verification_email".trParams(
          {'error': e.toString()},
        ),
      );
    }
  }

  static Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 signInWithEmailAndPassword() -> Iniciando...');
      debugPrint('🔐 Email: $email');
      
      // Verificar si hay un usuario autenticado actualmente
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final currentEmail = currentUser.email?.toLowerCase().trim();
        final newEmail = email.toLowerCase().trim();
        
        // Si el email es diferente, cerrar la sesión actual primero
        if (currentEmail != newEmail) {
          debugPrint('🔐 Usuario diferente detectado. Cerrando sesión actual...');
          debugPrint('🔐 Email actual: $currentEmail');
          debugPrint('🔐 Email nuevo: $newEmail');
          try {
            await signOut();
            debugPrint('🔐 Sesión anterior cerrada correctamente');
          } catch (e) {
            debugPrint('🔐 Error al cerrar sesión anterior (continuando): $e');
            // Intentar cerrar sesión de todas formas
            try {
              await _firebaseAuth.signOut();
            } catch (_) {
              // Ignorar error
            }
          }
        }
      }
      
      DialogHelper.showProcessingDialog();
      
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('🔐 signInWithEmailAndPassword() -> Autenticación exitosa');
      
      // Get User
      final firebaseUser = userCredential.user!;
      debugPrint('🔐 Usuario ID: ${firebaseUser.uid}');
      debugPrint('🔐 Email verificado: ${firebaseUser.emailVerified}');

      // Check verification status
      if (!firebaseUser.emailVerified) {
        debugPrint('🔐 Email no verificado, enviando verificación...');
        // Send email verification if not already sent
        await sendEmailVerification(firebaseUser);
        DialogHelper.closeDialog();
        return;
      }

      debugPrint('🔐 Email verificado, continuando...');

      // Set login provider
      _authController.provider = LoginProvider.email;
      debugPrint('🔐 Provider establecido: email');

      // Check account in database
      debugPrint('🔐 Verificando cuenta en base de datos...');
      await _authController.checkUserAccount();
      debugPrint('🔐 checkUserAccount() completado');
      
      DialogHelper.closeDialog();
      debugPrint('🔐 signInWithEmailAndPassword() -> ✅ Éxito');
    } catch (e, stackTrace) {
      debugPrint('🔐 signInWithEmailAndPassword() -> ❌ ERROR: $e');
      debugPrint('🔐 Stack trace: $stackTrace');
      DialogHelper.closeDialog();
      
      // Obtener mensaje de error más amigable
      String errorMessage = getReadableAuthError(e);
      
      debugPrint('🔐 Mensaje de error para el usuario: $errorMessage');
      
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        errorMessage,
      );
    }
  }

  static Future<void> requestPasswordRecovery(String email) async {
    try {
      // Send request
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      // Success message
      DialogHelper.showAlertDialog(
        icon: const Icon(Icons.check_circle, color: primaryColor),
        title: Text('success'.tr),
        content: Text(
          "password_reset_email_sent_successfully".tr,
          style: const TextStyle(fontSize: 16),
        ),
        actionText: 'OKAY'.tr,
        action: () {
          // Close dialog
          Get.back();
          // Close page
          Get.back();
        },
      );
    } catch (e) {
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        "failed_to_send_password_reset_request".trParams(
          {'error': e.toString()},
        ),
      );
    }
  }

  static Future<void> signOut() async {
    try {
      await Get.deleteAll(force: true);
      await _firebaseAuth.signOut();
      // Sign out from Google with the same client ID configuration
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '70473962578-iivno9idub0f9gstp95hg4rq4ihuf998.apps.googleusercontent.com',
      );
      await googleSignIn.signOut();
      Get.offAllNamed(AppRoutes.splash);

      debugPrint('signOut() -> success');
    } catch (e) {
      debugPrint('signOut() -> error: $e');
    }
  }

  /// Sign in with Google
  static Future<void> signInWithGoogle() async {
    try {
      debugPrint('🔐 signInWithGoogle() -> Iniciando...');
      DialogHelper.showProcessingDialog();

      // Configure GoogleSignIn with the correct client ID for iOS
      // Client ID from the new Firebase project: 70473962578-iivno9idub0f9gstp95hg4rq4ihuf998.apps.googleusercontent.com
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // iOS client ID from GoogleService-Info.plist
        clientId: '70473962578-iivno9idub0f9gstp95hg4rq4ihuf998.apps.googleusercontent.com',
      );

      debugPrint('🔐 GoogleSignIn configurado con Client ID: 70473962578-iivno9idub0f9gstp95hg4rq4ihuf998.apps.googleusercontent.com');

      // Trigger the authentication flow
      debugPrint('🔐 Iniciando flujo de autenticación de Google...');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        debugPrint('🔐 Usuario canceló el inicio de sesión');
        DialogHelper.closeDialog();
        return;
      }

      debugPrint('🔐 Usuario de Google obtenido: ${googleUser.email}');

      // Obtain the auth details from the request
      debugPrint('🔐 Obteniendo detalles de autenticación...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      debugPrint('🔐 Access Token obtenido: ${googleAuth.accessToken != null ? "✅" : "❌"}');
      debugPrint('🔐 ID Token obtenido: ${googleAuth.idToken != null ? "✅" : "❌"}');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      debugPrint('🔐 Autenticando con Firebase...');
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      debugPrint('🔐 Usuario autenticado en Firebase: ${userCredential.user?.uid}');

      // Set login provider
      _authController.provider = LoginProvider.google;
      debugPrint('🔐 Provider establecido: google');

      // Check account in database
      debugPrint('🔐 Verificando cuenta en base de datos...');
      await _authController.checkUserAccount();
      debugPrint('🔐 checkUserAccount() completado');

      DialogHelper.closeDialog();

      debugPrint('🔐 signInWithGoogle() -> ✅ Éxito');
    } catch (e, stackTrace) {
      debugPrint('🔐 signInWithGoogle() -> ❌ ERROR: $e');
      debugPrint('🔐 Stack trace: $stackTrace');
      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        "failed_to_sign_in_with_google".trParams(
          {'error': e.toString()},
        ),
      );
    }
  }

  /// Convierte errores técnicos de Firebase Auth en mensajes legibles para el registro
  static String _getReadableSignUpError(dynamic error) {
    final errorCode = (error as FirebaseAuthException?)?.code ?? '';
    final errorMessage = error.toString().toLowerCase();

    debugPrint('📧 Error code: $errorCode');
    
    // Manejar errores específicos de Firebase Auth para registro
    switch (errorCode) {
      case 'email-already-in-use':
        return "email_already_in_use".tr;
      
      case 'invalid-email':
        return "enter_valid_email_address".tr;
      
      case 'weak-password':
        return "weak_password".tr;
      
      case 'operation-not-allowed':
        return "operation_not_allowed".tr;
      
      case 'network-request-failed':
        return "Error de conexión. Por favor, verifica tu conexión a internet.";
      
      default:
        // Mensaje genérico con el error original
        return "failed_to_sign_up_with_email_and_password".trParams(
          {'error': error.toString().replaceAll('Exception: ', '').split('\n').first},
        );
    }
  }

  /// Convierte errores técnicos de Firebase Auth en mensajes legibles para el usuario
  static String getReadableAuthError(dynamic error) {
    String errorCode = '';
    String errorMessage = error.toString().toLowerCase();

    // Extraer el código de error correctamente
    if (error is FirebaseAuthException) {
      errorCode = error.code;
    } else if (error.toString().contains('invalid-credential')) {
      errorCode = 'invalid-credential';
    } else if (error.toString().contains('wrong-password')) {
      errorCode = 'wrong-password';
    } else if (error.toString().contains('user-not-found')) {
      errorCode = 'user-not-found';
    } else if (error.toString().contains('too-many-requests')) {
      errorCode = 'too-many-requests';
    }

    debugPrint('🔐 Error code: $errorCode');
    debugPrint('🔐 Error message: $errorMessage');
    
    // Manejar errores específicos de Firebase Auth
    switch (errorCode) {
      case 'invalid-credential':
        // invalid-credential puede significar email o contraseña incorrectos
        return "invalid_credentials".tr;
      
      case 'wrong-password':
        return "wrong_password".tr;
      
      case 'user-not-found':
        return "user_not_found".tr;
      
      case 'invalid-email':
        return "enter_valid_email_address".tr;
      
      case 'user-disabled':
        return "your_account_is_blocked".tr;
      
      case 'too-many-requests':
        return "too_many_requests".tr;
      
      case 'network-request-failed':
        return "Error de conexión. Por favor, verifica tu conexión a internet.";
      
      case 'operation-not-allowed':
        return "El inicio de sesión con email y contraseña no está habilitado. Por favor, contacta al soporte.";
      
      default:
        // Si el error contiene información sobre credenciales inválidas
        if (errorMessage.contains('invalid-credential') || 
            errorMessage.contains('wrong-password') ||
            errorMessage.contains('invalid credential')) {
          return "invalid_credentials".tr;
        }
        
        // Mensaje genérico con el error original
        return "failed_to_sign_in_with_email_and_password".trParams(
          {'error': error.toString().replaceAll('Exception: ', '').split('\n').first},
        );
    }
  }

}
