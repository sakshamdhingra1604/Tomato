import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/canteen_data.dart';

class CanteenCard extends StatelessWidget {
  final Canteen canteen;

  const CanteenCard({Key? key, required this.canteen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return GestureDetector(
      onTap: canteen.isAvailable
          ? () {
              context.push('/canteen_detail', extra: canteen);
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${canteen.name} is currently closed / unavailable.')),
              );
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Card Banner Header
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                gradient: LinearGradient(
                  colors: canteen.isAvailable
                      ? [primaryColor.withOpacity(0.85), primaryColor.withOpacity(0.6)]
                      : [Colors.grey.shade600, Colors.grey.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      Icons.storefront_rounded,
                      size: 90,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            canteen.tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!canteen.isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'CLOSED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Body Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        canteen.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (canteen.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${canteen.rating}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.star_rounded, color: Colors.white, size: 13),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: theme.textTheme.bodyMedium?.color),
                      const SizedBox(width: 4),
                      Text(
                        canteen.prepTimeEstimate,
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Text('•', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 12),
                      Icon(Icons.payments_outlined, size: 16, color: theme.textTheme.bodyMedium?.color),
                      const SizedBox(width: 4),
                      Text(
                        canteen.priceForTwo,
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
