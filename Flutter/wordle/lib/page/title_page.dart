import 'package:flutter/material.dart';
import 'package:wordle/app.dart';

/// タイトルページ
class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(App.title)
      ),
      body: Container(),
    );
  }
}
