import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/performance_tracker.dart';
import '../../data/items_repository.dart';
import '../../model/item.dart';
import '../items_view_state.dart';

part 'items_event.dart';
part 'items_state.dart';

/// مكون إدارة الحالة الأول: ItemsBloc (ضمن النموذج التجريبي الأول MVVM + BLoC).
class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  final ItemsRepository _repository;

  ItemsBloc(this._repository) : super(const ItemsState()) {
    on<LoadItems>(_onLoad);
    on<AddItemRequested>(_onAdd);
    on<ToggleItemRequested>(_onToggle);
    on<IncrementItemCounterRequested>(_onIncrementCounter);
    on<SimulateAsyncOperationRequested>(_onSimulateAsync);
    on<FilterAndSortItemsRequested>(_onFilterAndSort);
  }

  Future<void> _onLoad(LoadItems event, Emitter<ItemsState> emit) async {
    PerformanceTracker.startOperation('bloc_load');
    emit(state.copyWith(status: ItemsStatus.loading));
    try {
      final items = await _repository.getItems(
        count: event.count,
        customDelayMs: event.customDelayMs,
      );
      final elapsed = PerformanceTracker.stopOperation('bloc_load');
      emit(state.copyWith(
        status: ItemsStatus.success,
        items: items,
        lastOperationTimeMs: elapsed,
      ));
    } catch (e) {
      final elapsed = PerformanceTracker.stopOperation('bloc_load');
      emit(state.copyWith(
        status: ItemsStatus.failure,
        errorMessage: _clean(e),
        lastOperationTimeMs: elapsed,
      ));
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onAdd(AddItemRequested event, Emitter<ItemsState> emit) async {
    PerformanceTracker.startOperation('bloc_add');
    final title = event.title.trim();
    if (title.isEmpty) {
      final elapsed = PerformanceTracker.stopOperation('bloc_add');
      emit(state.copyWith(
        status: ItemsStatus.failure,
        errorMessage: 'لا يمكن إضافة عنصر بعنوان فارغ',
        lastOperationTimeMs: elapsed,
      ));
      event.completer?.complete();
      return;
    }
    try {
      final items = await _repository.addItem(title);
      final elapsed = PerformanceTracker.stopOperation('bloc_add');
      emit(state.copyWith(
        status: ItemsStatus.success,
        items: items,
        lastOperationTimeMs: elapsed,
      ));
    } catch (e) {
      final elapsed = PerformanceTracker.stopOperation('bloc_add');
      emit(state.copyWith(
        status: ItemsStatus.failure,
        errorMessage: _clean(e),
        lastOperationTimeMs: elapsed,
      ));
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onToggle(
      ToggleItemRequested event, Emitter<ItemsState> emit) async {
    PerformanceTracker.startOperation('bloc_toggle');
    try {
      final items = await _repository.toggleItem(event.id);
      final elapsed = PerformanceTracker.stopOperation('bloc_toggle');
      emit(state.copyWith(
        status: ItemsStatus.success,
        items: items,
        lastOperationTimeMs: elapsed,
      ));
    } catch (e) {
      final elapsed = PerformanceTracker.stopOperation('bloc_toggle');
      emit(state.copyWith(
        status: ItemsStatus.failure,
        errorMessage: _clean(e),
        lastOperationTimeMs: elapsed,
      ));
    } finally {
      event.completer?.complete();
    }
  }

  void _onIncrementCounter(
      IncrementItemCounterRequested event, Emitter<ItemsState> emit) {
    PerformanceTracker.startOperation('bloc_inc');
    try {
      final items = _repository.incrementCounterSync(event.id);
      final elapsed = PerformanceTracker.stopOperation('bloc_inc');
      emit(state.copyWith(
        status: ItemsStatus.success,
        items: items,
        lastOperationTimeMs: elapsed,
      ));
    } catch (e) {
      final elapsed = PerformanceTracker.stopOperation('bloc_inc');
      emit(state.copyWith(
        status: ItemsStatus.failure,
        errorMessage: _clean(e),
        lastOperationTimeMs: elapsed,
      ));
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onSimulateAsync(
      SimulateAsyncOperationRequested event, Emitter<ItemsState> emit) async {
    PerformanceTracker.startOperation('bloc_async');
    emit(state.copyWith(status: ItemsStatus.loading));
    try {
      final items = await _repository.runAsyncNetworkOperation(
        delayMs: event.delayMs,
        itemCount: event.itemCount,
      );
      final elapsed = PerformanceTracker.stopOperation('bloc_async');
      emit(state.copyWith(
        status: ItemsStatus.success,
        items: items,
        lastOperationTimeMs: elapsed,
      ));
    } catch (e) {
      final elapsed = PerformanceTracker.stopOperation('bloc_async');
      emit(state.copyWith(
        status: ItemsStatus.failure,
        errorMessage: _clean(e),
        lastOperationTimeMs: elapsed,
      ));
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onFilterAndSort(
      FilterAndSortItemsRequested event, Emitter<ItemsState> emit) async {
    PerformanceTracker.startOperation('bloc_filter');
    emit(state.copyWith(
      status: ItemsStatus.loading,
      searchQuery: event.query,
      selectedCategory: event.category,
      sortByPriorityDesc: event.sortByPriorityDesc,
      onlyCompleted: event.onlyCompleted,
    ));
    try {
      final items = await _repository.processMediumDataset(
        datasetSize: event.datasetSize,
        query: event.query,
        category: event.category,
        sortByPriorityDesc: event.sortByPriorityDesc,
        onlyCompleted: event.onlyCompleted,
      );
      final elapsed = PerformanceTracker.stopOperation('bloc_filter');
      emit(state.copyWith(
        status: ItemsStatus.success,
        items: items,
        lastOperationTimeMs: elapsed,
      ));
    } catch (e) {
      final elapsed = PerformanceTracker.stopOperation('bloc_filter');
      emit(state.copyWith(
        status: ItemsStatus.failure,
        errorMessage: _clean(e),
        lastOperationTimeMs: elapsed,
      ));
    } finally {
      event.completer?.complete();
    }
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');
}
