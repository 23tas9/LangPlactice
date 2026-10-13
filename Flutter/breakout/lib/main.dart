import 'package:breakout/widgets/score_view.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:breakout/breakout.dart';

final gameWidgetKey = GlobalKey<RiverpodAwareGameWidgetState<Breakout>>();

void main() {
  runApp(ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            RiverpodAwareGameWidget(game: Breakout(columns: 20, rows: 6), key: gameWidgetKey),
            const ScoreView(),
          ],
        ),
      ),
    );
  }
}