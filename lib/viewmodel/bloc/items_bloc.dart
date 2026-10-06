import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/items_repository.dart';
import '../../model/item.dart';

part 'items_event.dart';
part 'items_state.dart';

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  final ItemsRepository _repository;

  ItemsBloc(this._repository) : super(const ItemsState()) {
    on<LoadItems>(_onLoad);
    on<AddItemRequested>(_onAdd);
    on<ToggleItemRequested>(_onToggle);
  }

  Future<void> _onLoad(LoadItems event, Emitter<ItemsState> emit) async {
    emit(state.copyWith(status: ItemsStatus.loading));
    try {
      final items = await _repository.getItems();
      emit(state.copyWith(status: ItemsStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: ItemsStatus.failure,
        errorMessage: _clean(e),
      ));
    }
  }

  Future<void> _onAdd(AddItemRequested event, Emitter<ItemsState> emit) async {
    final title = event.title.trim();
    // معالجة إدخال المستخدم: رفض النص الفارغ
    if (title.isEmpty) {
      emit(state.copyWith(
        status: ItemsStatus.failure,
        errorMessage: 'لا يمكن إضافة عنصر بعنوان فارغ',
      ));
      return;
    }
    try {
      final items = await _repository.addItem(title);
      emit(state.copyWith(status: ItemsStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: ItemsStatus.failure,
        errorMessage: _clean(e),
      ));
    }
  }

  Future<void> _onToggle(
      ToggleItemRequested event, Emitter<ItemsState> emit) async {
    try {
      final items = await _repository.toggleItem(event.id);
      emit(state.copyWith(status: ItemsStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: ItemsStatus.failure,
        errorMessage: _clean(e),
      ));
    }
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');
}
