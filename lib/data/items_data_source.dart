import '../model/item.dart';

/// مصدر بيانات محاكى (في الذاكرة) مع تأخير لمحاكاة العمليات غير المتزامنة.
class ItemsDataSource {
  final List<Item> _items = List.generate(
    50,
    (i) => Item(id: i + 1, title: 'عنصر رقم ${i + 1}'),
  );
  int _nextId = 51;

  /// عند تفعيلها يرمي المصدر استثناءً لاختبار حالة الخطأ.
  bool simulateError = false;

  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (simulateError) {
      throw Exception('تعذر الاتصال بمصدر البيانات');
    }
  }

  Future<List<Item>> fetchItems() async {
    await _delay();
    return List.unmodifiable(_items);
  }

  Future<Item> addItem(String title) async {
    await _delay();
    final item = Item(id: _nextId++, title: title);
    _items.insert(0, item);
    return item;
  }

  Future<Item> toggleItem(int id) async {
    await _delay();
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) throw Exception('العنصر غير موجود');
    _items[index] = _items[index].copyWith(done: !_items[index].done);
    return _items[index];
  }
}
