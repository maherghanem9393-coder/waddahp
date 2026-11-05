import 'package:redux/redux.dart';

import '../../core/performance_tracker.dart';
import '../../data/items_repository.dart';
import 'items_actions.dart';
import 'items_redux_state.dart';

/// الطبقة الوسيطة (Middleware) في Redux لمعالجة العمليات غير المتزامنة والتواصل مع المستودع (Repository).
class ItemsMiddleware extends MiddlewareClass<ReduxItemsState> {
  final ItemsRepository _repository;

  ItemsMiddleware(this._repository);

  @override
  dynamic call(
      Store<ReduxItemsState> store, dynamic action, NextDispatcher next) async {
    next(action);

    if (action is LoadItemsAction) {
      await _handleLoad(store, action);
    } else if (action is AddItemAction) {
      await _handleAdd(store, action);
    } else if (action is ToggleItemAction) {
      await _handleToggle(store, action);
    } else if (action is IncrementItemCounterAction) {
      _handleIncrementCounter(store, action);
    } else if (action is SimulateAsyncOperationAction) {
      await _handleSimulateAsync(store, action);
    } else if (action is FilterAndSortItemsAction) {
      await _handleFilterAndSort(store, action);
    }
  }

  Future<void> _handleLoad(
      Store<ReduxItemsState> store, LoadItemsAction action) async {
    PerformanceTracker.startOperation('redux_load');
    store.dispatch(const SetItemsLoadingAction());
    try {
      final items = await _repository.getItems(
        count: action.count,
        customDelayMs: action.customDelayMs,
      );
      final elapsed = PerformanceTracker.stopOperation('redux_load');
      store.dispatch(
          ItemsLoadedSuccessAction(items, operationTimeMs: elapsed));
    } catch (e) {
      final elapsed = PerformanceTracker.stopOperation('redux_load');
      store.dispatch(ItemsFailureAction(_clean(e), operationTimeMs: elapsed));
    } finally {
      action.completer?.complete();
    }
  }

  Future<void> _handleAdd(
      Store<ReduxItemsState> store, AddItemAction action) async {
    PerformanceTracker.startOperation('redux_add');
    final title = action.title.trim();
    if (title.isEmpty) {
      final elapsed = PerformanceTracker.stopOperation('redux_add');
      store.dispatch(ItemsFailureAction(
        'لا يمكن إضافة عنصر بعنوان فارغ',
        operationTimeMs: elapsed,
      ));
      action.completer?.complete();
      return;
    }
    try {
      final items = await _repository.addItem(title);
      final elapsed = PerformanceTracker.stopOperation('redux_add');
      store.dispatch(
          ItemsLoadedSuccessAction(items, operationTimeMs: elapsed));
    } catch (e) {
      final elapsed = PerformanceTracker.stopOperation('redux_add');
      store.dispatch(ItemsFailureAction(_clean(e), operationTimeMs: elapsed));
    } finally {
      action.completer?.complete();
    }
  }

  Future<void> _handleToggle(
      Store<ReduxItemsState> store, ToggleItemAction action) async {
    PerformanceTracker.startOperation('redux_toggle');
    try {
      final items = await _repository.toggleItem(action.id);
      final elapsed = PerformanceTracker.stopOperation('redux_toggle');
      store.dispatch(
          ItemsLoadedSuccessAction(items, operationTimeMs: elapsed));
    } catch (e) {
      final elapsed = PerformanceTracker.stopOperation('redux_toggle');
      store.dispatch(ItemsFailureAction(_clean(e), operationTimeMs: elapsed));
    } finally {
      action.completer?.complete();
    }
  }

  void _handleIncrementCounter(
      Store<ReduxItemsState> store, IncrementItemCounterAction action) {
    PerformanceTracker.startOperation('redux_inc');
    try {
      final items = _repository.incrementCounterSync(action.id);
      final elapsed = PerformanceTracker.stopOperation('redux_inc');
      store.dispatch(
          ItemsLoadedSuccessAction(items, operationTimeMs: elapsed));
    } catch (e) {
      final elapsed = PerformanceTracker.stopOperation('redux_inc');
      store.dispatch(ItemsFailureAction(_clean(e), operationTimeMs: elapsed));
    } finally {
      action.completer?.complete();
    }
  }

  Future<void> _handleSimulateAsync(Store<ReduxItemsState> store,
      SimulateAsyncOperationAction action) async {
    PerformanceTracker.startOperation('redux_async');
    store.dispatch(const SetItemsLoadingAction());
    try {
      final items = await _repository.runAsyncNetworkOperation(
        delayMs: action.delayMs,
        itemCount: action.itemCount,
      );
      final elapsed = PerformanceTracker.stopOperation('redux_async');
      store.dispatch(
          ItemsLoadedSuccessAction(items, operationTimeMs: elapsed));
    } catch (e) {
      final elapsed = PerformanceTracker.stopOperation('redux_async');
      store.dispatch(ItemsFailureAction(_clean(e), operationTimeMs: elapsed));
    } finally {
      action.completer?.complete();
    }
  }

  Future<void> _handleFilterAndSort(
      Store<ReduxItemsState> store, FilterAndSortItemsAction action) async {
    PerformanceTracker.startOperation('redux_filter');
    store.dispatch(SetItemsLoadingAction(
      query: action.query,
      category: action.category,
      sortByPriorityDesc: action.sortByPriorityDesc,
      onlyCompleted: action.onlyCompleted,
    ));
    try {
      final items = await _repository.processMediumDataset(
        datasetSize: action.datasetSize,
        query: action.query,
        category: action.category,
        sortByPriorityDesc: action.sortByPriorityDesc,
        onlyCompleted: action.onlyCompleted,
      );
      final elapsed = PerformanceTracker.stopOperation('redux_filter');
      store.dispatch(
          ItemsLoadedSuccessAction(items, operationTimeMs: elapsed));
    } catch (e) {
      final elapsed = PerformanceTracker.stopOperation('redux_filter');
      store.dispatch(ItemsFailureAction(_clean(e), operationTimeMs: elapsed));
    } finally {
      action.completer?.complete();
    }
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');
}
