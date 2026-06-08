import 'package:invoice/features/user/domain/enitites/invoice_enitites.dart';

class InvoiceDataModel extends UserInvoiceEntity {
  const InvoiceDataModel({
    super.id,
    required super.customerName,
    required super.email,
    required super.phone,
    required super.address,
    required super.date,
    required super.item,
    required super.createdBy,
  });

  factory InvoiceDataModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDataModel(
      id: json['id'],
      customerName: json['customer_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      date: json['date'] ?? '',
      item: json['item'] ?? 0,
      createdBy: json['created_by'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'customer_name': customerName,
    'email': email,
    'phone': phone,
    'address': address,
    'date': date,
    'item': item,
    'created_by': createdBy,
  };
}
