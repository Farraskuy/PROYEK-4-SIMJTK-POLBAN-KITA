import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class ProfileHeroCardData {
  const ProfileHeroCardData({
    required this.initials,
    required this.name,
    required this.roleLabel,
    required this.programStudy,
    required this.email,
  });

  final String initials;
  final String name;
  final String roleLabel;
  final String programStudy;
  final String email;
}

class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({super.key, required this.data});

  final ProfileHeroCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E507E), Color(0xFF0D3157)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            child: Text(
              data.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                _HeroMetaLine(icon: Icons.badge_outlined, text: data.roleLabel),
                const SizedBox(height: 6),
                _HeroMetaLine(icon: Icons.school_outlined, text: data.programStudy),
                const SizedBox(height: 6),
                _HeroMetaLine(icon: Icons.mail_outline_rounded, text: data.email),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetaLine extends StatelessWidget {
  const _HeroMetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
