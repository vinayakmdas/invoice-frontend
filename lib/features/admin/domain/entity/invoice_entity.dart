class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;

  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class InvoiceEntity {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final String createdByUserId;
  final String createdByUserName;
  final DateTime createdAt;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final double taxRate;
  final String status;
  final String? notes;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    required this.createdByUserId,
    required this.createdByUserName,
    required this.createdAt,
    required this.dueDate,
    required this.items,
    required this.taxRate,
    required this.status,
    this.notes,
    required DateTime invoiceDate,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);

  double get taxAmount => subtotal * (taxRate / 100);

  double get totalAmount => subtotal + taxAmount;
}
