part of 'items_bloc.dart';

/// حالة نموذج BLoC (State).
class ItemsState extends Equatable {
  final ItemsStatus status;
  final List<Item> items;
  final String? errorMessage;
  final String searchQuery;
  final String selectedCategory;
  final bool sortByPriorityDesc;
  final bool onlyCompleted;
  final double lastOperationTimeMs;

  const ItemsState({
    this.status = ItemsStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategory = 'الكل',
    this.sortByPriorityDesc = true,
    this.onlyCompleted = false,
    this.lastOperationTimeMs = 0.0,
  });

  ItemsState copyWith({
    ItemsStatus? status,
    List<Item>? items,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
    bool? sortByPriorityDesc,
    bool? onlyCompleted,
    double? lastOperationTimeMs,
  }) =>
      ItemsState(
        status: status ?? this.status,
        items: items ?? this.items,
        errorMessage: errorMessage,
        searchQuery: searchQuery ?? this.searchQuery,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        sortByPriorityDesc: sortByPriorityDesc ?? this.sortByPriorityDesc,
        onlyCompleted: onlyCompleted ?? this.onlyCompleted,
        lastOperationTimeMs: lastOperationTimeMs ?? this.lastOperationTimeMs,
      );

  ItemsViewState toViewState() => ItemsViewState(
        status: status,
        items: items,
        errorMessage: errorMessage,
        searchQuery: searchQuery,
        selectedCategory: selectedCategory,
        sortByPriorityDesc: sortByPriorityDesc,
        onlyCompleted: onlyCompleted,
        lastOperationTimeMs: lastOperationTimeMs,
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
