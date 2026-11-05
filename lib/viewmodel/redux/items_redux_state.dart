import 'package:equatable/equatable.dart';
import '../../model/item.dart';
import '../items_view_state.dart';

/// حالة المخزن المركزي (Store State) في النموذج التجريبي الثاني (MVVM + Redux).
/// مطابقة بنيوياً ووظيفياً لحالة ItemsState في نموذج BLoC لضمان عدالة المقارنة.
class ReduxItemsState extends Equatable {
  final ItemsStatus status;
  final List<Item> items;
  final String? errorMessage;
  final String searchQuery;
  final String selectedCategory;
  final bool sortByPriorityDesc;
  final bool onlyCompleted;
  final double lastOperationTimeMs;

  const ReduxItemsState({
    this.status = ItemsStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategory = 'الكل',
    this.sortByPriorityDesc = true,
    this.onlyCompleted = false,
    this.lastOperationTimeMs = 0.0,
  });

  factory ReduxItemsState.initial() => const ReduxItemsState();

  ReduxItemsState copyWith({
    ItemsStatus? status,
    List<Item>? items,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
    bool? sortByPriorityDesc,
    bool? onlyCompleted,
    double? lastOperationTimeMs,
  }) =>
      ReduxItemsState(
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
