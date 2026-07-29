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
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? 
                 (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Iconsax.receipt_2),
                activeIcon: Icon(Iconsax.receipt_25),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.menu),
                activeIcon: Icon(Iconsax.menu_15),
                label: 'Menu',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.wallet),
                activeIcon: Icon(Iconsax.wallet_25),
                label: 'Earnings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.profile_circle),
                activeIcon: Icon(Iconsax.profile_circle5),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
