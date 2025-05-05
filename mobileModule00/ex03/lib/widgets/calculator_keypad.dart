import 'package:flutter/material.dart';
import 'calculator_button.dart';

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