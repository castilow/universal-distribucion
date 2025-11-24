import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/screens/messages/controllers/message_controller.dart';
import 'package:chat_messenger/screens/messages/components/chat_input_field.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:ui';

class KlinkAIChatView extends StatefulWidget {
  final User user;

  const KlinkAIChatView({super.key, required this.user});

  @override
  State<KlinkAIChatView> createState() => _KlinkAIChatViewState();
}

class _KlinkAIChatViewState extends State<KlinkAIChatView> with TickerProviderStateMixin {
  late MessageController controller;
  late AnimationController _bgController;
  late Animation<Color?> _bgColor1;
  late Animation<Color?> _bgColor2;

  @override
  void initState() {
    super.initState();
    // Initialize controller for this chat
    // Ensure we don't duplicate if it already exists
    if (Get.isRegistered<MessageController>()) {
      controller = Get.find<MessageController>();
      // If the existing controller is for a different user/group, we might need to reload or handle it.
      // But typically MessageScreen handles the put. Since we are inside MessageScreen logic (conditionally),
      // we should ensure the controller is set up for THIS user.
      // However, MessageScreen does Get.put BEFORE checking the condition in the original code?
      // No, I modified MessageScreen to check condition FIRST. So I need to put the controller here.
    } else {
       controller = Get.put(MessageController(isGroup: false, user: widget.user));
    }

    // Background Animation
    _bgController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _bgColor1 = ColorTween(
      begin: const Color(0xFF0F2027),
      end: const Color(0xFF203A43),
    ).animate(_bgController);

    _bgColor2 = ColorTween(
      begin: const Color(0xFF2C5364),
      end: const Color(0xFF0F2027),
    ).animate(_bgController);
  }

  @override
  void dispose() {
    _bgController.dispose();
    // Do not dispose controller here if it's managed by GetX pages, but since we did Get.put, we might need to.
    // Standard MessageScreen relies on GetX to dispose when route pops.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _bgColor1.value!,
                  _bgColor2.value!,
                  Colors.black,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildMessageList()),
                  // Standard Chat Input Field
                  ChatInputField(user: widget.user),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Image.asset('assets/images/app_logo.png'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Klink AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Online',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Optional: Add more actions here if needed
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Colors.cyan));
      }
      
      return AnimationLimiter(
        child: ListView.builder(
          reverse: true,
          itemCount: controller.messages.length,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemBuilder: (context, index) {
            final message = controller.messages[index];
            final isMe = message.isSender;

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        // Glassmorphism effect
                        color: isMe 
                            ? const Color(0xFF00E5FF).withOpacity(0.15) 
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                          bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                        ),
                        border: Border.all(
                          color: isMe 
                              ? const Color(0xFF00E5FF).withOpacity(0.3) 
                              : Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        message.textMsg,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
