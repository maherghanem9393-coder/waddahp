/// عدّاد بسيط لإعادة بناء الـ Widgets (أحد مؤشرات الدراسة).
class RebuildCounter {
  static final Map<String, int> _counts = {};

  static int increment(String key) => _counts[key] = (_counts[key] ?? 0) + 1;

  static int of(String key) => _counts[key] ?? 0;

  static void reset() => _counts.clear();
}
