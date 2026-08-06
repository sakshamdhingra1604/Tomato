import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../data/canteen_data.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/floating_cart_bar.dart';
import '../services/cart_manager.dart';
import '../services/canteen_service.dart';

class CanteenDetailScreen extends StatefulWidget {
  final Canteen canteen;

  const CanteenDetailScreen({Key? key, required this.canteen}) : super(key: key);

  @override
  _CanteenDetailScreenState createState() => _CanteenDetailScreenState();
}

class _CanteenDetailScreenState extends State<CanteenDetailScreen> {
  final CartManager _cartManager = CartManager();
  final CanteenService _canteenService = CanteenService();
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _cartManager.addListener(_onCartChanged);
    _loadMenu();
  }

  @override
  void dispose() {
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadMenu() async {
    try {
      final itemsData = await _canteenService.getMenuForCafe(widget.canteen.id);
      final list = itemsData.map((item) {
        return MenuItem(
          id: item['_id'] ?? '',
          name: item['name'] ?? '',
          price: (item['price'] as num?)?.toDouble() ?? 0.0,
          specialPrice: item['specialPrice'] != null ? (item['specialPrice'] as num).toDouble() : null,
          description: item['description'] ?? '',
          rating: 4.5,
          reviewsCount: 20,
          category: item['category'] ?? 'Snacks',
          isVeg: true,
          prepTimeMins: 10,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _menuItems = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading menu: $e');
    }
  }

  List<String> get _categories {
    final Set<String> cats = {'All'};
    for (var item in _menuItems) {
      cats.add(item.category);
    }
    return cats.toList();
  }

  List<MenuItem> get _filteredMenuItems {
    return _menuItems.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _addItem(MenuItem item) {
    _cartManager.addItem(
      id: item.id,
      name: item.name,
      price: item.specialPrice ?? item.price,
      description: item.description,
      prepTimeMins: item.prepTimeMins,
      vendorId: widget.canteen.id,
      vendorName: widget.canteen.name,
    );
  }

  void _removeItem(MenuItem item) {
    _cartManager.removeItem(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final totalCartItems = _cartManager.totalItems;
    final totalCartPrice = _cartManager.totalPrice;

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
                if (!_isLoading)
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
                _isLoading
                    ? SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverToBoxAdapter(
                          child: _buildShimmerMenu(),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.fromLTRB(20, 12, 20, totalCartItems > 0 ? 100 : 32),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = _filteredMenuItems[index];
                              final cartQty = _cartManager.items[item.id]?.quantity ?? 0;
                              return MenuItemCard(
                                item: item,
                                qty: cartQty,
                                onAdd: () => _addItem(item),
                                onRemove: () => _removeItem(item),
                              );
                            },
                            childCount: _filteredMenuItems.length,
                          ),
                        ),
                      ),
              ],
            ),

            // Modular Floating Bottom Cart Bar Widget
            if (totalCartItems > 0)
              FloatingCartBar(
                totalItems: totalCartItems,
                totalPrice: totalCartPrice,
                onTap: () {
                  context.go('/dashboard?tab=1'); // Navigates to Cart Tab
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerMenu() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(4, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        )),
      ),
    );
  }
}
