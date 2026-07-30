// ── vendor_earnings_screen.dart ───────────────────────────────────────────────
// Main screen: Vendor Earnings & Settlements
// Handles state, filter logic, data, and assembles widgets from:
//   • earnings_widgets.dart      (banner, metric card, settlement card)
//   • earnings_export_sheet.dart (export bottom sheet)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tomato/features/vendor_portal/widgets/earnings_widgets.dart';
import 'package:tomato/features/vendor_portal/widgets/earnings_export_sheet.dart';

class VendorEarningsScreen extends StatefulWidget {
  const VendorEarningsScreen({Key? key}) : super(key: key);

  @override
  _VendorEarningsScreenState createState() => _VendorEarningsScreenState();
}

class _VendorEarningsScreenState extends State<VendorEarningsScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  String _selectedFilter = 'Today';
  final List<String> _filters = ['Today', 'Last 7 Days', 'This Month', 'Custom Date'];

  // ── Mock Data ──────────────────────────────────────────────────────────────
  static const double _pendingPayout  = 1840.00;
  static const double _lifetimeEarned = 124560.00;
  static const int    _lifetimeOrders = 1243;
  static const int    _todayOrders    = 18;
  static const int    _itemsSold      = 47;
  static const double _avgOrderValue  = 102.0;

  final List<Map<String, dynamic>> _settlements = [
    {'date': 'Today, 30 Jul 2026', 'orders': 18,  'sales': 1840.00, 'isPending': true},
    {'date': '29 Jul 2026',        'orders': 31,  'sales': 3120.00, 'isPending': false},
    {'date': '28 Jul 2026',        'orders': 27,  'sales': 2680.00, 'isPending': false},
    {'date': '27 Jul 2026',        'orders': 22,  'sales': 2100.00, 'isPending': false},
    {'date': '26 Jul 2026',        'orders': 35,  'sales': 3540.00, 'isPending': false},
    {'date': '25 Jul 2026',        'orders': 19,  'sales': 1920.00, 'isPending': false},
    {'date': '24 Jul 2026',        'orders': 29,  'sales': 2870.00, 'isPending': false},
  ];

  // ── Computed ───────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _filteredSettlements {
    switch (_selectedFilter) {
      case 'Today':
        return _settlements.where((s) => s['date'].toString().contains('Today')).toList();
      case 'Last 7 Days':
        return _settlements.take(7).toList();
      default:
        return _settlements;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000)   return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  Future<void> _showCustomDatePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF6B35),
            onPrimary: Colors.white,
            surface: Color(0xFF1E1E1E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Custom range: ${picked.start.day} – ${picked.end.day} Jul 2026'),
        backgroundColor: const Color(0xFFFF6B35),
      ));
    }
  }

  void _exportReport() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const EarningsExportSheet(),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(isDark),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            PendingPayoutBanner(
              pendingAmount:  _pendingPayout,
              todayOrders:    _todayOrders,
              itemsSold:      _itemsSold,
              avgOrderValue:  _avgOrderValue,
            ),
            const SizedBox(height: 20),
            _buildLifetimeMetrics(isDark),
            const SizedBox(height: 20),
            _buildFilterBar(isDark),
            const SizedBox(height: 20),
            _buildSectionHeader(isDark),
            const SizedBox(height: 12),
            _buildSettlementList(isDark),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings & Settlements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Daily cash/UPI settlement @ 5:00 PM',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Iconsax.document_download,
                color: Color(0xFFFF6B35), size: 22),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ),
      ],
    );
  }

  // ── Lifetime Metrics Row ───────────────────────────────────────────────────
  Widget _buildLifetimeMetrics(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: EarningsMetricCard(
                isDark: isDark,
                icon: Iconsax.chart_1,
                iconColor: const Color(0xFFFF6B35),
                label: 'Lifetime Earned',
                value: _formatAmount(_lifetimeEarned),
                subValue: '₹${_lifetimeEarned.toStringAsFixed(0)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: EarningsMetricCard(
                isDark: isDark,
                icon: Iconsax.bag_tick_2,
                iconColor: Colors.blue,
                label: 'Total Orders',
                value: _lifetimeOrders.toString(),
                subValue: 'all time completed',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter Chip Bar ────────────────────────────────────────────────────────
  Widget _buildFilterBar(bool isDark) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _filters.length,
        itemBuilder: (_, i) {
          final f = _filters[i];
          final isSelected = _selectedFilter == f;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              if (f == 'Custom Date') {
                _showCustomDatePicker();
              } else {
                setState(() => _selectedFilter = f);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF6B35)
                    : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6B35)
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  if (f == 'Custom Date') ...[
                    Icon(Iconsax.calendar_1, size: 13,
                        color: isSelected ? Colors.white : Colors.grey.shade500),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    f,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Settlement Audit Log',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Text(
            '${_filteredSettlements.length} entries',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ── Settlement List ────────────────────────────────────────────────────────
  Widget _buildSettlementList(bool isDark) {
    final data = _filteredSettlements;
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Iconsax.document_text, size: 56, color: Colors.grey.shade500),
              const SizedBox(height: 12),
              Text(
                'No settlements found',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => SettlementCard(isDark: isDark, data: data[i]),
    );
  }
}
