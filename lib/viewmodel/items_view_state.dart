import 'package:equatable/equatable.dart';
import '../model/item.dart';

/// حالة العرض الموحدة (Unified View State) التي تستهلكها طبقة View
/// لضمان عدم اعتماد واجهة المستخدم على تفاصيل تنفيذ BLoC أو Redux.
enum ItemsStatus { initial, loading, success, failure }

class ItemsViewState extends Equatable {
  final ItemsStatus status;
  final List<Item> items;
  final String? errorMessage;
  final String searchQuery;
  final String selectedCategory;
  final bool sortByPriorityDesc;
  final bool onlyCompleted;
  final double lastOperationTimeMs;

  const ItemsViewState({
    this.status = ItemsStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategory = 'الكل',
    this.sortByPriorityDesc = true,
    this.onlyCompleted = false,
    this.lastOperationTimeMs = 0.0,
  });

  ItemsViewState copyWith({
    ItemsStatus? status,
    List<Item>? items,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
    bool? sortByPriorityDesc,
    bool? onlyCompleted,
    double? lastOperationTimeMs,
  }) =>
      ItemsViewState(
        status: status ?? this.status,
        items: items ?? this.items,
        errorMessage: errorMessage,
        searchQuery: searchQuery ?? this.searchQuery,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        sortByPriorityDesc: sortByPriorityDesc ?? this.sortByPriorityDesc,
        onlyCompleted: onlyCompleted ?? this.onlyCompleted,
        lastOperationTimeMs: lastOperationTimeMs ?? this.lastOperationTimeMs,
      );

  @override
  List<Object?> get props => [
        status,
        items,
        errorMessage,
        searchQuery,
        selectedCategory,
        sortByPriorityDesc,
        onlyCompleted,
        lastOperationTimeMs,
      ];
}
