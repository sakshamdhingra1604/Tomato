import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math';
import 'dart:async';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({Key? key}) : super(key: key);

  @override
  _VendorOrdersScreenState createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> with SingleTickerProviderStateMixin {
  bool _isOnline = true;
  late TabController _tabController;
  
  // Dummy data for orders
  final List<Map<String, dynamic>> _newOrders = [];
  final List<Map<String, dynamic>> _pendingOrders = [];
  final List<Map<String, dynamic>> _preparingOrders = [
    {
      'id': '#ORD-8821',
      'pin': '4192',
      'student': 'Saksham Dhingra',
      'time': '10:42 AM',
      'items': [
        {'name': 'Paneer Tikka Sandwich', 'qty': 2},
        {'name': 'Cold Coffee', 'qty': 1},
      ],
      'total': 210,
    },
    {
      'id': '#ORD-8822',
      'pin': '7381',
      'student': 'Rahul Kumar',
      'time': '10:50 AM',
      'items': [
        {'name': 'Aloo Patties', 'qty': 3},
      ],
      'total': 90,
    }
  ];
  
  final List<Map<String, dynamic>> _readyOrders = [];
  final List<Map<String, dynamic>> _completedOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Simulate incoming order after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isOnline) {
        _simulateNewOrder();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _generatePin() {
    return (1000 + Random().nextInt(9000)).toString();
  }

  void _simulateNewOrder() {
    final pin = _generatePin();
    final newOrder = {
      'id': '#ORD-${8823 + _newOrders.length + _completedOrders.length}',
      'pin': pin,
      'student': 'Neha Sharma',
      'time': 'Just now',
      'items': [
        {'name': 'Cheese Burger', 'qty': 1},
        {'name': 'French Fries', 'qty': 1},
      ],
      'total': 150,
    };

    // Show popup
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Auto dismiss after 2.5 seconds and move to pending
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            _moveToPending(newOrder);
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Iconsax.notification_bing5, color: Colors.green),
              SizedBox(width: 10),
              Text('New Order Received!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${newOrder['student']} just placed an order.'),
              const SizedBox(height: 10),
              Text('Total: ₹${newOrder['total']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              const SizedBox(height: 10),
              const Center(child: Text('Auto-accepting...', style: TextStyle(color: Colors.grey, fontSize: 12))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  // Rejected
                });
              },
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.of(context).pop();
                _acceptOrderDirectly(newOrder);
              },
              child: const Text('Accept Now', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _moveToPending(Map<String, dynamic> order) {
    if (!mounted) return;
    setState(() {
      _newOrders.add(order);
      _pendingOrders.insert(0, order);
      _newOrders.remove(order);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order ${order['id']} moved to Pending!')),
    );
  }

  void _acceptOrderDirectly(Map<String, dynamic> order) {
    if (!mounted) return;
    setState(() {
      _preparingOrders.insert(0, order);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order ${order['id']} accepted and preparing!')),
    );
  }

  void _acceptFromPending(Map<String, dynamic> order) {
    setState(() {
      _pendingOrders.remove(order);
      _preparingOrders.insert(0, order);
    });
  }

  void _rejectFromPending(Map<String, dynamic> order) {
    setState(() {
      _pendingOrders.remove(order);
    });
  }

  void _markAsReady(Map<String, dynamic> order) {
    setState(() {
      _preparingOrders.remove(order);
      _readyOrders.insert(0, order);
    });
  }

  void _markAsDone(Map<String, dynamic> order) {
    setState(() {
      _readyOrders.remove(order);
      _completedOrders.insert(0, order);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order marked as Completed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(isDark),
            _buildStatsSection(),
            const SizedBox(height: 16),
            _buildTabBar(isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(_pendingOrders, 'pending'),
                  _buildOrderList(_preparingOrders, 'preparing'),
                  _buildOrderList(_readyOrders, 'ready'),
                  _buildOrderList(_completedOrders, 'completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome Back,', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const Text(
                'Vendor Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                _isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isOnline ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _isOnline,
                activeColor: Colors.green,
                onChanged: (val) {
                  setState(() {
                    _isOnline = val;
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    int totalOrders = _preparingOrders.length + _readyOrders.length + _completedOrders.length;
    double earnings = _completedOrders.fold(0.0, (sum, item) => sum + (item['total'] as int));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Pending',
              value: '${_pendingOrders.length + _preparingOrders.length}',
              icon: Iconsax.timer,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Completed',
              value: '${_completedOrders.length}',
              icon: Iconsax.task_square,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Earnings',
              value: '₹${earnings.toInt()}',
              icon: Iconsax.wallet,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pending'),
                  if (_pendingOrders.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    )
                  ]
                ],
              ),
            ),
            const Tab(text: 'Preparing'),
            const Tab(text: 'Ready'),
            const Tab(text: 'Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders, String status) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.box, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No $status orders', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, status, context);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, String status, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252525) : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['id'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['time'],
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.lock, size: 14, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'PIN: ${order['pin']}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.profile_circle, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      order['student'],
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                // Items
                ...List.generate(order['items'].length, (i) {
                  final item = order['items'][i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item['qty']}x',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['name'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                    Text(
                      '₹${order['total']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          if (status == 'pending')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectFromPending(order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptFromPending(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            
          if (status == 'preparing')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: () => _markAsReady(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Mark as Ready', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            
          if (status == 'ready')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: () => _markAsDone(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Handover Done (Verify PIN)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
