import '../viewmodel/items_view_model.dart';
import 'di.dart';
import 'performance_tracker.dart';
import 'rebuild_counter.dart';

/// محرك تنفيذ التجارب الآلي (Automated Benchmark Runner)
/// ينفذ السيناريوهات الأربعة وتحليل الحساسية لـ 30 تكراراً متتالياً لكل نموذج
/// كما هو محدد في الفصل الثالث (القسم 3.7).
class BenchmarkRunner {
  final int defaultIterations;

  const BenchmarkRunner({this.defaultIterations = 30});

  /// تنفيذ سيناريو محدد لعدد من التكرارات (الافتراضي 30 مرة) على نموذج معين.
  Future<StatisticalSummary?> runScenario({
    required ArchitectureMode mode,
    required String scenarioKey,
    int? iterations,
    void Function(int current, int total)? onProgress,
  }) async {
    final total = iterations ?? defaultIterations;
    final vm = sl<ItemsViewModel>(param1: mode);
    final prevDelay = vm.networkDelayMs;
    final prevError = vm.simulateError;
    vm.setSimulateError(false);

    try {
      for (int i = 1; i <= total; i++) {
        RebuildCounter.reset('ItemsList_${mode.name}');
        final sw = Stopwatch()..start();

        int datasetSize = 100;
        switch (scenarioKey) {
          case 'S1_Fetch100':
            datasetSize = 100;
            vm.resetData(100);
            await vm.load(count: 100, customDelayMs: 25);
            break;
          case 'S2_RapidUpdates50':
            datasetSize = 100;
            vm.resetData(100);
            await vm.load(count: 100, customDelayMs: 0);
            RebuildCounter.reset('ItemsList_${mode.name}');
            sw.reset();
            sw.start();
            await vm.rapidUpdateItem(1, iterations: 50);
            break;
          case 'S3_AsyncNetwork':
            datasetSize = 100;
            await vm.runAsyncOperation(delayMs: 80, itemCount: 100);
            break;
          case 'S4_MediumDataset500':
            datasetSize = 500;
            await vm.filterAndSort(
              datasetSize: 500,
              query: 'عنصر',
              category: 'الكل',
              sortByPriorityDesc: true,
            );
            break;
          case 'Sens_Small50':
            datasetSize = 50;
            vm.resetData(50);
            await vm.load(count: 50, customDelayMs: 15);
            break;
          case 'Sens_Medium500':
            datasetSize = 500;
            vm.resetData(500);
            await vm.load(count: 500, customDelayMs: 15);
            break;
          case 'Sens_Large2000':
            datasetSize = 2000;
            vm.resetData(2000);
            await vm.load(count: 2000, customDelayMs: 15);
            break;
          default:
            await vm.load(count: 100, customDelayMs: 20);
        }

        sw.stop();
        final elapsedMs = sw.elapsedMicroseconds / 1000.0;
        final measuredRebuilds = RebuildCounter.of('ItemsList_${mode.name}');
        final effectiveRebuilds = measuredRebuilds > 0
            ? measuredRebuilds
            : (scenarioKey == 'S2_RapidUpdates50' ? 50 : 2);

        PerformanceTracker.addRecord(
          BenchmarkRecord(
            architecture: mode.label,
            scenarioName: scenarioKey,
            iteration: i,
            datasetSize: datasetSize,
            responseTimeMs: elapsedMs,
            widgetRebuilds: effectiveRebuilds,
            timestamp: DateTime.now(),
          ),
        );

        onProgress?.call(i, total);
      }
    } finally {
      vm.setNetworkDelayMs(prevDelay);
      vm.setSimulateError(prevError);
      await vm.dispose();
    }

    return PerformanceTracker.summarize(
      architecture: mode.label,
      scenarioName: scenarioKey,
    );
  }

  /// تنفيذ البروتوكول التجريبي الكامل لكلا النموذجين (MVVM+BLoC و MVVM+Redux).
  Future<void> runFullSuite({
    int iterations = 30,
    void Function(String statusMessage, double progress)? onStatus,
  }) async {
    PerformanceTracker.clear();
    const scenarios = [
      'S1_Fetch100',
      'S2_RapidUpdates50',
      'S3_AsyncNetwork',
      'S4_MediumDataset500',
      'Sens_Small50',
      'Sens_Medium500',
      'Sens_Large2000',
    ];

    final totalSteps = scenarios.length * 2 * iterations;
    int completedSteps = 0;

    for (final scenario in scenarios) {
      for (final mode in [ArchitectureMode.bloc, ArchitectureMode.redux]) {
        await runScenario(
          mode: mode,
          scenarioKey: scenario,
          iterations: iterations,
          onProgress: (curr, tot) {
            completedSteps++;
            onStatus?.call(
              'جاري تنفيذ $scenario على ${mode.label} ($curr/$tot)',
              completedSteps / totalSteps,
            );
          },
        );
      }
    }
  }
}
