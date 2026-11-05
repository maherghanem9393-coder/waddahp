part of 'items_bloc.dart';

/// أحداث نموذج BLoC (Events) تغطي جميع السيناريوهات الوظيفية والتجريبية.
sealed class ItemsEvent extends Equatable {
  const ItemsEvent();

  @override
  List<Object?> get props => [];
}

/// حدث جلب القائمة (السيناريو الأول وتحليل الحساسية).
class LoadItems extends ItemsEvent {
  final int? count;
  final int? customDelayMs;
  final Completer<void>? completer;

  const LoadItems({this.count, this.customDelayMs, this.completer});

  @override
  List<Object?> get props => [count, customDelayMs];
}

/// حدث إضافة عنصر جديد.
class AddItemRequested extends ItemsEvent {
  final String title;
  final Completer<void>? completer;

  const AddItemRequested(this.title, {this.completer});

  @override
  List<Object?> get props => [title];
}

/// حدث تبديل حالة العنصر.
class ToggleItemRequested extends ItemsEvent {
  final int id;
  final Completer<void>? completer;

  const ToggleItemRequested(this.id, {this.completer});

  @override
  List<Object?> get props => [id];
}

/// حدث التحديث المتكرر لعنصر واحد (السيناريو الثاني).
class IncrementItemCounterRequested extends ItemsEvent {
  final int id;
  final Completer<void>? completer;

  const IncrementItemCounterRequested(this.id, {this.completer});

  @override
  List<Object?> get props => [id];
}

/// حدث العملية غير المتزامنة المحاكية للشبكة (السيناريو الثالث).
class SimulateAsyncOperationRequested extends ItemsEvent {
  final int delayMs;
  final int itemCount;
  final Completer<void>? completer;

  const SimulateAsyncOperationRequested({
    this.delayMs = 400,
    this.itemCount = 100,
    this.completer,
  });

  @override
  List<Object?> get props => [delayMs, itemCount];
}

/// حدث تصفية وفرز البيانات متوسطة/كبيرة الحجم (السيناريو الرابع).
class FilterAndSortItemsRequested extends ItemsEvent {
  final int datasetSize;
  final String query;
  final String category;
  final bool sortByPriorityDesc;
  final bool onlyCompleted;
  final Completer<void>? completer;

  const FilterAndSortItemsRequested({
    this.datasetSize = 500,
    this.query = '',
    this.category = 'الكل',
    this.sortByPriorityDesc = true,
    this.onlyCompleted = false,
    this.completer,
  });

  @override
  List<Object?> get props => [
        datasetSize,
        query,
        category,
        sortByPriorityDesc,
        onlyCompleted,
      ];
}
