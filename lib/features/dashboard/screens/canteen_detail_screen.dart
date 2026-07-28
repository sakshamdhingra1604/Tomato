import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/canteen_data.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/floating_cart_bar.dart';

class CanteenDetailScreen extends StatefulWidget {
  final Canteen canteen;

  const CanteenDetailScreen({Key? key, required this.canteen}) : super(key: key);

  @override
  _CanteenDetailScreenState createState() => _CanteenDetailScreenState();
}

class _CanteenDetailScreenState extends State<CanteenDetailScreen> {
  final Map<String, int> _cart = {}; // itemId -> quantity
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<String> get _categories {
    final Set<String> cats = {'All'};
    for (var item in widget.canteen.menuItems) {
      cats.add(item.category);
    }
    return cats.toList();
  }

  List<MenuItem> get _filteredMenuItems {
    return widget.canteen.menuItems.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  int get _totalCartItems {
    return _cart.values.fold(0, (sum, count) => sum + count);
  }

  double get _totalCartPrice {
    double total = 0;
    _cart.forEach((itemId, qty) {
      final item = widget.canteen.menuItems.firstWhere((element) => element.id == itemId);
      total += (item.price * qty);
    });
    return total;
  }

  void _addItem(String id) {
    setState(() {
      _cart[id] = (_cart[id] ?? 0) + 1;
    });
  }

  void _removeItem(String id) {
    setState(() {
      if (_cart.containsKey(id)) {
        if (_cart[id]! > 1) {
          _cart[id] = _cart[id]! - 1;
        } else {
          _cart.remove(id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Vendor Header Banner & Navigation
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: () => context.pop(),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Pure Veg Outlet',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.canteen.name,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.canteen.tag,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${widget.canteen.rating}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('(${widget.canteen.ratingCount}+ ratings)', style: theme.textTheme.bodySmall),
                            const Spacer(),
                            Icon(Icons.timer_outlined, size: 16, color: primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              widget.canteen.prepTimeEstimate,
                              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // In-Menu Search Bar
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search in ${widget.canteen.name}...",
                        prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),

                // Category Filter Chips
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(category),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            selectedColor: primaryColor,
                            backgroundColor: theme.colorScheme.surface,
                            onSelected: (bool selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Menu Items List
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, _totalCartItems > 0 ? 100 : 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _filteredMenuItems[index];
                        final qty = _cart[item.id] ?? 0;
                        return MenuItemCard(
                          item: item,
                          qty: qty,
                          onAdd: () => _addItem(item.id),
                          onRemove: () => _removeItem(item.id),
                        );
                      },
                      childCount: _filteredMenuItems.length,
                    ),
                  ),
                ),
              ],
            ),

            // Modular Floating Bottom Cart Bar Widget
            FloatingCartBar(
              totalItems: _totalCartItems,
              totalPrice: _totalCartPrice,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cart feature coming next!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
