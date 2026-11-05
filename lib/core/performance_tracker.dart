import 'dart:math' as math;

/// سجل قياس فردي لتكرار واحد ضمن سيناريو تجريبي.
class BenchmarkRecord {
  final String architecture; // 'MVVM+BLoC' أو 'MVVM+Redux'
  final String scenarioName;
  final int iteration;
  final int datasetSize;
  final double responseTimeMs;
  final int widgetRebuilds;
  final DateTime timestamp;

  const BenchmarkRecord({
    required this.architecture,
    required this.scenarioName,
    required this.iteration,
    required this.datasetSize,
    required this.responseTimeMs,
    required this.widgetRebuilds,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'architecture': architecture,
        'scenario': scenarioName,
        'iteration': iteration,
        'dataset_size': datasetSize,
        'response_time_ms': double.parse(responseTimeMs.toStringAsFixed(3)),
        'widget_rebuilds': widgetRebuilds,
        'timestamp': timestamp.toIso8601String(),
      };

  String toCsvRow() =>
      '$architecture,$scenarioName,$iteration,$datasetSize,${responseTimeMs.toStringAsFixed(3)},$widgetRebuilds,${timestamp.toIso8601String()}';
}

/// ملخص إحصائي لمجموعة تكرارات (المتوسط الحسابي، الانحراف المعياري، القيم الصغرى والعظمى).
class StatisticalSummary {
  final String architecture;
  final String scenarioName;
  final int count;
  final double meanResponseTimeMs;
  final double sdResponseTimeMs;
  final double minResponseTimeMs;
  final double maxResponseTimeMs;
  final double meanRebuilds;
  final double sdRebuilds;

  const StatisticalSummary({
    required this.architecture,
    required this.scenarioName,
    required this.count,
    required this.meanResponseTimeMs,
    required this.sdResponseTimeMs,
    required this.minResponseTimeMs,
    required this.maxResponseTimeMs,
    required this.meanRebuilds,
    required this.sdRebuilds,
  });

  /// حساب نسبة الفرق المئوية (Percentage Difference) وفق معادلة الفصل الثالث:
  /// PD = (|X_BLoC - X_Redux| / ((X_BLoC + X_Redux) / 2)) * 100
  static double percentageDifference(double val1, double val2) {
    final avg = (val1 + val2) / 2.0;
    if (avg == 0) return 0.0;
    return ((val1 - val2).abs() / avg) * 100.0;
  }

  /// حساب حجم التأثير (Cohen's d) وفق معادلة الفصل الثالث:
  /// d = (M1 - M2) / SD_pooled
  static double cohensD(
      double mean1, double sd1, int n1, double mean2, double sd2, int n2) {
    if (n1 + n2 <= 2) return 0.0;
    final pooledVar =
        (((n1 - 1) * sd1 * sd1) + ((n2 - 1) * sd2 * sd2)) / (n1 + n2 - 2);
    final pooledSd = math.sqrt(pooledVar);
    if (pooledSd == 0) return 0.0;
    return (mean1 - mean2) / pooledSd;
  }
}

/// أداة الرصد البرمجي لزمن الاستجابة (Response Time) عبر الطابع الزمني (Timestamp / Stopwatch)
/// لتعزيز موثوقية القياس إلى جانب Flutter DevTools كما ورد في الفصل الثالث (قسم 3.8).
class PerformanceTracker {
  static final List<BenchmarkRecord> _records = [];
  static final Map<String, Stopwatch> _activeTimers = {};

  static List<BenchmarkRecord> get records => List.unmodifiable(_records);

  static void startOperation(String operationKey) {
    final sw = Stopwatch()..start();
    _activeTimers[operationKey] = sw;
  }

  static double stopOperation(String operationKey) {
    final sw = _activeTimers.remove(operationKey);
    if (sw == null) return 0.0;
    sw.stop();
    return sw.elapsedMicroseconds / 1000.0;
  }

  static void addRecord(BenchmarkRecord record) {
    _records.add(record);
  }

  static void clear() {
    _records.clear();
    _activeTimers.clear();
  }

  static StatisticalSummary? summarize({
    required String architecture,
    required String scenarioName,
  }) {
    final filtered = _records
        .where((r) =>
            r.architecture == architecture && r.scenarioName == scenarioName)
        .toList();
    if (filtered.isEmpty) return null;

    final n = filtered.length;
    final times = filtered.map((e) => e.responseTimeMs).toList();
    final rebuilds = filtered.map((e) => e.widgetRebuilds.toDouble()).toList();

    final meanTime = times.reduce((a, b) => a + b) / n;
    final sdTime = _stdDev(times, meanTime);
    final minTime = times.reduce(math.min);
    final maxTime = times.reduce(math.max);

    final meanReb = rebuilds.reduce((a, b) => a + b) / n;
    final sdReb = _stdDev(rebuilds, meanReb);

    return StatisticalSummary(
      architecture: architecture,
      scenarioName: scenarioName,
      count: n,
      meanResponseTimeMs: meanTime,
      sdResponseTimeMs: sdTime,
      minResponseTimeMs: minTime,
      maxResponseTimeMs: maxTime,
      meanRebuilds: meanReb,
      sdRebuilds: sdReb,
    );
  }

  static double _stdDev(List<double> values, double mean) {
    if (values.length <= 1) return 0.0;
    final sumSq = values
        .map((x) => (x - mean) * (x - mean))
        .reduce((a, b) => a + b);
    return math.sqrt(sumSq / (values.length - 1));
  }

  static String exportCsv() {
    final buffer = StringBuffer();
    buffer.writeln(
        'Architecture,Scenario,Iteration,DatasetSize,ResponseTimeMs,WidgetRebuilds,Timestamp');
    for (final r in _records) {
      buffer.writeln(r.toCsvRow());
    }
    return buffer.toString();
  }
}
