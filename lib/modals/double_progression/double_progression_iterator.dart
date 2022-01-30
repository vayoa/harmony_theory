import 'package:thoery_test/modals/double_progression/double_progression.dart';
import 'package:thoery_test/modals/progression.dart';

class DoubleProgressionIterator<T, E>
    extends Iterator<DoubleProgressionEntry<T, E>> {
  final Progression<T> _upper;
  final Progression<E> _lower;
  int _upperIndex;
  int _lowerIndex;
  double _upperDurSum;
  double _lowerDurSum;

  DoubleProgressionIterator({
    required Progression<T> upper,
    required Progression<E> lower,
  })  : _upper = upper,
        _lower = lower,
        _upperIndex = -1,
        _lowerIndex = -1,
        _upperDurSum = 0,
        _lowerDurSum = 0;

  @override
  DoubleProgressionEntry<T, E> get current => DoubleProgressionEntry(
        upper: ProgressionEntry(
          value: _upper[_upperIndex],
          duration: _upper.durations[_upperIndex],
        ),
        lower: ProgressionEntry(
          value: _lower[_lowerIndex],
          duration: _lower.durations[_lowerIndex],
        ),
      );

  @override
  bool moveNext() {
    double upperSum = _upperDurSum, lowerSum = _lowerDurSum;
    if (lowerSum >= upperSum) {
      if (_upperIndex + 1 < _upper.length) {
        _upperIndex++;
        _upperDurSum += _upper.durations[_upperIndex];
      } else {
        return false;
      }
    }
    if (upperSum >= lowerSum) {
      if (_lowerIndex + 1 < _lower.length) {
        _lowerIndex++;
        _lowerDurSum += _lower.durations[_lowerIndex];
      } else {
        return false;
      }
    }
    return true;
  }
}
