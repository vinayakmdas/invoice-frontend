import 'package:flutter/material.dart';
import 'package:invoice/core/theme/admin_theme.dart';
import 'package:invoice/features/admin/domain/entity/invoice_entity.dart';
import 'package:invoice/features/admin/presentation/provider/admin_provider.dart';
import 'package:invoice/features/admin/presentation/widget/sharedwidget.dart';
import 'package:provider/provider.dart';

// ── Invoices List Screen ──────────────────────────────────────────────────────

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<InvoiceProvider>();
      if (prov.state == LoadingState.idle) {
        prov.loadInvoices();
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
        onRefresh: () => context.read<InvoiceProvider>().loadInvoices(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                title: const Text(
                  'Invoices',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryDark, Color(0xFF5C6BC0)],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Consumer<InvoiceProvider>(
                      builder: (_, prov, __) => AppSearchBar(
                        hintText: 'Search by customer or invoice ID...',
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
                  Consumer<InvoiceProvider>(
                    builder: (_, prov, __) => FilterChipRow(
                      options: const [
                        'All',
                        'Draft',
                        'Sent',
                        'Paid',
                        'Overdue',
                      ],
                      selected: prov.statusFilter,
                      onSelected: prov.setStatusFilter,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            Consumer<InvoiceProvider>(
              builder: (_, prov, __) {
                if (prov.state == LoadingState.loading) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const InvoiceCardSkeleton(),
                      childCount: 4,
                    ),
                  );
                }

                if (prov.state == LoadingState.error) {
                  return SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.wifi_off_rounded,
                      title: 'Failed to load invoices',
                      subtitle: prov.error ?? 'Something went wrong',
                      onAction: prov.loadInvoices,
                      actionLabel: 'Retry',
                    ),
                  );
                }

                if (prov.invoices.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No invoices found',
                      subtitle: 'Invoices created by users will appear here',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => InvoiceCard(invoice: prov.invoices[i]),
                      childCount: prov.invoices.length,
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

// ── Invoice Card ──────────────────────────────────────────────────────────────

class InvoiceCard extends StatelessWidget {
  final InvoiceEntity invoice;

  const InvoiceCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                InvoiceDetailScreen(invoiceId: invoice.id, invoice: null),
          ),
        ),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    InvoiceStatusChip(status: invoice.status),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  invoice.customerName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 12,
                      color: AppTheme.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'By ${invoice.createdByUserName}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF0F4FF)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(invoice.createdAt),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${invoice.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
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

// ── Invoice Detail Screen ─────────────────────────────────────────────────────

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
    required invoice,
  });

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadInvoiceDetail(widget.invoiceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (_, prov, __) {
        if (prov.detailState == LoadingState.loading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Invoice Details')),
            body: const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        if (prov.detailState == LoadingState.error ||
            prov.selectedInvoice == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Invoice Details')),
            body: EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Failed to load invoice',
              subtitle: prov.error ?? 'Unknown error',
              onAction: () => prov.loadInvoiceDetail(widget.invoiceId),
              actionLabel: 'Retry',
            ),
          );
        }

        final inv = prov.selectedInvoice!;
        return _InvoiceDetailView(invoice: inv);
      },
    );
  }
}

class _InvoiceDetailView extends StatelessWidget {
  final InvoiceEntity invoice;

  const _InvoiceDetailView({required this.invoice});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.primary,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  InvoiceStatusChip(status: invoice.status),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryDark, Color(0xFF5C6BC0)],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: 60,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Total Amount Card ──────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.elevatedShadow,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${invoice.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _DateBadge(
                              label: 'Created',
                              date: _formatDate(invoice.createdAt),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 1,
                              height: 28,
                              color: Colors.white24,
                            ),
                            const SizedBox(width: 12),
                            _DateBadge(
                              label: 'Due',
                              date: _formatDate(invoice.dueDate),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Customer Info ──────────────────────────────────────────
                  _SectionCard(
                    title: 'Customer Information',
                    icon: Icons.person_rounded,
                    children: [
                      _DetailRow(label: 'Name', value: invoice.customerName),
                      _DetailRow(label: 'Email', value: invoice.customerEmail),
                      _DetailRow(label: 'Phone', value: invoice.customerPhone),
                      _DetailRow(
                        label: 'Address',
                        value: invoice.customerAddress,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Created By ─────────────────────────────────────────────
                  _SectionCard(
                    title: 'Created By',
                    icon: Icons.account_circle_outlined,
                    children: [
                      _DetailRow(
                        label: 'User',
                        value: invoice.createdByUserName,
                      ),
                      _DetailRow(
                        label: 'User ID',
                        value: invoice.createdByUserId,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Items ──────────────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: AppTheme.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.list_alt_rounded,
                                  size: 16,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Invoice Items',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Table header
                        Container(
                          color: AppTheme.background,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: const [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  'Description',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Qty',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Amount',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...invoice.items.asMap().entries.map((e) {
                          final i = e.key;
                          final item = e.value;
                          return Container(
                            color: i.isEven
                                ? Colors.white
                                : const Color(0xFFFAFCFF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    item.description,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '×${item.quantity}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '₹${item.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // ── Summary ────────────────────────────────────────
                        const Divider(height: 1, color: Color(0xFFF0F4FF)),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _SummaryRow(
                                label: 'Subtotal',
                                value:
                                    '₹${invoice.subtotal.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 6),
                              _SummaryRow(
                                label:
                                    'Tax (${invoice.taxRate.toStringAsFixed(0)}%)',
                                value:
                                    '₹${invoice.taxAmount.toStringAsFixed(2)}',
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(color: Color(0xFFF0F4FF)),
                              ),
                              _SummaryRow(
                                label: 'Total',
                                value:
                                    '₹${invoice.totalAmount.toStringAsFixed(2)}',
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (invoice.notes != null) ...[
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Notes',
                      icon: Icons.notes_rounded,
                      children: [
                        Text(
                          invoice.notes!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ── Read-only notice ───────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This is a read-only view. Only users can edit invoices.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final String label;
  final String date;

  const _DateBadge({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
        Text(
          date,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: AppTheme.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F4FF)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppTheme.textHint,
              ),
            ),
          ),
          const Text(
            ':  ',
            style: TextStyle(color: AppTheme.textHint, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isTotal ? 16 : 12,
            fontWeight: FontWeight.w700,
            color: isTotal ? AppTheme.primary : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
