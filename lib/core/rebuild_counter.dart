/// عدّاد قياس عدد مرات إعادة بناء الـ Widgets (Widget Rebuild Count)
/// أحد المؤشرات السبعة الأساسية المعتمدة في الفصل الثالث من الأطروحة.
class RebuildCounter {
  static final Map<String, int> _counts = {};

  static int increment(String key) => _counts[key] = (_counts[key] ?? 0) + 1;

  static int of(String key) => _counts[key] ?? 0;

  static Map<String, int> get snapshot => Map.unmodifiable(_counts);

  static void reset([String? key]) {
    if (key != null) {
      _counts.remove(key);
    } else {
      _counts.clear();
    }
  }
}
