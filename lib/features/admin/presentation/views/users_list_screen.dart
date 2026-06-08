import 'package:flutter/material.dart';
import 'package:invoice/core/theme/admin_theme.dart';
import 'package:invoice/features/admin/domain/entity/user_entity.dart';
import 'package:invoice/features/admin/presentation/provider/admin_provider.dart';
import 'package:invoice/features/admin/presentation/views/dashboard_summery_screen.dart';
import 'package:invoice/features/admin/presentation/widget/sharedwidget.dart';
import 'package:provider/provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<UserProvider>();
      if (prov.state == LoadingState.idle) {
        prov.loadUsers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => context.read<UserProvider>().loadUsers(),
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                title: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Management',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryDark, AppTheme.primaryLight],
                    ),
                  ),
                ),
              ),
              actions: [
                Consumer<UserProvider>(
                  builder: (_, prov, __) => prov.pendingCount > 0
                      ? Stack(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () => context
                                  .read<UserProvider>()
                                  .setFilter('Pending'),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: AppTheme.pending,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  prov.pendingCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),

            // ── Dashboard Summary ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Overview',
                    subtitle: 'System summary at a glance',
                  ),
                  const DashboardSummaryWidget(),
                  const SizedBox(height: 16),

                  // ── Search ─────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Consumer<UserProvider>(
                      builder: (_, prov, __) => AppSearchBar(
                        hintText: 'Search users by name or email...',
                        controller: _searchController,
                        onChanged: prov.setSearch,
                        onClear: () {
                          _searchController.clear();
                          prov.setSearch('');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Filter Chips ───────────────────────────────────────────
                  Consumer<UserProvider>(
                    builder: (_, prov, __) => FilterChipRow(
                      options: const ['All', 'Pending', 'Approved', 'Rejected'],
                      selected: prov.filterStatus,
                      onSelected: prov.setFilter,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── List Header ────────────────────────────────────────────
                  Consumer<UserProvider>(
                    builder: (_, prov, __) {
                      if (prov.state == LoadingState.loaded) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                          child: Text(
                            '${prov.users.length} user${prov.users.length != 1 ? 's' : ''} found',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

            // ── User List ────────────────────────────────────────────────────
            Consumer<UserProvider>(
              builder: (_, prov, __) {
                if (prov.state == LoadingState.loading) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const UserCardSkeleton(),
                      childCount: 4,
                    ),
                  );
                }

                if (prov.state == LoadingState.error) {
                  return SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.wifi_off_rounded,
                      title: 'Failed to load users',
                      subtitle: prov.error ?? 'Something went wrong',
                      onAction: prov.loadUsers,
                      actionLabel: 'Retry',
                    ),
                  );
                }

                if (prov.users.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'No users found',
                      subtitle: 'Try adjusting your search or filter settings',
                    ),
                  );
                }

                // After (fixed) — card rebuilds whenever provider notifies
                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Consumer<UserProvider>(
                        builder: (context, provider, _) {
                          // Guard: index may be out of range if list shrinks mid-animation
                          if (i >= provider.users.length) {
                            return const SizedBox.shrink();
                          }
                          return UserCard(user: provider.users[i]);
                        },
                      ),
                      childCount: prov.users.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── User Card ─────────────────────────────────────────────────────────────────

class UserCard extends StatefulWidget {
  final UserEntity user;

  const UserCard({super.key, required this.user});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard>
    with SingleTickerProviderStateMixin {
  bool _isActing = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleApprove() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Approve User',
      message:
          'Are you sure you want to approve ${widget.user.name}? They will gain full system access.',
      confirmLabel: 'Approve',
    );
    if (confirm != true || !mounted) return;

    setState(() => _isActing = true);
    // After (fixed)
    final ok = await context.read<UserProvider>().approveUser(widget.user.id);
    if (mounted) {
      setState(() => _isActing = false);
      // Explicitly coerce to bool — null/void return treated as failure
      _showSnack(
        ok == true ? 'User approved successfully' : 'Failed to approve user',
        ok == true,
      );
    }
  }

  Future<void> _handleReject() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Reject User',
      message: 'Are you sure you want to reject ${widget.user.name}?',
      confirmLabel: 'Reject',
      isDangerous: true,
    );
    if (confirm != true || !mounted) return;

    setState(() => _isActing = true);
    final ok = await context.read<UserProvider>().rejectUser(widget.user.id);
    if (mounted) {
      setState(() => _isActing = false);
      _showSnack(ok ? 'User rejected' : 'Failed to reject user', ok);
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete User',
      message:
          'This will permanently delete ${widget.user.name}. This action cannot be undone.',
      confirmLabel: 'Delete',
      isDangerous: true,
    );
    if (confirm != true || !mounted) return;

    setState(() => _isActing = true);
    final ok = await context.read<UserProvider>().deleteUser(widget.user.id);
    setState(() => _isActing = false);

    if (mounted && !ok) {
      _showSnack('Failed to delete user', false);
    }
  }

  void _showSnack(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              msg,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
          ],
        ),
        backgroundColor: success ? AppTheme.approved : AppTheme.rejected,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTapDown: (_) => _animController.forward(),
        onTapUp: (_) => _animController.reverse(),
        onTapCancel: () => _animController.reverse(),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Row ─────────────────────────────────────────────
                  Row(
                    children: [
                      UserAvatar(name: widget.user.name, size: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.user.name,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (widget.user.companyName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.user.companyName!,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      StatusChip(status: widget.user.status),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF0F4FF)),
                  const SizedBox(height: 12),

                  // ── Contact Info ───────────────────────────────────────────
                  _InfoRow(icon: Icons.email_outlined, text: widget.user.email),
                  const SizedBox(height: 6),
                  _InfoRow(icon: Icons.phone_outlined, text: widget.user.phone),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: 'Joined ${_formatDate(widget.user.createdAt)}',
                  ),

                  // ── Action Buttons ─────────────────────────────────────────
                  if (_isActing) ...[
                    const SizedBox(height: 14),
                    const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (widget.user.status != UserStatus.approved)
                          Expanded(
                            child: _ActionButton(
                              label: 'Approve',
                              icon: Icons.check_rounded,
                              color: AppTheme.approved,
                              bgColor: AppTheme.approvedBg,
                              onTap: _handleApprove,
                            ),
                          ),
                        if (widget.user.status != UserStatus.approved)
                          const SizedBox(width: 8),
                        if (widget.user.status != UserStatus.rejected)
                          Expanded(
                            child: _ActionButton(
                              label: 'Reject',
                              icon: Icons.close_rounded,
                              color: AppTheme.pending,
                              bgColor: AppTheme.pendingBg,
                              onTap: _handleReject,
                            ),
                          ),
                        if (widget.user.status != UserStatus.rejected)
                          const SizedBox(width: 8),
                        _ActionButton(
                          label: 'Delete',
                          icon: Icons.delete_outline_rounded,
                          color: AppTheme.rejected,
                          bgColor: AppTheme.rejectedBg,
                          onTap: _handleDelete,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppTheme.textHint),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
