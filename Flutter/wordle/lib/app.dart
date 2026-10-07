import 'package:flutter/material.dart';
import 'package:wordle/page/title_page.dart';

/// アプリ
class App extends StatelessWidget {
  const App({super.key});

  /// アプリタイトル
  static const String title = 'Wordle';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: const TitlePage()
    );
  }
}
