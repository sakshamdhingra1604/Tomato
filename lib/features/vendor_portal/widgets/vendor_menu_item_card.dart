import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../data/vendor_menu_data.dart';

class VendorMenuItemCard extends StatelessWidget {
  final VendorMenuItem item;
  final int specialCount;
  final VoidCallback onEdit;
  final VoidCallback onToggleStock;
  final VoidCallback onToggleSpecial;
  final VoidCallback onDelete;

  const VendorMenuItemCard({
    Key? key,
    required this.item,
    required this.specialCount,
    required this.onEdit,
    required this.onToggleStock,
    required this.onToggleSpecial,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.isTodaysSpecial
                  ? Colors.amber.withValues(alpha: 0.6)
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              width: item.isTodaysSpecial ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image area
                    Stack(
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Iconsax.image, size: 36, color: Colors.grey.shade400),
                        ),
                        if (item.isTodaysSpecial)
                          Positioned(
                            top: 5, right: 5,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.star_rounded, size: 11, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              if (item.specialPrice != null) ...[
                                Text(
                                  '₹${item.price.toInt()}',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '₹${item.specialPrice!.toInt()}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ] else
                                Text(
                                  '₹${item.price.toInt()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Iconsax.timer_1, size: 13, color: Colors.grey.shade500),
                              const SizedBox(width: 3),
                              Text('${item.prepTimeMins}m', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(item.cuisineCategory,
                                    style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Rating stars
                          Row(
                            children: [
                              ...List.generate(5, (i) => Icon(
                                i < item.rating.floor()
                                    ? Icons.star_rounded
                                    : (i < item.rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                                color: Colors.amber,
                                size: 14,
                              )),
                              const SizedBox(width: 4),
                              Text('(${item.reviewCount} reviews)',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Action bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252525) : Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    _ActionChip(icon: Iconsax.edit, label: 'Edit', color: Colors.blue, onTap: onEdit),
                    const SizedBox(width: 7),
                    _ActionChip(
                      icon: item.isOutOfStock ? Iconsax.tick_circle : Iconsax.close_circle,
                      label: item.isOutOfStock ? 'In Stock' : 'Out of Stock',
                      color: item.isOutOfStock ? Colors.green : Colors.orange,
                      onTap: onToggleStock,
                    ),
                    const SizedBox(width: 7),
                    _ActionChip(
                      icon: item.isTodaysSpecial ? Icons.star_rounded : Icons.star_outline_rounded,
                      label: 'Special',
                      color: item.isTodaysSpecial ? Colors.amber : Colors.grey,
                      onTap: onToggleSpecial,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Iconsax.trash, color: Colors.red, size: 19),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Out of stock overlay
        if (item.isOutOfStock)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'OUT OF STOCK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
