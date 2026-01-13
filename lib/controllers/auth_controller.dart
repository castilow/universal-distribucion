import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:chat_messenger/services/zego_call_service.dart';
import 'package:chat_messenger/api/auth_api.dart';

import 'app_controller.dart';

class AuthController extends GetxController {
  // Get the current instance
  static AuthController instance = Get.find();

  // Firebase Auth
  final _firebaseAuth = auth.FirebaseAuth.instance;
  // Firebase User
  auth.User? get firebaseUser => _firebaseAuth.currentUser;

  // Hold login provider
  LoginProvider provider = LoginProvider.email;

  // Timestamp del último envío de email de verificación
  DateTime? _lastVerificationEmailSent;
  
  // Getter para acceder al timestamp
  DateTime? get lastVerificationEmailSent => _lastVerificationEmailSent;
  
  // Tiempo mínimo entre envíos de email (5 minutos)
  static const Duration _minTimeBetweenEmails = Duration(minutes: 5);
  
  // Verificar si se puede enviar un email de verificación
  bool get canSendVerificationEmail {
    return _lastVerificationEmailSent == null || 
        DateTime.now().difference(_lastVerificationEmailSent!) >= _minTimeBetweenEmails;
  }

  // Enviar email de verificación con control de rate limiting
  Future<void> sendVerificationEmail() async {
    if (!canSendVerificationEmail) {
      throw Exception('too-many-requests');
    }
    
    if (firebaseUser == null) {
      throw Exception('user-not-found');
    }
    
    await firebaseUser!.sendEmailVerification();
    _lastVerificationEmailSent = DateTime.now();
  }

  // Current User Model
  final Rxn<User> _currentUser = Rxn();
  StreamSubscription<User>? _stream;

  // <-- GETTERS -->
  User get currentUser {
    try {
      if (_currentUser.value == null) {
        // Return a default user if current user is null
        return User(
          userId: firebaseUser?.uid ?? '',
          fullname: '',
          username: '',
          photoUrl: '',
          email: firebaseUser?.email ?? '',
          bio: '',
          isOnline: false,
          deviceToken: '',
          status: 'active',
          loginProvider: LoginProvider.email,
          isTyping: false,
          typingTo: '',
          isRecording: false,
          recordingTo: '',
          mutedGroups: const [],
        );
      }
      return _currentUser.value!;
    } catch (e) {
      debugPrint('AuthController.currentUser -> Error: $e');
      // Return a default user if there's any error
      return User(
        userId: firebaseUser?.uid ?? '',
        fullname: '',
        username: '',
        photoUrl: '',
        email: firebaseUser?.email ?? '',
        bio: '',
        isOnline: false,
        deviceToken: '',
        status: 'active',
        loginProvider: LoginProvider.email,
        isTyping: false,
        typingTo: '',
        isRecording: false,
        recordingTo: '',
        mutedGroups: const [],
      );
    }
  }

  @override
  void onClose() {
    _stream?.cancel();
    super.onClose();
  }

  // Update Current User Model
  void _updateCurrentUser(User user) {
    _currentUser.value = user;
    // Get user updates
    _stream = UserApi.getUserUpdates(user.userId).listen(
      (event) {
        _currentUser.value = event;
      },
      onError: (e) {
        debugPrint('AuthController._updateCurrentUser() -> Error: $e');
        // Don't update the current user on error to avoid null issues
      },
    );
  }

  // Handle user auth
  Future<void> checkUserAccount() async {
    debugPrint('👤 checkUserAccount() -> Iniciando...');
    
    // Check logged in firebase user
    if (firebaseUser == null) {
      debugPrint('👤 checkUserAccount() -> ❌ firebaseUser es null, redirigiendo a signInOrSignUp');
      // Go directly to sign in page, skip welcome screen
      Future(() => Get.offAllNamed(AppRoutes.signInOrSignUp));
      return;
    }

    debugPrint('👤 firebaseUser ID: ${firebaseUser!.uid}');
    debugPrint('👤 Email: ${firebaseUser!.email}');
    debugPrint('👤 Email verificado: ${firebaseUser!.emailVerified}');

    // Check if email is verified
    if (!firebaseUser!.emailVerified) {
      debugPrint('👤 Email no verificado, recargando usuario...');
      // Reload user to get latest verification status
      try {
        await firebaseUser!.reload();
      } catch (e) {
        debugPrint('👤 ❌ Error al recargar usuario: $e');
      }
      
      // Check again after reload
      if (!firebaseUser!.emailVerified) {
        debugPrint('👤 Email aún no verificado, redirigiendo a verifyEmail');
        
        // Solo enviar email si han pasado al menos 5 minutos desde el último envío
        final canSendEmail = _lastVerificationEmailSent == null || 
            DateTime.now().difference(_lastVerificationEmailSent!) >= _minTimeBetweenEmails;
        
        if (canSendEmail) {
          try {
            debugPrint('👤 Enviando email de verificación...');
            await sendVerificationEmail();
            debugPrint('👤 ✅ Email de verificación enviado');
          } catch (e) {
            debugPrint('👤 ❌ Error enviando email de verificación: $e');
            // No bloquear el flujo si hay error, solo mostrar mensaje
            final errorMessage = AuthApi.getReadableAuthError(e);
            if (e.toString().contains('too-many-requests') || 
                (e is auth.FirebaseAuthException && e.code == 'too-many-requests')) {
              // Ya se envió un email recientemente, solo redirigir
              debugPrint('👤 ⚠️ Demasiadas solicitudes, esperando antes de enviar otro email');
            }
          }
        } else {
          debugPrint('👤 ⏳ Esperando antes de enviar otro email de verificación');
        }
        
        // Go to verify email screen (siempre, independientemente de si se envió el email)
        Future(() => Get.offAllNamed(AppRoutes.verifyEmail));
        return;
      }
    }

    debugPrint('👤 Email verificado, continuando...');

    // Init app controller
    Get.put(AppController(), permanent: true);
    debugPrint('👤 AppController inicializado');

    // Check User Account in database
    debugPrint('👤 Buscando usuario en base de datos con UID: ${firebaseUser!.uid}');
    final user = await UserApi.getUser(firebaseUser!.uid);

    // Check user
    if (user == null) {
      debugPrint('👤 ❌ Usuario no encontrado en base de datos, redirigiendo a signUp');
      // Go to sign-up page to complete profile
      Future(() => Get.offAllNamed(AppRoutes.signUp));
      return;
    }

    debugPrint('👤 ✅ Usuario encontrado en base de datos');
    debugPrint('👤 Nombre: ${user.fullname}');
    debugPrint('👤 Estado: ${user.status}');

    // Check blocked account status
    if (user.status == 'blocked') {
      debugPrint('👤 ❌ Cuenta bloqueada, redirigiendo a blockedAccount');
      // Go to blocked account page
      Future(() => Get.offAllNamed(AppRoutes.blockedAccount));
      return;
    }

    debugPrint('👤 Cuenta activa, actualizando información...');

    // Update the current user model
    _updateCurrentUser(user);
    debugPrint('👤 Usuario actualizado en el controlador');

    // Update current user info
    await UserApi.updateUserInfo(user);
    debugPrint('👤 Información de usuario actualizada en Firestore');

    // Inicializar ZEGOCLOUD después de que el usuario esté autenticado
    try {
      final zegoService = Get.find<ZegoCallService>();
      await zegoService.initializeWhenUserAuthenticated();
      debugPrint('👤 ZEGOCLOUD inicializado');
    } catch (e) {
      debugPrint('👤 ⚠️ Error inicializando ZEGOCLOUD: $e');
    }

    // Go to home page
    debugPrint('👤 ✅ checkUserAccount() completado, redirigiendo a home');
    Future(() => Get.offAllNamed(AppRoutes.home));
  }

  Future<void> getCurrentUserAndLoadData() async {
    try {
      final user = await UserApi.getUser(firebaseUser!.uid);
      if (user != null) {
        // Update the current user model
        _updateCurrentUser(user);
        // Update current user info
        UserApi.updateUserInfo(user);
        
        // Inicializar ZEGOCLOUD después de cargar los datos del usuario
        try {
          final zegoService = Get.find<ZegoCallService>();
          await zegoService.initializeWhenUserAuthenticated();
        } catch (e) {
          debugPrint('AuthController.getCurrentUserAndLoadData() -> Error inicializando ZEGOCLOUD: $e');
        }
      } else {
        debugPrint('AuthController.getCurrentUserAndLoadData() -> User not found');
      }
    } catch (e) {
      debugPrint('AuthController.getCurrentUserAndLoadData() -> Error: $e');
    }
  }
}
