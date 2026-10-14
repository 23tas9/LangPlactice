import 'package:breakout/widgets/game_clear_view.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:breakout/breakout.dart';
import 'package:breakout/widgets/score_view.dart';
import 'package:breakout/widgets/game_over_view.dart';

final gameWidgetKey = GlobalKey<RiverpodAwareGameWidgetState<Breakout>>();

/// エントリーポイント
void main() {
  // アプリ実行
  runApp(ProviderScope(child: App()));
}

/// アプリ
class App extends StatelessWidget {
  /// コンストラクタ
  App({super.key});

  /// ゲーム
  final game = Breakout(columns: 16, rows: 4);

  /// 構築
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            RiverpodAwareGameWidget(game: game, key: gameWidgetKey),
            const ScoreView(),
            GameOverView(onRestart: game.restart),
            GameClearView(onRestart: game.restart)
          ],
        ),
      ),
    );
  }
}