import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/api/auth_api.dart';
import 'package:chat_messenger/helpers/ads/ads_helper.dart';
import 'package:chat_messenger/helpers/ads/banner_ad_helper.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/models/user.dart';
import 'dart:ui'; // For Glassmorphism

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Load Ads
    AdsHelper.loadAds();
  }

  @override
  void dispose() {
    super.dispose();
    AdsHelper.disposeAds();
  }

  @override
  Widget build(BuildContext context) {
    // Force dark modern theme logic for this screen
    final User currentUser = AuthController.instance.currentUser;
    const Color goldColor = Color(0xFFD4AF37);
    const Color glassColor = Color(0xFF141414);

    return Scaffold(
      backgroundColor: Colors.black, // Deep Black Background
      body: Stack(
        children: [
          // Ambient Background Glow (Optional, keeping it subtle)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.1),
                backgroundBlendMode: BlendMode.plus,
              ),
            ).blurred(blur: 80),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // 1. Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(IconlyLight.arrowLeft, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Settings',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Banner Ad (Preserved)
                BannerAdHelper.showBannerAd(),

                // 3. Content List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    children: [
                      // PROFILE CARD
                      _buildGlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.editProfile,
                                arguments: {'user': currentUser},
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: goldColor, width: 2),
                                    boxShadow: [
                                      BoxShadow(color: goldColor.withOpacity(0.2), blurRadius: 10),
                                    ],
                                  ),
                                  child: CachedCircleAvatar(
                                    imageUrl: currentUser.photoUrl,
                                    radius: 35,
                                    iconSize: 35,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentUser.fullname,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentUser.email.isNotEmpty 
                                            ? currentUser.email 
                                            : '@${currentUser.username}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(IconlyLight.edit, color: goldColor, size: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // GENERAL SETTINGS SECTION
                      const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 8),
                        child: Text(
                          "GENERAL",
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildSettingTile(
                              icon: IconlyBold.setting,
                              title: 'Appearance',
                              color: goldColor,
                              onTap: () => Get.toNamed(AppRoutes.appearance),
                            ),
                            _buildDivider(),
                            _buildSettingTile(
                              icon: IconlyBold.chart, 
                              title: 'Language',
                              color: goldColor,
                              onTap: () => Get.toNamed(AppRoutes.languages),
                            ),
                            _buildDivider(),
                            _buildSettingTile(
                              icon: IconlyBold.chat,
                              title: 'Chat Configuration', // Unified English title
                              color: goldColor,
                              onTap: () => Get.toNamed(AppRoutes.chatSettings),
                            ),
                            _buildDivider(),
                             _buildSettingTile(
                              icon: IconlyBold.shieldDone,
                              title: 'Blocked Accounts', // New Section
                              color: goldColor,
                              onTap: () => Get.toNamed(AppRoutes.blockedAccount),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ACCOUNT SECTION
                      const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 8),
                        child: Text(
                          "ACCOUNT",
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildSettingTile(
                              icon: IconlyBold.profile,
                              title: 'Account', // Restored "Account" title
                              color: goldColor,
                              onTap: () => Get.toNamed(AppRoutes.session),
                            ),
                            _buildDivider(),
                             _buildSettingTile(
                              icon: IconlyBold.infoSquare,
                              title: 'About', // New Section
                              color: goldColor,
                              onTap: () => Get.toNamed(AppRoutes.about),
                            ),
                            _buildDivider(),
                            _buildSettingTile(
                              icon: IconlyBold.logout,
                              title: 'Sign Out',
                              color: const Color(0xFFFF453A), 
                              isDestructive: true,
                              onTap: () {
                                DialogHelper.showAlertDialog(
                                  title: const Text('Sign Out'),
                                  icon: const Icon(IconlyLight.logout, color: goldColor),
                                  content: const Text('Are you sure you want to sign out?'),
                                  actionText: 'YES',
                                  action: () => AuthApi.signOut(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Version info
                      Center(
                        child: Text(
                          "Universal Distribucion v1.0.0",
                          style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                        ),
                      ),
                       const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141414).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? const Color(0xFFFF453A) : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(IconlyLight.arrowRight2, color: Colors.white54, size: 16),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.05),
      indent: 60, // Align with text start
    );
  }
}

// Extension for convenient blurring if not already present in project, 
// using local helper here to avoid dependency issues if 'velocity_x' or others aren't used everywhere
extension WidgetExtensions on Widget {
  Widget blurred({double blur = 10}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: this,
    );
  }
}



