import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/config/theme_config.dart'; // For primaryColor usage if needed
import '../../components/cached_circle_avatar.dart';
import '../../controllers/auth_controller.dart'; 
import '../../routes/app_routes.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Track which card is selected. Default is 0 (Total Products)
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Hardcoded data for visual matching
    final user = AuthController.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black, // Pure black background
      body: SafeArea(
        bottom: false, // Let navigation bar handle bottom padding
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              _buildHeader(user),
              const SizedBox(height: 24),

              // 2. Search Bar
              _buildSearchBar(),
              const SizedBox(height: 24),

              // 3. Metrics Grid
              _buildMetricsGrid(),
              const SizedBox(height: 24),

              // 4. Stock Overview
              const Text(
                'Stock Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              _buildStockOverview(),
              const SizedBox(height: 24),

              // 5. Recent Deliveries Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Deliveries',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: Color(0xFF4C8CFF), // Blueish text
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              // Filter/Placeholder for deliveries
              _buildRecentDeliveriesList(),
              
              // Extra space for bottom nav bar
              const SizedBox(height: 120),
            ]
            .animate(interval: 100.ms) // Slower stagger for visibility
            .fade(duration: 600.ms)
            .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    return Row(
      children: [
        // Profile Pic
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: CachedCircleAvatar(
              imageUrl: user.photoUrl ?? '',
              radius: 25,
            ),
          ),
        )
        .animate()
        .scale(duration: 400.ms, curve: Curves.easeOutBack), // Pop-in for avatar
        
        const SizedBox(width: 12),
        // text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ready to deliver!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  user.fullname.isNotEmpty ? user.fullname : 'Oliver Bennet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.back_hand, color: Color(0xFFFFD700), size: 16)
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .rotate(begin: -0.1, end: 0.1, duration: 600.ms), // Waving hand animation
              ],
            ),
          ],
        ),
        const Spacer(),
        // Actions
        _buildCircleAction(IconlyLight.message), // Help/Question
        const SizedBox(width: 12),
        _buildCircleAction(IconlyLight.setting, onTap: () {
          Get.toNamed(AppRoutes.settings);
        }), // Settings (antes era notification)
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Icon(IconlyLight.search, color: Colors.white.withOpacity(0.5)),
                const SizedBox(width: 12),
                Text(
                  'Search...',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: const Icon(IconlyLight.filter, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InteractiveMetricCard(
                title: 'Total Products', 
                value: '345',
                imagePath: 'assets/images/dashboard/box.png', 
                isSelected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InteractiveMetricCard(
                title: 'Total Revenue', 
                value: '€10,326.00',
                imagePath: 'assets/images/dashboard/safe.png',
                isSelected: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InteractiveMetricCard(
                title: 'Store Locator', 
                value: '112',
                imagePath: 'assets/images/dashboard/store.png',
                isSelected: _selectedIndex == 2,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InteractiveMetricCard(
                title: 'Sales Analytics', 
                value: '234',
                imagePath: 'assets/images/dashboard/graph.png', 
                isSelected: _selectedIndex == 3,
                onTap: () => setState(() => _selectedIndex = 3),
              ),
            ),
          ],
        ),
      ],
    );
  }
 
  Widget _buildStockOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStockItem(label: 'In Stock', value: '345', color: Colors.green),
          Container(width: 1, height: 24, color: Colors.white.withOpacity(0.1)),
          _buildStockItem(label: 'Low Stock', value: '15', color: Colors.orange),
          Container(width: 1, height: 24, color: Colors.white.withOpacity(0.1)),
          _buildStockItem(label: 'Out of Stock', value: '6', color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildStockItem({required String label, required String value, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, size: 14, color: color)
            .animate().scale(duration: 400.ms, delay: 200.ms, curve: Curves.elasticOut), // Icon pop
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              fontFamily: 'Courier',
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecentDeliveriesList() {
    return Column(
      children: [
        _buildDeliveryItem(
          title: 'Grocery Order #2458',
          subtitle: 'Delivered • 15 mins ago',
          imagePath: 'assets/images/dashboard/food_grocery_bag.png',
        ),
        const SizedBox(height: 12),
        _buildDeliveryItem(
          title: 'Fresh Fruit Restock',
          subtitle: 'Delivered • 2 hrs ago',
          imagePath: 'assets/images/dashboard/food_fruit_basket.png',
        ),
      ],
    );
  }

  Widget _buildDeliveryItem({
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // Removed background color to let 3D icon float
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
               Text(
                subtitle,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14)
          .animate().moveX(begin: -5, end: 0, duration: 600.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

class InteractiveMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const InteractiveMetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Colors based on selection state (Gold vs Dark)
    final bg = isSelected ? const Color(0xFFFFD700) : const Color(0xFF1C1C1E);
    final txt = isSelected ? Colors.black : Colors.white;
    final subTxt = isSelected ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.6);
    final arrowColor = isSelected ? Colors.black : Colors.white;
    final arrowBg = isSelected ? Colors.white : const Color(0xFF000000);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 175,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon Box (Image) - Background REMOVED as requested
                Container(
                  width: 58,
                  height: 58,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(imagePath, fit: BoxFit.cover),
                  ),
                ),
                // Arrow Circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: arrowBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_outward, 
                    color: arrowColor, 
                    size: 20,
                  ),
                ),
              ],
            ),
            const Spacer(),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: subTxt,
                fontSize: 13,
                fontFamily: 'Inter'
              ),
              child: Text(title),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: txt,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                 fontFamily: 'Inter'
              ),
              child: Text(value),
            ),
          ],
        ),
      ),
    );
  }
}
