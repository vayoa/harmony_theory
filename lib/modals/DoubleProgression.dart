import 'dart:math';

import 'package:thoery_test/modals/progression.dart';

class DoubleProgression<T, E> {
  final Progression<T> upper;
  final Progression<E> lower;

  DoubleProgression(
      {required this.upper, required this.lower})
      : assert(upper.timeSignature == lower.timeSignature);

  double get duration => max(upper.duration, lower.duration);

  // DoubleProgressionEntry getAt(double duration) {
  //
  // }
}

class DoubleProgressionEntry<T, E> {
  final ProgressionEntry<T> upper;
  final ProgressionEntry<E> lower;

  const DoubleProgressionEntry({required this.upper, required this.lower});
}
