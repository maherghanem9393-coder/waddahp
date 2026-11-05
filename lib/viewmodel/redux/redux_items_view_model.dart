import 'dart:async';
import 'package:redux/redux.dart';

import '../../data/items_repository.dart';
import '../items_view_model.dart';
import '../items_view_state.dart';
import 'items_actions.dart';
import 'items_redux_state.dart';

/// تطبيق طبقة ViewModel للنموذج التجريبي الثاني (MVVM + Redux).
/// ينفذ نفس الواجهة القياسية ItemsViewModel لضمان التكافؤ الوظيفي التام.
class ReduxItemsViewModel implements ItemsViewModel {
  final Store<ReduxItemsState> store;
  final ItemsRepository _repository;

  ReduxItemsViewModel(this.store, this._repository);

  @override
  ArchitectureMode get mode => ArchitectureMode.redux;

  @override
  ItemsViewState get currentState => store.state.toViewState();

  @override
  Stream<ItemsViewState> get stateStream =>
      store.onChange.map((s) => s.toViewState());

  @override
  bool get simulateError => _repository.simulateError;

  @override
  void setSimulateError(bool value) => _repository.simulateError = value;

  @override
  int get networkDelayMs => _repository.networkDelayMs;

  @override
  void setNetworkDelayMs(int value) => _repository.networkDelayMs = value;

  @override
  void resetData(int count) => _repository.resetDataset(count);

  @override
  Future<void> load({int? count, int? customDelayMs}) {
    final completer = Completer<void>();
    store.dispatch(LoadItemsAction(
      count: count,
      customDelayMs: customDelayMs,
      completer: completer,
    ));
    return completer.future;
  }

  @override
  Future<void> add(String title) {
    final completer = Completer<void>();
    store.dispatch(AddItemAction(title, completer: completer));
    return completer.future;
  }

  @override
  Future<void> toggle(int id) {
    final completer = Completer<void>();
    store.dispatch(ToggleItemAction(id, completer: completer));
    return completer.future;
  }

  @override
  Future<void> rapidUpdateItem(int id, {int iterations = 50}) async {
    for (int i = 0; i < iterations; i++) {
      final completer = Completer<void>();
      store.dispatch(IncrementItemCounterAction(id, completer: completer));
      await completer.future;
    }
  }

  @override
  Future<void> runAsyncOperation({int delayMs = 400, int itemCount = 100}) {
    final completer = Completer<void>();
    store.dispatch(SimulateAsyncOperationAction(
      delayMs: delayMs,
      itemCount: itemCount,
      completer: completer,
    ));
    return completer.future;
  }

  @override
  Future<void> filterAndSort({
    int datasetSize = 500,
    String? query,
    String? category,
    bool? sortByPriorityDesc,
    bool? onlyCompleted,
  }) {
    final completer = Completer<void>();
    store.dispatch(FilterAndSortItemsAction(
      datasetSize: datasetSize,
      query: query ?? currentState.searchQuery,
      category: category ?? currentState.selectedCategory,
      sortByPriorityDesc:
          sortByPriorityDesc ?? currentState.sortByPriorityDesc,
      onlyCompleted: onlyCompleted ?? currentState.onlyCompleted,
      completer: completer,
    ));
    return completer.future;
  }

  @override
  Future<void> dispose() async {
    // Store teardown if needed
  }
}
