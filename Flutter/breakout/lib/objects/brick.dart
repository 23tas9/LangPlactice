import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// ブロック
class Brick extends RectangleComponent {
  /// コンストラクタ
  Brick({
    required super.position,
    required super.size,
  }) : super();

  /// 初期処理
  @override
  Future<void> onLoad() async {
    // ヒットボックス適用
    add(RectangleHitbox());
    
    return super.onLoad();
  }
}