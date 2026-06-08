import 'package:invoice/features/user/domain/enitites/item_enities.dart';

abstract class UserItemRepository {
  Future<List<ItemEntity>> getItems();
  Future<ItemEntity> addItem(ItemEntity item);
}
