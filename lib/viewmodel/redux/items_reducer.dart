import '../items_view_state.dart';
import 'items_actions.dart';
import 'items_redux_state.dart';

/// الدالة النقية (Pure Function Reducer) في نمط Redux.
/// تستقبل الحالة السابقة والإجراء (Action) وتُنتج حالة جديدة دون تعديل مباشر للحالة السابقة.
ReduxItemsState itemsReducer(ReduxItemsState state, dynamic action) {
  if (action is SetItemsLoadingAction) {
    return state.copyWith(
      status: ItemsStatus.loading,
      searchQuery: action.query ?? state.searchQuery,
      selectedCategory: action.category ?? state.selectedCategory,
      sortByPriorityDesc: action.sortByPriorityDesc ?? state.sortByPriorityDesc,
      onlyCompleted: action.onlyCompleted ?? state.onlyCompleted,
    );
  }

  if (action is ItemsLoadedSuccessAction) {
    return state.copyWith(
      status: ItemsStatus.success,
      items: action.items,
      lastOperationTimeMs: action.operationTimeMs,
    );
  }

  if (action is ItemsFailureAction) {
    return state.copyWith(
      status: ItemsStatus.failure,
      errorMessage: action.errorMessage,
      lastOperationTimeMs: action.operationTimeMs,
    );
  }

  return state;
}
