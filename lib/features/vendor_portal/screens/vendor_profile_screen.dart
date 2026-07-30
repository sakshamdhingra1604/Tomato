// ── vendor_profile_screen.dart ────────────────────────────────────────────────
// Vendor Profile & Settings screen.
// Sections: Header card, quick stats, shop info, operational settings,
//           notification preferences, account links, danger zone (logout).
// Widgets are imported from profile_widgets.dart.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tomato/features/vendor_portal/widgets/profile_widgets.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({Key? key}) : super(key: key);

  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  // ── Vendor Mock Data ───────────────────────────────────────────────────────
  final String _canteenName   = 'Main Canteen';
  final String _ownerName     = 'Managed by Admin';
  final String _location      = 'Ground Floor, Academic Block A';
  final String _upiId         = 'maincanteen@okaxis';
  final String _phone         = '+91 98765 43210';
  final String _openTime      = '8:00 AM';
  final String _closeTime     = '6:00 PM';
  final double _rating        = 4.3;
  final int    _totalReviews  = 218;
  final String _cuisineTag    = '🍛 Multi-Cuisine';

  // ── Toggleable Settings ────────────────────────────────────────────────────
  bool _isOnline              = true;
  bool _notificationsEnabled  = true;
  bool _soundAlerts           = true;
  bool _autoAcceptOrders      = false;
  bool _showWaitTime          = true;
  bool _allowSpecialRequests  = true;

  // ── Quick Stats Mock ───────────────────────────────────────────────────────
  final int    _todayOrders   = 18;
  final String _monthRevenue  = '₹38.2K';
  final String _avgPrepTime   = '8 min';
  final int    _activeMenuItems = 24;

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFFF6B35),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'You will be signed out of your vendor portal. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text('Log Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResetPinDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Portal PIN',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'A PIN reset request will be sent to the platform admin (Moksh). They will update your portal password shortly.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _showSnack('PIN reset request sent to admin!');
            },
            child: const Text('Send Request',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(isDark),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Header card
            VendorProfileHeader(
              canteenName:  _canteenName,
              ownerName:    _ownerName,
              location:     _location,
              rating:       _rating,
              totalReviews: _totalReviews,
              isOnline:     _isOnline,
              cuisineTag:   _cuisineTag,
            ),

            // ── Quick stats
            ProfileSectionTitle(isDark: isDark, title: "TODAY'S SNAPSHOT"),
            _buildQuickStats(isDark),

            // ── Shop info
            ProfileSectionTitle(isDark: isDark, title: 'SHOP INFORMATION'),
            _buildShopInfoCard(isDark),

            // ── Operational settings
            ProfileSectionTitle(isDark: isDark, title: 'OPERATIONAL SETTINGS'),
            _buildOperationalSettings(isDark),

            // ── Notification preferences
            ProfileSectionTitle(isDark: isDark, title: 'NOTIFICATIONS & ALERTS'),
            _buildNotificationSettings(isDark),

            // ── Account
            ProfileSectionTitle(isDark: isDark, title: 'ACCOUNT'),
            _buildAccountSection(isDark),

            // ── Danger zone
            ProfileSectionTitle(isDark: isDark, title: 'DANGER ZONE'),
            _buildDangerZone(isDark),

            // ── Version footer
            _buildVersionFooter(isDark),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Manage your canteen settings',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Iconsax.edit_2, color: Color(0xFFFF6B35), size: 20),
            onPressed: () => _showSnack('Profile edit — contact admin to update details'),
            tooltip: 'Edit Profile',
          ),
        ),
      ],
    );
  }

  // ── Quick Stats Row ────────────────────────────────────────────────────────
  Widget _buildQuickStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ProfileStatCard(
              isDark: isDark,
              icon: Iconsax.bag_2,
              color: const Color(0xFFFF6B35),
              value: '$_todayOrders',
              label: "Today's\nOrders",
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ProfileStatCard(
              isDark: isDark,
              icon: Iconsax.wallet_1,
              color: Colors.green,
              value: _monthRevenue,
              label: 'This Month\nRevenue',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ProfileStatCard(
              isDark: isDark,
              icon: Iconsax.timer_1,
              color: Colors.blue,
              value: _avgPrepTime,
              label: 'Avg Prep\nTime',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ProfileStatCard(
              isDark: isDark,
              icon: Iconsax.menu_board,
              color: Colors.purple,
              value: '$_activeMenuItems',
              label: 'Active\nItems',
            ),
          ),
        ],
      ),
    );
  }

  // ── Shop Info Card ─────────────────────────────────────────────────────────
  Widget _buildShopInfoCard(bool isDark) {
    return _SectionCard(
      isDark: isDark,
      children: [
        ProfileInfoRow(isDark: isDark, icon: Iconsax.clock,    label: 'Opens',    value: _openTime),
        _divider(isDark),
        ProfileInfoRow(isDark: isDark, icon: Iconsax.clock_1,  label: 'Closes',   value: _closeTime),
        _divider(isDark),
        ProfileInfoRow(isDark: isDark, icon: Iconsax.call,     label: 'Phone',    value: _phone),
        _divider(isDark),
        ProfileInfoRow(isDark: isDark, icon: Iconsax.wallet,   label: 'UPI ID',   value: _upiId),
        _divider(isDark),
        ProfileInfoRow(isDark: isDark, icon: Iconsax.location, label: 'Location', value: _location),
      ],
    );
  }

  // ── Operational Settings ───────────────────────────────────────────────────
  Widget _buildOperationalSettings(bool isDark) {
    return _SectionCard(
      isDark: isDark,
      children: [
        ProfileSettingTile(
          isDark: isDark,
          icon: Iconsax.shop,
          iconColor: Colors.green,
          title: 'Shop Status',
          subtitle: _isOnline ? 'Currently accepting orders' : 'Shop is offline',
          toggleValue: _isOnline,
          onToggle: (val) {
            HapticFeedback.lightImpact();
            setState(() => _isOnline = val);
            _showSnack(val ? 'Shop is now Online ✅' : 'Shop is now Offline ⛔');
          },
        ),
        _divider(isDark),
        ProfileSettingTile(
          isDark: isDark,
          icon: Iconsax.timer_start,
          iconColor: Colors.blue,
          title: 'Auto-Accept Orders',
          subtitle: 'Skip manual approval for new orders',
          toggleValue: _autoAcceptOrders,
          onToggle: (val) => setState(() => _autoAcceptOrders = val),
        ),
        _divider(isDark),
        ProfileSettingTile(
          isDark: isDark,
          icon: Iconsax.clock,
          iconColor: Colors.orange,
          title: 'Show Wait Time to Students',
          subtitle: 'Display live prep time on student app',
          toggleValue: _showWaitTime,
          onToggle: (val) => setState(() => _showWaitTime = val),
        ),
        _divider(isDark),
        ProfileSettingTile(
          isDark: isDark,
          icon: Iconsax.message_edit,
          iconColor: Colors.purple,
          title: 'Allow Special Requests',
          subtitle: 'Students can add notes to their orders',
          toggleValue: _allowSpecialRequests,
          onToggle: (val) => setState(() => _allowSpecialRequests = val),
        ),
        _divider(isDark),
        ProfileSettingTile(
          isDark: isDark,
          icon: Iconsax.setting_3,
          iconColor: Colors.teal,
          title: 'Manage Operating Hours',
          subtitle: '$_openTime – $_closeTime (tap to edit)',
          onTap: () => _showSnack('Operating hours — managed by admin'),
        ),
      ],
    );
  }

  // ── Notification Settings ──────────────────────────────────────────────────
  Widget _buildNotificationSettings(bool isDark) {
    return _SectionCard(
      isDark: isDark,
      children: [
        ProfileSettingTile(
          isDark: isDark,
          icon: Iconsax.notification,
          iconColor: const Color(0xFFFF6B35),
          title: 'Order Notifications',
          subtitle: 'Get notified for new incoming orders',
          toggleValue: _notificationsEnabled,
          onToggle: (val) => setState(() => _notificationsEnabled = val),
        ),
        _divider(isDark),
        ProfileSettingTile(
          isDark: isDark,
          icon: Iconsax.volume_high,
          iconColor: Colors.blue,
          title: 'Sound Alerts',
          subtitle: 'Play audio alert for new orders',
          toggleValue: _soundAlerts,
          onToggle: (val) => setState(() => _soundAlerts = val),
        ),
      ],
    );
  }

  // ── Account Section ────────────────────────────────────────────────────────
  Widget _buildAccountSection(bool isDark) {
    return _SectionCard(
      isDark: isDark,
      children: [
        ProfileSettingTile(
          isDark: isDark,
          icon: Iconsax.lock,
          iconColor: Colors.indigo,
          title: 'Reset Portal PIN',
          subtitle: 'Request a PIN change from admin',
          onTap: _showResetPinDialog,
        ),
        _divider(isDark),
        ProfileSettingTile(
          isDark: isDark,
          icon: Iconsax.headphone,
          iconColor: Colors.teal,
          title: 'Contact Support',
          subtitle: 'Reach out to the Tomato team',
          onTap: () => _showSnack('Support: support@tomato.app'),
        ),
        _divider(isDark),
        ProfileSettingTile(
          isDark: isDark,
          icon: Iconsax.document_text,
          iconColor: Colors.grey,
          title: 'Terms & Privacy Policy',
          onTap: () => _showSnack('Opening Terms of Service...'),
        ),
        _divider(isDark),
        ProfileSettingTile(
          isDark: isDark,
          icon: Iconsax.star,
          iconColor: Colors.amber,
          title: 'Rate This App',
          subtitle: 'Help us improve Tomato',
          onTap: () => _showSnack('Thank you for your support! 🙏'),
        ),
      ],
    );
  }

  // ── Danger Zone ────────────────────────────────────────────────────────────
  Widget _buildDangerZone(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _SectionCard(
            isDark: isDark,
            borderColor: Colors.red.withValues(alpha: 0.25),
            children: [
              ProfileSettingTile(
                isDark: isDark,
                icon: Iconsax.logout,
                iconColor: Colors.red,
                title: 'Log Out',
                subtitle: 'Sign out of your vendor portal',
                isDestructive: true,
                onTap: _showLogoutDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Version Footer ─────────────────────────────────────────────────────────
  Widget _buildVersionFooter(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Center(
        child: Column(
          children: [
            Text(
              '🍅 Tomato Vendor Portal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Version 1.0.0 • Built with ❤️ by Team Tomato',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Utils ──────────────────────────────────────────────────────────────────
  Widget _divider(bool isDark) => Divider(
        height: 1,
        indent: 66,
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      );
}

// ── Section Card Container ────────────────────────────────────────────────────
// A rounded card that wraps a group of setting tiles cleanly.

class _SectionCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  final Color? borderColor;

  const _SectionCard({
    required this.isDark,
    required this.children,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor ??
              (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
