import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'delivery_jobs_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  final int initialTab;
  const MainLayoutScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  _MainLayoutScreenState createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  String _userRole = 'student';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _loadUserRole();
  }

  @override
  void didUpdateWidget(covariant MainLayoutScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _currentIndex = widget.initialTab;
      });
    }
  }

  void _loadUserRole() async {
    final role = await AuthService().getUserRole();
    setState(() {
      _userRole = role ?? 'student';
      _isLoading = false;
    });
  }

  List<Widget> get _screens {
    if (_userRole == 'deliverer') {
      return const [
        HomeScreen(),
        CartScreen(),
        DeliveryJobsScreen(),
        OrdersScreen(),
        ProfileScreen(),
      ];
    } else {
      return const [
        HomeScreen(),
        CartScreen(),
        OrdersScreen(),
        ProfileScreen(),
      ];
    }
  }

  List<BottomNavigationBarItem> get _navItems {
    if (_userRole == 'deliverer') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_rounded),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_walk_rounded),
          label: 'Delivery',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_rounded),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_rounded),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_rounded),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screens = _screens;
    // Bounds check current index in case role change modified screens list size
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedItemColor: Theme.of(context).primaryColor,
                unselectedItemColor: Theme.of(context).disabledColor,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                items: _navItems,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
