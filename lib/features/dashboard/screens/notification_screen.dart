import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> _notifications = const [
    {
      'title': 'Welcome to Tomato! 🍅',
      'subtitle': 'Order from campus canteens or earn pocket money by delivering on foot!',
      'time': 'Just now',
      'icon': '🎉',
    },
    {
      'title': 'Flat ₹99 Student Combos Active!',
      'subtitle': 'Check out Bunny\'s Kitchen for crisp burger & peri-peri fries deals.',
      'time': '2 hours ago',
      'icon': '🍔',
    },
    {
      'title': 'Deliverers Active on Block A & B Route 🚶',
      'subtitle': 'Order now for fast campus delivery directly to your block.',
      'time': '5 hours ago',
      'icon': '⚡',
    },
    {
      'title': 'New Outlet Joined: Cafe14 🍕',
      'subtitle': 'Explore freshly baked farm special pizzas and garlic breadstix.',
      'time': '1 day ago',
      'icon': '🔥',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: _notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notif = _notifications[index];
            return Container(
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        notif['icon']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notif['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              notif['time']!,
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif['subtitle']!,
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
