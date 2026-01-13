import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'dart:ui'; // For ImageFilter
import 'package:chat_messenger/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  // Center on Madrid, Spain
  final LatLng _center = LatLng(40.4168, -3.7038); 
  LatLng? _currentLocation;
  bool _showDetails = false;

  // Stores in Madrid
  final List<LatLng> _stores = [
    LatLng(40.4168, -3.7038), // Puerta del Sol
    LatLng(40.4200, -3.7000), // Barrio de Salamanca (Serrano)
    LatLng(40.4150, -3.7100), // La Latina
    LatLng(40.4300, -3.6900), // Chamberí
    LatLng(40.4400, -3.7200), // Moncloa
    LatLng(40.4100, -3.6950), // Atocha
    LatLng(40.4500, -3.6900), // Santiago Bernabeú area
    LatLng(40.4250, -3.6800), // Goya
    LatLng(40.4070, -3.6910), // Lavapiés
    LatLng(40.4240, -3.7120), // Plaza de España
  ];

  @override
  void initState() {
    super.initState();
    // Start with a slight delay to ensure map is ready, then animate
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _startMapAnimation();
    });
    _getCurrentLocation();
  }

  void _startMapAnimation() async {
    // Wait for map to initialize visually
    await Future.delayed(const Duration(milliseconds: 1000));
    // Animate from World (zoom 3) to Madrid (zoom 14)
    // Note: flutter_map controller doesn't have built-in animation helper easily accessible without plugins usually, 
    // but we can try a primitive approach or just set it if using a newer version.
    // For now, let's just move it if we started further out.
    // Actually, to do a smooth "Zoom In" effect, we can use a Timer or an AnimationController if we want to be fancy.
    // Simplifying: Let's start at Zoom 4 in build, and then move to Zoom 14 here.
     _animatedMapMove(_center, 14.0);
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Simple custom animation implementation
    final latTween = Tween<double>(begin: _mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: _mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.zoom, end: destZoom);

    final controller = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
    
    Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  Future<void> _getCurrentLocation() async {
    // ... existing location logic ...
    // Note: We won't auto-move here to avoid conflicting with the intro animation
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.of(context).isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Dark Base or Light Base
      floatingActionButton: FloatingActionButton(
        onPressed: () {
             if (_currentLocation != null) _animatedMapMove(_currentLocation!, 15);
        },
        backgroundColor: const Color(0xFFD4AF37), // Gold
        child: const Icon(Icons.my_location, color: Colors.black),
      ),
      body: Stack(
        children: [
          // 1. MAP LAYER
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Start at World View (Zoom 4) near Madrid or 0,0
              center: LatLng(40.4168, -3.7038), 
              zoom: 3.0, 
              minZoom: 2.0,
              maxZoom: 18.0,
              // Enable rotation for "3D feel"
              interactiveFlags: InteractiveFlag.all, 
              onTap: (_, __) {
                if (_showDetails) {
                  setState(() => _showDetails = false);
                }
              },
            ),
            children: [
              TileLayer(
                // CartoDB Dark Matter - High res for dark mode, Positron for light mode
                urlTemplate: isDarkMode 
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.universal.distribucion',
                backgroundColor: isDarkMode ? Colors.black : Colors.white, 
              ),
              MarkerLayer(
                markers: [
                  // Current Location
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 60,
                      height: 60,
                      builder: (ctx) => _buildUserMarker(),
                    ),
                  
                  // Store Markers
                  ..._stores.map((pos) => Marker(
                    point: pos,
                    width: 60, // Slightly larger for the new icon
                    height: 60,
                    anchorPos: AnchorPos.align(AnchorAlign.top), // Pin point at bottom
                    builder: (ctx) => GestureDetector(
                      onTap: () {
                         setState(() => _showDetails = true);
                         _animatedMapMove(pos, 16.0); // Zoom in on tap
                      },
                      child: _buildStoreMarker(),
                    ),
                  )).toList(),
                ],
              ),
            ],
          ),

          // 2. TOP OVERLAY (Glassmorphism)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Search Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? const Color(0xFF141414).withOpacity(0.8) // Dark Glass
                              : const Color(0xFFF8F9FA).withOpacity(0.85), // Light Glass
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3), 
                              blurRadius: 10, 
                              offset: const Offset(0, 4)
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(IconlyLight.search, color: Color(0xFFD4AF37)), // Gold Icon
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(
                                'Find a store nearby...',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black54,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                              ),
                              child: Icon(IconlyBold.voice, color: isDarkMode ? Colors.white : Colors.black54, size: 18),
                            ),
                            const SizedBox(width: 8),
                            const CircleAvatar(
                              radius: 16,
                              backgroundImage: AssetImage('assets/images/app_logo.png'), 
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildGlassChip(label: 'All Stores', icon: IconlyBold.category, isSelected: true, isDarkMode: isDarkMode),
                        const SizedBox(width: 10),
                        _buildGlassChip(label: 'Open Now', icon: IconlyBold.timeCircle, isDarkMode: isDarkMode),
                        const SizedBox(width: 10),
                        _buildGlassChip(label: 'Favorites', icon: IconlyBold.heart, isDarkMode: isDarkMode),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. BOTTOM SHEET (Details)
          if (_showDetails)
            Positioned(
              left: 16,
              right: 16,
              bottom: 110, // Above floating nav bar
              child: _buildLocationCard(isDarkMode),
            ),
        ],
      ),
    );
  }

  Widget _buildUserMarker() {
     // ... same ...
     return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.2), // Gold glow
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37), // Solid Gold
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreMarker() {
    // Custom Gold Icon matching user request (Pin shape with dot)
    return Image.asset(
      'assets/images/gold_store_pin_marker.png',
      width: 70, // Slightly larger for better visibility of 3D detail
      height: 70,
      fit: BoxFit.contain,
    );
  }

  Widget _buildGlassChip({required String label, required IconData icon, bool isSelected = false, required bool isDarkMode}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFFD4AF37).withOpacity(0.9) // Gold
                : (isDarkMode ? const Color(0xFF141414).withOpacity(0.6) : Colors.white.withOpacity(0.8)), // Dark Glass or White Glass
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFFD4AF37) : (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon, 
                size: 16, 
                color: isSelected ? Colors.black : (isDarkMode ? Colors.white70 : Colors.black87)
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : (isDarkMode ? Colors.white : Colors.black),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard(bool isDarkMode) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF141414).withOpacity(0.9) : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Store Image/Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white.withOpacity(0.05),
                  image: const DecorationImage(
                    image:AssetImage('assets/images/app_logo.png'), // Placeholder
                    fit: BoxFit.cover, 
                  )
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Universal Store Madrid',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Open • Closes 22:00',
                      style: TextStyle(
                        color: Colors.greenAccent[400],
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Calle Gran Vía, 24',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFD4AF37), // Gold button
                  shape: BoxShape.circle,
                ),
                child: const Icon(IconlyBold.arrowRight2, color: Colors.black),
              )
            ],
          ),
        ),
      ),
    );
  }
}


