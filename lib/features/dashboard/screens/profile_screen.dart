import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Student User';
  String _email = 'student@piet.co.in';
  String _college = 'P.I.E.T. Campus';
  String _rollNo = '21PIETCSE099';
  String _branch = 'Computer Science (CSE)';
  String _year = '3rd Year';
  String _block = 'Block A (Hostel)';
  String _room = 'Room 304';
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? _name;
      _email = prefs.getString('user_email') ?? _email;
      _college = prefs.getString('college_name') ?? _college;
      _rollNo = prefs.getString('roll_no') ?? _rollNo;
      _branch = prefs.getString('branch') ?? _branch;
      _year = prefs.getString('year') != null ? '${prefs.getString('year')} Year' : _year;
      _block = prefs.getString('block') ?? _block;
      _room = prefs.getString('class_room') ?? _room;
      _isLoading = false;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of Tomato?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().logout();
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  String get _initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'ST';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Student Profile',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),

              // Profile Card Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _email,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded, color: Colors.green, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  _college,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Academic Details Section Header
              Text(
                'Academic & Campus Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Academic Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(context, Icons.badge_outlined, 'Roll Number', _rollNo),
                    const Divider(height: 20),
                    _buildInfoRow(context, Icons.school_outlined, 'Branch', _branch),
                    const Divider(height: 20),
                    _buildInfoRow(context, Icons.calendar_today_outlined, 'Academic Year', _year),
                    const Divider(height: 20),
                    _buildInfoRow(context, Icons.location_city_outlined, 'Block / Hostel', _block),
                    const Divider(height: 20),
                    _buildInfoRow(context, Icons.meeting_room_outlined, 'Class / Room', _room),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Settings & Options Section Header
              Text(
                'Settings & Preferences',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Settings Items List
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingTile(
                      context,
                      icon: Icons.notifications_active_outlined,
                      title: 'Campus Delivery Alerts',
                      subtitle: 'Get notified when deliverers reach your block',
                      trailing: Switch(
                        value: _notificationsEnabled,
                        activeColor: primaryColor,
                        onChanged: (val) {
                          setState(() {
                            _notificationsEnabled = val;
                          });
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSettingTile(
                      context,
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Campus Support',
                      subtitle: 'Canteen timings, refund queries & FAQs',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Support helpline: support@piet.co.in')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingTile(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: 'About Tomato',
                      subtitle: 'App Version 1.0.0 (PIET Hyperlocal)',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Tomato',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2026 Tomato Hyperlocal Campus Logistics.',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showLogoutDialog,
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 20),
    );
  }
}
