import '../model/item.dart';
import 'items_data_source.dart';

/// واجهة المستودع (Repository Pattern) لفصل طبقة البيانات عن طبقة منطق التطبيق.
abstract class ItemsRepository {
  bool get simulateError;
  set simulateError(bool value);

  int get networkDelayMs;
  set networkDelayMs(int value);

  void resetDataset(int count);

  Future<List<Item>> getItems({int? count, int? customDelayMs});
  Future<List<Item>> addItem(String title);
  Future<List<Item>> toggleItem(int id);
  List<Item> incrementCounterSync(int id);
  Future<List<Item>> runAsyncNetworkOperation({int delayMs, int itemCount});
  Future<List<Item>> processMediumDataset({
    int datasetSize = 500,
    String? query,
    String? category,
    bool sortByPriorityDesc = true,
    bool onlyCompleted = false,
  });
}

class ItemsRepositoryImpl implements ItemsRepository {
  final ItemsDataSource _source;
  ItemsRepositoryImpl(this._source);

  @override
  bool get simulateError => _source.simulateError;

  @override
  set simulateError(bool value) => _source.simulateError = value;

  @override
  int get networkDelayMs => _source.networkDelayMs;

  @override
  set networkDelayMs(int value) => _source.networkDelayMs = value;

  @override
  void resetDataset(int count) => _source.seedData(count);

  @override
  Future<List<Item>> getItems({int? count, int? customDelayMs}) =>
      _source.fetchItems(count: count, customDelayMs: customDelayMs);

  @override
  Future<List<Item>> addItem(String title) async {
    await _source.addItem(title);
    return _source.fetchItems(customDelayMs: 0);
  }

  @override
  Future<List<Item>> toggleItem(int id) async {
    await _source.toggleItem(id);
    return _source.fetchItems(customDelayMs: 0);
  }

  @override
  List<Item> incrementCounterSync(int id) =>
      _source.incrementItemCounterSync(id);

  @override
  Future<List<Item>> runAsyncNetworkOperation({
    int delayMs = 400,
    int itemCount = 100,
  }) =>
      _source.simulateAsyncNetworkOperation(
        delayMs: delayMs,
        itemCount: itemCount,
      );

  @override
  Future<List<Item>> processMediumDataset({
    int datasetSize = 500,
    String? query,
    String? category,
    bool sortByPriorityDesc = true,
    bool onlyCompleted = false,
  }) =>
      _source.filterAndSortDataset(
        datasetSize: datasetSize,
        query: query,
        category: category,
        sortByPriorityDesc: sortByPriorityDesc,
        onlyCompleted: onlyCompleted,
      );
}
