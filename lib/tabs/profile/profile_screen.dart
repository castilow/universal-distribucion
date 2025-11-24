import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/preferences_controller.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/screens/languages/languages_screen.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:chat_messenger/api/auth_api.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/models/user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Vars
    final PreferencesController prefController = Get.find();
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    
    // Safe access to current user
    User currentUser;
    try {
      currentUser = AuthController.instance.currentUser;
    } catch (e) {
      // Fallback to default user if there's an error
      currentUser = User(
        userId: '',
        fullname: 'Usuario',
        username: 'usuario',
        photoUrl: '',
        email: 'usuario@email.com',
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

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF17212B) : const Color(0xFFF0F2F5),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            backgroundColor: isDarkMode ? const Color(0xFF17212B) : Colors.white,
            foregroundColor: isDarkMode ? Colors.white : Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Obx(() {
                final user = AuthController.instance.currentUser;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.editProfile, arguments: {'user': user}),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: user.photoUrl.isNotEmpty
                              ? DecorationImage(image: NetworkImage(user.photoUrl), fit: BoxFit.cover)
                              : null,
                          color: primaryColor,
                        ),
                        child: user.photoUrl.isEmpty
                            ? const Icon(Icons.person, color: Colors.white, size: 30)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullname.isNotEmpty ? user.fullname : 'Usuario',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.username.isNotEmpty ? '@${user.username}' : '@usuario',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code),
                onPressed: () {}, // TODO: QR Code
              ),
              // Search button removed as per request
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                   // TODO: Menu (Edit name, Log out)
                   AuthApi.signOut();
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Account Section
                _buildSectionTitle(context, 'Account'),
                _buildSettingsItem(
                  context,
                  icon: IconlyLight.profile,
                  title: 'My Profile',
                  onTap: () => Get.toNamed(AppRoutes.editProfile, arguments: {'user': AuthController.instance.currentUser}),
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  context,
                  icon: Icons.alternate_email,
                  title: 'Username',
                  subtitle: '@${AuthController.instance.currentUser.username}',
                  onTap: () {}, // Navigate to change username
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  context,
                  icon: IconlyLight.call,
                  title: 'Phone Number',
                  subtitle: '+1 234 567 890', // Placeholder
                  onTap: () {},
                ),

                const SizedBox(height: 16),

                // Settings Section
                _buildSectionTitle(context, 'Settings'),
                _buildSettingsItem(
                  context,
                  icon: IconlyLight.notification,
                  title: 'Notifications and Sounds',
                  onTap: () {},
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  context,
                  icon: IconlyLight.lock,
                  title: 'Privacy and Security',
                  onTap: () {},
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  context,
                  icon: IconlyLight.paper,
                  title: 'Data and Storage',
                  onTap: () {},
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  context,
                  icon: IconlyLight.chat,
                  title: 'Chat Settings',
                  onTap: () => Get.toNamed(AppRoutes.appearance), // Reusing appearance for now
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  context,
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: prefController.langName,
                  onTap: () => Get.to(() => const LanguagesScreen()),
                ),

                const SizedBox(height: 16),

                // Help Section
                _buildSectionTitle(context, 'Help'),
                 _buildSettingsItem(
                  context,
                  icon: IconlyLight.infoSquare,
                  title: 'Ask a Question',
                  onTap: () {},
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  context,
                  icon: IconlyLight.paper,
                  title: 'Telegram FAQ',
                  onTap: () => AppHelper.openTermsPage(), // Placeholder
                ),
                _buildDivider(isDarkMode),
                _buildSettingsItem(
                  context,
                  icon: IconlyLight.shieldDone,
                  title: 'Privacy Policy',
                  onTap: () => AppHelper.openPrivacyPage(),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    return Container(
      color: isDarkMode ? const Color(0xFF17212B) : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                  fontSize: 13,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Container(
      color: isDarkMode ? const Color(0xFF17212B) : Colors.white,
      child: Divider(
        height: 1,
        indent: 72,
        color: isDarkMode ? Colors.black : Colors.grey[200],
      ),
    );
  }
}
