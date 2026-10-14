import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ゲーム状態
enum GameState {
  /// 準備
  ready,
  /// プレイ中
  playing,
  /// ゲームオーバー
  gameOver,
  /// クリア
  clear,
}

/// ゲームマネージャー
class GameStateNotifier extends Notifier<GameState> {
  /// 構築
  @override
  GameState build() => .ready;

  /// 状態変更
  void set(GameState next) => state = next;

  /// リセット
  void reset() => state = .ready;
}

/// ゲームプロバイダー
final gameProvider = NotifierProvider<GameStateNotifier, GameState>(GameStateNotifier.new);