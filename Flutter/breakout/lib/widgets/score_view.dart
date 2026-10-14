import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:breakout/widgets/stroked_text.dart';
import 'package:breakout/providers/score_notifier.dart';
import 'package:breakout/providers/game_state_notifier.dart';

/// スコア表示
class ScoreView extends ConsumerWidget {
  /// コンストラクタ
  const ScoreView({super.key});

  /// 構築
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在の状態
    final state = ref.watch(gameProvider);

    // プレイ中でなければ非表示
    if (state != .playing) return SizedBox.shrink();

    // スコア
    final score = ref.watch(scoreProvider);

    // 表示テキスト
    final text = 'Score: $score';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StrokedText(
        text,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}