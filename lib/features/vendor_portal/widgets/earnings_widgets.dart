// ── earnings_widgets.dart ─────────────────────────────────────────────────────
// Reusable widgets for the Vendor Earnings screen:
//   • PendingPayoutBanner  – top green gradient card
//   • EarningsMetricCard   – lifetime stat card (earned / orders)
//   • SettlementCard       – individual daily audit row
//   • BannerStat           – small stat inside the banner
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// ── Pending Payout Banner ─────────────────────────────────────────────────────

class PendingPayoutBanner extends StatelessWidget {
  final double pendingAmount;
  final int todayOrders;
  final int itemsSold;
  final double avgOrderValue;

  const PendingPayoutBanner({
    Key? key,
    required this.pendingAmount,
    required this.todayOrders,
    required this.itemsSold,
    required this.avgOrderValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopRow(),
          const SizedBox(height: 18),
          _buildAmount(),
          const SizedBox(height: 10),
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 12),
          _buildSubtitle(),
          const SizedBox(height: 14),
          _buildMiniStats(),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.wallet_2, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'PENDING PAYOUT (TODAY)',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.access_time_rounded, color: Colors.white, size: 12),
              SizedBox(width: 4),
              Text(
                'Clears @ 5:00 PM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmount() {
    return Text(
      '₹${pendingAmount.toStringAsFixed(2)}',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.0,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Row(
      children: [
        Icon(Iconsax.info_circle, size: 14, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'This amount will be settled in cash / UPI by our admin team during the daily 5 PM audit.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStats() {
    return Row(
      children: [
        BannerStat(label: "Today's Orders", value: '$todayOrders'),
        _vDivider(),
        BannerStat(label: 'Avg. Order Value', value: '₹${avgOrderValue.toStringAsFixed(0)}'),
        _vDivider(),
        BannerStat(label: 'Items Sold', value: '$itemsSold'),
      ],
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 30,
        color: Colors.white.withValues(alpha: 0.2),
        margin: const EdgeInsets.symmetric(horizontal: 12),
      );
}

// ── Banner Stat ───────────────────────────────────────────────────────────────

class BannerStat extends StatelessWidget {
  final String label;
  final String value;

  const BannerStat({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Lifetime Metric Card ──────────────────────────────────────────────────────

class EarningsMetricCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subValue;

  const EarningsMetricCard({
    Key? key,
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subValue,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settlement Card ───────────────────────────────────────────────────────────

class SettlementCard extends StatelessWidget {
  final bool isDark;
  final Map<String, dynamic> data;

  const SettlementCard({Key? key, required this.isDark, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPending = data['isPending'] as bool;
    final sales = data['sales'] as double;
    final orders = data['orders'] as int;
    final date = data['date'] as String;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPending
              ? Colors.amber.withValues(alpha: 0.4)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          width: isPending ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatusIcon(isPending),
          const SizedBox(width: 14),
          Expanded(child: _buildDetails(isDark, date, orders, sales)),
          const SizedBox(width: 10),
          _buildAmountBadge(isDark, isPending, sales),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(bool isPending) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isPending
            ? Colors.amber.withValues(alpha: 0.12)
            : Colors.green.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isPending ? Iconsax.clock : Iconsax.tick_circle,
        color: isPending ? Colors.amber : Colors.green,
        size: 22,
      ),
    );
  }

  Widget _buildDetails(bool isDark, String date, int orders, double sales) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Iconsax.bag_2, size: 11, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              '$orders orders',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Icon(Iconsax.money, size: 11, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              '₹${sales.toStringAsFixed(0)} total',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountBadge(bool isDark, bool isPending, double sales) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '₹${sales.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isPending
                ? Colors.amber.withValues(alpha: 0.12)
                : Colors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isPending ? '⏳ Due @ 5 PM' : '✅ Paid',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isPending ? Colors.amber.shade700 : Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}
