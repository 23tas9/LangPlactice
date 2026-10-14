import 'package:flutter_riverpod/flutter_riverpod.dart';

/// スコアマネージャ
class ScoreNotifier extends Notifier<int> {
  /// 構築
  @override
  int build() => 0;

  /// 加算
  void add(int point) => state += point;

  /// リセット
  void reset() => state = 0;
}

/// スコアプロバイダー
final scoreProvider = NotifierProvider<ScoreNotifier, int>(ScoreNotifier.new);