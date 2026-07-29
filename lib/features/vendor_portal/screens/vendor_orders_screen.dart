import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    Future.delayed(const Duration(seconds: 4), () {
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

  void _triggerVibrationAlert() async {
    // Vibrate three times sequentially to alert the vendor
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void _simulateNewOrder() {
    _triggerVibrationAlert();

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

    // Show popup alert
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Auto-dismiss after 3 seconds and accept it automatically
        Timer? autoAcceptTimer;
        autoAcceptTimer = Timer(const Duration(milliseconds: 3000), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            _moveToPending(newOrder);
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.notification_bing5, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Incoming Order!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New order placed by ${newOrder['student']}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ...List.generate((newOrder['items'] as List).length, (i) {
                      final item = (newOrder['items'] as List)[i] as Map<String, dynamic>;
                      return Row(
                        children: [
                          Text('${item['qty']}x', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text(item['name']),
                        ],
                      );
                    }),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Bill:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('₹${newOrder['total']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Auto-accepting soon...',
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () {
                autoAcceptTimer?.cancel();
                Navigator.of(context).pop();
              },
              child: const Text('Reject', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {
                autoAcceptTimer?.cancel();
                Navigator.of(context).pop();
                _acceptOrderDirectly(newOrder);
              },
              child: const Text('Accept Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      SnackBar(
        content: Text('Order ${order['id']} moved to Pending!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _acceptOrderDirectly(Map<String, dynamic> order) {
    if (!mounted) return;
    setState(() {
      _preparingOrders.insert(0, order);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order['id']} accepted and preparing! 🍳'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade600,
      ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order['id']} rejected.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  void _markAsReady(Map<String, dynamic> order) {
    setState(() {
      _preparingOrders.remove(order);
      _readyOrders.insert(0, order);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order['id']} marked as Ready!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange.shade600,
      ),
    );
  }

  void _markAsDone(Map<String, dynamic> order) {
    setState(() {
      _readyOrders.remove(order);
      _completedOrders.insert(0, order);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order['id']} successfully handed over! 🍅'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade600,
      ),
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
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(_pendingOrders, 'Pending'),
                  _buildOrderList(_preparingOrders, 'Preparing'),
                  _buildOrderList(_readyOrders, 'Ready'),
                  _buildOrderList(_completedOrders, 'Completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final primaryColor = Theme.of(context).primaryColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: _isOnline
                          ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 6,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isOnline ? 'LIVE PORTAL ACTIVE' : 'PORTAL OFFLINE',
                    style: TextStyle(
                      color: _isOnline ? Colors.green.shade600 : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Vendor Orders',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _isOnline ? Colors.green.withOpacity(0.08) : Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isOnline ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: _isOnline ? Colors.green.shade700 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _isOnline,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() {
                        _isOnline = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    int totalOrders = _preparingOrders.length + _readyOrders.length + _completedOrders.length;
    double earnings = _completedOrders.fold(0.0, (sum, item) => sum + (item['total'] as int));

    return SizedBox(
      height: 95,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _StatCard(
            title: 'Active Orders',
            value: '${_pendingOrders.length + _preparingOrders.length}',
            icon: Iconsax.timer,
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _StatCard(
            title: 'Ready Pickup',
            value: '${_readyOrders.length}',
            icon: Iconsax.box,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          _StatCard(
            title: 'Completed',
            value: '${_completedOrders.length}',
            icon: Iconsax.task_square,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _StatCard(
            title: 'Today Earnings',
            value: '₹${earnings.toInt()}',
            icon: Iconsax.wallet,
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4.0),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pending'),
                  if (_pendingOrders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Text(
                        '${_pendingOrders.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    )
                  ]
                ],
              ),
            ),
            const Tab(text: 'Preparing'),
            const Tab(text: 'Ready'),
            const Tab(text: 'History'),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.box, size: 48, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              'No $status orders right now',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, status.toLowerCase(), context);
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
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order Card Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252525) : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['id'],
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Iconsax.clock, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          order['time'],
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.key, size: 12, color: theme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'PIN: ${order['pin']}',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Order Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.user, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(
                      order['student'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 0.8),
                ),
                
                // Item Lines
                ...List.generate(order['items'].length, (i) {
                  final item = order['items'][i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item['qty']}x',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['name'],
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
                const Divider(height: 16, thickness: 0.8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment Status: Mock Cash',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    Text(
                      '₹${order['total']}',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: theme.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
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
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptFromPending(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
            
          if (status == 'preparing')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.tick_circle, color: Colors.white, size: 16),
                onPressed: () => _markAsReady(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                label: const Text('Mark as Ready / Pack', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            
          if (status == 'ready')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.verify, color: Colors.white, size: 16),
                onPressed: () => _markAsDone(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                label: const Text('Verify PIN & Handover', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
      width: 125,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
