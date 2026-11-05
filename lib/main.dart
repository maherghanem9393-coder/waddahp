import 'package:flutter/material.dart';

import 'core/di.dart';
import 'view/items_page.dart';
import 'viewmodel/items_view_model.dart';

void main() {
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final ArchitectureMode initialMode;

  const MyApp({
    super.key,
    this.initialMode = ArchitectureMode.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مقارنة MVVM+BLoC و MVVM+Redux',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      // اتجاه الواجهة من اليمين إلى اليسار لدعم اللغة العربية
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: ItemsPage(initialMode: initialMode),
    );
  }
}
