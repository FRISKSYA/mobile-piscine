import 'package:flutter/material.dart';

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