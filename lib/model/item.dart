import 'package:equatable/equatable.dart';

/// طبقة Model: تمثيل البيانات.
class Item extends Equatable {
  final int id;
  final String title;
  final bool done;

  const Item({required this.id, required this.title, this.done = false});

  Item copyWith({String? title, bool? done}) =>
      Item(id: id, title: title ?? this.title, done: done ?? this.done);

  @override
  List<Object?> get props => [id, title, done];
}
