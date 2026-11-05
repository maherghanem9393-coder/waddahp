import 'dart:async';
import 'items_view_state.dart';

export 'bloc/bloc_items_view_model.dart';
export 'redux/redux_items_view_model.dart';

/// نوع آلية إدارة الحالة المستخدمة في التجربة (المتغير المستقل في الدراسة).
enum ArchitectureMode {
  bloc('MVVM+BLoC'),
  redux('MVVM+Redux');

  final String label;
  const ArchitectureMode(this.label);
}

/// الواجهة الموحدة لطبقة ViewModel ضمن نمط MVVM (الفصل الثالث - القسم 3.6).
/// تعزل طبقة View عن تفاصيل التنفيذ الداخلي لـ BLoC أو Redux.
abstract class ItemsViewModel {
  ArchitectureMode get mode;
  ItemsViewState get currentState;
  Stream<ItemsViewState> get stateStream;

  bool get simulateError;
  void setSimulateError(bool value);

  int get networkDelayMs;
  void setNetworkDelayMs(int value);

  void resetData(int count);

  /// السيناريو الأول وتحليل الحساسية: جلب قائمة بيانات (50، 100، 500، 2000 عنصر).
  Future<void> load({int? count, int? customDelayMs});

  /// إضافة عنصر جديد مع التحقق من صحة المدخلات.
  Future<void> add(String title);

  /// تبديل حالة عنصر.
  Future<void> toggle(int id);

  /// السيناريو الثاني: التحديثات المتكررة السريعة لحالة عنصر واحد.
  Future<void> rapidUpdateItem(int id, {int iterations = 50});

  /// السيناريو الثالث: عملية غير متزامنة تحاكي طلب شبكة بفترة انتظار محددة.
  Future<void> runAsyncOperation({int delayMs = 400, int itemCount = 100});

  /// السيناريو الرابع: معالجة بيانات متوسطة الحجم (تصفية وفرز 500 سجل).
  Future<void> filterAndSort({
    int datasetSize = 500,
    String? query,
    String? category,
    bool? sortByPriorityDesc,
    bool? onlyCompleted,
  });

  Future<void> dispose();
}
