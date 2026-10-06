import 'package:flutter_test/flutter_test.dart';
import 'package:waddahp/core/di.dart';
import 'package:waddahp/main.dart';

void main() {
  testWidgets('تحميل الصفحة وعرض العناصر', (tester) async {
    setupDependencies();

    await tester.pumpWidget(const MyApp());
    expect(find.text('MVVM + BLoC'), findsOneWidget);

    // انتظار انتهاء التحميل المحاكى (400 ms)
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('عنصر رقم 1'), findsOneWidget);
  });
}
