import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import 'package:breakout/breakout.dart';

/// 自機
class Paddle extends PositionComponent
  with HasGameReference<Breakout> {
  /// コンストラクタ
  Paddle({
    required super.position,
    required super.size,
    required this._cornerRadius,
  }) : super(anchor: Anchor.center);

  /// コーナー半径
  final double _cornerRadius;

  /// 色
  final _paint = Paint()
    ..color = Colors.white;

  /// 初期処理
  @override
  Future<void> onLoad() async {
    // ヒットボックス適用
    add(RectangleHitbox());

    return super.onLoad();
  }

  /// 更新処理
  @override
  void update(double dt) {
    super.update(dt);
  }

  /// 描画処理
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // RoundedRectangleを描画
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size.toSize(),
        Radius.circular(_cornerRadius)
      ), _paint
    );
  }

  /// 移動
  void moveTo(double x) {
    // 画面サイズでクランプ
    position.x = clampDouble(x, width / 2, game.size.x - width / 2);
  }
}