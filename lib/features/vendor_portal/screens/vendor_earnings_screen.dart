import 'package:flutter/material.dart';

class VendorEarningsScreen extends StatelessWidget {
  const VendorEarningsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wallet, size: 100, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Earnings (Coming Soon)', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
