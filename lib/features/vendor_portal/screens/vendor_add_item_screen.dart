import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../data/vendor_menu_data.dart';

class VendorAddItemScreen extends StatefulWidget {
  final VendorMenuItem? existingItem;
  final int specialCount;
  final Function(VendorMenuItem) onSave;

  const VendorAddItemScreen({
    Key? key,
    this.existingItem,
    required this.specialCount,
    required this.onSave,
  }) : super(key: key);

  @override
  _VendorAddItemScreenState createState() => _VendorAddItemScreenState();
}

class _VendorAddItemScreenState extends State<VendorAddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _specialPriceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _prepTimeCtrl = TextEditingController();

  String _priceCategory = 'Under ₹99';
  String _cuisineCategory = 'North Indian';
  bool _isTodaysSpecial = false;
  bool _mockImageSelected = false;

  final List<String> _priceCategories = ['Under ₹99', 'Under ₹149', 'Special'];
  final List<String> _cuisineCategories = [
    'North Indian', 'South Indian', 'Chinese',
    'Italian', 'Korean', 'Fast Food', 'Beverages', 'Snacks',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    if (item != null) {
      _nameCtrl.text = item.name;
      _priceCtrl.text = item.price.toStringAsFixed(0);
      _specialPriceCtrl.text = item.specialPrice?.toStringAsFixed(0) ?? '';
      _descCtrl.text = item.description;
      _prepTimeCtrl.text = item.prepTimeMins.toString();
      _priceCategory = item.priceCategory;
      _cuisineCategory = item.cuisineCategory;
      _isTodaysSpecial = item.isTodaysSpecial;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _specialPriceCtrl.dispose();
    _descCtrl.dispose();
    _prepTimeCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_isTodaysSpecial) {
      final isAlreadySpecial = widget.existingItem?.isTodaysSpecial ?? false;
      if (!isAlreadySpecial && widget.specialCount >= 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Max 2 "Today\'s Specials" allowed!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final item = VendorMenuItem(
      id: widget.existingItem?.id ?? VendorMenuItem.generateId(),
      name: _nameCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      specialPrice: _specialPriceCtrl.text.trim().isNotEmpty
          ? double.tryParse(_specialPriceCtrl.text.trim())
          : null,
      description: _descCtrl.text.trim(),
      prepTimeMins: int.tryParse(_prepTimeCtrl.text) ?? 10,
      priceCategory: _priceCategory,
      cuisineCategory: _cuisineCategory,
      isTodaysSpecial: _isTodaysSpecial,
      rating: widget.existingItem?.rating ?? 0.0,
      reviewCount: widget.existingItem?.reviewCount ?? 0,
    );

    widget.onSave(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.existingItem != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEdit ? 'Edit Item' : 'Add New Item',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageUpload(isDark),
              const SizedBox(height: 20),
              _buildTodaysSpecialToggle(isDark),
              const SizedBox(height: 20),
              _buildField(_nameCtrl, 'Item Name *', Iconsax.tag, required: true),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _buildField(_priceCtrl, 'Price (₹) *', Iconsax.money, isNumber: true, required: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(_specialPriceCtrl, 'Special Price (₹)', Iconsax.discount_circle, isNumber: true)),
                ],
              ),
              const SizedBox(height: 14),
              _buildField(_descCtrl, 'Description *', Iconsax.document_text, maxLines: 3, required: true),
              const SizedBox(height: 14),
              _buildField(_prepTimeCtrl, 'Avg. Prep Time (mins) *', Iconsax.timer_1, isNumber: true, required: true),
              const SizedBox(height: 24),
              _buildChipSection(
                title: '💰  Price Category',
                items: _priceCategories,
                selected: _priceCategory,
                onSelect: (v) => setState(() => _priceCategory = v),
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              _buildChipSection(
                title: '🍽️  Cuisine Category',
                items: _cuisineCategories,
                selected: _cuisineCategory,
                onSelect: (v) => setState(() => _cuisineCategory = v),
                isDark: isDark,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUpload(bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _mockImageSelected = !_mockImageSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 150,
        decoration: BoxDecoration(
          color: _mockImageSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
              : (isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _mockImageSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.4)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        child: _mockImageSelected
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Iconsax.image5, size: 70, color: Theme.of(context).primaryColor.withValues(alpha: 0.35)),
                  Positioned(
                    bottom: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Change Photo',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.camera, size: 40, color: Colors.grey.shade500),
                  const SizedBox(height: 10),
                  Text('Tap to upload food image',
                      style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('PNG, JPG — max 5 MB',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ],
              ),
      ),
    );
  }

  Widget _buildTodaysSpecialToggle(bool isDark) {
    final limitReached = !_isTodaysSpecial && widget.specialCount >= 2;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isTodaysSpecial
            ? Colors.amber.withValues(alpha: 0.1)
            : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isTodaysSpecial
              ? Colors.amber.withValues(alpha: 0.5)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's Special",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  limitReached
                      ? '⚠️ Limit reached — 2 specials max'
                      : 'Pin this dish as today\'s highlight (max 2)',
                  style: TextStyle(
                    color: limitReached ? Colors.red : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isTodaysSpecial,
            activeThumbColor: Colors.amber,
            onChanged: limitReached ? null : (val) => setState(() => _isTodaysSpecial = val),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool required = false,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: !required ? 'Optional' : null,
        suffixStyle: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null
          : null,
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> items,
    required String selected,
    required Function(String) onSelect,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSel = selected == item;
            return GestureDetector(
              onTap: () => onSelect(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isSel
                      ? Theme.of(context).primaryColor
                      : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSel ? Theme.of(context).primaryColor : Colors.transparent,
                  ),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
