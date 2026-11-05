import 'dart:async';
import 'package:equatable/equatable.dart';
import '../../model/item.dart';

/// إجراءات Redux (Actions) للنموذج التجريبي الثاني (MVVM + Redux).
/// تمثل الأوامر والوقائع التي تُرسل إلى الـ Store لمعالجتها عبر Middleware و Reducer.
sealed class ReduxAction extends Equatable {
  const ReduxAction();

  @override
  List<Object?> get props => [];
}

class LoadItemsAction extends ReduxAction {
  final int? count;
  final int? customDelayMs;
  final Completer<void>? completer;

  const LoadItemsAction({this.count, this.customDelayMs, this.completer});

  @override
  List<Object?> get props => [count, customDelayMs];
}

class AddItemAction extends ReduxAction {
  final String title;
  final Completer<void>? completer;

  const AddItemAction(this.title, {this.completer});

  @override
  List<Object?> get props => [title];
}

class ToggleItemAction extends ReduxAction {
  final int id;
  final Completer<void>? completer;

  const ToggleItemAction(this.id, {this.completer});

  @override
  List<Object?> get props => [id];
}

class IncrementItemCounterAction extends ReduxAction {
  final int id;
  final Completer<void>? completer;

  const IncrementItemCounterAction(this.id, {this.completer});

  @override
  List<Object?> get props => [id];
}

class SimulateAsyncOperationAction extends ReduxAction {
  final int delayMs;
  final int itemCount;
  final Completer<void>? completer;

  const SimulateAsyncOperationAction({
    this.delayMs = 400,
    this.itemCount = 100,
    this.completer,
  });

  @override
  List<Object?> get props => [delayMs, itemCount];
}

class FilterAndSortItemsAction extends ReduxAction {
  final int datasetSize;
  final String query;
  final String category;
  final bool sortByPriorityDesc;
  final bool onlyCompleted;
  final Completer<void>? completer;

  const FilterAndSortItemsAction({
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

// إجراءات تحديث الحالة المتزامنة التي يعالجها الـ Reducer مباشرة:

class SetItemsLoadingAction extends ReduxAction {
  final String? query;
  final String? category;
  final bool? sortByPriorityDesc;
  final bool? onlyCompleted;

  const SetItemsLoadingAction({
    this.query,
    this.category,
    this.sortByPriorityDesc,
    this.onlyCompleted,
  });

  @override
  List<Object?> get props =>
      [query, category, sortByPriorityDesc, onlyCompleted];
}

class ItemsLoadedSuccessAction extends ReduxAction {
  final List<Item> items;
  final double operationTimeMs;

  const ItemsLoadedSuccessAction(this.items, {this.operationTimeMs = 0.0});

  @override
  List<Object?> get props => [items, operationTimeMs];
}

class ItemsFailureAction extends ReduxAction {
  final String errorMessage;
  final double operationTimeMs;

  const ItemsFailureAction(this.errorMessage, {this.operationTimeMs = 0.0});

  @override
  List<Object?> get props => [errorMessage, operationTimeMs];
}
