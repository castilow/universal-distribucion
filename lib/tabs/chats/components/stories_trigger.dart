import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/config/theme_config.dart';

class StoriesTrigger extends StatelessWidget {
  final VoidCallback onTap;

  const StoriesTrigger({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center, // Center the trigger
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF9CE34),
                    Color(0xFFEE2A7B),
                    Color(0xFF6228D7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEE2A7B).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(2), // Border width
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Container(
                  margin: const EdgeInsets.all(2), // Gap
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color:  Color(0xFFEE2A7B), // Inner fill
                  ),
                  child: const Icon(
                    IconlyBold.play, // Or another icon representing stories
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Stories',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
