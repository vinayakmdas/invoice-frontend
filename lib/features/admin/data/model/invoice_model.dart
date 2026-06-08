import 'package:invoice/features/admin/data/model/invoice_item_model.dart';
import 'package:invoice/features/admin/domain/entity/invoice_entity.dart';

class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.customerName,
    required super.customerEmail,
    required super.customerPhone,
    required super.customerAddress,
    required super.createdByUserId,
    required super.createdByUserName,
    required super.createdAt,
    required super.dueDate,
    required super.items,
    required super.taxRate,
    required super.status,
    super.notes,
    required super.invoiceDate,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final List<InvoiceItem> itemsList = [];
    if (json['items'] != null && json['items'] is List) {
      itemsList.addAll(
        (json['items'] as List)
            .map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (json['item'] != null) {
      itemsList.add(
        InvoiceItem(
          description: "Item #${json['item']}",
          quantity: 1,
          unitPrice: 250.0,
        ),
      );
    }

    return InvoiceModel(
      invoiceDate: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      id: json['id']?.toString() ?? '',
      invoiceNumber:
          json['invoice_number'] ?? 'INV-2026-${json['id'] ?? '001'}',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['email'] ?? json['customer_email'] ?? '',
      customerPhone: json['phone'] ?? json['customer_phone'] ?? '',
      customerAddress: json['address'] ?? json['customer_address'] ?? '',
      createdByUserId:
          (json['created_by'] ?? json['created_by_user_id'])?.toString() ?? '',
      createdByUserName:
          json['created_by_name'] ??
          json['created_by_user_name'] ??
          'User #${json['created_by'] ?? ''}',
      createdAt:
          DateTime.tryParse(json['date'] ?? json['created_at'] ?? '') ??
          DateTime.now(),
      dueDate:
          DateTime.tryParse(json['due_date'] ?? '') ??
          (DateTime.tryParse(
                json['date'] ?? '',
              )?.add(const Duration(days: 14)) ??
              DateTime.now()),
      items: itemsList,
      taxRate: (json['tax_rate'] ?? 18.0).toDouble(),
      status: json['status'] ?? 'paid',
      notes: json['notes'],
    );
  }
}
