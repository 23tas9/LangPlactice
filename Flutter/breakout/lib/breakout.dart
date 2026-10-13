import 'dart:math';

import 'package:flutter/material.dart' hide PointerMoveEvent;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';

import 'package:breakout/objects/ball.dart';
import 'package:breakout/objects/brick.dart';
import 'package:breakout/objects/paddle.dart';

/// ブロック崩し
class Breakout extends FlameGame
  with HasCollisionDetection, PointerMoveCallbacks, DragCallbacks, RiverpodGameMixin {
  
  /// コンストラクタ
  Breakout({
    required this._columns,
    required this._rows,
  });

  /// ボールのスピード
  static const double speed = 500.0;

  /// 発射角度の最小の傾き
  static const double _minFireTilt = 0.17;

  /// ブロックの列数
  final int _columns;
  /// ブロックの行数
  final int _rows;

  /// ブロックエリアのマージン
  final Vector2 _brickAreaMargin = Vector2.all(100);
  /// ブロックアリアのサイズ
  late final Vector2 _brickAreaSize = Vector2(size.x - _brickAreaMargin.x, size.y / 2 - _brickAreaMargin.y);

  /// ブロックのマージン
  final Vector2 _brickMargin = Vector2.all(4);
  /// ブロックのサイズ
  late final Vector2 _brickSize = Vector2(_brickAreaSize.x / _columns - _brickMargin.x, _brickAreaSize.y / _rows - _brickMargin.y);


  /// 自機
  late final Paddle _paddle;
  /// ボール
  late final Ball _ball;

  /// ボールの発射角度
  double _fireAngle = -pi / 2;

  /// 発射角度ペイント設定
  final Paint _guideLinePaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke;

  /// ホールド中か
  bool _isHolding = false;
  
  /// 初期処理
  @override
  Future<void> onLoad() async {
    // 自機初期化
    _paddle = Paddle(position: Vector2(size.x / 2, size.y - 150), size: Vector2(250, 20), cornerRadius: 6);
    add(_paddle);

    // ボール初期化
    _ball = Ball(position: Vector2(size.x / 2, size.y - 180), radius: 16, angle: _fireAngle);
    add(_ball);

    // 行列によってブロックの初期化
    for (int y = 0; y < _rows; y++) {
      for (int x = 0; x < _columns; x++) {
        // ブロックの位置
        final pos = (_brickAreaMargin / 2) + Vector2(
          _brickMargin.x / 2 + (_brickSize.x + _brickMargin.x) * x,
          _brickMargin.y / 2 + (_brickSize.y + _brickMargin.y) * y
        );
        
        // ブロック
        final brick = Brick(position: pos, size: _brickSize);
        add(brick);
      }
    }

    return super.onLoad();
  }

  /// 描画処理
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 開始済みか非ホールドならスキップ
    if (_ball.isPlaying || !_isHolding) return;

    // 開始位置
    final begin = _ball.position.toOffset();
    // 終了位置
    final end = begin + Offset.fromDirection(_fireAngle, 100.0);

    // 線分の描画
    canvas.drawLine(begin, end, _guideLinePaint);
  }

  /// ドラッグ開始処理
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    // ホールド中に設定
    _isHolding = true;
  }

  /// ドラッグ更新処理
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    // 開始済みなら自機を追従させスキップ
    if (_ball.isPlaying) {
      // 自機をポインタに追従
      _trackPaddle(event.canvasEndPosition.x);

      return;
    }
    
    // 差分ベクトル
    final diff = event.canvasEndPosition - _ball.position;

    // ボールより下の位置はスキップ
    if (diff.y >= 0) return;

    // 角度の設定
    _fireAngle = atan2(diff.y, diff.x).clamp(-pi + _minFireTilt, -_minFireTilt);
  }

  /// ドラッグ終了処理
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    // 非ホールド中に設定
    _isHolding = false;

    // 開始済みならスキップ
    if (_ball.isPlaying) return;

    // 角度の適用
    _ball.angle = _fireAngle;

    // ボールを発射
    _ball.isPlaying = true;
  }

  /// ポインタ操作時処理
  @override
  void onPointerMove(PointerMoveEvent event) {
    super.onPointerMove(event);

    // 自機をポインタに追従
    _trackPaddle(event.canvasPosition.x);
  }

  /// 指定位置に自機を追従
  void _trackPaddle(double x) {
    // 自機を追従させる
    _paddle.moveTo(x);

    // プレイ中でなければボールを自機に追従させる
    if (!_ball.isPlaying) {
      _ball.x = _paddle.x;
    }
  }
}