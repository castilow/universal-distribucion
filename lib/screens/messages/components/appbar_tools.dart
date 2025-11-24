import 'package:flutter/material.dart';
import 'package:chat_messenger/components/scale_button.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/api/report_api.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/components/badge_count.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/tabs/chats/controllers/chat_controller.dart';
import 'package:chat_messenger/tabs/groups/controllers/group_controller.dart';
import 'package:chat_messenger/controllers/preferences_controller.dart';
import 'package:chat_messenger/controllers/report_controller.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/helpers/routes_helper.dart';
import 'package:chat_messenger/tabs/groups/controllers/group_controller.dart';
import 'package:chat_messenger/services/zego_call_service.dart';
import 'package:get/get.dart';
import '../controllers/block_controller.dart';
import '../controllers/message_controller.dart';
import 'popup_menu_title.dart';

class AppBarTools extends StatelessWidget implements PreferredSizeWidget {
  const AppBarTools({
    super.key,
    required this.isGroup,
    this.user,
    required this.group,
  });

  final bool isGroup;
  final Group? group;
  final User? user;

  @override
  Widget build(BuildContext context) {
    // Get controllers
    final GroupController groupController = Get.find();
    final PreferencesController prefController = Get.find();
    final ReportController reportController = Get.find();
    
    const devider = PopupMenuItem<String>(
      height: 0,
      padding: EdgeInsets.zero,
      child: Divider(height: 3),
    );

    // <-- Build Group AppBar -->
    if (isGroup) {
      // Vars
      final bool isBroadcast = group!.isBroadcast;
      final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return AppBar(
        backgroundColor: isDarkMode ? darkThemeBgColor : Colors.white.withOpacity(0.8),
        elevation: 0,
        toolbarHeight: 140, // Subir aún más el header
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? darkThemeBgColor : Colors.white.withOpacity(0.8),
            // Efecto de difuminado/blur
            boxShadow: [
              BoxShadow(
                 color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        leadingWidth: 60, // Más espacio para la flechita y el badge
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleButton(
                  onTap: () => Get.back(),
                   child: Icon(Icons.arrow_back_ios_new_sharp, color: isDarkMode ? primaryLight : Colors.blue),
                ),
                const SizedBox(width: 8), // Espacio entre flecha y badge
                // Badge con número total de mensajes sin leer
                Obx(() {
                  // Calcular total de mensajes sin leer de todos los chats y grupos
                  int totalUnread = 0;
                  
                  // Sumar mensajes sin leer de chats individuales
                  for (final chat in ChatController.instance.chats) {
                    totalUnread += chat.unread;
                  }
                  
                  // Sumar mensajes sin leer de grupos
                  for (final group in GroupController.instance.groups) {
                    totalUnread += group.unread;
                  }
                  
                  return BadgeCount(
                    counter: totalUnread,
                    bgColor: Colors.blue,
                  );
                }),
              ],
            ),
          ],
        ),
        // Group info
        title: GestureDetector(
          onTap: () => RoutesHelper.toGroupDetails(group!.groupId),
          child: Row(
            children: [
              // Group photo
              CachedCircleAvatar(
                isGroup: true,
                isBroadcast: isBroadcast,
                backgroundColor: secondaryColor,
                imageUrl: group!.photoUrl,
                borderWidth: 0,
                padding: 0,
                radius: 20,
              ),
              const SizedBox(width: defaultPadding * 0.75),
              // Group info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group name
                    Text(
                      group!.name,
                       style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Tap to for info
                    Text(
                      '${isBroadcast ? group!.recipients.length : group!.participants.length} ${isBroadcast ? 'recipients'.tr.toLowerCase() : 'participants'.tr.toLowerCase()}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                           ?.copyWith(color: isDarkMode ? Colors.white70 : Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: isBroadcast
            ? null
            : [
                Obx(() {
                  final User currentUser = AuthController.instance.currentUser;
                  // Get group wallpaper path
                  final String? groupWallpaperPath =
                      prefController.groupWallpaperPath.value;
                  return PopupMenuButton<String>(
                    initialValue: '',
                    icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.white : Colors.black),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        onTap: () =>
                            RoutesHelper.toGroupDetails(group!.groupId),
                        child: PopupMenuTitle(
                          icon: IconlyLight.dangerCircle,
                          title: 'group_info'.tr,
                        ),
                      ),
                      devider,
                      PopupMenuItem(
                        onTap: () =>
                            UserApi.muteGroup(group!.groupId, group!.isMuted),
                        child: PopupMenuTitle(
                          icon: group!.isMuted
                              ? Icons.volume_off
                              : IconlyLight.notification,
                          title: group!.isMuted
                              ? 'unmute_notifications'.tr
                              : 'mute_notifications'.tr,
                        ),
                      ),
                      devider,
                      PopupMenuItem(
                        onTap: () {
                          if (groupWallpaperPath == null) {
                            prefController.setGroupWallpaper(group!.groupId);
                          } else {
                            prefController.removeGroupWallpaper(group!.groupId);
                          }
                        },
                        child: PopupMenuTitle(
                          icon: IconlyLight.image2,
                          title: groupWallpaperPath == null
                              ? 'set_wallpaper'.tr
                              : 'remove_wallpaper'.tr,
                        ),
                      ),
                      devider,
                      PopupMenuItem(
                        onTap: () => reportController.reportDialog(
                          type: ReportType.group,
                          groupId: group!.groupId,
                        ),
                        child: PopupMenuTitle(
                          icon: IconlyLight.dangerTriangle,
                          title: 'report_group'.tr,
                        ),
                      ),
                      devider,
                      if (!group!.isRemoved(currentUser.userId))
                        PopupMenuItem(
                          onTap: () => groupController.exitGroup(),
                          child: PopupMenuTitle(
                            icon: IconlyLight.logout,
                            title: 'exit_group'.tr,
                          ),
                        ),
                    ],
                  );
                }),
              ],
      );
    }

    //
    // <-- Build 1-to-1 Chat AppBar Session -->
    //
    // Get block user controller
    final User currentUser = AuthController.instance.currentUser;
    
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDarkMode ? darkPrimaryContainer : Colors.white,
      elevation: 0,
      toolbarHeight: 60, // Standard height
      leadingWidth: 70, // Space for back button and badge
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleButton(
            onTap: () => Get.back(),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: isDarkMode ? Colors.white : Colors.black, size: 22),
          ),
          const SizedBox(width: 4),
          Obx(() {
            int totalUnread = 0;
            for (final chat in ChatController.instance.chats) {
              totalUnread += chat.unread;
            }
            for (final group in GroupController.instance.groups) {
              totalUnread += group.unread;
            }
            if (totalUnread == 0) return const SizedBox.shrink();
            return BadgeCount(
              counter: totalUnread,
              bgColor: primaryColor,
            );
          }),
        ],
      ),
      titleSpacing: 0,
      title: GestureDetector(
        onTap: () => RoutesHelper.toProfileView(user!, false),
        child: Row(
          children: [
            Hero(
              tag: 'avatar_${user!.userId}',
              child: CachedCircleAvatar(
                backgroundColor: user!.photoUrl.isEmpty ? secondaryColor : primaryColor,
                imageUrl: user!.photoUrl,
                borderWidth: 0,
                padding: 0,
                radius: 20, // 40px size
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user!.fullname,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user!.isOnline ? 'en línea' : 'últ. vez recientemente',
                    style: TextStyle(
                      fontSize: 12,
                      color: user!.isOnline ? primaryColor : (isDarkMode ? Colors.white54 : Colors.black54),
                      fontWeight: user!.isOnline ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => ZegoCallService.instance.startVoiceCall(targetUser: user!),
          icon: Icon(Icons.call, color: isDarkMode ? Colors.white : Colors.black),
        ),
        IconButton(
          onPressed: () => ZegoCallService.instance.startVideoCall(targetUser: user!),
          icon: Icon(Icons.videocam, color: isDarkMode ? Colors.white : Colors.black),
        ),
        const SizedBox(width: 8),
      ],
    );
  }



  @override
  Size get preferredSize => const Size.fromHeight(60);
}