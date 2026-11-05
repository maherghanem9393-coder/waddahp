import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../core/di.dart';
import '../core/rebuild_counter.dart';
import '../viewmodel/bloc/items_bloc.dart';
import '../viewmodel/items_view_model.dart';
import '../viewmodel/items_view_state.dart';
import '../viewmodel/redux/items_redux_state.dart';
import 'benchmark_page.dart';

/// طبقة View الموحدة (MVVM View Layer):
/// تعرض البيانات وتستقبل تفاعلات المستخدم لكلا النموذجين (MVVM+BLoC و MVVM+Redux)
/// مع الحفاظ التام على تطابق شجرة الـ Widgets والوظائف وسيناريوهات الاختبار.
class ItemsPage extends StatefulWidget {
  final ArchitectureMode initialMode;

  const ItemsPage({
    super.key,
    this.initialMode = ArchitectureMode.bloc,
  });

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  late ArchitectureMode _currentMode;
  late ItemsViewModel _vm;
  final _addController = TextEditingController();
  final _searchController = TextEditingController();

  static const List<String> _categories = [
    'الكل',
    'أداء',
    'موارد',
    'صيانة',
    'اختبار',
    'معمارية',
  ];

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _initViewModel();
  }

  void _initViewModel() {
    RebuildCounter.reset('ItemsList_${_currentMode.name}');
    _vm = sl<ItemsViewModel>(param1: _currentMode)..load(count: 100);
  }

  Future<void> _switchArchitecture(ArchitectureMode newMode) async {
    if (newMode == _currentMode) return;
    await _vm.dispose();
    setState(() {
      _currentMode = newMode;
      _initViewModel();
    });
  }

  @override
  void dispose() {
    _addController.dispose();
    _searchController.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _submitNewItem() {
    _vm.add(_addController.text);
    _addController.clear();
  }

  void _showErrorSnackBar(BuildContext context, String? message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message ?? 'حدث خطأ غير متوقع')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تطبيق المقارنة: ${_currentMode.label}'),
        actions: [
          IconButton(
            tooltip: 'مختبر القياسات والتحليل الإحصائي (30 تكراراً)',
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BenchmarkPage()),
              );
            },
          ),
          Row(
            children: [
              const Text('محاكاة خطأ', style: TextStyle(fontSize: 12)),
              StatefulBuilder(
                builder: (context, setLocal) => Switch(
                  value: _vm.simulateError,
                  onChanged: (v) => setLocal(() => _vm.setSimulateError(v)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildArchitectureSelector(),
          _buildScenarioQuickBar(),
          _buildAddAndFilterSection(),
          Expanded(
            child: _currentMode == ArchitectureMode.bloc
                ? _buildBlocConsumerSection()
                : _buildReduxConnectorSection(),
          ),
        ],
      ),
    );
  }

  /// شريط التبديل الفوري بين النموذج الأول (MVVM+BLoC) والنموذج الثاني (MVVM+Redux).
  Widget _buildArchitectureSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          const Text(
            'آلية إدارة الحالة:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SegmentedButton<ArchitectureMode>(
              segments: const [
                ButtonSegment(
                  value: ArchitectureMode.bloc,
                  label: Text('MVVM + BLoC'),
                  icon: Icon(Icons.bolt),
                ),
                ButtonSegment(
                  value: ArchitectureMode.redux,
                  label: Text('MVVM + Redux'),
                  icon: Icon(Icons.storage),
                ),
              ],
              selected: {_currentMode},
              onSelectionChanged: (selection) {
                _switchArchitecture(selection.first);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// شريط تشغيل السيناريوهات الأربعة وتحليل الحساسية مباشرة من الواجهة.
  Widget _buildScenarioQuickBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          ActionChip(
            avatar: const Icon(Icons.download, size: 16),
            label: const Text('س1: جلب 100 عنصر'),
            onPressed: () => _vm.load(count: 100),
          ),
          const SizedBox(width: 6),
          ActionChip(
            avatar: const Icon(Icons.repeat, size: 16),
            label: const Text('س2: 50 تحديثاً متتالياً'),
            onPressed: () {
              final firstId = _vm.currentState.items.isNotEmpty
                  ? _vm.currentState.items.first.id
                  : 1;
              _vm.rapidUpdateItem(firstId, iterations: 50);
            },
          ),
          const SizedBox(width: 6),
          ActionChip(
            avatar: const Icon(Icons.cloud_sync, size: 16),
            label: const Text('س3: عملية غير متزامنة'),
            onPressed: () =>
                _vm.runAsyncOperation(delayMs: 400, itemCount: 100),
          ),
          const SizedBox(width: 6),
          ActionChip(
            avatar: const Icon(Icons.filter_alt, size: 16),
            label: const Text('س4: معالجة 500 سجل'),
            onPressed: () => _vm.filterAndSort(
              datasetSize: 500,
              query: _searchController.text,
              sortByPriorityDesc: true,
            ),
          ),
          const SizedBox(width: 6),
          ActionChip(
            avatar: const Icon(Icons.speed, size: 16),
            label: const Text('حساسية: 50'),
            onPressed: () => _vm.load(count: 50),
          ),
          const SizedBox(width: 6),
          ActionChip(
            avatar: const Icon(Icons.speed, size: 16),
            label: const Text('حساسية: 500'),
            onPressed: () => _vm.load(count: 500),
          ),
          const SizedBox(width: 6),
          ActionChip(
            avatar: const Icon(Icons.speed, size: 16),
            label: const Text('حساسية: 2000'),
            onPressed: () => _vm.load(count: 2000),
          ),
        ],
      ),
    );
  }

  /// قسم إضافة عنصر جديد + أدوات التصفية والفرز.
  Widget _buildAddAndFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان عنصر جديد',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submitNewItem(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _submitNewItem,
                child: const Text('إضافة'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'بحث وتصفية (السيناريو 4)',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (val) => _vm.filterAndSort(
                    datasetSize: _vm.currentState.items.isEmpty
                        ? 500
                        : _vm.currentState.items.length,
                    query: val,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _categories.contains(_vm.currentState.selectedCategory)
                    ? _vm.currentState.selectedCategory
                    : 'الكل',
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (cat) {
                  if (cat != null) {
                    _vm.filterAndSort(
                      datasetSize: _vm.currentState.items.isEmpty
                          ? 500
                          : _vm.currentState.items.length,
                      category: cat,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ربط واجهة المستخدم بنموذج MVVM + BLoC.
  Widget _buildBlocConsumerSection() {
    final blocVm = _vm as BlocItemsViewModel;
    return BlocConsumer<ItemsBloc, ItemsState>(
      bloc: blocVm.bloc,
      listenWhen: (prev, curr) =>
          curr.status == ItemsStatus.failure && curr.items.isNotEmpty,
      listener: (context, state) =>
          _showErrorSnackBar(context, state.errorMessage),
      builder: (context, state) {
        final rebuilds =
            RebuildCounter.increment('ItemsList_${_currentMode.name}');
        return _buildUnifiedContent(state.toViewState(), rebuilds);
      },
    );
  }

  /// ربط واجهة المستخدم بنموذج MVVM + Redux.
  Widget _buildReduxConnectorSection() {
    final reduxVm = _vm as ReduxItemsViewModel;
    return StoreProvider<ReduxItemsState>(
      store: reduxVm.store,
      child: StoreConnector<ReduxItemsState, ItemsViewState>(
        distinct: true,
        converter: (store) => store.state.toViewState(),
        onWillChange: (prev, curr) {
          if (curr.status == ItemsStatus.failure && curr.items.isNotEmpty) {
            _showErrorSnackBar(context, curr.errorMessage);
          }
        },
        builder: (context, viewState) {
          final rebuilds =
              RebuildCounter.increment('ItemsList_${_currentMode.name}');
          return _buildUnifiedContent(viewState, rebuilds);
        },
      ),
    );
  }

  /// المحتوى المرئي الموحد لكلا النموذجين + شريط مؤشرات القياس الفوري أسفل الشاشة.
  Widget _buildUnifiedContent(ItemsViewState state, int rebuilds) {
    return Column(
      children: [
        Expanded(child: _buildBody(state)),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            children: [
              Text(
                'عدد العناصر: ${state.items.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'إعادة بناء الـ Widgets: $rebuilds',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'زمن آخر عملية: ${state.lastOperationTimeMs.toStringAsFixed(2)} ms',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ItemsViewState state) {
    if (state.status == ItemsStatus.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == ItemsStatus.failure && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage ?? 'حدث خطأ'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => _vm.load(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _vm.load(),
      child: ListView.builder(
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return CheckboxListTile(
            key: ValueKey('item_${item.id}'),
            value: item.done,
            title: Text(item.title),
            subtitle: Text(
              'الفئة: ${item.category} | الأولوية: ${item.priority} | التحديثات المتكررة: ${item.counter}',
            ),
            secondary: IconButton(
              tooltip: 'تحديث سريع للعداد (+1)',
              icon: const Icon(Icons.exposure_plus_1),
              onPressed: () => _vm.rapidUpdateItem(item.id, iterations: 1),
            ),
            onChanged: (_) => _vm.toggle(item.id),
          );
        },
      ),
    );
  }
}
