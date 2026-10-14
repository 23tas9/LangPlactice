import 'package:breakout/widgets/stroked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:breakout/providers/score_notifier.dart';

/// スコア表示
class ScoreView extends ConsumerWidget {
  const ScoreView({super.key});

  /// 構築
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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