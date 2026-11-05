import 'package:get_it/get_it.dart';
import 'package:redux/redux.dart';

import '../data/items_data_source.dart';
import '../data/items_repository.dart';
import '../viewmodel/bloc/items_bloc.dart';
import '../viewmodel/items_view_model.dart';
import '../viewmodel/redux/items_middleware.dart';
import '../viewmodel/redux/items_reducer.dart';
import '../viewmodel/redux/items_redux_state.dart';

final GetIt sl = GetIt.instance;

/// حقن التبعيات (Dependency Injection) الموحد للنموذجين (MVVM+BLoC و MVVM+Redux)
/// كما هو موثق في الفصل الثالث (القسم 3.6).
void setupDependencies() {
  if (sl.isRegistered<ItemsDataSource>()) {
    sl.reset();
  }

  // طبقة البيانات المشتركة (Model & Repository)
  sl.registerLazySingleton<ItemsDataSource>(() => ItemsDataSource());
  sl.registerLazySingleton<ItemsRepository>(() => ItemsRepositoryImpl(sl()));

  // النموذج التجريبي الأول: MVVM + BLoC
  sl.registerFactory<ItemsBloc>(() => ItemsBloc(sl()));
  sl.registerFactory<BlocItemsViewModel>(() => BlocItemsViewModel(sl(), sl()));

  // النموذج التجريبي الثاني: MVVM + Redux
  sl.registerFactory<Store<ReduxItemsState>>(
    () => Store<ReduxItemsState>(
      itemsReducer,
      initialState: ReduxItemsState.initial(),
      middleware: [ItemsMiddleware(sl()).call],
    ),
  );
  sl.registerFactory<ReduxItemsViewModel>(
      () => ReduxItemsViewModel(sl(), sl()));

  // تسجيل ViewModel بحسب الوضع المختار
  sl.registerFactoryParam<ItemsViewModel, ArchitectureMode, void>(
    (mode, _) => mode == ArchitectureMode.bloc
        ? sl<BlocItemsViewModel>()
        : sl<ReduxItemsViewModel>(),
  );
}
