import 'package:breakout/providers/score_notifier.dart';
import 'package:breakout/widgets/stroked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:breakout/providers/game_state_notifier.dart';

/// ゲームオーバー画面
class GameOverView extends ConsumerWidget {
  const GameOverView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在の状態
    final state = ref.watch(gameProvider);

    // ゲームオーバーでないなら非表示
    if (state != .gameOver) return SizedBox.shrink();

    // 最終スコア
    final score = ref.watch(scoreProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16.0,
        children: [
          StrokedText(
            'GAMEOVER',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          StrokedText(
            'RESULT: $score',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: StrokedText(
              'RETRY',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}