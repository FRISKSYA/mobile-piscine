import 'package:flutter_test/flutter_test.dart';
import 'package:ex03/utils/calculator_engine.dart';

void main() {
  group('CalculatorEngine Edge Cases and Bugs', () {
    
    test('Negative numbers at start of expression', () {
      expect(CalculatorEngine.evaluate('-5'), -5);
      expect(CalculatorEngine.evaluate('-10+5'), -5);
      expect(CalculatorEngine.evaluate('-2*-3'), 6);
    });

    test('Multiple operations with same operator', () {
      expect(CalculatorEngine.evaluate('5+5+5'), 15);
      expect(CalculatorEngine.evaluate('10-5-3'), 2);
      expect(CalculatorEngine.evaluate('2*3*4'), 24);
      expect(CalculatorEngine.evaluate('24/6/2'), 2);
    });

    test('Operations with zero', () {
      expect(CalculatorEngine.evaluate('0+5'), 5);
      expect(CalculatorEngine.evaluate('5-0'), 5);
      expect(CalculatorEngine.evaluate('0*5'), 0);
      expect(CalculatorEngine.evaluate('0/5'), 0);
    });

    test('Consecutive operators behavior', () {
      // 連続した演算子は例外をスローすべき
      expect(() => CalculatorEngine.evaluate('5++5'), throwsA(isA<FormatException>()));
      expect(() => CalculatorEngine.evaluate('5--5'), throwsA(isA<FormatException>()));
      // 5+-5は許可される（負数としての-5）
      // expect(() => CalculatorEngine.evaluate('5+-5'), throwsA(isA<FormatException>()));
    });

    test('Large numbers', () {
      expect(CalculatorEngine.evaluate('999999999+1'), 1000000000);
      expect(CalculatorEngine.evaluate('1000000*1000'), 1000000000);
    });

    test('Very small decimal results', () {
      expect(CalculatorEngine.evaluate('1/1000'), 0.001);
      expect(CalculatorEngine.evaluate('1/1000000'), 0.000001);
    });

    test('Long expressions', () {
      expect(CalculatorEngine.evaluate('1+2+3+4+5+6+7+8+9+10'), 55);
      expect(CalculatorEngine.evaluate('1*2*3*4*5'), 120);
      expect(CalculatorEngine.evaluate('100-20-15-10-5-4-3-2-1'), 40);
    });

    test('Mixed decimal and integer', () {
      expect(CalculatorEngine.evaluate('5.5+4.5'), 10);
      expect(CalculatorEngine.evaluate('10.5-0.5'), 10);
      expect(CalculatorEngine.evaluate('2.5*2'), 5);
      expect(CalculatorEngine.evaluate('10/2.5'), 4);
    });

    test('Invalid expressions', () {
      expect(() => CalculatorEngine.evaluate('5+'), throwsA(isA<FormatException>()));
      expect(() => CalculatorEngine.evaluate('*5'), throwsA(isA<FormatException>()));
      expect(() => CalculatorEngine.evaluate('5*/2'), throwsA(isA<FormatException>()));
    });
  });
}