import '../model/item.dart';
import 'items_data_source.dart';

abstract class ItemsRepository {
  bool get simulateError;
  set simulateError(bool value);

  Future<List<Item>> getItems();
  Future<List<Item>> addItem(String title);
  Future<List<Item>> toggleItem(int id);
}

class ItemsRepositoryImpl implements ItemsRepository {
  final ItemsDataSource _source;
  ItemsRepositoryImpl(this._source);

  @override
  bool get simulateError => _source.simulateError;
  @override
  set simulateError(bool value) => _source.simulateError = value;

  @override
  Future<List<Item>> getItems() => _source.fetchItems();

  @override
  Future<List<Item>> addItem(String title) async {
    await _source.addItem(title);
    return _source.fetchItems();
  }

  @override
  Future<List<Item>> toggleItem(int id) async {
    await _source.toggleItem(id);
    return _source.fetchItems();
  }
}
