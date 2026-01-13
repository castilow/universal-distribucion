import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/components/default_button.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/api/auth_api.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  Future<void> _checkEmailVerification() async {
    try {
      debugPrint('📧 ===== VERIFICANDO EMAIL =====');
      // Get auth controller
      final authController = AuthController.instance;
      
      // Si el usuario no está autenticado, necesita iniciar sesión primero
      if (authController.firebaseUser == null) {
        debugPrint('📧 ❌ Usuario no autenticado, redirigiendo a signIn');
        Get.offAllNamed(AppRoutes.signIn);
        return;
      }
      
      debugPrint('📧 Usuario autenticado: ${authController.firebaseUser?.uid}');
      debugPrint('📧 Email: ${authController.firebaseUser?.email}');
      debugPrint('📧 Email verificado (antes de reload): ${authController.firebaseUser?.emailVerified}');
      
      // Reload firebase user to get latest status
      try {
        await authController.firebaseUser?.reload();
        debugPrint('📧 Usuario recargado');
        debugPrint('📧 Email verificado (después de reload): ${authController.firebaseUser?.emailVerified}');
      } catch (e) {
        debugPrint('📧 ⚠️ Error al recargar usuario: $e');
        // Continuar con el flujo aunque haya error al recargar
      }
      
      // Verificar que el usuario sigue autenticado después del reload
      if (authController.firebaseUser == null) {
        debugPrint('📧 ❌ Usuario perdió sesión después del reload, redirigiendo a signIn');
        Get.offAllNamed(AppRoutes.signIn);
        return;
      }
      
      // Verificar si el email está verificado ahora
      if (!authController.firebaseUser!.emailVerified) {
        debugPrint('📧 ❌ Email aún no verificado');
        DialogHelper.showSnackbarMessage(
          SnackMsgType.info,
          "Tu email aún no ha sido verificado. Por favor, revisa tu bandeja de entrada y haz clic en el enlace de verificación.",
        );
        return;
      }
      
      // Email verificado, continuar con el flujo
      debugPrint('📧 ✅ Email verificado, continuando con el flujo de cuenta...');
      
      // Check verification status and proceed with account setup
      debugPrint('📧 Llamando a checkUserAccount()...');
      await authController.checkUserAccount();
      debugPrint('📧 ===== FIN VERIFICACIÓN EMAIL =====');
    } catch (e, stackTrace) {
      debugPrint('❌ Error checking email verification: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        "Error al verificar el email. Por favor, intenta de nuevo.",
      );
    }
  }

  Future<void> _resendVerification() async {
    try {
      final authController = AuthController.instance;
      final user = authController.firebaseUser;
      
      if (user == null) {
        DialogHelper.showSnackbarMessage(
          SnackMsgType.error,
          "No hay una sesión activa. Por favor, inicia sesión nuevamente.",
        );
        Get.offAllNamed(AppRoutes.signIn);
        return;
      }
      
      // Verificar si se puede enviar otro email (control de rate limiting)
      if (!authController.canSendVerificationEmail) {
        DialogHelper.showSnackbarMessage(
          SnackMsgType.info,
          "Por favor, espera unos minutos antes de solicitar otro email de verificación.",
        );
        return;
      }
      
      debugPrint('📧 Reenviando email de verificación...');
      await authController.sendVerificationEmail();
      
      DialogHelper.showSnackbarMessage(
        SnackMsgType.success,
        "Email de verificación reenviado. Por favor, revisa tu bandeja de entrada.",
      );
    } catch (e) {
      debugPrint('❌ Error resending verification: $e');
      
      // Obtener mensaje de error amigable
      String errorMessage = AuthApi.getReadableAuthError(e);
      
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        errorMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        hideLeading: false,
        title: const Text('Verify Email'),
        onBackPress: () {
          // Intentar volver atrás, si no hay pantalla anterior, ir a sign in
          if (Navigator.of(context).canPop()) {
            Get.back();
          } else {
            // Si no hay pantalla anterior, ir a sign in
            Get.offAllNamed(AppRoutes.signIn);
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              IconlyBold.message,
              size: 100,
              color: primaryColor,
            ),
            const SizedBox(height: defaultPadding * 2),
            Text(
              'Verify your email',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: defaultPadding),
            Text(
              'We have sent you a verification email. Please check your inbox and verify your email address.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: defaultPadding * 2),
            DefaultButton(
              text: 'I have verified my email',
              onPress: _checkEmailVerification,
            ),
            const SizedBox(height: defaultPadding),
            TextButton(
              onPressed: _resendVerification,
              child: Text(
                'Resend verification email',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
