import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:breakout/widgets/stroked_text.dart';
import 'package:breakout/providers/game_state_notifier.dart';
import 'package:breakout/providers/score_notifier.dart';

/// リザルト画面
class ResultView extends ConsumerWidget {
  /// コンストラクタ
  const ResultView({super.key, required this.onRestart});

  /// リスタートコールバック
  final VoidCallback onRestart;

  /// 構築
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在のスコア
    final score = ref.watch(scoreProvider);

    // 現在の状態
    final state = ref.watch(gameProvider);

    // タイトルテキスト
    final titleText = switch (state) {
      .clear => 'CLEAR',
      .gameOver => 'GAMEOVER',
      _ => ''
    };

    // 表示するタイトルがなければ非表示
    if (titleText.isEmpty) return SizedBox.shrink();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16.0,
        children: [
          StrokedText(
            titleText,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          StrokedText(
            'RESULT: $score',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: onRestart,
            child: Text('RESTART'),
          ),
        ],
      ),
    );
  }
}