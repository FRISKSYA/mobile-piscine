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
        padding: const EdgeInsets.all(8),
        color: Colors.grey.shade200,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 計算式を表示する領域
                Flexible(
                  flex: 1,
                  child: _buildDisplayField(
                    text: expression,
                    fontSize: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                const SizedBox(height: 4),
                // 計算結果を表示する領域
                Flexible(
                  flex: 2,
                  child: _buildDisplayField(
                    text: result,
                    fontSize: 75,
                    fontWeight: FontWeight.bold,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            );
          },
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
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          textAlign: TextAlign.right,
        ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // 利用可能な高さに基づいてボタンの高さを計算
        final availableHeight = constraints.maxHeight;
        // 5行のボタン + パディング用の余裕
        final buttonHeight = (availableHeight / 5.5);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1行目: AC, C, /, *
              Flexible(
                child: _buildButtonRow([
                  CalculatorButton(text: 'AC', onPressed: () => onKeyPressed('AC'), backgroundColor: Colors.redAccent[100]!),
                  CalculatorButton(text: 'C', onPressed: () => onKeyPressed('C'), backgroundColor: Colors.orange[200]!),
                  CalculatorButton(text: '/', onPressed: () => onKeyPressed('/'), backgroundColor: Colors.blueAccent[100]!),
                  CalculatorButton(text: '*', onPressed: () => onKeyPressed('*'), backgroundColor: Colors.blueAccent[100]!),
                ], buttonHeight),
              ),
              
              // 2行目: 7, 8, 9, -
              Flexible(
                child: _buildButtonRow([
                  CalculatorButton(text: '7', onPressed: () => onKeyPressed('7')),
                  CalculatorButton(text: '8', onPressed: () => onKeyPressed('8')),
                  CalculatorButton(text: '9', onPressed: () => onKeyPressed('9')),
                  CalculatorButton(text: '-', onPressed: () => onKeyPressed('-'), backgroundColor: Colors.blueAccent[100]!),
                ], buttonHeight),
              ),
              
              // 3行目: 4, 5, 6, +
              Flexible(
                child: _buildButtonRow([
                  CalculatorButton(text: '4', onPressed: () => onKeyPressed('4')),
                  CalculatorButton(text: '5', onPressed: () => onKeyPressed('5')),
                  CalculatorButton(text: '6', onPressed: () => onKeyPressed('6')),
                  CalculatorButton(text: '+', onPressed: () => onKeyPressed('+'), backgroundColor: Colors.blueAccent[100]!),
                ], buttonHeight),
              ),
              
              // 4行目: 1, 2, 3, =
              Flexible(
                child: _buildButtonRow([
                  CalculatorButton(text: '1', onPressed: () => onKeyPressed('1')),
                  CalculatorButton(text: '2', onPressed: () => onKeyPressed('2')),
                  CalculatorButton(text: '3', onPressed: () => onKeyPressed('3')),
                  CalculatorButton(text: '=', onPressed: () => onKeyPressed('='), backgroundColor: Colors.greenAccent[200]!),
                ], buttonHeight),
              ),
              
              // 5行目: 0, ., 00
              Flexible(
                child: _buildButtonRow([
                  CalculatorButton(text: '0', onPressed: () => onKeyPressed('0'), backgroundColor: Colors.white),
                  CalculatorButton(text: '.', onPressed: () => onKeyPressed('.'), backgroundColor: Colors.white),
                  CalculatorButton(text: '00', onPressed: () => onKeyPressed('00'), backgroundColor: Colors.white),
                  // 残りは空白またはボタンなし
                  const SizedBox(), // 空のスペース
                ], buttonHeight),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // ボタンの行を構築するヘルパーメソッド
  Widget _buildButtonRow(List<Widget> buttons, double height) {
    return Row(
      children: buttons.map((button) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: SizedBox(
              height: height,
              child: button,
            ),
          ),
        );
      }).toList(),
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
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}