import 'package:flutter/material.dart';

/// 縁取り付きテキスト
class StrokedText extends StatelessWidget {
  /// コンストラクタ
  const StrokedText(
    this.text, {
    super.key,
    this.style = const TextStyle(),
    this.fillColor = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 4.0,
  });

  /// 表示テキスト
  final String text;
  /// スタイル
  final TextStyle style;
  /// 塗りつぶし色
  final Color fillColor;
  /// 縁色
  final Color strokeColor;
  /// 縁の太さ
  final double strokeWidth;

  /// 構築
  @override
  Widget build(BuildContext context) {
    // 重ねて表示
    return Stack(
      children: [
        // 縁取り
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        // 塗り
        Text(
          text,
          style: style.copyWith(color: fillColor),
        ),
      ],
    );
  }
}