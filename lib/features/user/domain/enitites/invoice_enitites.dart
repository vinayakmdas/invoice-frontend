class UserInvoiceEntity {
  final int? id;
  final String customerName;
  final String email;
  final String phone;
  final String address;
  final String date;
  final int item;
  final int createdBy;

  const UserInvoiceEntity({
    this.id,
    required this.customerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.date,
    required this.item,
    required this.createdBy,
  });
}
