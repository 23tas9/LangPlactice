import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScoreNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void add(int point) => state += point;

  void reset() => state = 0;
}

final scoreProvider = NotifierProvider<ScoreNotifier, int>(ScoreNotifier.new);