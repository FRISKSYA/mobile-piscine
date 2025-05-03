import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String expression = '0';
  String result = '0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Columnのchildren配列内に追加
          Expanded(
            flex: 2,  // 画面の上部を表示セクション用に確保
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,  // 背景色
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,  // 上揃え
                crossAxisAlignment: CrossAxisAlignment.stretch,  // 横幅いっぱい
                children: [
                  // 計算式を表示する領域
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    alignment: Alignment.centerRight,  // 右揃え
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      expression,  // 計算式を表示
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 10),  // 間隔
                  // 計算結果を表示する領域
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    alignment: Alignment.centerRight,  // 右揃え
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      result,  // 計算結果を表示
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}