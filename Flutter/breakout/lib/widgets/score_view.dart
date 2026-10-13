import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:breakout/providers/score_notifier.dart';

/// スコア表示
class ScoreView extends ConsumerWidget {
  const ScoreView({super.key});

  /// ベースのテキストスタイル
  static const TextStyle _baseStyle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold
  );

  /// 構築
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // スコア
    final score = ref.watch(scoreProvider);

    // 表示テキスト
    final text = 'Score: $score';

    // 表示テキスト内側
    final innerText = Text(
      text,
      style: _baseStyle.copyWith(color: Colors.white),
    );

    // 表示テキスト外側
    final outerText = Text(
      text,
      style: _baseStyle.copyWith(
        foreground: Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(children: [ innerText, outerText ]),
    );
  }
}