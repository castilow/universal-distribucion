import 'package:chat_messenger/models/user.dart';

/// Usuario especial que representa al asistente IA
class AIAssistantUser {
  static User get instance => User(
    userId: 'klink_ai_assistant',
    fullname: 'Klink AI',
    username: 'klink_ai',
    email: 'ai@klink.app',
    photoUrl: 'https://firebasestorage.googleapis.com/v0/b/klink-b0358.appspot.com/o/ai_avatar.png?alt=media',
    bio: 'Soy tu asistente inteligente. Pregúntame lo que necesites.',
    deviceToken: '',
    isOnline: true,
    status: 'active',
    loginProvider: LoginProvider.email,
    createdAt: DateTime.now(),
    lastActive: DateTime.now(),
    isTyping: false,
    typingTo: '',
    isRecording: false,
    recordingTo: '',
    mutedGroups: const [],
  );
}



