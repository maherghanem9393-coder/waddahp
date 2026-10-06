part of 'items_bloc.dart';

enum ItemsStatus { initial, loading, success, failure }

class ItemsState extends Equatable {
  final ItemsStatus status;
  final List<Item> items;
  final String? errorMessage;

  const ItemsState({
    this.status = ItemsStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  ItemsState copyWith({
    ItemsStatus? status,
    List<Item>? items,
    String? errorMessage,
  }) =>
      ItemsState(
        status: status ?? this.status,
        items: items ?? this.items,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, items, errorMessage];
}
