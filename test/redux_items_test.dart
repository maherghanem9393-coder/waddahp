import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:state_compare_app/data/items_data_source.dart';
import 'package:state_compare_app/data/items_repository.dart';
import 'package:state_compare_app/viewmodel/items_view_state.dart';
import 'package:state_compare_app/viewmodel/redux/items_actions.dart';
import 'package:state_compare_app/viewmodel/redux/items_middleware.dart';
import 'package:state_compare_app/viewmodel/redux/items_reducer.dart';
import 'package:state_compare_app/viewmodel/redux/items_redux_state.dart';
import 'package:state_compare_app/viewmodel/redux/redux_items_view_model.dart';

void main() {
  group('اختبارات الوحدة لنموذج MVVM + Redux (Unit Tests)', () {
    late ItemsDataSource dataSource;
    late ItemsRepository repository;
    late Store<ReduxItemsState> store;
    late ReduxItemsViewModel viewModel;

    setUp(() {
      dataSource = ItemsDataSource(initialCount: 10, networkDelayMs: 0);
      repository = ItemsRepositoryImpl(dataSource);
      store = Store<ReduxItemsState>(
        itemsReducer,
        initialState: ReduxItemsState.initial(),
        middleware: [ItemsMiddleware(repository).call],
      );
      viewModel = ReduxItemsViewModel(store, repository);
    });

    test('الحالة الابتدائية للمخزن تكون ItemsStatus.initial وقائمة فارغة', () {
      expect(store.state.status, ItemsStatus.initial);
      expect(store.state.items, isEmpty);
    });

    test('اختبار الدالة النقية Reducer بشكل معزول عند نجاح التحميل', () {
      final initial = ReduxItemsState.initial();
      final items = dataSource.incrementItemCounterSync(1);
      final nextState = itemsReducer(
        initial,
        ItemsLoadedSuccessAction(items, operationTimeMs: 12.5),
      );
      expect(nextState.status, ItemsStatus.success);
      expect(nextState.items.length, 10);
      expect(nextState.lastOperationTimeMs, 12.5);
    });

    test('السيناريو 1: جلب قائمة العناصر عبر ViewModel يحدث Store بنجاح',
        () async {
      await viewModel.load(count: 10, customDelayMs: 0);
      expect(store.state.status, ItemsStatus.success);
      expect(store.state.items.length, 10);
    });

    test('حالة الخطأ: عند تفعيل simulateError ينتقل المخزن إلى حالة failure',
        () async {
      viewModel.setSimulateError(true);
      await viewModel.load(count: 10, customDelayMs: 0);
      expect(store.state.status, ItemsStatus.failure);
      expect(store.state.errorMessage, isNotNull);
    });

    test('إضافة عنصر بعنوان فارغ يصدر حالة failure', () async {
      await viewModel.add('   ');
      expect(store.state.status, ItemsStatus.failure);
      expect(store.state.errorMessage, 'لا يمكن إضافة عنصر بعنوان فارغ');
    });

    test('إضافة عنصر صالح يدرجه في مقدمة القائمة', () async {
      await viewModel.add('عنصر Redux جديد');
      expect(store.state.status, ItemsStatus.success);
      expect(store.state.items.length, 11);
      expect(store.state.items.first.title, 'عنصر Redux جديد');
    });

    test('السيناريو 2: التحديث المتكرر لعداد العنصر (50 مرة) يعمل بدقة',
        () async {
      await viewModel.load(count: 10, customDelayMs: 0);
      await viewModel.rapidUpdateItem(1, iterations: 50);
      expect(store.state.status, ItemsStatus.success);
      final updated = store.state.items.firstWhere((e) => e.id == 1);
      expect(updated.counter, 50);
    });

    test('السيناريو 4: تصفية وفرز 500 سجل عبر Redux Middleware', () async {
      await viewModel.filterAndSort(
        datasetSize: 500,
        category: 'صيانة',
        sortByPriorityDesc: true,
      );
      expect(store.state.status, ItemsStatus.success);
      expect(
        store.state.items.every((item) => item.category == 'صيانة'),
        isTrue,
      );
    });
  });
}
