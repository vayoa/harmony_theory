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

  Progression<T> get reversed =>
      Progression(_values.reversed.toList(), _durations.reversed.toList(),
          timeSignature: timeSignature);

  bool _full = false;

  /// Whether the [Progression] leaves no empty spaces in a measure, based on
  /// its [_timeSignature].
  bool get full => duration % _timeSignature.decimal == 0;

  double _duration = 0.0;

  /// The overall duration of the [Progression].
  double get duration => _duration;

  /// The number of measures the [Progression] takes.
  double get measureCount => duration / _timeSignature.decimal;

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
    _duration = _durations.reduce((value, element) => value + element);
    _full = duration % _timeSignature.decimal == 0;
    return _full;
  }

  /// Sums [durations] from [start] to [end], not including [end].
  double sumDurations([int start = 0, int? end]) {
    if (start == 0 && end == null) return _duration;
    end ??= length;
    return _durations.sublist(start, end).fold(0, (prev, e) => prev + e);
  }

  /// Returns a list index such that the duration from that index to [from] is
  /// [duration]. Negative [durations] also work.
  /// If no such index exits, returns -1.
  int getIndexFromDuration(double duration, {int from = 0}) {
    if (duration == 0) return from;
    double sum = 0;
    if (duration.isNegative) {
      duration = -1 * duration;
      for (var i = from - 1; i >= 0; i--) {
        sum += _durations[i];
        if (sum >= duration) return i;
      }
    } else {
      for (var i = from; i < length; i++) {
        if (sum >= duration) return i;
        sum += _durations[i];
      }
    }
    return -1;
  }

  /// Returns a new [Progression] with the same values where all durations
  /// have been multiplied by [ratio].
  /// Example:
  /// [Progression] p.durations => [1/4, 1/4, 1/4, 1/4].
  /// p.relativeTo(0.5).durations => [1/8, 1/8, 1/8, 1/8].
  Progression<T> relativeTo(double ratio) {
    return Progression(
      _values,
      _durations.map((double duration) => duration * ratio).toList(),
      timeSignature: _timeSignature,
    );
  }

  List<Progression<T>> splitToMeasures({TimeSignature? timeSignature}) {
    timeSignature ??= _timeSignature;
    if (duration < timeSignature.decimal) return [this];
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

  void add(T value, double duration) {
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
  int get hashCode =>
      Object.hash(Object.hashAll(_values), Object.hashAll(_durations));

  /* TODO: Support chords with duration bigger than a step (like a 1/2 in a 1/4
      step, which would just not display the second 1/4 of it currently) and
      chords that move between measures. */
  String format(
      String Function(T) valueFormat, String Function(double) durationFormat) {
    String output = '';
    if (measureCount <= 1.0) {
      output = '| ';
      final double step = 1 / _timeSignature.denominator;
      double stepSum = 0.0;
      for (var i = 0; i < length; i++) {
        String durationFormatted = durationFormat(_durations[i]);
        final String formatted = valueFormat(_values[i]) +
            (durationFormatted.isEmpty ? '' : '($durationFormatted)');
        if (_durations[i] + stepSum >= step) {
          stepSum = 0.0;
          output += '$formatted, ';
        } else {
          stepSum += _durations[i];
          output += '$formatted ';
        }
      }
      if (!_full) {
        final double rhythmLeft = timeSignature.decimal - _duration;
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

  @override
  String toString() => format((T v) => v.toString(), (double d) => '');

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
