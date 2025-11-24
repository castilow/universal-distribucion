import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:chat_messenger/models/chat.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/tabs/chats/components/story_item.dart';
import 'package:chat_messenger/tabs/stories/controller/story_controller.dart';
import 'package:chat_messenger/tabs/stories/story_view_screen.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:get/get.dart';

class StoriesSection extends StatelessWidget {
  final List<Chat> chats;

  const StoriesSection({
    super.key,
    required this.chats,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthController.instance.currentUser;
    final storyController = Get.find<StoryController>();

    return Obx(() {
      // Filtrar solo usuarios con historias activas (no expiradas)
      final activeStories = storyController.stories
          .where((story) => story.hasValidItems) // Solo historias con items válidos (< 24 horas)
          .toList();

      // Obtener IDs de usuarios con historias activas
      final usersWithStories = activeStories.map((s) => s.userId).toSet();

      // Filtrar chats para mostrar solo los que tienen historias activas
      final chatsWithStories = chats.where((chat) {
        if (chat.receiver == null) return false;
        return usersWithStories.contains(chat.receiver!.userId);
      }).toList();

      // Verificar si el usuario actual tiene historias activas
      final currentUserHasStory = activeStories
          .any((story) => story.userId == currentUser.userId);

      // Calcular el total de items (Your Story + usuarios con historias)
      final totalItems = (currentUserHasStory ? 1 : 0) + chatsWithStories.length;

      if (totalItems == 0) {
        // Si no hay historias, mostrar solo "Your Story" para crear una
        return Container(
          height: 110,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: 1,
            itemBuilder: (context, index) {
              return StoryItem(
                imageUrl: currentUser.photoUrl,
                name: currentUser.fullname,
                isMe: true,
                hasStory: false,
                onTap: () {
                  Get.toNamed(AppRoutes.writeStory);
                },
              );
            },
          ),
        );
      }

      return Container(
        height: 110,
        margin: const EdgeInsets.only(bottom: 10),
        child: AnimationLimiter(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: totalItems,
            itemBuilder: (context, index) {
              // Si el usuario actual tiene historias, mostrarlo primero
              if (currentUserHasStory && index == 0) {
                final myStory = activeStories.firstWhere(
                  (s) => s.userId == currentUser.userId,
                );
                
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: StoryItem(
                        imageUrl: currentUser.photoUrl,
                        name: 'Your Story',
                        isMe: true,
                        hasStory: true,
                        onTap: () {
                          Get.to(() => StoryViewScreen(story: myStory));
                        },
                      ),
                    ),
                  ),
                );
              }

              // Ajustar índice si el usuario actual tiene historias
              final chatIndex = currentUserHasStory ? index - 1 : index;
              final chat = chatsWithStories[chatIndex];
              final user = chat.receiver;

              if (user == null) return const SizedBox.shrink();

              // Encontrar la historia del usuario
              final userStory = activeStories.firstWhere(
                (s) => s.userId == user.userId,
                orElse: () => activeStories.first, // Fallback (no debería pasar)
              );

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: StoryItem(
                      imageUrl: user.photoUrl,
                      name: user.fullname.split(' ')[0], // First name only
                      hasStory: true,
                      onTap: () {
                        Get.to(() => StoryViewScreen(story: userStory));
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
