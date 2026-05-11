import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppNavItem {
  final String label;
  final IconData icon;

  const AppNavItem({required this.label, required this.icon});
}

class AppBottomNavBar extends StatelessWidget {
  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final active = selectedIndex == index;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          horizontal: active ? 14 : 0,
                          vertical: active ? 5 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.blueSoft
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          item.icon,
                          size: active ? 21 : 23,
                          color: active ? AppColors.primary : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: active ? AppColors.primary : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
