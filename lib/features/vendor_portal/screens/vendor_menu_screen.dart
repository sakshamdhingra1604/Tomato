import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../vendor_portal/screens/vendor_add_item_screen.dart';
import 'package:tomato/features/vendor_portal/screens/vendor_add_item_screen.dart' hide VendorAddItemScreen;
import '../data/vendor_menu_data.dart';
import '../widgets/vendor_menu_item_card.dart';

class VendorMenuScreen extends StatefulWidget {
  const VendorMenuScreen({Key? key}) : super(key: key);

  @override
  _VendorMenuScreenState createState() => _VendorMenuScreenState();
}

class _VendorMenuScreenState extends State<VendorMenuScreen> {
  List<VendorMenuItem> _items = getSampleMenuItems();
  bool _isMenuLive = true;
  String _sortBy = 'Default';
  String _filterBy = 'All';
  bool _showCombos = false;

  int get _specialCount => _items.where((i) => i.isTodaysSpecial).length;

  List<VendorMenuItem> get _todaysSpecials =>
      _items.where((i) => i.isTodaysSpecial).toList();

  List<VendorMenuItem> get _filteredSortedItems {
    List<VendorMenuItem> result = List.from(_items);
    if (_filterBy != 'All') {
      result = result.where((i) =>
          i.cuisineCategory == _filterBy || i.priceCategory == _filterBy).toList();
    }
    if (_sortBy == 'Price ↑') { result.sort((a, b) => a.price.compareTo(b.price)); }
    else if (_sortBy == 'Price ↓') { result.sort((a, b) => b.price.compareTo(a.price)); }
    else if (_sortBy == 'Rating') { result.sort((a, b) => b.rating.compareTo(a.rating)); }
    return result;
  }

  void _openAddItem() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => VendorAddItemScreen(
        specialCount: _specialCount,
        onSave: (item) => setState(() => _items.add(item)),
      ),
    ));
  }

  void _openEditItem(VendorMenuItem item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => VendorAddItemScreen(
        existingItem: item,
        specialCount: _specialCount,
        onSave: (updated) => setState(() {
          final idx = _items.indexWhere((e) => e.id == updated.id);
          if (idx != -1) _items[idx] = updated;
        }),
      ),
    )).then((_) => setState(() {}));
  }

  void _toggleStock(VendorMenuItem item) =>
      setState(() => item.isOutOfStock = !item.isOutOfStock);

  void _toggleSpecial(VendorMenuItem item) {
    if (!item.isTodaysSpecial && _specialCount >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Max 2 "Today\'s Specials" allowed!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => item.isTodaysSpecial = !item.isTodaysSpecial);
  }

  void _deleteItem(VendorMenuItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Item?'),
        content: Text('Remove "${item.name}" from your menu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _items.remove(item));
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final specials = _todaysSpecials;
    final allItems = _filteredSortedItems;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                children: [
                  _buildLiveToggle(isDark),
                  const SizedBox(height: 16),
                  _buildSortFilterSection(isDark),
                  const SizedBox(height: 20),
                  if (specials.isNotEmpty && _filterBy == 'All') ...[
                    _buildSectionLabel('⭐  Today\'s Specials', Colors.amber.shade700),
                    const SizedBox(height: 10),
                    ...specials.map((item) => _card(item)),
                    const SizedBox(height: 8),
                    _buildSectionLabel('📋  Full Menu', Theme.of(context).primaryColor),
                    const SizedBox(height: 10),
                  ],
                  if (allItems.isEmpty)
                    _buildEmptyState()
                  else
                    ...allItems.map((item) => _card(item)),
                  const SizedBox(height: 20),
                  _buildComboSection(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddItem,
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Iconsax.add_circle, color: Colors.white),
        label: const Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _card(VendorMenuItem item) => VendorMenuItemCard(
        item: item,
        specialCount: _specialCount,
        onEdit: () => _openEditItem(item),
        onToggleStock: () => _toggleStock(item),
        onToggleSpecial: () => _toggleSpecial(item),
        onDelete: () => _deleteItem(item),
      );

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Menu Management',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('${_items.length} items listed',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${_items.where((i) => !i.isOutOfStock).length} Live',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveToggle(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isMenuLive ? Colors.green.withValues(alpha: 0.08) : Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isMenuLive ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isMenuLive ? Iconsax.shop : Iconsax.shop_remove,
            color: _isMenuLive ? Colors.green : Colors.red,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isMenuLive ? 'Menu is Live 🟢' : 'Menu is Offline 🔴',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isMenuLive ? Colors.green : Colors.red,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _isMenuLive
                      ? 'Students can see and order your items'
                      : 'Your menu is hidden from all students',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _isMenuLive,
            activeThumbColor: Colors.green,
            inactiveThumbColor: Colors.red,
            onChanged: (val) => setState(() => _isMenuLive = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSortFilterSection(bool isDark) {
    final sorts = ['Default', 'Price ↑', 'Price ↓', 'Rating'];
    final filters = [
      'All', 'North Indian', 'South Indian', 'Chinese',
      'Italian', 'Korean', 'Fast Food', 'Beverages', 'Snacks',
      'Under ₹99', 'Under ₹149',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: sorts.map((s) => GestureDetector(
            onTap: () => setState(() => _sortBy = s),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _sortBy == s
                    ? Theme.of(context).primaryColor
                    : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(s,
                  style: TextStyle(
                    color: _sortBy == s ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: FontWeight.w600, fontSize: 13,
                  )),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: filters.map((f) => GestureDetector(
              onTap: () => setState(() => _filterBy = f),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _filterBy == f
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
                      : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _filterBy == f ? Theme.of(context).primaryColor : Colors.transparent,
                  ),
                ),
                child: Text(f,
                    style: TextStyle(
                      color: _filterBy == f
                          ? Theme.of(context).primaryColor
                          : (isDark ? Colors.white70 : Colors.black54),
                      fontWeight: _filterBy == f ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    )),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String title, Color color) {
    return Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Iconsax.box, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No items match your filter', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildComboSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _showCombos = !_showCombos),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.category_2, color: Colors.purple, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Combo Meals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Bundle items for a special deal price', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(_showCombos ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1, color: Colors.grey),
                ],
              ),
            ),
          ),
          if (_showCombos) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.withValues(alpha: 0.15)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Iconsax.category, color: Colors.purple, size: 22),
                        SizedBox(width: 12),
                        Text('No combos created yet', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Combo builder coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Iconsax.add_circle, color: Colors.white, size: 18),
                    label: const Text('Create New Combo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
