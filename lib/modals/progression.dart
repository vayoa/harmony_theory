import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/time_signature.dart';
import 'package:tonic/tonic.dart';

class Progression<T> {
  late final List<T> _values;

  List<T> get values => _values;
  final List<double> _durations;

  List<double> get durations => _durations;

  final TimeSignature _timeSignature;

  TimeSignature get timeSignature => _timeSignature;

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
    if (!isEmpty) {
      // Join all the adjacent equal values.
      int i = 0;
      while (i < length - 1) {
        // We do this because Chord doesn't have an equals implementation...
        var val = values[i];
        var val2 = values[i + 1];
        /* FIXME: Dart is really dumb sometimes (it won't let me do this
                otherwise...) */
        if (val == val2 ||
            (val is Chord && val2 is Chord && val.equals(val2))) {
          _durations[i] += _durations[i + 1];
          _durations.removeAt(i + 1);
          _values.removeAt(i + 1);
        } else {
          i++;
        }
      }
      updateFull();
    }
  }

  /// Doesn't check for duplicates or full and just sets the values for the
  /// fields.
  Progression.raw({
    required List<T> values,
    required List<double> durations,
    required TimeSignature timeSignature,
    required double duration,
    required bool full,
  })  : _values = values,
        _durations = durations,
        _timeSignature = timeSignature,
        _duration = duration,
        _full = full;

  Progression.empty(
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : this([], [], timeSignature: timeSignature);

  Progression.evenTime(List<T> base,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : this(
            base,
            List.generate(
                base.length, (index) => 1 / timeSignature.denominator),
            timeSignature: timeSignature);

  bool updateFull() {
    if (isEmpty) return false;
    _duration = _durations.reduce((value, element) => value + element);
    _full = _duration % _timeSignature.decimal == 0;
    return _full;
  }

  /// Sums [durations] from [start] to [end], not including [end].
  double sumDurations([int start = 0, int? end]) {
    // assert(end == null || start < end);
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
      /* FIXME: Write this better (we check this afterwards but there's
                probably a way to do it in the loop...)*/
      if (sum >= duration) return length - 1;
    }
    return -1;
  }

  /// Returns a new [Progression] with the same values where all durations
  /// have been multiplied by [ratio].
  /// Example:
  /// [Progression] p.durations => [1/4, 1/4, 1/4, 1/4].
  /// p.relativeTo(0.5).durations => [1/8, 1/8, 1/8, 1/8].
  Progression<T> relativeRhythmTo(double ratio) {
    return Progression(
      _values,
      _durations.map((double duration) => duration * ratio).toList(),
      timeSignature: _timeSignature,
    );
  }

  /// Use this only for printing purposes as it can split a chord that goes
  /// over one measures into two chords (thus ruining the original progression).
  List<Progression<T>> splitToMeasures({TimeSignature? timeSignature}) {
    timeSignature ??= _timeSignature;
    if (_duration < _timeSignature.decimal) return [this];
    final List<Progression<T>> measures = [];
    Progression<T> currentMeasure =
        Progression.empty(timeSignature: timeSignature);
    double currentRhythmSum = 0.0;
    for (var i = 0; i < length; i++) {
      double newDur = _durations[i];
      if (currentRhythmSum + newDur > timeSignature.decimal) {
        double left = timeSignature.decimal - currentRhythmSum;
        if (left != 0) {
          currentMeasure.add(_values[i], left);
          newDur -= currentMeasure._durations.last;
        }
        currentRhythmSum = 0.0;
        measures.add(currentMeasure);
        currentMeasure = Progression.empty(timeSignature: timeSignature);
        while (newDur > _timeSignature.decimal) {
          currentMeasure.add(_values[i], 1.0);
          measures.add(currentMeasure);
          currentMeasure = Progression.empty(timeSignature: timeSignature);
          newDur -= _timeSignature.decimal;
        }
      }
      currentRhythmSum += newDur;
      currentMeasure.add(_values[i], newDur);
    }
    if (!currentMeasure.isEmpty) measures.add(currentMeasure);
    return measures;
  }

  void add(T value, double duration) {
    if (_values.isNotEmpty && value == _values.last) {
      _durations.last += duration;
    } else {
      _values.add(value);
      _durations.add(duration);
    }
    updateFull();
  }

  void addAll(Progression<T> progression) {
    if (_values.isNotEmpty && progression.values.first == _values.last) {
      double dur = progression.removeAt(0).value;
      _durations.last += dur;
    }
    _values.addAll(progression._values);
    _durations.addAll(progression._durations);
    updateFull();
  }

  // TODO: Change this from map entry to something else...
  MapEntry<T, double> removeAt(int index) {
    T val = _values.removeAt(index);
    double dur = _durations.removeAt(index);
    return MapEntry(val, dur);
  }

  @override
  bool operator ==(Object other) {
    if (other is! Progression<T> ||
        _duration != other._duration ||
        length != other.length) {
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

  String valueFormat(T value) => value.toString();

  String durationFormat(double duration) => '';

  /* TODO: Support chords with duration bigger than a step (like a 1/2 in a 1/4
      step, which would just not display the second 1/4 of it currently) and
      chords that move between measures. */
  @override
  String toString() {
    String output = '';
    if (measureCount <= 1.0) {
      output = '| ';
      final double step = 1 / _timeSignature.denominator;
      double stepSum = 0.0;
      for (var i = 0; i < length; i++) {
        String durationFormatted = durationFormat(_durations[i]);
        final val = _values[i];
        /* FIXME: This is written badly but I can't think of another way to
                  make it work */
        final String valueFormatted =
            val is Chord ? val.getCommonName() : valueFormat(_values[i]);
        final String formatted = valueFormatted +
            (durationFormatted.isEmpty ? '' : '($durationFormatted)');
        double curDuration = _durations[i];
        // TODO: Check if there's a better more covering way to do this...
        // while (curDuration < _timeSignature.decimal && curDuration > step) {
        //   curDuration -= step;
        //   output += '$formatted, ';
        // }
        if (curDuration + stepSum >= step) {
          stepSum = 0.0;
          output += '$formatted, ';
        } else {
          stepSum += curDuration;
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

  int get length => _values.length;

  T operator [](int index) => _values[index];

  void operator []=(int index, T value) {
    _values[index] = value;
  }

  bool get isEmpty => _values.isEmpty;

  Progression<T> sublist(int start, [int? end]) =>
      Progression(_values.sublist(start, end), _durations.sublist(start, end),
          timeSignature: _timeSignature);
}
