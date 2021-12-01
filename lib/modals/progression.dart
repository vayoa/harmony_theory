import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/time_signature.dart';
import 'package:tonic/tonic.dart';

class Progression<T> {
  late final List<T> _values;

  List<T> get values => _values;
  late final List<double> _durations;

  List<double> get durations => _durations;

  TimeSignature _timeSignature;

  TimeSignature get timeSignature => _timeSignature;

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

  bool get full => rhythmSum % _timeSignature.decimal == 0;

  double _rhythmSum = 0.0;

  double get rhythmSum => _rhythmSum;

  double get measureCount => rhythmSum / _timeSignature.decimal;

  Progression(this._values, this._durations,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : assert(_values.length == _durations.length),
        _timeSignature = timeSignature {
    updateFull();
  }

  Progression.empty(
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : this([], [], timeSignature: timeSignature);

  Progression.evenTime(List<T> base)
      : this(base, List.generate(base.length, (index) => 1 / 4));

  bool updateFull() {
    if (_values.isEmpty) return false;
    _rhythmSum = _durations.reduce((value, element) => value + element);
    _full = rhythmSum % _timeSignature.decimal == 0;
    return _full;
  }

  List<Progression<T>> splitToMeasures({TimeSignature? timeSignature}) {
    timeSignature ??= _timeSignature;
    if (rhythmSum < timeSignature.decimal) return [this];
    final List<Progression<T>> measures = [];
    Progression<T> currentMeasure =
        Progression.empty(timeSignature: timeSignature);
    double currentRhythmSum = 0.0;
    for (var i = 0; i < length; i++) {
      if (currentRhythmSum + _durations[i] > timeSignature.decimal) {
        currentRhythmSum = 0.0;
        measures.add(currentMeasure);
        currentMeasure = Progression.empty(timeSignature: timeSignature);
      }
      currentRhythmSum += _durations[i];
      currentMeasure.add(_values[i], _durations[i]);
    }
    if (currentMeasure.isNotEmpty) measures.add(currentMeasure);
    return measures;
  }

  void add(T value, [double duration = 1 / 4]) {
    _values.add(value);
    _durations.add(duration);
    updateFull();
  }

  void addAll(Progression<T> progression) {
    _values.addAll(progression._values);
    _durations.addAll(progression._durations);
    updateFull();
  }

  void addAllElements(
      Iterable<T> valuesIterable, Iterable<double> durationsIterable) {
    _values.addAll(valuesIterable);
    _durations.addAll(durationsIterable);
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
  int get hashCode => Object.hash(_values, _durations);

  // TODO: Find a better way to do this...
  String _format(T object) =>
      object is Chord ? object.getCommonName() : object.toString();

  /* FIXME: Currently we're not supporting chords that move between measures,
            which could cause problems.
   */
  @override
  String toString() {
    String output = '';
    if (measureCount <= 1.0) {
      output = '| ';
      final double step = 1 / _timeSignature.denominator;
      double stepSum = 0.0;
      for (var i = 0; i < length; i++) {
        final String formatted = _format(_values[i]);
        if (_durations[i] + stepSum >= step) {
          stepSum = 0.0;
          output += '$formatted, ';
        } else {
          stepSum += _durations[i];
          output += '$formatted ';
        }
      }
      if (!_full) {
        final double rhythmLeft = timeSignature.decimal - _rhythmSum;
        if (rhythmLeft <= step) {
          output += '-, ';
        } else {
          final int left = (rhythmLeft / step).ceil();
          for (var i = 0; i < left; i++) {
            output += '-, ';
          }
        }
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

  int get length => _values.length;

  set length(int newLength) {
    _values.length = newLength;
    _durations.length = newLength;
  }

  T operator [](int index) => _values[index];

  void operator []=(int index, T value) {
    _values[index] = value;
  }

  bool get isEmpty => _values.isEmpty;

  bool get isNotEmpty => _values.isNotEmpty;

  Progression<T> sublist(int start, [int? end]) =>
      Progression(_values.sublist(start, end), _durations.sublist(start, end),
          timeSignature: _timeSignature);

  Iterable<E> map<E>(E Function(T e) toElement) => _values.map(toElement);
}
