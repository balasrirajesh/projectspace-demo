import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const FloatingNavbar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 35, top: 20),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD54F).withOpacity(0.5), // Professional Amber Yellow tint
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: const Color(0xFFFFE082).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, "Home"),
                _buildNavItem(1, Icons.forum_rounded, "Chat"),       // index 1
                _buildNavItem(2, Icons.notifications_active_rounded, "Alerts"), // index 2
                _buildNavItem(3, Icons.account_circle_rounded, "Profile"), // index 3
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.black87 : Colors.black54,
            size: 26,
          ),
        ),
      ),
    );
  }
}
