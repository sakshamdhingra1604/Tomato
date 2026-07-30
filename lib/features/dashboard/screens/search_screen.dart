import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../data/canteen_data.dart';
import '../services/cart_manager.dart';
import '../services/canteen_service.dart';

class SearchScreenItem {
  final MenuItem item;
  final Canteen canteen;

  const SearchScreenItem({required this.item, required this.canteen});
}

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({Key? key, this.initialQuery = ''}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  final CanteenService _canteenService = CanteenService();
  final CartManager _cartManager = CartManager();
  List<Canteen> _canteens = [];
  bool _isLoading = true;
  String _selectedSort = 'Default'; // 'Default', 'Price: Low to High', 'Rating: High to Low', 'Fastest Prep'

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _cartManager.addListener(_onCartChanged);
    _loadCanteens();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadCanteens() async {
    try {
      final vendors = await _canteenService.getVendors();
      final List<Canteen> tempCanteens = [];

      for (var v in vendors) {
        final vendorId = v['vendorId'] ?? '';
        final vendorName = v['name'] ?? '';
        final isOpen = v['isOpen'] ?? true;

        List<dynamic> itemsData = [];
        try {
          itemsData = await _canteenService.getMenuForCafe(vendorId);
        } catch (e) {
          debugPrint('Failed to load menu for $vendorId: $e');
        }

        final menuItems = itemsData.map((item) {
          return MenuItem(
            id: item['_id'] ?? '',
            name: item['name'] ?? '',
            price: (item['price'] as num?)?.toDouble() ?? 0.0,
            description: item['description'] ?? '',
            rating: 4.5,
            reviewsCount: 20,
            category: item['category'] ?? 'Snacks',
            isVeg: true,
            prepTimeMins: 10,
          );
        }).toList();

        tempCanteens.add(Canteen(
          id: vendorId,
          name: vendorName,
          rating: 4.5,
          ratingCount: 120,
          prepTimeEstimate: '10-15 mins',
          priceForTwo: '₹150 for two',
          isAvailable: isOpen,
          tag: vendorId == 'cafe14' ? 'Top Rated' : 'Campus Favorite',
          menuItems: menuItems,
        ));
      }

      if (mounted) {
        setState(() {
          _canteens = tempCanteens;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading canteens in search: $e');
    }
  }

  List<SearchScreenItem> get _allSearchItems {
    final List<SearchScreenItem> list = [];
    for (var canteen in _canteens) {
      if (canteen.isAvailable) {
        for (var item in canteen.menuItems) {
          list.add(SearchScreenItem(item: item, canteen: canteen));
        }
      }
    }
    return list;
  }

  List<SearchScreenItem> get _filteredAndSortedItems {
    final query = _searchController.text.toLowerCase().trim();

    List<SearchScreenItem> results = _allSearchItems.where((element) {
      if (query.isEmpty) return true;
      final matchDish = element.item.name.toLowerCase().contains(query) ||
          element.item.category.toLowerCase().contains(query) ||
          element.item.description.toLowerCase().contains(query);
      final matchCanteen = element.canteen.name.toLowerCase().contains(query) ||
          element.canteen.tag.toLowerCase().contains(query);
      return matchDish || matchCanteen;
    }).toList();

    if (_selectedSort == 'Price: Low to High') {
      results.sort((a, b) => a.item.price.compareTo(b.item.price));
    } else if (_selectedSort == 'Rating: High to Low') {
      results.sort((a, b) => b.item.rating.compareTo(a.item.rating));
    } else if (_selectedSort == 'Fastest Prep') {
      results.sort((a, b) => a.item.prepTimeMins.compareTo(b.item.prepTimeMins));
    }

    return results;
  }

  void _addItem(MenuItem item, Canteen canteen) {
    _cartManager.addItem(
      id: item.id,
      name: item.name,
      price: item.price,
      description: item.description,
      prepTimeMins: item.prepTimeMins,
      vendorId: canteen.id,
      vendorName: canteen.name,
    );
  }

  void _removeItem(String id) {
    _cartManager.removeItem(id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final results = _filteredAndSortedItems;
    final totalCartItems = _cartManager.totalItems;
    final totalCartPrice = _cartManager.totalPrice;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialQuery.isEmpty,
          onChanged: (val) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: "Search 'Burgers', 'Pasta', 'Momos'...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: theme.disabledColor),
          ),
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
      ),
      body: _isLoading
          ? _buildShimmer(context)
          : Stack(
              children: [
                Column(
                  children: [
                    // Sort Options Horizontal Bar
                    SizedBox(
                      height: 52,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildSortChip('Default'),
                          _buildSortChip('Price: Low to High'),
                          _buildSortChip('Rating: High to Low'),
                          _buildSortChip('Fastest Prep'),
                        ],
                      ),
                    ),

                    // Results Area
                    Expanded(
                      child: results.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off_rounded, size: 70, color: theme.disabledColor),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No results found for "${_searchController.text}"',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.disabledColor),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(20, 8, 20, totalCartItems > 0 ? 100 : 20),
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final searchItem = results[index];
                                final qty = _cartManager.items[searchItem.item.id]?.quantity ?? 0;
                                return _buildDishSearchResultCard(searchItem, qty, theme, primaryColor);
                              },
                            ),
                    ),
                  ],
                ),

                // Floating Bottom Cart Bar
                if (totalCartItems > 0)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$totalCartItems ITEM${totalCartItems > 1 ? 'S' : ''}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '₹${totalCartPrice.toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go('/dashboard?tab=1'); // Navigates to Cart Tab
                            },
                            child: Row(
                              children: const [
                                Text(
                                  'View Cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSortChip(String label) {
    final isSelected = _selectedSort == label;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        selectedColor: primaryColor,
        backgroundColor: theme.colorScheme.surface,
        onSelected: (bool selected) {
          setState(() {
            _selectedSort = label;
          });
        },
      ),
    );
  }

  Widget _buildDishSearchResultCard(SearchScreenItem searchItem, int qty, ThemeData theme, Color primaryColor) {
    final item = searchItem.item;
    final canteen = searchItem.canteen;

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
          // Canteen Badge Header
          GestureDetector(
            onTap: () {
              context.push('/canteen_detail', extra: canteen);
            },
            child: Row(
              children: [
                Icon(Icons.storefront_rounded, size: 16, color: primaryColor),
                const SizedBox(width: 6),
                Text(
                  canteen.name,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.grey),
                const Spacer(),
                Text(
                  '${item.prepTimeMins} mins',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

          const Divider(height: 20),

          // Dish Row Details & ADD Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                '${item.rating}',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${item.price.toInt()}',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Add / Counter Button
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: qty > 0 ? primaryColor : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor, width: 1.5),
                  boxShadow: [
                    if (qty > 0)
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: qty == 0
                    ? InkWell(
                        onTap: () => _addItem(item, canteen),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          child: Text(
                            'ADD',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                            onPressed: () => _removeItem(item.id),
                          ),
                          Text(
                            '$qty',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          IconButton(
                            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.add, color: Colors.white, size: 16),
                            onPressed: () => _addItem(item, canteen),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
