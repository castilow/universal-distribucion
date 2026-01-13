import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/api/auth_api.dart';

class SignUpWithEmailController extends GetxController {
  // Variables
  final RxBool isLoading = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscurePassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  String? confirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'enter_confirm_password'.tr;
    } else if (passwordController.text != value) {
      return 'passwords_dont_match'.tr;
    }
    return null;
  }

  Future<void> signUpWithEmailAndPassword() async {
    // Evitar múltiples llamadas simultáneas
    if (isLoading.value) {
      debugPrint('📝 Ya hay un intento de registro en progreso...');
      return;
    }

    debugPrint('📝 ===== SIGNUP WITH EMAIL =====');
    debugPrint('📝 Email: ${emailController.text.trim()}');
    
    // Check the form
    if (!formKey.currentState!.validate()) {
      debugPrint('📝 ❌ Validación del formulario falló');
      return;
    }

    debugPrint('📝 ✅ Validación del formulario exitosa');
    isLoading.value = true;

    try {
      debugPrint('📝 Llamando a AuthApi.signUpWithEmailAndPassword()...');
      await AuthApi.signUpWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      debugPrint('📝 ✅ AuthApi.signUpWithEmailAndPassword() completado');
    } catch (e, stackTrace) {
      debugPrint('📝 ❌ Error en signUpWithEmailAndPassword: $e');
      debugPrint('📝 Stack trace: $stackTrace');
    } finally {
      // Asegurar que isLoading se resetee siempre
      isLoading.value = false;
      debugPrint('📝 ===== FIN SIGNUP WITH EMAIL =====');
    }
  }
}
