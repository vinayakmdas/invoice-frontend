import 'package:invoice/features/admin/domain/entity/invoice_entity.dart';

class InvoiceItemModel extends InvoiceItem {
  const InvoiceItemModel({
    required super.description,
    required super.quantity,
    required super.unitPrice,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      description: json['description'] ?? '',
      quantity: (json['quantity'] ?? 1).toInt(),
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'description': description,
    'quantity': quantity,
    'unit_price': unitPrice,
  };
}
