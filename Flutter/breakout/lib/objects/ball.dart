import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';

import 'package:breakout/breakout.dart';
import 'package:breakout/config.dart';
import 'package:breakout/objects/brick.dart';
import 'package:breakout/objects/paddle.dart';
import 'package:breakout/providers/score_notifier.dart';
import 'package:breakout/providers/game_state_notifier.dart';

/// ボールクラス
class Ball extends CircleComponent
  with CollisionCallbacks, HasGameReference<Breakout>, RiverpodComponentMixin {

  /// コンストラクタ
  Ball({
    required super.position,
    required super.radius,
    required super.angle,
  }) : super(anchor: Anchor.center);
  
  /// 向きの取得
  Vector2 get _direction => Vector2(cos(angle), sin(angle));

  /// 初期処理
  @override
  Future<void> onLoad() async {
    // ヒットボックスの適用
    add(CircleHitbox());
    
    return super.onLoad();
  }
  
  /// 更新処理
  @override
  void update(double dt) {
    super.update(dt);

    // 動いていなければスキップ
    if (ref.read(gameProvider) != .playing) return;

    // 画面外に出る前に反射
    if (position.x < radius) _reflect(Vector2(1, 0));
    if (game.size.x - position.x < radius) _reflect(Vector2(-1, 0));

    if (position.y < radius) _reflect(Vector2(0, 1));

    // 向いている方向に移動
    position += _direction * BallConfig.speed * dt;

    // 画面下部を超えたら削除
    if (game.size.y < position.y - radius) {
      // ゲームオーバーに設定
      ref.read(gameProvider.notifier).set(.gameOver);
    }
  }
  
  /// 衝突判定開始処理
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // 自機との衝突
    if (other is Paddle) {
      _bounceOfPaddle(other);
    }
    // ブロックとの衝突
    else if (other is Brick) {
      // 反射
      _reflect(_normalFrom(other));

      // ブロック破壊
      other.removeFromParent();
      
      // ポイント加算
      ref.read(scoreProvider.notifier).add(100);
    }
  }

  /// リセット
  void reset({required Vector2 position, required double angle}) {
    this.position = position;
    this.angle = angle;
  }

  /// 自機で反射
  void _bounceOfPaddle(Paddle paddle) {
    // 上向きならスキップ
    if (_direction.y <= 0) return;

    // 自機中心からのオフセット
    final offset = (absoluteCenter.x - paddle.absoluteCenter.x) / (paddle.size.x / 2);
    final t = offset.clamp(-1.0, 1.0);

    // 自機中心からの離れ具合によって反射角度を変更
    final newAngle = -pi / 2 + (pi / 3) * t;

    // 新角度の適用
    angle = newAngle;
  }

  // 反射
  void _reflect(Vector2 normal) {
    // 現在の向き
    final dir = _direction;

    // 上向きか
    if (dir.dot(normal) < 0) {
      // 向きを反転させて角度を適用
      final r = dir.reflected(normal);
      angle = atan2(r.y, r.x);
    }
  }

  /// 他オブジェクトから見てどの方向に存在するか
  Vector2 _normalFrom(PositionComponent other) {
    final rect = other.toAbsoluteRect();
    
    // otherの中心からボールがどれだけ離れているか
    final dx = absoluteCenter.x - rect.center.dx;
    final dy = absoluteCenter.y - rect.center.dy;

    // 辺の外にどれだけ出ているか
    if (dx.abs() - rect.width / 2 > dy.abs() - rect.height / 2) {
      return Vector2(dx.sign, 0);
    }
    else {
      return Vector2(0, dy.sign);
    }
  }
}