import 'dart:math' as math;

class CalculatorEngine {
  /// 計算式を評価し、結果を返す
  static double evaluate(String expression) {
    try {
      // 式をトークンに分解
      List<String> tokens = _tokenize(expression);
      
      // 空の式の場合は0を返す
      if (tokens.isEmpty) {
        return 0;
      }
      
      // 乗算と除算を先に処理
      _processMulDiv(tokens);
      
      // 加算と減算を処理
      return _processAddSub(tokens);
    } catch (e) {
      throw FormatException('Invalid expression: $expression, Error: $e');
    }
  }

  /// 式をトークンに分解する
  static List<String> _tokenize(String expression) {
    if (expression.isEmpty) {
      return [];
    }
    
    List<String> tokens = [];
    String current = '';
    bool previousWasOperator = true; // 最初の文字がマイナスの場合を処理するため
    
    // 式の先頭と末尾をチェック
    if (expression.length > 1) {
      // 演算子で始まる場合（マイナス以外）
      if ((expression[0] == '+' || expression[0] == '*' || expression[0] == '/')) {
        throw FormatException('Invalid expression: cannot start with operator ${expression[0]}');
      }
      
      // 演算子で終わる場合
      final lastChar = expression[expression.length - 1];
      if (lastChar == '+' || lastChar == '-' || lastChar == '*' || lastChar == '/') {
        throw FormatException('Invalid expression: cannot end with operator $lastChar');
      }
    }
    
    // 連続する演算子をチェック - この部分は5++5などの特定のパターンのみをチェック
    // /の後に数字が来るべきだがマイナスは許可
    for (int i = 0; i < expression.length - 1; i++) {
      if (i + 1 < expression.length) {
        final current = expression[i];
        final next = expression[i + 1];
        
        // これらのパターンのみチェック
        if ((current == '+' && next == '+') ||
            (current == '-' && next == '-') ||
            (current == '*' && (next == '+' || next == '*' || next == '/'))) {
          throw FormatException('Invalid expression: consecutive operators $current$next');
        }
      }
    }
    
    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];
      
      // 演算子の場合
      if (char == '+' || char == '*' || char == '/') {
        if (current.isNotEmpty) {
          tokens.add(current);
          current = '';
        }
        tokens.add(char);
        previousWasOperator = true;
      } 
      // マイナスの特別処理 - 負数のサポート
      else if (char == '-') {
        if (current.isNotEmpty) {
          tokens.add(current);
          current = '';
          tokens.add(char);
        } else if (previousWasOperator || i == 0) {
          // 前が演算子だった場合または式の先頭の場合、これは負数の符号
          current = '-';
        } else {
          tokens.add(char);
        }
        previousWasOperator = true;
      }
      // 数字または小数点の場合
      else {
        current += char;
        previousWasOperator = false;
      }
    }
    
    // 最後の数字を追加
    if (current.isNotEmpty) {
      tokens.add(current);
    }
    
    return tokens;
  }

  /// 乗算と除算を処理する
  static void _processMulDiv(List<String> tokens) {
    for (int i = 1; i < tokens.length - 1;) {
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
      } else {
        i += 2; // 演算子と次の数字をスキップ
      }
    }
  }

  /// 加算と減算を処理する
  static double _processAddSub(List<String> tokens) {
    if (tokens.isEmpty) return 0;
    
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

  /// 計算結果を適切にフォーマットする
  static String formatResult(double value) {
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
}