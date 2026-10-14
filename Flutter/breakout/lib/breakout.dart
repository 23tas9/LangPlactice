import 'dart:math';

import 'package:flutter/material.dart' hide PointerMoveEvent;

import 'package:flame/components.dart';
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
  }) : super(
    camera: CameraComponent.withFixedResolution(
      width: GameConfig.width,
      height: GameConfig.height
    ),
  );

  /// ブロックの列数
  final int _columns;
  /// ブロックの行数
  final int _rows;

  /// 自機
  late final Paddle _paddle;
  /// ボール
  late final Ball _ball;
  /// ブロック一覧
  final List<Brick> _bricks = [];
  
  /// 初期処理
  @override
  Future<void> onLoad() async {
    // 基準点を左上に移動
    camera.viewfinder.anchor = Anchor.topLeft;

    // ワールドに背景をつける
    world.add(RectangleComponent(
      size: Vector2(GameConfig.width, GameConfig.height),
      paint: Paint()..color = const Color(0xFF1A1A2E),
    ));

    // 自機初期化
    _paddle = Paddle(position: PaddleConfig.position, size: PaddleConfig.size, cornerRadius: PaddleConfig.cornerRadius);

    // ボール初期化
    _ball = Ball(position: BallConfig.position, radius: BallConfig.radius, angle: BallConfig.angle);

    // オブジェクトの適用
    world.addAll([_paddle, _ball]);

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

  /// ドラッグ開始処理
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    // 準備中でないならスキップ
    if (ref.read(gameProvider) != .ready) return;
    
    // 照準中に変更
    ref.read(gameProvider.notifier).set(.aiming);
  }

  /// ドラッグ更新処理
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    // 現在の状態
    final state = ref.read(gameProvider);
    
    // ポインタのワールド座標
    final pos = camera.globalToLocal(event.canvasEndPosition);

    // 照準中でないならスキップ
    if (state != .aiming) {

      // プレイ中のみ自機を動かす
      if (state == .playing) {
        // 自機をポインタに追従
        _trackPaddle(pos.x);
      }

      // スキップ
      return;
    }
    
    // 差分ベクトル
    final diff = pos - _ball.position;

    // ボールより下の位置はスキップ
    if (diff.y >= 0) return;

    // 角度の設定
    _ball.angle = atan2(diff.y, diff.x).clamp(-pi + BallConfig.minFireTilt, -BallConfig.minFireTilt);
  }

  /// ドラッグ終了処理
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    final state = ref.read(gameProvider);

    // 開始済みならスキップ
    if (state != .aiming) return;

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

    // ポインタのワールド座標
    final pos = camera.globalToLocal(event.canvasPosition);

    // 自機をポインタに追従
    _trackPaddle(pos.x);
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

    // 自機初期化
    _paddle.position = PaddleConfig.position;

    // ボール初期化
    _ball.reset(position: BallConfig.position, angle: BallConfig.angle);

    // スコアのリセット
    ref.read(scoreProvider.notifier).reset();

    // 準備中に状態を切り替え
    ref.read(gameProvider.notifier).reset();
  }

  // ステージの作成
  void _setupStage() {
    // ブロックのサイズ
    final brickSize = BrickConfig.size(_columns, _rows);

    // 行と列からブロックの初期化
    for (int y = 0; y < _rows; y++) {
      for (int x = 0; x < _columns; x++) {
        // ブロックの位置
        final pos = (BrickConfig.areaMargin / 2) + Vector2(
          BrickConfig.margin.x / 2 + (brickSize.x + BrickConfig.margin.x) * x,
          BrickConfig.margin.y / 2 + (brickSize.y + BrickConfig.margin.y) * y
        );
        
        // ブロック
        final brick = Brick(position: pos, size: brickSize);
        world.add(brick);

        // ブロック一覧に保持
        _bricks.add(brick);
      }
    }
  }

  /// ステージの消去
  void _clearStage() {
    // ブロックの全削除
    world.removeAll(_bricks);

    // 一覧からも削除
    _bricks.clear();
  }
}