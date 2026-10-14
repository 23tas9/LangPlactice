import 'dart:math';

import 'package:flutter/material.dart' hide PointerMoveEvent;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';

import 'package:breakout/config.dart';
import 'package:breakout/objects/ball.dart';
import 'package:breakout/objects/brick.dart';
import 'package:breakout/objects/paddle.dart';
import 'package:breakout/providers/game_state_notifier.dart';
import 'package:breakout/providers/score_notifier.dart';

/// ブロック崩し
class Breakout extends FlameGame
  with HasCollisionDetection, PointerMoveCallbacks, DragCallbacks, RiverpodGameMixin {
  
  /// コンストラクタ
  Breakout({
    required this._columns,
    required this._rows,
  }) : super();

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
  /// ブロック一覧
  final List<Brick> _bricks = [];

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
    // 画面中央下
    final centerBottom = Vector2(size.x / 2, size.y);

    // 自機初期化
    _paddle = Paddle(position: centerBottom + PaddleConfig.offset, size: PaddleConfig.size, cornerRadius: PaddleConfig.cornerRadius);

    // ボール初期化
    _ball = Ball(position: centerBottom + BallConfig.offset, radius: BallConfig.radius, angle: BallConfig.angle);

    // オブジェクトの適用
    addAll([_paddle, _ball]);

    // ステージの作成
    _setupStage();

    return super.onLoad();
  }

  /// 更新処理
  @override
  void update(double dt) {
    super.update(dt);
    
    // 現在の状態
    final state = ref.read(gameProvider);

    // プレイ中以外はスキップ
    if (state != .playing) return;

    // 削除済みのブロックを一覧から削除
    _bricks.removeWhere((brick) => brick.isRemoved);

    // すべてのブロックがなくなればクリア
    if (_bricks.isEmpty) {
      ref.read(gameProvider.notifier).set(.clear);
    }
  }

  /// 描画処理
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 開始済みか非ホールドならスキップ
    if (ref.read(gameProvider) != .ready || !_isHolding) return;

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

    // 現在の状態
    final state = ref.read(gameProvider);

    // 開始済みならスキップ
    if (state != .ready) {

      // プレイ中のみ自機を動かす
      if (state == .playing) {
        // 自機をポインタに追従
        _trackPaddle(event.canvasEndPosition.x);
      }

      // スキップ
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
    if (ref.read(gameProvider) != .ready) return;

    // 角度の適用
    _ball.angle = _fireAngle;

    // ボールを発射
    ref.read(gameProvider.notifier).set(.playing);
  }

  /// ポインタ操作時処理
  @override
  void onPointerMove(PointerMoveEvent event) {
    super.onPointerMove(event);

    // 現在の状態
    final state = ref.read(gameProvider);

    // プレイ中でなければスキップ
    if (state != .ready && state != .playing) return;

    // 自機をポインタに追従
    _trackPaddle(event.canvasPosition.x);
  }

  /// 指定位置に自機を追従
  void _trackPaddle(double x) {
    // 自機を追従させる
    _paddle.moveTo(x);

    // プレイ前であればボールを自機に追従させる
    if (ref.read(gameProvider) == .ready) {
      _ball.x = _paddle.x;
    }
  }

  /// リスタート
  void restart() {
    // ステージの削除
    _clearStage();

    // ステージの構築
    _setupStage();

    // 画面中央下
    final centerBottom = Vector2(size.x / 2, size.y);

    // 自機初期化
    _paddle.position = centerBottom + PaddleConfig.offset;

    // ボール初期化
    _ball.reset(position: centerBottom + BallConfig.offset, angle: BallConfig.angle);

    // スコアのリセット
    ref.read(scoreProvider.notifier).reset();

    // 準備中に状態を切り替え
    ref.read(gameProvider.notifier).reset();
  }

  // ステージの作成
  void _setupStage() {
    // 行と列からブロックの初期化
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

        // ブロック一覧に保持
        _bricks.add(brick);
      }
    }
  }

  /// ステージの消去
  void _clearStage() {
    // ブロックの全削除
    removeAll(_bricks);

    // 一覧からも削除
    _bricks.clear();
  }
}