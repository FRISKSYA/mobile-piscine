import 'package:flutter/material.dart';

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
      body: Column(
        children: [
          // 表示部分
          CalculatorDisplay(expression: expression, result: result),
          // キーパッド部分
          Expanded(flex: 5, child: CalculatorKeypad(onKeyPressed: handleKeyPress)),
        ],
      ),
    );
  }
}

class CalculatorDisplay extends StatelessWidget {
  final String expression;
  final String result;

  const CalculatorDisplay({
    required this.expression,
    required this.result,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 計算式を表示する領域
            _buildDisplayField(
              text: expression,
              fontSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            const SizedBox(height: 10),
            // 計算結果を表示する領域
            _buildDisplayField(
              text: result,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ],
        ),
      ),
    );
  }

  // 表示フィールドを作成するヘルパーメソッド
  Widget _buildDisplayField({
    required String text,
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    required EdgeInsets padding,
  }) {
    return Container(
      padding: padding,
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      ),
    );
  }
}

// 2. ボタン部分を分離したウィジェット（プレースホルダー）
class CalculatorKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;

  const CalculatorKeypad({
    required this.onKeyPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // ここに将来的にボタンのグリッドを実装
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade100,
      child: const Center(
        child: Text('キーパッド部分（実装予定）'),
      ),
    );
  }
}

// 3. ボタン自体を定義したウィジェット
class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const CalculatorButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.fontSize = 24,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
        ),
      ),
    );
  }
}