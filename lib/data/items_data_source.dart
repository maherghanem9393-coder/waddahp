import '../model/item.dart';

/// مصدر بيانات محاكى (في الذاكرة) مع تحكم كامل بحجم البيانات والتأخير الزمني
/// لتنفيذ السيناريوهات التجريبية الأربعة وتحليل الحساسية (50، 100، 500، 2000 عنصر).
class ItemsDataSource {
  static const List<String> _categories = [
    'أداء',
    'موارد',
    'صيانة',
    'اختبار',
    'معمارية',
  ];

  List<Item> _items = [];
  int _nextId = 1;

  /// عند تفعيلها يرمي المصدر استثناءً لاختبار حالة الخطأ (Error State).
  bool simulateError = false;

  /// مدة التأخير الافتراضية لمحاكاة العمليات غير المتزامنة (بالميلي ثانية).
  int networkDelayMs;

  ItemsDataSource({
    int initialCount = 100,
    this.networkDelayMs = 150,
  }) {
    seedData(initialCount);
  }

  /// إعادة توليد البيانات بحجم محدد (تُستخدم لتوحيد بيانات الاختبار وتحليل الحساسية).
  void seedData(int count) {
    _items = List.generate(
      count,
      (i) => Item(
        id: i + 1,
        title: 'عنصر تجريبي رقم ${i + 1}',
        category: _categories[i % _categories.length],
        priority: (i % 5) + 1,
        counter: 0,
        done: i % 3 == 0,
      ),
    );
    _nextId = count + 1;
  }

  Future<void> _delay([int? customDelayMs]) async {
    final ms = customDelayMs ?? networkDelayMs;
    if (ms > 0) {
      await Future.delayed(Duration(milliseconds: ms));
    }
    if (simulateError) {
      throw Exception('تعذر الاتصال بمصدر البيانات');
    }
  }

  /// السيناريو الأول وتحليل الحساسية: جلب قائمة بيانات بالحجم المحدد.
  Future<List<Item>> fetchItems({int? count, int? customDelayMs}) async {
    if (count != null && count != _items.length) {
      seedData(count);
    }
    await _delay(customDelayMs);
    return List.unmodifiable(_items);
  }

  /// إضافة عنصر جديد إلى القائمة.
  Future<Item> addItem(String title) async {
    await _delay();
    final item = Item(
      id: _nextId++,
      title: title,
      category: _categories[_nextId % _categories.length],
      priority: (_nextId % 5) + 1,
    );
    _items.insert(0, item);
    return item;
  }

  /// تبديل حالة الإنجاز لعنصر محدد.
  Future<Item> toggleItem(int id) async {
    await _delay(20);
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) throw Exception('العنصر غير موجود');
    _items[index] = _items[index].copyWith(done: !_items[index].done);
    return _items[index];
  }

  /// السيناريو الثاني: تحديث سريع متكرر لعنصر واحد (عداد داخل العنصر)
  /// بدون تأخير شبكة لعزل سرعة استجابة إدارة الحالة وإعادة بناء الـ Widgets.
  List<Item> incrementItemCounterSync(int id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) throw Exception('العنصر غير موجود');
    final current = _items[index];
    _items[index] = current.copyWith(counter: current.counter + 1);
    return List.unmodifiable(_items);
  }

  /// السيناريو الثالث: محاكاة طلب شبكة غير متزامن بفترة انتظار محددة.
  Future<List<Item>> simulateAsyncNetworkOperation({
    int delayMs = 400,
    int itemCount = 100,
  }) async {
    seedData(itemCount);
    await _delay(delayMs);
    return List.unmodifiable(_items);
  }

  /// السيناريو الرابع: معالجة بيانات متوسطة/كبيرة الحجم (تصفية وفرز 500 سجل).
  Future<List<Item>> filterAndSortDataset({
    int datasetSize = 500,
    String? query,
    String? category,
    bool sortByPriorityDesc = true,
    bool onlyCompleted = false,
  }) async {
    if (_items.length != datasetSize) {
      seedData(datasetSize);
    }
    await _delay(50);
    Iterable<Item> result = _items;

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim();
      result = result.where(
        (item) => item.title.contains(q) || item.category.contains(q),
      );
    }
    if (category != null && category.isNotEmpty && category != 'الكل') {
      result = result.where((item) => item.category == category);
    }
    if (onlyCompleted) {
      result = result.where((item) => item.done);
    }

    final list = result.toList();
    if (sortByPriorityDesc) {
      list.sort((a, b) {
        final cmp = b.priority.compareTo(a.priority);
        return cmp != 0 ? cmp : a.id.compareTo(b.id);
      });
    } else {
      list.sort((a, b) => a.id.compareTo(b.id));
    }
    return List.unmodifiable(list);
  }
}
