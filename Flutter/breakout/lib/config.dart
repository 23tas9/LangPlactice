import 'dart:math';

import 'package:flame/extensions.dart';

/// パドルコンフィグ
abstract final class PaddleConfig {
  /// サイズ
  static Vector2 get size => Vector2(150, 20);
  /// コーナー半径
  static const double cornerRadius = 6.0;
  /// 配置オフセット
  static Vector2 get offset => Vector2(0.0, -100.0);
}

/// ボールコンフィグ
abstract final class BallConfig {
  /// 半径
  static const double radius = 16.0;
  /// 角度
  static const double angle = -pi / 2;
  /// 配置オフセット
  static Vector2 get offset => PaddleConfig.offset - Vector2(0.0, 30.0);
  // 速度
  static const double speed = 500.0;
}