import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/models/user.dart' hide User;
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
      DialogHelper.showProcessingDialog();
      
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Send email verification
      await sendEmailVerification(userCredential.user!);
    } catch (e) {
      DialogHelper.closeDialog();
      
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        "failed_to_sign_up_with_email_and_password".trParams(
          {'error': e.toString()},
        ),
      );
    }
  }

  static Future<void> sendEmailVerification(User user) async {
    try {
      // Check status
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        // Go to verify email screen
        Future(() => Get.offAllNamed(AppRoutes.verifyEmail));
        // Sign-out the user to ensure the email is verified first.
        await _firebaseAuth.signOut();
      }
    } catch (e) {
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
      DialogHelper.showProcessingDialog();
      
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('🔐 signInWithEmailAndPassword() -> Autenticación exitosa');
      
      // Get User
      User user = userCredential.user!;
      debugPrint('🔐 Usuario ID: ${user.uid}');
      debugPrint('🔐 Email verificado: ${user.emailVerified}');

      // Check verification status
      if (!user.emailVerified) {
        debugPrint('🔐 Email no verificado, enviando verificación...');
        // Send email verification if not already sent
        await sendEmailVerification(user);
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
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        "failed_to_sign_in_with_email_and_password".trParams(
          {'error': e.toString()},
        ),
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
      await GoogleSignIn().signOut(); // Sign out from Google
      Get.offAllNamed(AppRoutes.splash);

      debugPrint('signOut() -> success');
    } catch (e) {
      debugPrint('signOut() -> error: $e');
    }
  }

  /// Sign in with Google
  static Future<void> signInWithGoogle() async {
    try {
      DialogHelper.showProcessingDialog();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        DialogHelper.closeDialog();
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await _firebaseAuth.signInWithCredential(credential);

      // Set login provider
      _authController.provider = LoginProvider.google;

      // Check account in database
      await _authController.checkUserAccount();

      DialogHelper.closeDialog();

      debugPrint('signInWithGoogle() -> success');
    } catch (e) {
      DialogHelper.closeDialog();
      DialogHelper.showSnackbarMessage(
        SnackMsgType.error,
        "failed_to_sign_in_with_google".trParams(
          {'error': e.toString()},
        ),
      );
      debugPrint('signInWithGoogle() -> error: $e');
    }
  }

}
