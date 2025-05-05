import 'package:flutter/material.dart';
import 'dart:math' as math;
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
  bool shouldReplaceExpression = true;
  bool hasCalculated = false;

  void handleKeyPress(String key) {
    print(key);
    setState(() {
      switch (key) {
        case 'AC':
          _clearAll();
          break;
        case 'C':
          _clear();
          break;
        case '=':
          _calculate();
          break;
        case '+':
        case '-':
        case '*':
        case '/':
          _addOperator(key);
          break;
        case '.':
          _addDecimalPoint();
          break;
        default:
          _addDigit(key);
          break;
      }
    });
  }

  void _clearAll() {
    expression = '0';
    result = '0';
    shouldReplaceExpression = true;
    hasCalculated = false;
  }

  void _clear() {
    // 現在の式が'0'でない場合、最後の文字を削除
    if (expression != '0') {
      if (expression.length > 1) {
        expression = expression.substring(0, expression.length - 1);
      } else {
        expression = '0';
        shouldReplaceExpression = true;
      }
    }
  }

  void _addDigit(String digit) {
    if (hasCalculated) {
      // 計算後に数字を入力した場合、新しい計算を開始
      expression = digit;
      result = '0';
      hasCalculated = false;
      shouldReplaceExpression = false;
    } else if (shouldReplaceExpression) {
      // 表示を置き換える場合
      expression = digit;
      shouldReplaceExpression = false;
    } else {
      // 表示に追加する場合
      expression += digit;
    }
  }

  void _addOperator(String operator) {
    if (hasCalculated) {
      // 計算結果に演算子を追加する場合
      expression = result + operator;
      shouldReplaceExpression = false;
      hasCalculated = false;
    } else {
      // 最後の文字が演算子かどうかチェック
      if (expression.isNotEmpty) {
        final lastChar = expression[expression.length - 1];
        if (lastChar == '+' || lastChar == '-' || lastChar == '*' || lastChar == '/') {
          // 演算子を置き換え
          expression = expression.substring(0, expression.length - 1) + operator;
        } else {
          // 演算子を追加
          expression += operator;
        }
      }
      shouldReplaceExpression = false;
    }
  }

  void _addDecimalPoint() {
    if (hasCalculated) {
      // 計算後に小数点を入力した場合、新しい計算を開始
      expression = '0.';
      result = '0';
      hasCalculated = false;
      shouldReplaceExpression = false;
      return;
    }

    // 最後の数字に既に小数点があるかチェック
    bool hasDecimal = false;
    // 最後の演算子以降の部分を取得
    int lastOperatorIndex = -1;
    for (int i = expression.length - 1; i >= 0; i--) {
      if (expression[i] == '+' || expression[i] == '-' || expression[i] == '*' || expression[i] == '/') {
        lastOperatorIndex = i;
        break;
      }
    }
    
    String currentNumber = lastOperatorIndex >= 0 
        ? expression.substring(lastOperatorIndex + 1)
        : expression;
    
    hasDecimal = currentNumber.contains('.');

    if (!hasDecimal) {
      if (shouldReplaceExpression) {
        expression = '0.';
        shouldReplaceExpression = false;
      } else {
        expression += '.';
      }
    }
  }

  void _calculate() {
    try {
      // 式の最後が演算子であれば削除
      String evaluableExpression = expression;
      if (evaluableExpression.isNotEmpty) {
        final lastChar = evaluableExpression[evaluableExpression.length - 1];
        if (lastChar == '+' || lastChar == '-' || lastChar == '*' || lastChar == '/') {
          evaluableExpression = evaluableExpression.substring(0, evaluableExpression.length - 1);
        }
      }
      
      // 式を評価
      final evaluated = _evaluateExpression(evaluableExpression);
      
      // 結果を表示用にフォーマット
      result = _formatResult(evaluated);
      hasCalculated = true;
    } catch (e) {
      result = 'Error';
    }
  }

  double _evaluateExpression(String expr) {
    // 簡易的な計算式の評価
    // 実際の実装ではより堅牢な方法を使うべき
    
    // 複数の演算子を含む式を分解するためのヘルパー関数
    List<String> tokenize(String expression) {
      List<String> tokens = [];
      String current = '';
      
      for (int i = 0; i < expression.length; i++) {
        String char = expression[i];
        if (char == '+' || char == '-' || char == '*' || char == '/') {
          if (current.isNotEmpty) {
            tokens.add(current);
            current = '';
          }
          tokens.add(char);
        } else {
          current += char;
        }
      }
      
      if (current.isNotEmpty) {
        tokens.add(current);
      }
      
      return tokens;
    }
    
    // 式をトークンに分解
    List<String> tokens = tokenize(expr);
    
    // 乗算と除算を先に処理
    for (int i = 1; i < tokens.length - 1; i += 2) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        double left = double.parse(tokens[i - 1]);
        double right = double.parse(tokens[i + 1]);
        double result;
        
        if (tokens[i] == '*') {
          result = left * right;
        } else {
          if (right == 0) throw Exception('Division by zero');
          result = left / right;
        }
        
        tokens[i - 1] = result.toString();
        tokens.removeAt(i);
        tokens.removeAt(i);
        i -= 2;
      }
    }
    
    // 加算と減算を処理
    double result = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length - 1; i += 2) {
      double right = double.parse(tokens[i + 1]);
      
      if (tokens[i] == '+') {
        result += right;
      } else if (tokens[i] == '-') {
        result -= right;
      }
    }
    
    return result;
  }

  String _formatResult(double value) {
    // 整数の場合は小数点以下を表示しない
    if (value == value.truncate()) {
      return value.truncate().toString();
    }
    
    // 小数点以下の桁数を制限
    String result = value.toString();
    
    // 小数点以下が9桁以上あれば、科学的表記法を使用
    if (result.contains('.') && result.split('.')[1].length > 8) {
      return value.toStringAsExponential(8);
    }
    
    return result;
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