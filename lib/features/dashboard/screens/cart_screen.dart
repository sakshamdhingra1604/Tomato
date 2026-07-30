import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/cart_manager.dart';
import '../services/order_service.dart';
import '../../auth/services/auth_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartManager _cartManager = CartManager();
  final OrderService _orderService = OrderService();
  final TextEditingController _locationController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _cartManager.addListener(_onCartChanged);
    _loadDefaultLocation();
  }

  @override
  void dispose() {
    _cartManager.removeListener(_onCartChanged);
    _locationController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _loadDefaultLocation() async {
    // Populate default classroom/block from user profile if available
    try {
      final res = await AuthService().getProfile();
      if (res['success'] == true && mounted) {
        final user = res['user'];
        final block = user['block'] ?? '';
        final classRoom = user['classRoom'] ?? '';
        if (block.isNotEmpty || classRoom.isNotEmpty) {
          final parts = [if (block.isNotEmpty) block, if (classRoom.isNotEmpty) classRoom];
          _locationController.text = parts.join(', ');
        }
      }
    } catch (e) {
      debugPrint('Failed to load profile for location: $e');
    }
  }

  Future<void> _placeOrder() async {
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a delivery location (e.g. Block A Room 304)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final vendorId = _cartManager.vendorId!;
      final items = _cartManager.items.values.map((cartItem) {
        return {
          'menuItemId': cartItem.id,
          'quantity': cartItem.quantity,
        };
      }).toList();

      await _orderService.placeOrder(
        vendorId: vendorId,
        items: items,
        deliveryLocation: _locationController.text.trim(),
      );

      // Clear cart
      _cartManager.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully! 🍅'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Direct user to correct Orders Tab depending on role
        final role = await AuthService().getUserRole();
        if (mounted) {
          if (role == 'deliverer') {
            context.go('/dashboard?tab=3'); // Orders is Tab index 3 for deliverers
          } else {
            context.go('/dashboard?tab=2'); // Orders is Tab index 2 for students
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final items = _cartManager.items.values.toList();
    final hasItems = items.isNotEmpty;

    const deliveryFee = 10.0;
    final itemTotal = _cartManager.totalPrice;
    final grandTotal = itemTotal > 0 ? itemTotal + deliveryFee : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: !hasItems
          ? _buildEmptyState(context)
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Vendor name banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.restaurant_rounded, color: primaryColor, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Ordering from: ${_cartManager.vendorName}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // List of items
                      Text(
                        'Items Selected',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${item.price.toInt()} each',
                                        style: TextStyle(color: theme.disabledColor, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                                      onPressed: () => _cartManager.removeItem(item.id),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline_rounded, color: primaryColor, size: 20),
                                      onPressed: () => _cartManager.addItem(
                                        id: item.id,
                                        name: item.name,
                                        price: item.price,
                                        description: item.description,
                                        prepTimeMins: item.prepTimeMins,
                                        vendorId: _cartManager.vendorId!,
                                        vendorName: _cartManager.vendorName!,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${(item.price * item.quantity).toInt()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Delivery Location Input
                      Text(
                        'Delivery Location',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Enter your block & classroom (e.g. Block A, Room 304)',
                          prefixIcon: Icon(Icons.location_on_rounded, color: primaryColor),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bill Summary
                      Text(
                        'Bill Summary',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Item Total', style: TextStyle(color: theme.disabledColor)),
                                Text('₹${itemTotal.toInt()}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Delivery Partner Fee', style: TextStyle(color: theme.disabledColor)),
                                const Text('₹10'),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Grand Total',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '₹${grandTotal.toInt()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Place Order Action Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isPlacingOrder ? null : _placeOrder,
                      child: _isPlacingOrder
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Pay & Place Order (₹${grandTotal.toInt()})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious items from campus stalls!',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Switch back to Home Tab (index 0)
              context.go('/dashboard?tab=0');
            },
            child: const Text('Browse Canteens'),
          ),
        ],
      ),
    );
  }
}
