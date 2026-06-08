import 'package:flutter/material.dart';
import 'package:invoice/features/user/domain/enitites/item_enities.dart';
import 'package:invoice/features/user/domain/repo/user_item_repo.dart';

enum ItemState { idle, loading, success, error }

class ItemViewModel extends ChangeNotifier {
  final UserItemRepository _repository;
  ItemViewModel(this._repository);

  List<ItemEntity> _items = [];
  List<ItemEntity> get items => List.unmodifiable(_items);

  ItemState _state = ItemState.idle;
  ItemState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<void> loadItems() async {
    _state = ItemState.loading;
    notifyListeners();
    try {
      _items = await _repository.getItems();
      _state = ItemState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ItemState.error;
    }
    notifyListeners();
  }

  /// Returns null on success, error string on failure.
  Future<String?> addItem({
    required String name,
    required String itemType,
    required String hsnSac,
    required bool taxable,
    required double price,
    required int createdBy,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final newItem = await _repository.addItem(
        ItemEntity(
          name: name,
          itemType: itemType,
          hsnSac: hsnSac,
          taxable: taxable,
          price: price,
          createdBy: createdBy,
        ),
      );
      _items = [..._items, newItem];
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
