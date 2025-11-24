import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/controllers/background_controller.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class BackgroundSelectionScreen extends StatelessWidget {
  const BackgroundSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BackgroundController controller = Get.put(BackgroundController());
    final bool isDarkMode = AppTheme.of(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Wallpaper'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Preview Area
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Obx(() => Container(
                      decoration: controller.currentDecoration,
                      child: Stack(
                        children: [
                          // Mock Messages
                          ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              _buildMockMessage(
                                'Hey! Do you like this background?',
                                true,
                                isDarkMode,
                              ),
                              _buildMockMessage(
                                'It looks amazing! 😍',
                                false,
                                isDarkMode,
                              ),
                              _buildMockMessage(
                                'The turquoise theme is 🔥',
                                true,
                                isDarkMode,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ),

          // Selection Area
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(text: 'Colors'),
                        Tab(text: 'Gradients'),
                        Tab(text: 'Photos'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Colors Tab
                          _buildColorsGrid(context, controller),
                          // Gradients Tab
                          _buildGradientsGrid(context, controller),
                          // Photos Tab
                          _buildPhotosTab(context, controller, isDarkMode),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockMessage(String text, bool isMe, bool isDarkMode) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFF00E5FF) // Premium Cyan
              : (isDarkMode ? const Color(0xFF2C2C2E) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : (isDarkMode ? Colors.white : Colors.black),
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildColorsGrid(BuildContext context, BackgroundController controller) {
    final List<Color> colors = [
      Colors.white,
      const Color(0xFFF5F5F5),
      const Color(0xFFE0F7FA), // Light Cyan
      const Color(0xFFE8F5E9), // Light Green
      const Color(0xFFFFF3E0), // Light Orange
      const Color(0xFFF3E5F5), // Light Purple
      const Color(0xFFFFEBEE), // Light Red
      const Color(0xFFECEFF1), // Light Blue Grey
      const Color(0xFF212121), // Dark Grey
      const Color(0xFF000000), // Black
      const Color(0xFF0F172A), // Slate 900
      const Color(0xFF1E293B), // Slate 800
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => controller.setSolidColor(colors[index]),
          child: Obx(() {
            final isSelected = controller.backgroundType.value == BackgroundType.color &&
                controller.selectedColorValue.value == colors[index].value;
            
            return Container(
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.grey)
                  : null,
            );
          }),
        );
      },
    );
  }

  Widget _buildGradientsGrid(BuildContext context, BackgroundController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: controller.gradients.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => controller.setGradient(index),
          child: Obx(() {
            final isSelected = controller.backgroundType.value == BackgroundType.gradient &&
                controller.selectedGradientIndex.value == index;

            return Container(
              decoration: BoxDecoration(
                gradient: controller.gradients[index],
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: Theme.of(context).primaryColor, width: 3)
                    : null,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check_circle, color: Colors.white),
                    )
                  : null,
            );
          }),
        );
      },
    );
  }

  Widget _buildPhotosTab(BuildContext context, BackgroundController controller, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => controller.pickImage(),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    IconlyBold.image,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose Photo',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Select a photo from your gallery to set as your chat background.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
