import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppHomeAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData avatarIcon;
  final String? avatarText;
  final int unreadCount;
  final VoidCallback? onNotificationTap;

  const AppHomeAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.avatarIcon,
    this.avatarText,
    this.unreadCount = 0,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      elevation: 0,
      floating: true,
      pinned: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary,
              child: avatarText == null
                  ? Icon(avatarIcon, color: Colors.white, size: 22)
                  : Text(
                      avatarText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.body,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _NotificationButton(count: unreadCount, onTap: onNotificationTap),
          ],
        ),
      ),
    );
  }
}

class AppGreeting extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const AppGreeting({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.body,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.title,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: AppColors.body),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _NotificationButton({required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.title,
            size: 26,
          ),
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
