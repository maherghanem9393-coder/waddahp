import '../data/items_repository.dart';
import 'bloc/items_bloc.dart';

/// طبقة ViewModel: تنسّق بين الواجهة وآلية إدارة الحالة (BLoC).
/// الواجهة لا تتعامل مع الأحداث مباشرة، بل مع هذه الطبقة.
class ItemsViewModel {
  final ItemsBloc bloc;
  final ItemsRepository _repository;

  ItemsViewModel(this.bloc, this._repository);

  void load() => bloc.add(const LoadItems());
  void add(String title) => bloc.add(AddItemRequested(title));
  void toggle(int id) => bloc.add(ToggleItemRequested(id));

  bool get simulateError => _repository.simulateError;
  void setSimulateError(bool value) => _repository.simulateError = value;

  Future<void> dispose() => bloc.close();
}
