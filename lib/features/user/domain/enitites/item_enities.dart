class ItemEntity {
  final int? id;
  final String name;
  final String itemType; // "Goods" or "Service"
  final String hsnSac;
  final bool taxable;
  final double price;
  final int createdBy;

  const ItemEntity({
    this.id,
    required this.name,
    required this.itemType,
    required this.hsnSac,
    required this.taxable,
    required this.price,
    required this.createdBy,
  });
}
