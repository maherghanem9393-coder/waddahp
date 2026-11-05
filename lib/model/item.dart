import 'package:equatable/equatable.dart';

/// طبقة Model: تمثيل عنصر البيانات الأساسي في التطبيق التجريبي.
/// تدعم السيناريوهات الأربعة وتحليل الحساسية (جلب، تحديث متكرر، عمليات غير متزامنة، فرز وتصفية).
class Item extends Equatable {
  final int id;
  final String title;
  final String category;
  final int priority;
  final int counter;
  final bool done;

  const Item({
    required this.id,
    required this.title,
    this.category = 'عام',
    this.priority = 1,
    this.counter = 0,
    this.done = false,
  });

  Item copyWith({
    String? title,
    String? category,
    int? priority,
    int? counter,
    bool? done,
  }) =>
      Item(
        id: id,
        title: title ?? this.title,
        category: category ?? this.category,
        priority: priority ?? this.priority,
        counter: counter ?? this.counter,
        done: done ?? this.done,
      );

  @override
  List<Object?> get props => [id, title, category, priority, counter, done];
}
