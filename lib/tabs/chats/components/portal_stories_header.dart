import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/models/chat.dart';
import 'stories_section.dart';
import 'dart:math' as math;

class PortalStoriesHeader extends StatelessWidget {
  final ScrollController scrollController;
  final List<Chat> chats;
  final double maxHeight;

  const PortalStoriesHeader({
    super.key,
    required this.scrollController,
    required this.chats,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        // Calculate progress based on scroll offset
        // offset goes from maxHeight (hidden) down to 0 (fully visible)
        // We want animation to happen as we approach 0.
        
        double offset = 0;
        if (scrollController.hasClients) {
          offset = scrollController.offset;
        } else {
          offset = maxHeight; // Default to hidden
        }

        // Clamp offset
        offset = offset.clamp(0.0, maxHeight);

        // Calculate reveal progress (0.0 = hidden, 1.0 = fully revealed)
        final double revealProgress = 1.0 - (offset / maxHeight);

        // Animation Phases
        // Phase 1: Logo Grow (0.0 to 0.6 progress)
        // Phase 2: Transition (0.6 to 0.8 progress)
        // Phase 3: Stories Settle (0.8 to 1.0 progress)

        double logoOpacity = 1.0;
        double logoScale = 0.5 + (revealProgress * 0.8); // 0.5 -> 1.3
        double storiesOpacity = 0.0;
        double storiesScale = 0.8;

        if (revealProgress > 0.6) {
          // Transition phase: Logo fades out, Stories fade in
          final double transitionProgress = (revealProgress - 0.6) / 0.4; // 0.0 -> 1.0
          
          logoOpacity = (1.0 - transitionProgress * 2).clamp(0.0, 1.0);
          storiesOpacity = transitionProgress.clamp(0.0, 1.0);
          storiesScale = 0.8 + (transitionProgress * 0.2); // 0.8 -> 1.0
        }

        return SizedBox(
          height: maxHeight,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // 1. The Glowing Logo (The Portal)
              Positioned(
                bottom: 40, // Center vertically roughly
                child: Opacity(
                  opacity: logoOpacity,
                  child: Transform.scale(
                    scale: logoScale,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3 * revealProgress), // Glow effect
                            blurRadius: 20 * revealProgress,
                            spreadRadius: 5 * revealProgress,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // 2. The Stories Section
              if (revealProgress > 0.4) // Optimization: don't render if hidden
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: storiesOpacity,
                    child: Transform.scale(
                      scale: storiesScale,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: StoriesSection(chats: chats),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
