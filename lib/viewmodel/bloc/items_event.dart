part of 'items_bloc.dart';

sealed class ItemsEvent extends Equatable {
  const ItemsEvent();
  @override
  List<Object?> get props => [];
}

class LoadItems extends ItemsEvent {
  const LoadItems();
}

class AddItemRequested extends ItemsEvent {
  final String title;
  const AddItemRequested(this.title);
  @override
  List<Object?> get props => [title];
}

class ToggleItemRequested extends ItemsEvent {
  final int id;
  const ToggleItemRequested(this.id);
  @override
  List<Object?> get props => [id];
}
