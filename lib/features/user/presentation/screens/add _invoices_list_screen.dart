import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice/features/user/domain/enitites/item_enities.dart';
import 'package:invoice/features/user/presentation/viewmodel/invoice_view_model.dart';
import 'package:invoice/features/user/presentation/viewmodel/item_view_model.dart';
import 'package:invoice/features/user/presentation/viewmodel/user_session_provider.dart';
import 'package:invoice/core/theme/userWidgets.dart';
import 'package:invoice/core/theme/user_theme.dart';
import 'package:provider/provider.dart';

class AddInvoiceScreen extends StatefulWidget {
  const AddInvoiceScreen({super.key});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  ItemEntity? _selectedItem;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure items are loaded for the dropdown
      context.read<ItemViewModel>().loadItems();
    });
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    // Check for duplicate email among existing invoices
    final existing = context.read<InvoiceViewModel>().invoices;
    final duplicate = existing.any((inv) =>
        inv.email.toLowerCase() == value.trim().toLowerCase());
    if (duplicate) {
      return 'An invoice with this email already exists';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return 'Phone must be exactly 10 digits';
    }
    // Check duplicate phone
    final existing = context.read<InvoiceViewModel>().invoices;
    final duplicate = existing.any((inv) => inv.phone == value.trim());
    if (duplicate) {
      return 'An invoice with this phone already exists';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: UserAppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an item'),
          backgroundColor: UserAppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final vm = context.read<InvoiceViewModel>();
    final session = context.read<UserSessionProvider>();
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final error = await vm.addInvoice(
      customerName: _customerNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      date: dateStr,
      item: _selectedItem!.id!,
      createdBy: session.userId,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice created successfully!'),
          backgroundColor: UserAppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: UserAppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemVm = context.watch<ItemViewModel>();
    final invoiceVm = context.watch<InvoiceViewModel>();
    final session = context.read<UserSessionProvider>();

    // Only show items created by this user
    final myItems = itemVm.items
        .where((item) => item.createdBy == session.userId)
        .toList();

    return Scaffold(
      backgroundColor: UserAppColors.background,
      appBar: AppBar(
        backgroundColor: UserAppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add Invoice',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Item Selection ────────────────────────────────────────────
              UserWidgets.card(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(
                        icon: Icons.inventory_2_rounded, label: 'Item'),
                    const SizedBox(height: 16),
                    UserWidgets.fieldLabel('Select Item', required: true),
                    if (itemVm.state == ItemState.loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                              color: UserAppColors.primary),
                        ),
                      )
                    else if (myItems.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: UserAppColors.pendingBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: UserAppColors.pending.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.warning_amber_rounded,
                                color: UserAppColors.pending, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No items yet. Please add an item first.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: UserAppColors.pending,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: UserAppColors.border, width: 1.5),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ItemEntity>(
                            value: _selectedItem,
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            borderRadius: BorderRadius.circular(12),
                            hint: const Text(
                              'Select an item',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: UserAppColors.textHint,
                              ),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: UserAppColors.textSecondary),
                            items: myItems.map((item) {
                              return DropdownMenuItem<ItemEntity>(
                                value: item,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          color: UserAppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '₹${item.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: UserAppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedItem = val),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Customer Details ──────────────────────────────────────────
              UserWidgets.card(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(
                        icon: Icons.person_rounded, label: 'Customer Details'),
                    const SizedBox(height: 16),

                    // Customer Name
                    UserWidgets.fieldLabel('Customer Name', required: true),
                    TextFormField(
                      controller: _customerNameCtrl,
                      decoration: UserWidgets.inputDecoration(
                          hint: 'Full name'),
                      style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 14),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Customer name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    UserWidgets.fieldLabel('Email', required: true),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: UserWidgets.inputDecoration(
                        hint: 'customer@example.com',
                        prefixIcon: const Icon(Icons.email_outlined,
                            size: 18, color: UserAppColors.textHint),
                      ),
                      style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 14),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    UserWidgets.fieldLabel('Phone Number', required: true),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: UserWidgets.inputDecoration(
                        hint: '10-digit mobile number',
                        prefixIcon: const Icon(Icons.phone_outlined,
                            size: 18, color: UserAppColors.textHint),
                      ),
                      style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 14),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 16),

                    // Address
                    UserWidgets.fieldLabel('Address', required: true),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: UserWidgets.inputDecoration(
                        hint: 'Full address',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(top: 12, left: 12, right: 4),
                          child: Icon(Icons.location_on_outlined,
                              size: 18, color: UserAppColors.textHint),
                        ),
                      ),
                      style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 14),
                      maxLines: 3,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Address is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Date ─────────────────────────────────────────────────────
              UserWidgets.card(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(
                        icon: Icons.calendar_month_rounded,
                        label: 'Invoice Date'),
                    const SizedBox(height: 16),
                    UserWidgets.fieldLabel('Date', required: true),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: UserAppColors.border, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 18, color: UserAppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              '${_selectedDate.day.toString().padLeft(2, '0')} / '
                              '${_selectedDate.month.toString().padLeft(2, '0')} / '
                              '${_selectedDate.year}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: UserAppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Change',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: UserAppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              UserWidgets.primaryButton(
                label: 'Create Invoice',
                icon: Icons.receipt_long_rounded,
                loading: invoiceVm.isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: UserAppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: UserAppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: UserAppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
