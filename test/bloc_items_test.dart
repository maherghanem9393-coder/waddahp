import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_compare_app/data/items_data_source.dart';
import 'package:state_compare_app/data/items_repository.dart';
import 'package:state_compare_app/viewmodel/bloc/items_bloc.dart';
import 'package:state_compare_app/viewmodel/items_view_state.dart';

void main() {
  group('اختبارات الوحدة لنموذج MVVM + BLoC (Unit Tests)', () {
    late ItemsDataSource dataSource;
    late ItemsRepository repository;
    late ItemsBloc bloc;

    setUp(() {
      dataSource = ItemsDataSource(initialCount: 10, networkDelayMs: 0);
      repository = ItemsRepositoryImpl(dataSource);
      bloc = ItemsBloc(repository);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('الحالة الابتدائية تكون ItemsStatus.initial وقائمة فارغة', () {
      expect(bloc.state.status, ItemsStatus.initial);
      expect(bloc.state.items, isEmpty);
    });

    blocTest<ItemsBloc, ItemsState>(
      'السيناريو 1: جلب قائمة العناصر يصدر حالة loading ثم success',
      build: () => bloc,
      act: (b) => b.add(const LoadItems(count: 10, customDelayMs: 0)),
      expect: () => [
        isA<ItemsState>()
            .having((s) => s.status, 'status', ItemsStatus.loading),
        isA<ItemsState>()
            .having((s) => s.status, 'status', ItemsStatus.success)
            .having((s) => s.items.length, 'items.length', 10),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'حالة الخطأ: عند تفعيل simulateError يصدر حالة loading ثم failure',
      build: () {
        repository.simulateError = true;
        return bloc;
      },
      act: (b) => b.add(const LoadItems(count: 10, customDelayMs: 0)),
      expect: () => [
        isA<ItemsState>()
            .having((s) => s.status, 'status', ItemsStatus.loading),
        isA<ItemsState>()
            .having((s) => s.status, 'status', ItemsStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'إضافة عنصر بعنوان فارغ يصدر حالة failure مع رسالة تنبيه',
      build: () => bloc,
      act: (b) => b.add(const AddItemRequested('   ')),
      expect: () => [
        isA<ItemsState>()
            .having((s) => s.status, 'status', ItemsStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'لا يمكن إضافة عنصر بعنوان فارغ',
            ),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'إضافة عنصر صالح يزيد عدد العناصر بمقدار 1',
      build: () => bloc,
      act: (b) => b.add(const AddItemRequested('عنصر اختباري جديد')),
      expect: () => [
        isA<ItemsState>()
            .having((s) => s.status, 'status', ItemsStatus.success)
            .having((s) => s.items.length, 'items.length', 11)
            .having((s) => s.items.first.title, 'first.title',
                'عنصر اختباري جديد'),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'السيناريو 2: التحديث المتكرر لعداد العنصر يحدث القيمة بنجاح',
      build: () => bloc,
      act: (b) => b
        ..add(const IncrementItemCounterRequested(1))
        ..add(const IncrementItemCounterRequested(1)),
      expect: () => [
        isA<ItemsState>()
            .having((s) => s.items.first.counter, 'counter', 1),
        isA<ItemsState>()
            .having((s) => s.items.first.counter, 'counter', 2),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'السيناريو 4: تصفية وفرز 500 عنصر يعمل بدقة',
      build: () => bloc,
      act: (b) => b.add(const FilterAndSortItemsRequested(
        datasetSize: 500,
        category: 'أداء',
        sortByPriorityDesc: true,
      )),
      expect: () => [
        isA<ItemsState>()
            .having((s) => s.status, 'status', ItemsStatus.loading),
        isA<ItemsState>()
            .having((s) => s.status, 'status', ItemsStatus.success)
            .having(
              (s) => s.items.every((item) => item.category == 'أداء'),
              'all match category',
              isTrue,
            ),
      ],
    );
  });
}
