import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di.dart';
import '../core/rebuild_counter.dart';
import '../viewmodel/bloc/items_bloc.dart';
import '../viewmodel/items_view_model.dart';

/// طبقة View: عرض البيانات واستقبال تفاعلات المستخدم فقط.
class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  late final ItemsViewModel _vm;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = sl<ItemsViewModel>()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _submit() {
    _vm.add(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MVVM + BLoC'),
        actions: [
          const Text('محاكاة خطأ'),
          StatefulBuilder(
            builder: (context, setLocal) => Switch(
              value: _vm.simulateError,
              onChanged: (v) => setLocal(() => _vm.setSimulateError(v)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'عنوان عنصر جديد',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _submit, child: const Text('إضافة')),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<ItemsBloc, ItemsState>(
              bloc: _vm.bloc,
              listenWhen: (prev, curr) =>
                  curr.status == ItemsStatus.failure &&
                  curr.items.isNotEmpty,
              listener: (context, state) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(state.errorMessage ?? 'حدث خطأ')));
              },
              builder: (context, state) {
                final rebuilds = RebuildCounter.increment('ItemsList');
                return Column(
                  children: [
                    Expanded(child: _buildBody(state)),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('عدد مرات إعادة البناء: $rebuilds'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ItemsState state) {
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
                onPressed: _vm.load, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _vm.load(),
      child: ListView.builder(
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return CheckboxListTile(
            value: item.done,
            title: Text(item.title),
            onChanged: (_) => _vm.toggle(item.id),
          );
        },
      ),
    );
  }
}
