import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:breakout/widgets/stroked_text.dart';
import 'package:breakout/providers/game_state_notifier.dart';
import 'package:breakout/providers/score_notifier.dart';

/// ゲームクリア画面
class GameClearView extends ConsumerWidget {
  /// コンストラクタ
  const GameClearView({super.key, required this.onRestart});

  /// リスタートコールバック
  final VoidCallback onRestart;

  /// 構築
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在の状態
    final state = ref.watch(gameProvider);

    // クリアでないなら非表示
    if (state != .clear) return SizedBox.shrink();

    // 最終スコア
    final score = ref.read(scoreProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16.0,
        children: [
          StrokedText(
            'GAME CLEAR!',
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