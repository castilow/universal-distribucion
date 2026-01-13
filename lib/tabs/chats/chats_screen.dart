import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/floating_button.dart';
import 'package:chat_messenger/components/scale_button.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/components/loading_indicator.dart';
import 'package:chat_messenger/components/no_data.dart';
import 'package:chat_messenger/models/chat.dart';
import 'package:chat_messenger/tabs/chats/controllers/chat_controller.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:get/get.dart';

import 'components/chat_card.dart';
import 'components/stories_section.dart';
import 'components/chat_search_bar.dart';
import 'components/portal_stories_header.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  // Vars
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  Worker? _searchWorker;

  @override
  void initState() {
    super.initState();
    // Initialize scroll controller with offset to hide stories initially
    // Stories height (110) + Logo (30) + Padding (20) = 160
    _scrollController = ScrollController(initialScrollOffset: 160.0);
    
    // Listen to search state to reset scroll
    final ChatController controller = Get.find();
    _searchWorker = ever(controller.isSearching, (isSearching) {
      if (isSearching) {
        // If searching, ensure we are at top to see search bar
        if (_scrollController.hasClients && _scrollController.offset > 160) {
           _scrollController.jumpTo(160);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get controllers
    final ChatController controller = Get.find();

    // Other vars
    const padding = EdgeInsets.symmetric(vertical: defaultPadding);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : null,
      body: Obx(
        () {
          // Check loading
          if (controller.isLoading.value) {
            return const LoadingIndicator();
          } else if (controller.chats.isEmpty && !controller.isSearching.value) {
             // Only show NoData if not searching and really no chats
            return NoData(
              iconData: IconlyBold.chat,
              text: 'no_chats'.tr,
              subtitle: 'Start a conversation by tapping the + button below',
            );
          }
          
          // Get the chats list
          final List<Chat> chats = controller.isSearching.value
              ? controller.searchChat()
              : controller.visibleChats;

          return AnimationLimiter(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Stories Section (Pull to reveal)
                // Only visible when not searching (or searching but scrolled up)
                SliverAppBar(
                  backgroundColor: isDarkMode ? Colors.black : Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  expandedHeight: 160.0,
                  toolbarHeight: 0,
                  collapsedHeight: 0,
                  floating: false,
                  snap: false,
                  stretch: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: PortalStoriesHeader(
                      scrollController: _scrollController,
                      chats: controller.visibleChats,
                      maxHeight: 160.0,
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: ChatSearchBar(
                    controller: _searchController,
                    onChanged: (val) {
                       controller.searchController.text = val;
                       // Trigger search in controller
                       controller.searchChat();
                    },
                  ),
                ),

                // Chats List
                if (chats.isEmpty && controller.isSearching.value)
                   SliverToBoxAdapter(
                     child: Padding(
                       padding: const EdgeInsets.only(top: 50),
                       child: Center(child: Text('No results found')),
                     ),
                   )
                else
                  SliverPadding(
                    padding: padding,
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final Chat chat = chats[index];

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: ChatCard(
                                  chat,
                                  onDeleteChat: () {
                                    // Check if this is a group chat
                                    if (chat.groupId != null) {
                                      controller.deleteGroupChat(chat.groupId!);
                                    } else {
                                      controller.deleteChat(chat.receiver!.userId);
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: chats.length,
                      ),
                    ),
                  ),
                  
                  // Ensure there is enough space to scroll the stories out of view
                  // We use SliverFillRemaining to fill the rest of the screen
                  // This ensures that even with few chats, we can scroll up to hide the stories
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      height: MediaQuery.of(context).size.height, // Force extra height
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 80),
                      child: const SizedBox(), // Just spacer
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: ScaleButton(
        child: FloatingButton(
          icon: IconlyBold.chat,
          onPress: () => Get.toNamed(AppRoutes.contacts),
        ),
      ),
    );
  }
}
