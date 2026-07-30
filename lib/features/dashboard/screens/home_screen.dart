import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../data/canteen_data.dart';
import '../widgets/home_header.dart';
import '../widgets/promo_banner_carousel.dart';
import '../widgets/canteen_card.dart';
import '../services/canteen_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CanteenService _canteenService = CanteenService();
  List<Canteen> _canteens = [];
  List<MenuItem> _topPicks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCanteens();
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

      final List<MenuItem> picks = [];
      for (var c in tempCanteens) {
        if (c.isAvailable && c.menuItems.isNotEmpty) {
          picks.add(c.menuItems.first);
        }
      }

      if (mounted) {
        setState(() {
          _canteens = tempCanteens;
          _topPicks = picks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading canteens: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCanteens,
          color: primaryColor,
          child: _isLoading
              ? _buildShimmer(context)
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Top App Bar Header Widget
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                      sliver: SliverToBoxAdapter(
                        child: HomeHeader(),
                      ),
                    ),

                    // Search Bar (Tap to open full search)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      sliver: SliverToBoxAdapter(
                        child: GestureDetector(
                          onTap: () => context.push('/search'),
                          child: AbsorbPointer(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search 'Momos', 'Burger', 'Pasta'...",
                                prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Sliding Promo Banner Carousel Widget
                    const SliverPadding(
                      padding: EdgeInsets.only(top: 16),
                      sliver: SliverToBoxAdapter(
                        child: PromoBannerCarousel(),
                      ),
                    ),

                    // Pure Veg Campus Badge
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
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
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  '100% Pure Veg Campus Outlets',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Icon(Icons.verified_rounded, color: Colors.green, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Food Categories Title
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'What are you craving today?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Food Category Badges Horizontal List
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 96,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: CanteenData.categories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return GestureDetector(
                                onTap: () => context.push('/search', extra: ''),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Text('🍽️', style: TextStyle(fontSize: 26)),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'All Items',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final cat = CanteenData.categories[index - 1];

                            return GestureDetector(
                              onTap: () => context.push('/search', extra: cat.name),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(cat.icon, style: const TextStyle(fontSize: 26)),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      cat.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Top Campus Picks Header
                    if (_topPicks.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Top Campus Picks 🔥',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Popular',
                                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Top Campus Picks Horizontal Scroll
                    if (_topPicks.isNotEmpty)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 155,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            itemCount: _topPicks.length,
                            itemBuilder: (context, index) {
                              final item = _topPicks[index];
                              return Container(
                                width: 170,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star_rounded, color: Colors.green, size: 14),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${item.rating}',
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${item.prepTimeMins} mins',
                                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '₹${item.price.toInt()}',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_rounded, color: primaryColor, size: 16),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // Outlets Section Header
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Campus Canteens & Outlets',
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_canteens.length} Outlets',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Canteen Cards Vertical List
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final canteen = _canteens[index];
                            return CanteenCard(canteen: canteen);
                          },
                          childCount: _canteens.length,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 40, width: 200, color: Colors.white),
            const SizedBox(height: 20),
            Container(height: 50, color: Colors.white),
            const SizedBox(height: 30),
            Container(height: 120, color: Colors.white),
            const SizedBox(height: 30),
            Container(height: 40, width: 150, color: Colors.white),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Container(height: 150, color: Colors.white)),
                const SizedBox(width: 16),
                Expanded(child: Container(height: 150, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
