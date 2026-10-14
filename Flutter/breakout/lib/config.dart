import 'dart:math';

import 'package:flame/extensions.dart';

/// ゲームコンフィグ
abstract final class GameConfig {
  /// 画面幅
  static const double width = 1280.0;
  /// 画面縦幅
  static const double height = 720.0;
}

/// パドルコンフィグ
abstract final class PaddleConfig {
  /// 配置オフセット
  static Vector2 get offset => Vector2(0.0, -100.0);
  /// 初期位置
  static Vector2 get position => Vector2(GameConfig.width / 2, GameConfig.height) + offset;

  /// サイズ
  static Vector2 get size => Vector2(150, 20);

  /// コーナー半径
  static const double cornerRadius = 6.0;
}

/// ボールコンフィグ
abstract final class BallConfig {
  /// 配置オフセット
  static Vector2 get offset => PaddleConfig.offset - Vector2(0.0, 30.0);
  /// 初期位置
  static Vector2 get position => Vector2(GameConfig.width / 2, GameConfig.height) + offset;

  /// 半径
  static const double radius = 16.0;
  /// 角度
  static const double angle = -pi / 2;

  /// 速度
  static const double speed = 500.0;

  /// 発射角度の最小の傾き
  static const double minFireTilt = 0.17;
  /// ガイドラインの長さ
  static const double guideLineLength = 100.0;
}

/// ブロックコンフィグ
abstract final class BrickConfig {
  /// 破壊毎ポイント
  static const int pointPerBreak = 100;

  /// マージン
  static Vector2 get margin => Vector2.all(4);
  /// サイズ
  static Vector2 size(int columns, int rows) => Vector2(areaSize.x / columns - margin.x, areaSize.y / rows - margin.y);

  /// エリアのマージン
  static Vector2 get areaMargin => Vector2.all(100);
  /// エリアサイズ
  static Vector2 get areaSize => Vector2(GameConfig.width - areaMargin.x, GameConfig.height / 2 - areaMargin.y);
}