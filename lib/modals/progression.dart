import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:tonic/tonic.dart';

class Progression<T> {
  late final List<T> _base;

  List<T> get base => _base;
  late final List<double> _durations;

  List<double> get durations => _durations;

  /// The time signature of the [Progression]. 4/4 by defaults.
  /// A 4/4 time signature is represented as a whole of 1. This means a 4/4
  /// time signature and a 8/8 time signatures will be the same...
  // TODO: Maybe change this ^.
  late final double _timeSignature;

  /// The sum of the [Progression]'s [_durations].
  /* TODO: This is done like this because a lot of functions that I don't want
        to override can affect the members of the progression, but this can
        calculate the sum multiple times even if nothing changed, so think of
        a better way to do all of this (it probably requires a completely new
        class instead of extending DelegatingList.
   */

  /// Whether the [Progression] leaves no empty spaces in a measure, based on
  /// its [_timeSignature].
  bool _full = false;

  bool get full => rhythmSum % _timeSignature == 0;

  double _rhythmSum = 0.0;

  double get rhythmSum => _rhythmSum;

  double get measureCount => rhythmSum / _timeSignature;

  Progression(this._base, this._durations, {double timeSignature = 4 / 4})
      : assert(_base.length == _durations.length) {
    _timeSignature = timeSignature;
    updateFull();
  }

  Progression.empty({double timeSignature = 4 / 4})
      : this([], [], timeSignature: timeSignature);

  Progression.evenTime(List<T> base, {double timeSignature = 4 / 4})
      : this(base, List.generate(base.length, (index) => 1 / 4),
            timeSignature: timeSignature);

  bool updateFull() {
    if (_base.isEmpty) return false;
    _rhythmSum = _durations.reduce((value, element) => value + element);
    _full = rhythmSum % _timeSignature == 0;
    return _full;
  }

  List<Progression<T>> splitToMeasures({double? timeSignature}) {
    timeSignature ??= _timeSignature;
    if (rhythmSum < timeSignature) return [this];
    final List<Progression<T>> measures = [];
    Progression<T> currentMeasure =
        Progression.empty(timeSignature: timeSignature);
    double currentRhythmSum = 0.0;
    for (var i = 0; i < length; i++) {
      if (currentRhythmSum + _durations[i] > timeSignature) {
        currentRhythmSum = 0.0;
        measures.add(currentMeasure);
        currentMeasure = Progression.empty(timeSignature: timeSignature);
      }
      currentRhythmSum += _durations[i];
      currentMeasure.add(_base[i], _durations[i]);
    }
    if (currentMeasure.isNotEmpty) measures.add(currentMeasure);
    return measures;
  }

  void add(T value, [double duration = 1 / 4]) {
    _base.add(value);
    _durations.add(duration);
    updateFull();
  }

  @override
  bool operator ==(Object other) {
    if (other is! Progression<T> || length != other.length) {
      return false;
    }
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i] || _durations[i] != other._durations[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  // TODO: Check if this is correct
  int get hashCode => Object.hash(_base, _durations);

  // TODO: Find a better way to do this...
  String _format(T object) =>
      object is Chord ? object.getCommonName() : object.toString();

  @override
  String toString() {
    String output = '';
    if (measureCount <= 1.0) {
      output = '| ';
      for (var i = 0; i < length; i++) {
        output += '${_format(_base[i])}, ';
      }
      if (!full) {
        output += '-, ';
      }
      return output.substring(0, output.length - 2) + ' |';
    } else {
      final List<Progression<T>> measures = splitToMeasures();
      for (var i = 0; i < measures.length; i++) {
        output += measures[i].toString().substring(i == 0 ? 0 : 1);
      }
      return output;
    }
  }

  int get length => _base.length;

  set length(int newLength) {
    _base.length = newLength;
    _durations.length = newLength;
  }

  T operator [](int index) => _base[index];

  void operator []=(int index, T value) {
    _base[index] = value;
  }

  bool get isEmpty => _base.isEmpty;

  bool get isNotEmpty => _base.isNotEmpty;

  Iterable<E> map<E>(E Function(T e) toElement) => _base.map(toElement);
}
