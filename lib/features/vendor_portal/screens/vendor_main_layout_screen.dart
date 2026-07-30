import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'vendor_orders_screen.dart';
import 'vendor_menu_screen.dart';
import 'vendor_earnings_screen.dart';
import 'vendor_profile_screen.dart';

class VendorMainLayoutScreen extends StatefulWidget {
  const VendorMainLayoutScreen({Key? key}) : super(key: key);

  @override
  _VendorMainLayoutScreenState createState() => _VendorMainLayoutScreenState();
}

class _VendorMainLayoutScreenState extends State<VendorMainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const VendorOrdersScreen(),
    const VendorMenuScreen(),
    const VendorEarningsScreen(),
    const VendorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey.shade500,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Iconsax.receipt_2, size: 22),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Iconsax.receipt_25, size: 22),
              ),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Iconsax.menu, size: 22),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Iconsax.menu_15, size: 22),
              ),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Iconsax.wallet, size: 22),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Iconsax.wallet_25, size: 22),
              ),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Iconsax.profile_circle, size: 22),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Iconsax.profile_circle5, size: 22),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
