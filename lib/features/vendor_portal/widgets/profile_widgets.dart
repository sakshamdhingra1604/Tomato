// ── profile_widgets.dart ──────────────────────────────────────────────────────
// Reusable widgets for the Vendor Profile screen:
//   • VendorProfileHeader  – avatar, name, canteen, rating, status
//   • ProfileStatCard      – quick metric tile (orders / earnings / rating)
//   • ProfileSectionTitle  – section label with accent bar
//   • ProfileSettingTile   – toggle / arrow list tile for settings
//   • ProfileInfoRow       – icon + label + value info row
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ── Vendor Profile Header ─────────────────────────────────────────────────────

class VendorProfileHeader extends StatelessWidget {
  final String canteenName;
  final String ownerName;
  final String location;
  final double rating;
  final int totalReviews;
  final bool isOnline;
  final String cuisineTag;

  const VendorProfileHeader({
    Key? key,
    required this.canteenName,
    required this.ownerName,
    required this.location,
    required this.rating,
    required this.totalReviews,
    required this.isOnline,
    required this.cuisineTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF252525)]
              : [Colors.white, const Color(0xFFFAFAFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(isDark),
              const SizedBox(width: 16),
              Expanded(child: _buildInfo(isDark)),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            height: 1,
          ),
          const SizedBox(height: 14),
          _buildBottomRow(isDark),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Stack(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              canteenName.isNotEmpty ? canteenName[0].toUpperCase() : 'V',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        // Online / Offline indicator dot
        Positioned(
          bottom: 2,
          right: 2,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                width: 2.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          canteenName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          ownerName,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
            const SizedBox(width: 3),
            Text(
              '$rating',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.amber,
              ),
            ),
            Text(
              '  ($totalReviews reviews)',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: isOnline
                ? Colors.green.withValues(alpha: 0.12)
                : Colors.grey.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isOnline ? '● Online — Accepting Orders' : '● Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isOnline ? Colors.green : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow(bool isDark) {
    return Row(
      children: [
        Icon(Iconsax.location, size: 14,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            location,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            cuisineTag,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF6B35),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Profile Stat Card ─────────────────────────────────────────────────────────

class ProfileStatCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const ProfileStatCard({
    Key? key,
    required this.isDark,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────

class ProfileSectionTitle extends StatelessWidget {
  final bool isDark;
  final String title;

  const ProfileSectionTitle({
    Key? key,
    required this.isDark,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Setting Tile ──────────────────────────────────────────────────────

class ProfileSettingTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;

  const ProfileSettingTile({
    Key? key,
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.toggleValue,
    this.onToggle,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = isDestructive
        ? Colors.red
        : (isDark ? Colors.white : const Color(0xFF1A1A1A));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (toggleValue != null && onToggle != null)
              Switch(
                value: toggleValue!,
                onChanged: onToggle,
                activeThumbColor: const Color(0xFFFF6B35),
                activeTrackColor: const Color(0xFFFF6B35).withValues(alpha: 0.3),
              )
            else if (trailing != null)
              trailing!
            else if (!isDestructive)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Info Row ──────────────────────────────────────────────────────────

class ProfileInfoRow extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoRow({
    Key? key,
    required this.isDark,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 16,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
