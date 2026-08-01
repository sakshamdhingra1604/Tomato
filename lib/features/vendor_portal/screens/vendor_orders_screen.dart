import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';
import '../../dashboard/services/order_service.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({Key? key}) : super(key: key);

  @override
  _VendorOrdersScreenState createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> with SingleTickerProviderStateMixin {
  bool _isOnline = true;
  late TabController _tabController;
  final OrderService _orderService = OrderService();
  bool _isLoading = true;

  List<dynamic> _pendingOrders = [];
  List<dynamic> _preparingOrders = [];
  List<dynamic> _readyOrders = [];
  List<dynamic> _completedOrders = [];

  final Set<String> _seenPendingOrderIds = {};
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchOrders(initial: true);

    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isOnline) {
        _fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _triggerVibrationAlert() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500]);
    } else {
      for (int i = 0; i < 3; i++) {
        await HapticFeedback.vibrate();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  void _simulateNewOrder() {
    _triggerVibrationAlert();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulated incoming order vibration alert! 🔊'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _fetchOrders({bool initial = false}) async {
    if (initial) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final orders = await _orderService.getVendorOrders();

      final List<dynamic> pending = [];
      final List<dynamic> preparing = [];
      final List<dynamic> ready = [];
      final List<dynamic> completed = [];

      bool hasNewPending = false;

      for (var order in orders) {
        final status = order['status'] ?? 'pending';
        final orderId = order['_id'] ?? '';

        if (status == 'pending') {
          pending.add(order);
          if (!_seenPendingOrderIds.contains(orderId)) {
            _seenPendingOrderIds.add(orderId);
            hasNewPending = true;
          }
        } else if (status == 'accepted' || status == 'preparing') {
          preparing.add(order);
        } else if (status == 'ready_for_pickup' || status == 'out_for_delivery') {
          ready.add(order);
        } else if (status == 'delivered' || status == 'cancelled') {
          completed.add(order);
        }
      }

      if (hasNewPending && !initial) {
        _triggerVibrationAlert();
      }

      if (mounted) {
        setState(() {
          _pendingOrders = pending;
          _preparingOrders = preparing;
          _readyOrders = ready;
          _completedOrders = completed;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading vendor orders: $e');
    }
  }

  Future<void> _updateStatus(String orderId, String status) async {
    try {
      await _orderService.updateOrderStatus(orderId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPinVerificationDialog(String orderId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify Handover PIN'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter student claim PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(orderId, 'delivered');
            },
            child: const Text('Verify & Handover'),
          ),
        ],
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => _fetchOrders(),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrderList(_pendingOrders, 'Pending'),
                          _buildOrderList(_preparingOrders, 'Preparing'),
                          _buildOrderList(_readyOrders, 'Ready'),
                          _buildOrderList(_completedOrders, 'History'),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Campus Outlets Portal', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Switch(
            value: _isOnline,
            onChanged: (val) {
              setState(() {
                _isOnline = val;
              });
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final double earnings = _completedOrders.fold(0.0, (sum, o) => sum + (o['totalAmount'] ?? 0.0));
    final int activeCount = _preparingOrders.length + _readyOrders.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatCard(
            title: 'Active Orders',
            value: '$activeCount',
            icon: Iconsax.bag_2,
            color: Colors.blue,
          ),
          _StatCard(
            title: 'Today\'s Sales',
            value: '₹${earnings.toStringAsFixed(0)}',
            icon: Iconsax.wallet_3,
            color: Colors.green,
          ),
          _StatCard(
            title: 'Average Prep',
            value: '12 min',
            icon: Iconsax.timer,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Preparing'),
          Tab(text: 'Ready'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, String statusType) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.box, size: 50, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'No $statusType orders right now',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, statusType.toLowerCase(), context);
      },
    );
  }

  Widget _buildOrderCard(dynamic order, String statusType, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final orderId = order['_id'] ?? '';
    final shortId = orderId.length > 6 ? '#ORD-${orderId.substring(orderId.length - 6)}' : '#ORD-$orderId';
    final itemsList = order['items'] as List<dynamic>? ?? [];
    final claimPin = order['claimPin'] ?? '1234';
    final total = order['totalAmount'] ?? 0;
    final status = order['status'] ?? 'pending';
    final location = order['deliveryLocation'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252525) : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  shortId.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                        'PIN: $claimPin',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Location: $location',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                ...itemsList.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${item['quantity']}x',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['name'] ?? 'Item',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${total.toInt()}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActionButtons(orderId, status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String orderId, String status) {
    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _updateStatus(orderId, 'cancelled'),
              child: const Text('Reject'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _updateStatus(orderId, 'preparing'),
              child: const Text('Accept', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      );
    } else if (status == 'preparing' || status == 'accepted') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _updateStatus(orderId, 'ready_for_pickup'),
          child: const Text('Mark as Ready / Pack', style: TextStyle(color: Colors.white)),
        ),
      );
    } else if (status == 'ready_for_pickup') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _showPinVerificationDialog(orderId),
          child: const Text('Verify PIN & Handover', style: TextStyle(color: Colors.white)),
        ),
      );
    }
    return const SizedBox();
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
      width: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
