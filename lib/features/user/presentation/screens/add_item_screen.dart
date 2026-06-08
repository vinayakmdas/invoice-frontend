import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice/core/theme/userWidgets.dart';
import 'package:invoice/core/theme/user_theme.dart';

import 'package:invoice/features/user/presentation/viewmodel/item_view_model.dart';
import 'package:invoice/features/user/presentation/viewmodel/user_session_provider.dart';
import 'package:provider/provider.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _hsnSacCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  String _itemType = 'Goods';
  bool _taxable = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hsnSacCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  bool get _isGoods => _itemType == 'Goods';

  String? _validateHsnSac(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '${_isGoods ? 'HSN' : 'SAC'} code is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return '${_isGoods ? 'HSN' : 'SAC'} must be exactly 6 digits';
    }
    // Check for duplicates in existing items
    final existingItems = context.read<ItemViewModel>().items;
    final duplicate = existingItems.any(
      (item) => item.hsnSac == value.trim() && item.itemType == _itemType,
    );
    if (duplicate) {
      return '${_isGoods ? 'HSN' : 'SAC'} code already exists for this type';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<ItemViewModel>();
    final session = context.read<UserSessionProvider>();

    final error = await vm.addItem(
      name: _nameCtrl.text.trim(),
      itemType: _itemType,
      hsnSac: _hsnSacCtrl.text.trim(),
      taxable: _taxable,
      price: double.parse(_priceCtrl.text.trim()),
      createdBy: session.userId,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item added successfully!'),
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
    final vm = context.watch<ItemViewModel>();

    return Scaffold(
      backgroundColor: UserAppColors.background,
      appBar: AppBar(
        backgroundColor: UserAppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add Item',
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
              UserWidgets.card(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Name ───────────────────────────────────────────────
                    UserWidgets.fieldLabel('Name', required: true),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: UserWidgets.inputDecoration(
                        hint: 'Enter item name',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Item Type ──────────────────────────────────────────
                    UserWidgets.fieldLabel('Item Type', required: true),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: UserAppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: ['Goods', 'Service'].map((type) {
                          final selected = _itemType == type;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _itemType = type;
                                  _hsnSacCtrl.clear();
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.all(4),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? UserAppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  type,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: selected
                                        ? Colors.white
                                        : UserAppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── HSN / SAC (dynamic label) ──────────────────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Column(
                        key: ValueKey(_itemType),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UserWidgets.fieldLabel(
                            _isGoods ? 'HSN Code' : 'SAC Code',
                            required: true,
                          ),
                          TextFormField(
                            controller: _hsnSacCtrl,
                            decoration: UserWidgets.inputDecoration(
                              hint: _isGoods
                                  ? 'Enter 6-digit HSN'
                                  : 'Enter 6-digit SAC',
                            ),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            validator: _validateHsnSac,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isGoods
                                ? 'Harmonized System of Nomenclature – 6 digits'
                                : 'Services Accounting Code – 6 digits',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: UserAppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Taxable Toggle ─────────────────────────────────────
                    UserWidgets.fieldLabel('Tax Status'),
                    GestureDetector(
                      onTap: () => setState(() => _taxable = !_taxable),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: UserAppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 22,
                              width: 22,
                              decoration: BoxDecoration(
                                color: _taxable
                                    ? UserAppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _taxable
                                      ? UserAppColors.primary
                                      : UserAppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: _taxable
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _taxable ? 'Taxable' : 'Non-Taxable',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: _taxable
                                    ? UserAppColors.textPrimary
                                    : UserAppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _taxable
                                    ? UserAppColors.successBg
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _taxable ? 'Yes' : 'No',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: _taxable
                                      ? UserAppColors.success
                                      : UserAppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Price ──────────────────────────────────────────────
                    UserWidgets.fieldLabel('Price (₹)', required: true),
                    TextFormField(
                      controller: _priceCtrl,
                      decoration: UserWidgets.inputDecoration(
                        hint: '0.00',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            '₹',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: UserAppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Price is required';
                        }
                        final val = double.tryParse(v.trim());
                        if (val == null || val <= 0) {
                          return 'Enter a valid price greater than 0';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              UserWidgets.primaryButton(
                label: 'Save Item',
                icon: Icons.save_rounded,
                loading: vm.isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
