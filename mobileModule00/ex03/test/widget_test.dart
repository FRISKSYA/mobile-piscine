// This is a basic Flutter widget test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ex03/main.dart';

void main() {
  testWidgets('Calculator app loads correctly', (WidgetTester tester) async {
    // 計算機アプリをビルド
    await tester.pumpWidget(const MyApp());

    // アプリのタイトルをチェック
    expect(find.text('Calculator'), findsOneWidget);
    
    // テキストウィジェットが存在することを確認（複数あっても良い）
    expect(find.byType(Text), findsWidgets);
  });
}
