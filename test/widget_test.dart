import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_compare_app/core/di.dart';
import 'package:state_compare_app/main.dart';
import 'package:state_compare_app/viewmodel/items_view_model.dart';

void main() {
  setUp(() {
    setupDependencies();
  });

  testWidgets('اختبار واجهة MVVM + BLoC والتبديل إلى MVVM + Redux',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialMode: ArchitectureMode.bloc));
    await tester.pumpAndSettle();

    expect(find.textContaining('MVVM+BLoC'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsWidgets);

    // التبديل إلى MVVM + Redux من شريط الاختيار
    await tester.tap(find.text('MVVM + Redux'));
    await tester.pumpAndSettle();

    expect(find.textContaining('MVVM+Redux'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsWidgets);
  });
}
