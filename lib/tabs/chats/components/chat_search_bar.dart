import 'package:flutter/material.dart';
import 'package:chat_messenger/theme/app_theme.dart';

class ChatSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onTap;

  const ChatSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12), // Slightly less rounded than global
        border: isDarkMode
            ? Border.all(
                color: const Color(0xFF404040).withOpacity(0.6),
                width: 1,
              )
            : null,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            color: isDarkMode
                ? const Color(0xFF9CA3AF)
                : const Color(0xFF64748B),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode
                ? const Color(0xFF9CA3AF)
                : const Color(0xFF64748B),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8, // Centered vertically
          ),
          isDense: true,
        ),
      ),
    );
  }
}
