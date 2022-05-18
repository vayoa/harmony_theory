import 'dart:collection';
import 'dart:math';

import 'package:thoery_test/modals/double_progression/double_progression_iterator.dart';
import 'package:thoery_test/modals/quantized_progression.dart';

class DoubleProgression<T, E> with IterableMixin<DoubleProgressionEntry<T, E>> {
  final QuantizedProgression<T> upper;
  final QuantizedProgression<E> lower;

  DoubleProgression({required this.upper, required this.lower})
      : assert(upper.timeSignature == lower.timeSignature);

  double get duration => max(upper.duration, lower.duration);

  @override
  Iterator<DoubleProgressionEntry<T, E>> get iterator =>
      DoubleProgressionIterator(upper: upper, lower: lower);

// DoubleProgressionEntry getAt(double duration) {
//
// }
}

class DoubleProgressionEntry<T, E> {
  final ProgressionEntry<T> upper;
  final ProgressionEntry<E> lower;

  const DoubleProgressionEntry({required this.upper, required this.lower});

  @override
  String toString() => '[$upper, $lower]';
}
