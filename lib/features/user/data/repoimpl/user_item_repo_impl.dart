import 'package:invoice/features/user/data/model/item_data_model.dart';
import 'package:invoice/features/user/domain/enitites/item_enities.dart';
import 'package:invoice/features/user/domain/repo/user_item_repo.dart';
import '../datasources/user_api_datasource.dart';

class UserItemRepositoryImpl implements UserItemRepository {
  final UserApiDatasource _datasource;
  UserItemRepositoryImpl(this._datasource);

  @override
  Future<List<ItemEntity>> getItems() => _datasource.fetchItems();

  @override
  Future<ItemEntity> addItem(ItemEntity item) {
    final model = ItemDataModel(
      name: item.name,
      itemType: item.itemType,
      hsnSac: item.hsnSac,
      taxable: item.taxable,
      price: item.price,
      createdBy: item.createdBy,
    );
    return _datasource.createItem(model);
  }
}
