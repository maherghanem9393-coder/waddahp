import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/benchmark_runner.dart';
import '../core/performance_tracker.dart';
import '../viewmodel/items_view_model.dart';

/// لوحة المختبر التجريبي والقياسات الإحصائية (Benchmark & Statistical Analysis Lab)
/// تتيح للباحث تشغيل السيناريوهات الأربعة وتحليل الحساسية (30 تكراراً) وعرض المتوسط الحسابي،
/// الانحراف المعياري، نسبة الفرق المئوية (PD%)، وحجم التأثير (Cohen's d)، وتصدير CSV.
class BenchmarkPage extends StatefulWidget {
  const BenchmarkPage({super.key});

  @override
  State<BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage> {
  bool _isRunning = false;
  String _statusMessage = 'جاهز لتشغيل البروتوكول التجريبي';
  double _progress = 0.0;
  int _selectedIterations = 30;

  static const Map<String, String> _scenarioTitles = {
    'S1_Fetch100': 'السيناريو 1: جلب قائمة بيانات (100 عنصر)',
    'S2_RapidUpdates50': 'السيناريو 2: التحديثات المتكررة (50 تحديثاً متتالياً)',
    'S3_AsyncNetwork': 'السيناريو 3: العمليات غير المتزامنة (طلب شبكة محاكى)',
    'S4_MediumDataset500': 'السيناريو 4: معالجة وفرز بيانات متوسطة (500 سجل)',
    'Sens_Small50': 'تحليل الحساسية: بيانات صغيرة (50 عنصراً)',
    'Sens_Medium500': 'تحليل الحساسية: بيانات متوسطة (500 عنصر)',
    'Sens_Large2000': 'تحليل الحساسية: بيانات كبيرة (2000 عنصر)',
  };

  Future<void> _runBenchmarks() async {
    setState(() {
      _isRunning = true;
      _progress = 0.0;
      _statusMessage = 'بدء تشغيل التجارب...';
    });

    final runner = BenchmarkRunner(defaultIterations: _selectedIterations);
    await runner.runFullSuite(
      iterations: _selectedIterations,
      onStatus: (msg, prog) {
        if (mounted) {
          setState(() {
            _statusMessage = msg;
            _progress = prog;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isRunning = false;
        _statusMessage =
            'اكتمل تنفيذ جميع السيناريوهات ($_selectedIterations تكراراً لكل نموذج)';
      });
    }
  }

  void _copyCsvToClipboard() {
    final csv = PerformanceTracker.exportCsv();
    if (csv.trim().split('\n').length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد بيانات مسجلة بعد لتصديرها')),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ البيانات الخام بصيغة CSV إلى الحافظة بنجاح'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مختبر القياسات والتحليل الإحصائي'),
        actions: [
          IconButton(
            tooltip: 'نسخ النتائج الخام CSV',
            onPressed: _copyCsvToClipboard,
            icon: const Icon(Icons.copy_all),
          ),
          IconButton(
            tooltip: 'مسح السجلات',
            onPressed: _isRunning
                ? null
                : () {
                    setState(() {
                      PerformanceTracker.clear();
                      _statusMessage = 'تم مسح السجلات';
                    });
                  },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildControlCard(),
          const SizedBox(height: 16),
          ..._scenarioTitles.entries.map(
            (entry) => _buildScenarioComparisonCard(entry.key, entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إعدادات البروتوكول التجريبي الموحد (الفصل الثالث - قسم 3.7)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'يقوم المحرك بتشغيل السيناريوهات الأربعة وتحليل الحساسية على كل من MVVM+BLoC و MVVM+Redux تحت ظروف متطابقة، مع حساب المتوسط الحسابي (Mean)، الانحراف المعياري (SD)، نسبة الفرق (PD%)، وحجم التأثير (Cohen's d).',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('عدد التكرارات لكل سيناريو: '),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _selectedIterations,
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 (استطلاعي Pilot)')),
                    DropdownMenuItem(value: 15, child: Text('15 تكراراً')),
                    DropdownMenuItem(value: 30, child: Text('30 تكراراً (معيار الأطروحة)')),
                  ],
                  onChanged: _isRunning
                      ? null
                      : (v) {
                          if (v != null) {
                            setState(() => _selectedIterations = v);
                          }
                        },
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _isRunning ? null : _runBenchmarks,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('تشغيل البروتوكول الكامل'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isRunning) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
            ],
            Text(
              _statusMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioComparisonCard(String scenarioKey, String title) {
    final blocSum = PerformanceTracker.summarize(
      architecture: ArchitectureMode.bloc.label,
      scenarioName: scenarioKey,
    );
    final reduxSum = PerformanceTracker.summarize(
      architecture: ArchitectureMode.redux.label,
      scenarioName: scenarioKey,
    );

    if (blocSum == null || reduxSum == null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('لم يتم تشغيل هذا السيناريو بعد'),
          trailing: OutlinedButton(
            onPressed: _isRunning
                ? null
                : () async {
                    setState(() => _isRunning = true);
                    final runner =
                        BenchmarkRunner(defaultIterations: _selectedIterations);
                    await runner.runScenario(
                      mode: ArchitectureMode.bloc,
                      scenarioKey: scenarioKey,
                      iterations: _selectedIterations,
                    );
                    await runner.runScenario(
                      mode: ArchitectureMode.redux,
                      scenarioKey: scenarioKey,
                      iterations: _selectedIterations,
                    );
                    if (mounted) setState(() => _isRunning = false);
                  },
            child: const Text('تشغيل منفرد'),
          ),
        ),
      );
    }

    final pdTime = StatisticalSummary.percentageDifference(
      blocSum.meanResponseTimeMs,
      reduxSum.meanResponseTimeMs,
    );
    final dTime = StatisticalSummary.cohensD(
      blocSum.meanResponseTimeMs,
      blocSum.sdResponseTimeMs,
      blocSum.count,
      reduxSum.meanResponseTimeMs,
      reduxSum.sdResponseTimeMs,
      reduxSum.count,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('المؤشر الإحصائي',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('MVVM + BLoC',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('MVVM + Redux',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('متوسط زمن الاستجابة (Mean ms)'),
                    ),
                    Text('${blocSum.meanResponseTimeMs.toStringAsFixed(2)} ms'),
                    Text('${reduxSum.meanResponseTimeMs.toStringAsFixed(2)} ms'),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('الانحراف المعياري (SD ms)'),
                    ),
                    Text('±${blocSum.sdResponseTimeMs.toStringAsFixed(2)} ms'),
                    Text('±${reduxSum.sdResponseTimeMs.toStringAsFixed(2)} ms'),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('متوسط إعادة البناء (Rebuilds)'),
                    ),
                    Text(blocSum.meanRebuilds.toStringAsFixed(1)),
                    Text(reduxSum.meanRebuilds.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text('نسبة الفرق (PD): ${pdTime.toStringAsFixed(2)}%'),
                ),
                Chip(
                  label: Text('حجم التأثير (Cohen's d): ${dTime.toStringAsFixed(3)}'),
                ),
                Chip(
                  label: Text('عدد التكرارات (n): ${blocSum.count}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
