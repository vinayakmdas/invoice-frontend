import 'package:invoice/features/user/domain/enitites/item_enities.dart';

class ItemDataModel extends ItemEntity {
  const ItemDataModel({
    super.id,
    required super.name,
    required super.itemType,
    required super.hsnSac,
    required super.taxable,
    required super.price,
    required super.createdBy,
  });

  factory ItemDataModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedBy = json['created_by'];
    final createdBy = rawCreatedBy is int
        ? rawCreatedBy
        : rawCreatedBy is Map
        ? (rawCreatedBy['id'] as int? ?? 0)
        : int.tryParse(rawCreatedBy.toString()) ?? 0;

    return ItemDataModel(
      id: json['id'] as int?,
      name: json['name'] ?? '',
      itemType: json['item_type'] ?? '',
      hsnSac: json['hsn_sac'] ?? '',
      taxable: json['taxable'] ?? false,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      createdBy: createdBy,
    );
  }

  // ← this was missing
  Map<String, dynamic> toJson() => {
    'name': name,
    'item_type': itemType,
    'hsn_sac': hsnSac,
    'taxable': taxable,
    'price': price.toString(),
    'created_by': createdBy,
  };
}
