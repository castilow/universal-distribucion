import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/api/report_api.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/api/message_api.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/app_controller.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/controllers/report_controller.dart';
import 'package:chat_messenger/helpers/date_helper.dart';
import 'package:chat_messenger/helpers/routes_helper.dart';
import 'package:chat_messenger/models/app_info.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import 'components/action_button.dart';
import 'controllers/profile_view_controller.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({
    super.key,
    required this.user,
    required this.isGroup,
  });

  final User user;
  final bool isGroup;

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }
  
  // Calcula la opacidad del título en el AppBar basado en el scroll
  double get _titleOpacity {
    const double fadeStart = 200.0;
    const double fadeEnd = 300.0;
    
    if (_scrollOffset <= fadeStart) return 0.0;
    if (_scrollOffset >= fadeEnd) return 1.0; // Se mantiene visible una vez alcanzado
    
    return (_scrollOffset - fadeStart) / (fadeEnd - fadeStart);
  }
  
  // Calcula la opacidad de la imagen de fondo
  double get _backgroundOpacity {
    const double fadeStart = 100.0;
    const double fadeEnd = 300.0;
    
    if (_scrollOffset <= fadeStart) return 1.0;
    if (_scrollOffset >= fadeEnd) return 0.0; // Se mantiene invisible una vez desvanecida
    
    return 1.0 - ((_scrollOffset - fadeStart) / (fadeEnd - fadeStart));
  }
  
  // Calcula el color del AppBar - se mantiene blanco una vez alcanzado el límite
  Color get _appBarColor {
    const double fadeStart = 200.0;
    const double fadeEnd = 300.0;
    
    if (_scrollOffset <= fadeStart) return Colors.transparent;
    if (_scrollOffset >= fadeEnd) return Colors.white; // Se mantiene blanco para siempre
    
    double opacity = (_scrollOffset - fadeStart) / (fadeEnd - fadeStart);
    return Colors.white.withOpacity(opacity);
  }

  void _showFullScreenImage(BuildContext context, [String? imageUrl]) {
    final String displayImageUrl = imageUrl ?? widget.user.photoUrl;
    final String heroTag = imageUrl != null ? 'image-$imageUrl' : 'profile-${widget.user.userId}';
    
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (BuildContext context, _, __) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Hero(
              tag: heroTag,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: displayImageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white,
                          size: 64,
                        ),
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
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    final controller = Get.put(ProfileViewController(widget.user.userId));
    final ReportController reportController = Get.find();

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF17212B) : const Color(0xFFF0F2F5), // Telegram background
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to chat
          // We need to find the chat or create one. 
          // For now, let's assume we can go back or use a helper.
          // Actually, usually we are coming FROM a chat. 
          // If not, we might need to start one.
          // But typically this screen is opened from a chat or contact list.
          Get.back(); 
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.message_rounded, color: Colors.white),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom Sliver App Bar with profile photo
          SliverAppBar(
            expandedHeight: 380.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: isDarkMode ? const Color(0xFF17212B) : Colors.white,
            foregroundColor: isDarkMode ? Colors.white : Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white), // Always white on image
              onPressed: () => Get.back(),
            ),
            actions: [
               IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {}, // TODO: Show menu
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  GestureDetector(
                    onTap: () => widget.user.photoUrl.isNotEmpty 
                      ? _showFullScreenImage(context)
                      : null,
                    child: Hero(
                      tag: 'profile-${widget.user.userId}',
                      child: CachedNetworkImage(
                        imageUrl: widget.user.photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: secondaryColor),
                        errorWidget: (context, url, error) => Container(color: secondaryColor),
                      ),
                    ),
                  ),
                  // Gradient overlay for text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  // Name and Status at bottom
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.fullname,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1))],
                          ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<User?>(
                          future: UserApi.getUser(widget.user.userId),
                          builder: (context, snapshot) {
                            final User? updatedUser = snapshot.data;
                            final bool isOnline = updatedUser?.isOnline ?? widget.user.isOnline;
                            return Text(
                              isOnline ? 'en línea' : 'últ. vez recientemente',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                shadows: const [Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1))],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Info Section (Bio, Username)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  color: isDarkMode ? const Color(0xFF17212B) : Colors.white,
                  child: Column(
                    children: [
                      if (widget.user.bio.isNotEmpty)
                        ListTile(
                          leading: Icon(Icons.info_outline, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                          title: Text(widget.user.bio, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16)),
                          subtitle: Text('Bio', style: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                        ),
                      if (widget.user.bio.isNotEmpty)
                        Divider(height: 1, indent: 72, color: isDarkMode ? Colors.black : Colors.grey[200]),
                      ListTile(
                        leading: Icon(Icons.alternate_email, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                        title: Text('@${widget.user.username}', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16)),
                        subtitle: Text('Username', style: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Media Section
                Container(
                  color: isDarkMode ? const Color(0xFF17212B) : Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Media',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 120, // Horizontal scroll for media preview
                        child: StreamBuilder<List<Message>>(
                          stream: MessageApi.getMessages(widget.user.userId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            final imageMessages = snapshot.data!
                                .where((m) => m.type == MessageType.image && !m.isDeleted && m.fileUrl.isNotEmpty)
                                .take(10)
                                .toList();
                            
                            if (imageMessages.isEmpty) {
                              return Center(child: Text('No media shared', style: TextStyle(color: Colors.grey[500])));
                            }

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: imageMessages.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => _showFullScreenImage(context, imageMessages[index].fileUrl),
                                  child: Container(
                                    width: 120,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: imageMessages[index].fileUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Actions Section (Block, Report)
                Container(
                  color: isDarkMode ? const Color(0xFF17212B) : Colors.white,
                  child: Column(
                    children: [
                      Obx(() {
                        final bool isBlocked = controller.isBlocked.value;
                        return ListTile(
                          leading: Icon(Icons.block, color: Colors.red[400]),
                          title: Text(
                            isBlocked ? 'Unblock User' : 'Block User',
                            style: TextStyle(color: Colors.red[400], fontSize: 16),
                          ),
                          onTap: () => controller.toggleBlockUser(),
                        );
                      }),
                      Divider(height: 1, indent: 72, color: isDarkMode ? Colors.black : Colors.grey[200]),
                      ListTile(
                        leading: Icon(Icons.report_problem_outlined, color: Colors.red[400]),
                        title: Text(
                          'Report User',
                          style: TextStyle(color: Colors.red[400], fontSize: 16),
                        ),
                        onTap: () => reportController.reportDialog(
                          type: ReportType.user,
                          userId: widget.user.userId,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }




}
