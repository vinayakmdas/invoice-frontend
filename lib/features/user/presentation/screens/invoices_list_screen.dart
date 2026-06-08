import 'package:flutter/material.dart';
import 'package:invoice/core/theme/userWidgets.dart';
import 'package:invoice/core/theme/user_theme.dart';
import 'package:invoice/features/user/domain/enitites/invoice_enitites.dart';
import 'package:invoice/features/user/presentation/screens/add%20_invoices_list_screen.dart';
import 'package:invoice/features/user/presentation/viewmodel/invoice_view_model.dart';
import 'package:invoice/features/user/presentation/viewmodel/item_view_model.dart';
import 'package:invoice/features/user/presentation/viewmodel/user_session_provider.dart';
import 'package:invoice/features/user/presentation/widget/usermoduleProvider.dart';
import 'package:provider/provider.dart';

class InvoicesListScreen extends StatefulWidget {
  const InvoicesListScreen({super.key});

  @override
  State<InvoicesListScreen> createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends State<InvoicesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<UserSessionProvider>();
      context.read<InvoiceViewModel>().loadInvoices(session.userId);
    });
  }

  Future<void> _confirmDelete(
    BuildContext context,
    UserInvoiceEntity invoice,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Invoice',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Delete invoice for ${invoice.customerName}? This action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: UserAppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: UserAppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: UserAppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final error = await context.read<InvoiceViewModel>().deleteInvoice(
        invoice.id!,
      );
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: UserAppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice deleted'),
            backgroundColor: UserAppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InvoiceViewModel>();
    final itemVm = context.watch<ItemViewModel>();
    final session = context.read<UserSessionProvider>();

    return Scaffold(
      backgroundColor: UserAppColors.background,
      body: RefreshIndicator(
        color: UserAppColors.primary,
        onRefresh: () => vm.loadInvoices(session.userId),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Invoices',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: UserAppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vm.invoices.length} invoice${vm.invoices.length == 1 ? '' : 's'}',
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

            if (vm.state == InvoiceState.loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: UserAppColors.primary,
                  ),
                ),
              )
            else if (vm.state == InvoiceState.error)
              SliverFillRemaining(
                child: _ErrorView(
                  message: vm.errorMessage,
                  onRetry: () => vm.loadInvoices(session.userId),
                ),
              )
            else if (vm.invoices.isEmpty)
              const SliverFillRemaining(child: _EmptyInvoicesView())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final inv = vm.invoices[i];
                    // Find the item name for this invoice
                    final itemEntity = itemVm.items.cast<dynamic?>().firstWhere(
                      (it) => it?.id == inv.item,
                      orElse: () => null,
                    );
                    final itemName = itemEntity?.name ?? 'Item #${inv.item}';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _InvoiceCard(
                        invoice: inv,
                        itemName: itemName,
                        onDelete: () => _confirmDelete(context, inv),
                      ),
                    );
                  }, childCount: vm.invoices.length),
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
              invoiceVm: vm,
              itemVm: itemVm,
              child: const AddInvoiceScreen(),
            ),
          ),
        ).then((_) => vm.loadInvoices(session.userId)),
        backgroundColor: UserAppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Invoice',
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

// ── Invoice Card ──────────────────────────────────────────────────────────────

class _InvoiceCard extends StatelessWidget {
  final UserInvoiceEntity invoice;
  final String itemName;
  final VoidCallback onDelete;

  const _InvoiceCard({
    required this.invoice,
    required this.itemName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return UserWidgets.card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: UserAppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: UserAppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.customerName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: UserAppColors.textPrimary,
                      ),
                    ),
                    Text(
                      invoice.email,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: UserAppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: UserAppColors.danger,
                  size: 20,
                ),
                tooltip: 'Delete Invoice',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFEDF0F7), height: 1),
          ),
          // Details grid
          Row(
            children: [
              _DetailCell(
                icon: Icons.inventory_2_outlined,
                label: 'Item',
                value: itemName,
              ),
              _DetailCell(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: invoice.phone,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _DetailCell(
                icon: Icons.calendar_today_outlined,
                label: 'Date',
                value: invoice.date,
              ),
              _DetailCell(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: invoice.address,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: UserAppColors.textHint),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: UserAppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: UserAppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty / Error ─────────────────────────────────────────────────────────────

class _EmptyInvoicesView extends StatelessWidget {
  const _EmptyInvoicesView();

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
              Icons.receipt_long_outlined,
              size: 40,
              color: UserAppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No invoices yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: UserAppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Create your first invoice by tapping the button below',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: UserAppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
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
