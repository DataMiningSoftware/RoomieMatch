import 'package:flutter/material.dart';

import '../app_theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.25), width: 1.2),
          left: BorderSide(color: Colors.white.withOpacity(0.15)),
          right: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            spreadRadius: 1,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
        child: Row(
          children: [
            _buildItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
            _buildItem(1, Icons.chat_bubble_rounded, Icons.chat_bubble_outline, 'Chats'),
            _buildItem(2, Icons.style_rounded, Icons.style_outlined, 'Swipe'),
            _buildItem(3, Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(int index, IconData activeIcon, IconData icon, String label) {
    final bool selected = index == currentIndex;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: selected ? 56 : 42,
                height: 32,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  selected ? activeIcon : icon,
                  size: 22,
                  color: selected ? AppColors.primary : Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.white : Colors.white.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
