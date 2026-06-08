import 'package:flutter/material.dart';
import 'package:invoice/core/theme/admin_theme.dart';
import 'package:invoice/features/admin/domain/entity/dashboard_entity.dart';
import 'package:invoice/features/admin/presentation/provider/admin_provider.dart';
import 'package:invoice/features/admin/presentation/widget/sharedwidget.dart';
import 'package:provider/provider.dart';

class DashboardSummaryWidget extends StatefulWidget {
  const DashboardSummaryWidget({super.key});

  @override
  State<DashboardSummaryWidget> createState() => _DashboardSummaryWidgetState();
}

class _DashboardSummaryWidgetState extends State<DashboardSummaryWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (_, prov, __) {
        if (prov.state == LoadingState.loading) {
          return _buildSkeletons();
        }
        if (prov.state == LoadingState.error || prov.stats == null) {
          return const SizedBox.shrink();
        }
        return _buildStats(prov.stats!);
      },
    );
  }

  Widget _buildSkeletons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
        children: List.generate(
          4,
          (_) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow,
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 36, height: 36, radius: 10),
                  SizedBox(height: 10),
                  SkeletonLoader(width: 60, height: 22),
                  SizedBox(height: 4),
                  SkeletonLoader(width: 90, height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(DashboardStats stats) {
    final cards = [
      _StatCard(
        title: 'Total Users',
        value: stats.totalUsers.toString(),
        icon: Icons.people_rounded,
        color: AppTheme.primary,
        bgColor: const Color(0xFFE8EEF9),
      ),
      _StatCard(
        title: 'Pending',
        value: stats.pendingApprovals.toString(),
        icon: Icons.schedule_rounded,
        color: AppTheme.pending,
        bgColor: AppTheme.pendingBg,
        badge: stats.pendingApprovals > 0,
      ),
      _StatCard(
        title: 'Total Invoices',
        value: stats.totalInvoices.toString(),
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF5C6BC0),
        bgColor: const Color(0xFFEDE7F6),
      ),
      _StatCard(
        title: 'Revenue',
        value: '₹${_formatAmount(stats.totalRevenue)}',
        icon: Icons.currency_rupee_rounded,
        color: AppTheme.approved,
        bgColor: AppTheme.approvedBg,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
        children: cards.map((card) => _StatCardWidget(card: card)).toList(),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool badge;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.badge = false,
  });
}

class _StatCardWidget extends StatelessWidget {
  final _StatCard card;

  const _StatCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: card.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(card.icon, color: card.color, size: 18),
              ),
              if (card.badge) ...[
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.pending,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.pending.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          Text(
            card.value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: card.color,
            ),
          ),
          Text(
            card.title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
