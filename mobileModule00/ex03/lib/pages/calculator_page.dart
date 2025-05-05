import 'package:flutter/material.dart';
import '../widgets/calculator_display.dart';
import '../widgets/calculator_keypad.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String expression = '0';
  String result = '0';

  void handleKeyPress(String key) {
    // 将来的にキー押下時の処理を実装
    print(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 表示部分
            CalculatorDisplay(expression: expression, result: result),
            // キーパッド部分（画面下部に配置、LayoutBuilderでスペースに合わせる）
            Expanded(
              flex: 5,
              child: CalculatorKeypad(onKeyPressed: handleKeyPress),
            ),
          ],
        ),
      ),
    );
  }
}