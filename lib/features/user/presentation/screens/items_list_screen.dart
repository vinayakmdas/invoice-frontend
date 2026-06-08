import 'package:flutter/material.dart';
import 'package:invoice/core/theme/userWidgets.dart';
import 'package:invoice/core/theme/user_theme.dart';
import 'package:invoice/features/user/domain/enitites/item_enities.dart';
import 'package:invoice/features/user/presentation/viewmodel/item_view_model.dart';
import 'package:invoice/features/user/presentation/viewmodel/user_session_provider.dart';
import 'package:invoice/features/user/presentation/widget/usermoduleProvider.dart';
import 'package:provider/provider.dart';
import 'add_item_screen.dart';

class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({super.key});

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemViewModel>().loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ItemViewModel>();
    final session = context.read<UserSessionProvider>();

    // Filter only items created by this user
    final myItems = vm.items
        .where((item) => item.createdBy == session.userId)
        .toList();

    return Scaffold(
      backgroundColor: UserAppColors.background,
      body: RefreshIndicator(
        color: UserAppColors.primary,
        onRefresh: () => vm.loadItems(),
        child: CustomScrollView(
          slivers: [
            // Header section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Items',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: UserAppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${myItems.length} item${myItems.length == 1 ? '' : 's'} added',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: UserAppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (vm.state == ItemState.loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: UserAppColors.primary,
                  ),
                ),
              )
            else if (vm.state == ItemState.error)
              SliverFillRemaining(
                child: _ErrorView(
                  message: vm.errorMessage,
                  onRetry: () => vm.loadItems(),
                ),
              )
            else if (myItems.isEmpty)
              const SliverFillRemaining(child: _EmptyItemsView())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ItemCard(item: myItems[i]),
                    ),
                    childCount: myItems.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserModuleProviders(
              session: session,
              itemVm: vm,
              child: const AddItemScreen(),
            ),
          ),
        ).then((_) => vm.loadItems()),
        backgroundColor: UserAppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Item',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Item Card ────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final ItemEntity item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isGoods = item.itemType.toLowerCase() == 'goods';

    return UserWidgets.card(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: UserAppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: UserAppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: UserAppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '₹${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: UserAppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    UserWidgets.statusChip(
                      item.itemType,
                      color: isGoods
                          ? const Color(0xFF1565C0)
                          : const Color(0xFF6A1B9A),
                      bgColor: isGoods
                          ? const Color(0xFFE3F2FD)
                          : const Color(0xFFF3E5F5),
                    ),
                    const SizedBox(width: 8),
                    UserWidgets.statusChip(
                      item.taxable ? 'Taxable' : 'Non-Taxable',
                      color: item.taxable
                          ? UserAppColors.success
                          : UserAppColors.textSecondary,
                      bgColor: item.taxable
                          ? UserAppColors.successBg
                          : const Color(0xFFF5F5F5),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${isGoods ? 'HSN' : 'SAC'}: ${item.hsnSac}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: UserAppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty/Error states ────────────────────────────────────────────────────────

class _EmptyItemsView extends StatelessWidget {
  const _EmptyItemsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: UserAppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: UserAppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No items yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: UserAppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap the button below to add your first item',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: UserAppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: UserAppColors.danger,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: UserAppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: UserAppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
