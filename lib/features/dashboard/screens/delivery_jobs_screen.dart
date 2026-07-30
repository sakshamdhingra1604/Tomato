import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/order_service.dart';

class DeliveryJobsScreen extends StatefulWidget {
  const DeliveryJobsScreen({Key? key}) : super(key: key);

  @override
  _DeliveryJobsScreenState createState() => _DeliveryJobsScreenState();
}

class _DeliveryJobsScreenState extends State<DeliveryJobsScreen> {
  final OrderService _orderService = OrderService();
  List<dynamic> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final jobs = await _orderService.getOpenJobs();
      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load delivery jobs: $e')),
      );
    }
  }

  Future<void> _claimJob(String orderId) async {
    try {
      final res = await _orderService.claimJob(orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Delivery job claimed successfully! 🚶'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchJobs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to claim job: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Deliveries', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchJobs,
          ),
        ],
      ),
      body: _isLoading
          ? _buildShimmer(context)
          : RefreshIndicator(
              onRefresh: _fetchJobs,
              child: _jobs.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _jobs.length,
                      itemBuilder: (context, index) {
                        final job = _jobs[index];
                        final itemsList = job['items'] as List<dynamic>? ?? [];
                        final total = job['totalAmount'] ?? 0;
                        final location = job['deliveryLocation'] ?? 'Unknown';
                        final vendorName = job['vendorId'] ?? 'Canteen'; // Note: matches database schema

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
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'READY FOR PICKUP',
                                      style: TextStyle(
                                        color: Colors.amber,
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
                                  const Icon(Icons.location_on_rounded, color: Colors.grey, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Deliver to: $location',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text(
                                'Items to Pick Up:',
                                style: TextStyle(color: theme.disabledColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              ...itemsList.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${item['quantity']}x ',
                                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                                        ),
                                        Expanded(
                                          child: Text(
                                            item['name'] ?? 'Item',
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Earnings: ₹${(total * 0.15).toStringAsFixed(0)} (15% fee)', // Deliverers earn 15% delivery fee
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () => _claimJob(job['_id']),
                                    child: const Text('Claim Delivery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_walk_rounded, size: 70, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Deliveries Available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Canteens are currently preparing orders or there are no unassigned delivery jobs.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
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
            height: 180,
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
