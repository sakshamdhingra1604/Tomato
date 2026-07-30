import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/order_service.dart';
import '../../auth/services/auth_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _userRole = 'student';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final role = await AuthService().getUserRole();
      final list = await _orderService.getUserOrders();
      if (mounted) {
        setState(() {
          _userRole = role ?? 'student';
          _orders = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load orders: $e')),
        );
      }
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order updated to ${newStatus.replaceAll('_', ' ')}!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Waiting for Acceptance';
      case 'accepted':
        return 'Order Accepted';
      case 'preparing':
        return 'Preparing Food';
      case 'ready_for_pickup':
        return 'Ready for Pickup';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.blue;
      case 'accepted':
      case 'preparing':
        return Colors.amber;
      case 'ready_for_pickup':
        return Colors.orange;
      case 'out_for_delivery':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? _buildShimmer(context)
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: _orders.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final orderId = order['_id'] ?? '';
                        final itemsList = order['items'] as List<dynamic>? ?? [];
                        final total = order['totalAmount'] ?? 0;
                        final status = order['status'] ?? 'pending';
                        final location = order['deliveryLocation'] ?? 'Unknown';
                        final vendorName = order['vendorId'] ?? 'Canteen';
                        final delivererId = order['delivererId'];

                        // Check if this order is a delivery job claimed by the user
                        final isMyDeliveryJob = _userRole == 'deliverer' && delivererId != null;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    vendorName.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getStatusText(status).toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(status),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, color: Colors.grey, size: 16),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Deliver to: $location',
                                      style: TextStyle(color: theme.disabledColor, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              ...itemsList.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${item['quantity']}x ${item['name']}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        Text('₹${(item['price'] * item['quantity']).toInt()}'),
                                      ],
                                    ),
                                  )),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total: ₹${total.toInt()}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  // Action buttons for deliverer if they are actively delivering this order
                                  if (isMyDeliveryJob && status != 'delivered' && status != 'cancelled')
                                    _buildDelivererActions(orderId, status),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildDelivererActions(String orderId, String status) {
    if (status == 'ready_for_pickup') {
      return ElevatedButton.icon(
        icon: const Icon(Icons.directions_bike_rounded, size: 16),
        label: const Text('Pick Up Order', style: TextStyle(fontSize: 12)),
        onPressed: () => _updateStatus(orderId, 'out_for_delivery'),
      );
    } else if (status == 'out_for_delivery') {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        icon: const Icon(Icons.check_rounded, size: 16),
        label: const Text('Mark Delivered', style: TextStyle(fontSize: 12)),
        onPressed: () => _updateStatus(orderId, 'delivered'),
      );
    }
    return const SizedBox();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_rounded, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Orders Placed Yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your active and past orders will show up here.',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
