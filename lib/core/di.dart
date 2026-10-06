import 'package:get_it/get_it.dart';

import '../data/items_data_source.dart';
import '../data/items_repository.dart';
import '../viewmodel/bloc/items_bloc.dart';
import '../viewmodel/items_view_model.dart';

final GetIt sl = GetIt.instance;

/// حقن التبعيات (Dependency Injection) الموحد للنموذجين.
void setupDependencies() {
  sl.registerLazySingleton<ItemsDataSource>(() => ItemsDataSource());
  sl.registerLazySingleton<ItemsRepository>(() => ItemsRepositoryImpl(sl()));
  sl.registerFactory<ItemsBloc>(() => ItemsBloc(sl()));
  sl.registerFactory<ItemsViewModel>(() => ItemsViewModel(sl(), sl()));
}
