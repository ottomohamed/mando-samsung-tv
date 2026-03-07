// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mando_samsung_tv/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    // تشغيل التطبيق
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // التحقق أن التطبيق يعمل - يجد MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Remote screen shows connection status', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // يجب أن يظهر نص الحالة
    expect(
      find.textContaining('Disconnected').evaluate().isNotEmpty ||
      find.textContaining('Connected').evaluate().isNotEmpty,
      isTrue,
    );
  });

  testWidgets('Find TV button exists', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // يجب أن يظهر زر البحث عن التلفاز
    expect(find.text('Find TV'), findsOneWidget);
  });
}
