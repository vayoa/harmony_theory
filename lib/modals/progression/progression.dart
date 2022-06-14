import 'package:tonic/tonic.dart';

import '../../extensions/chord_extension.dart';
import 'absolute_durations.dart';
import 'exceptions.dart';
import '../identifiable.dart';
import 'time_signature.dart';

/// Describes a progression of any sort - a set of values, each with a duration.
///
/// The durations have to be all valid ([TimeSignature.validDuration]).
/// If a duration is bigger than [TimeSignature.decimal], it is determined as
/// valid if it's remainder from [TimeSignature.decimal] is valid.
///
/// If 2 adjacent values are the same, their durations are summed and they
/// become one value. This is done to save space as the cases in which we need
/// them to be split are less common then the cases where it doesn't matter.
class Progression<T> implements Identifiable {
  late final List<T?> _values;

  List<T?> get values => _values;
  late final AbsoluteDurations _durations;

  AbsoluteDurations get durations => _durations;

  final TimeSignature _timeSignature;

  TimeSignature get timeSignature => _timeSignature;

  /// Whether the [Progression] leaves no empty spaces in a measure, based on
  /// its [_timeSignature].
  bool get full => duration % _timeSignature.decimal == 0;

  /// The overall duration of the [Progression].
  double get duration => durations.isEmpty ? 0.0 : _durations.realLast;

  /// The number of measures the [Progression] takes.
  int get measureCount => (duration / _timeSignature.decimal).ceil();

  /// Whether the progression has a null value.
  bool _hasNull;

  bool get hasNull => _hasNull;

  /// Creates a new [Progression] object, where all durations are positive
  /// and smaller than 1 (if an element in [durations] isn't, we split it).
  /// [timeSignature] is [TimeSignature.evenTime()] by default.
  /// [ratio] would be multiplied for all durations (1.0 by default).
  Progression(List<T?> values, List<double> durations,
      {TimeSignature? timeSignature, double? ratio})
      : assert(values.length == durations.length),
        _timeSignature = timeSignature ?? const TimeSignature.evenTime(),
        _hasNull = false,
        _values = [] {
    ratio ??= 1.0;
    List<double> _durationList = [];
    if (values.isNotEmpty) {
      double overallDuration = 0.0;
      double durSum = 0.0;
      for (int i = 0; i < values.length; i++) {
        if (durations[i] <= 0) {
          throw Exception('A non-positive duration at index $i'
              ' (${_values[i]} -> ${_durations[i]})');
        }
        // Fails if we made it to the last index or if adjacent values aren't
        // equal...
        if (i < values.length - 1 &&
            adjacentValuesEqual(values[i], values[i + 1])) {
          durSum += durations[i];
        } else {
          durSum = (durSum + durations[i]) * ratio;
          T? val = values[i];
          checkValidDuration(
              value: val, duration: durSum, overallDuration: overallDuration);
          if (!_hasNull) _hasNull = values[i] == null;
          overallDuration += durSum;
          _durationList.add(overallDuration);
          _values.add(val);
          durSum = 0;
        }
      }
    }
    _durations = AbsoluteDurations(_durationList);
  }

  // Since sublist is used a lot, I made this one function for a light
  // optimization instead of sublisting the values and the durations and then
  // going through them again in the constructor...
  /// Constructs a progression where [durations] is a list of absolute durations.
  /// [timeSignature] is [TimeSignature.evenTime()] by default.
  /// [ratio] would be multiplied for all durations (1.0 by default).
  /// [start] and [end] determine the range of the list to be converted (end is
  /// excluded...).
  /// [durationDiff] will be deducted from each duration.
  Progression._absoluteInternal(
    List<T?> values,
    List<double> durations, {
    TimeSignature? timeSignature,
    double? ratio,
    int start = 0,
    int? end,
    double durationDiff = 0.0,
  })  : assert(values.length == durations.length),
        _timeSignature = timeSignature ?? const TimeSignature.evenTime(),
        _hasNull = false,
        _values = [] {
    ratio ??= 1.0;
    end ??= values.length;
    List<double> _durationList = [];
    if (values.isNotEmpty) {
      double previousDuration = 0.0;
      for (int i = start; i < end; i++) {
        if (durations[i] <= 0) {
          throw Exception('A non-positive duration at index $i'
              ' (${_values[i]} -> ${_durations[i]})');
        }
        // Skips the current value if its index is smaller than the last index
        // and it's equal to the chord that comes after it.
        if (!(i < values.length - 1 &&
            adjacentValuesEqual(values[i], values[i + 1]))) {
          double nonAbsoluteDuration =
              (durations[i] * ratio) - previousDuration - durationDiff;
          T? val = values[i];
          checkValidDuration(
              value: val,
              duration: nonAbsoluteDuration,
              overallDuration: previousDuration);
          if (!_hasNull) _hasNull = values[i] == null;
          previousDuration += nonAbsoluteDuration;
          _durationList.add(previousDuration);
          _values.add(val);
        }
      }
    }
    _durations = AbsoluteDurations(_durationList);
  }

  /// Constructs a progression where [durations] is a list of absolute durations.
  /// [timeSignature] is [TimeSignature.evenTime()] by default.
  /// [ratio] would be multiplied for all durations (1.0 by default).
  Progression.absolute(List<T?> values, List<double> durations,
      {TimeSignature? timeSignature, double? ratio})
      : this._absoluteInternal(values, durations,
            timeSignature: timeSignature, ratio: ratio);

  /// Doesn't check for duplicates or full and just sets the values for the
  /// fields.
  Progression.raw({
    required List<T?> values,
    required AbsoluteDurations durations,
    required TimeSignature timeSignature,
    required bool hasNull,
  })  : _values = values,
        _durations = durations,
        _timeSignature = timeSignature,
        _hasNull = hasNull;

  Progression.empty({TimeSignature? timeSignature})
      : this.absolute([], [], timeSignature: timeSignature);

  Progression.evenTime(List<T?> base,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : this.absolute(
            base,
            List.generate(base.length,
                (index) => (index + 1) * (1 / timeSignature.denominator)),
            timeSignature: timeSignature);

  /// Sums [durations] from [start] to [end], not including [end].
  /// If [start] == [end], returns 0.0.
  double sumDurations([int start = 0, int? end]) {
    if (!(start >= 0 && (end == null || (end <= length && start <= end)))) {
      throw RangeError('0 <= $start <= $end <= $length is not true.');
    }
    if (start == 0 && end == null) return duration;
    end ??= length;
    // This is done like this since every element includes its own duration...
    return (end == 0 ? 0.0 : _durations.real(end - 1)) -
        (start == 0 ? 0.0 : _durations.real(start - 1));
  }

  /// Returns the index of the "playing" value at [duration] from the index
  /// [from] (INCLUDED!!! see examples), which is 0 by default.
  /// If no such index exists, returns -1.
  ///
  /// [duration] can also be negative.
  ///
  /// Complexity: O(log(n)).
  ///
  /// Examples:
  ///
  /// Progression - [I(0.5), V(0.5)].
  /// duration: 0.4 -> 0.
  /// duration: 0.5 -> 1.
  /// duration: 0.9 -> 1.
  /// duration: 1.0 -> -1.
  /// duration: 0.2, from: 1 -> 1.
  int getPlayingIndex(double duration, {int from = 0}) {
    int l = from, r = length - 1;
    double diff = 0.0;
    if (l != 0) diff = _durations.real(l - 1);
    if (duration < 0) {
      l = 0;
      r = from;
      duration = diff + duration;
      // We got out of bounds (from the left)...
      if (duration < 0.0) return -1;
      diff = 0.0;
    }
    // Diff is to allow the algorithm to start from a different index.
    // Regular binary search structure but instead of stopping when the value
    // is duration we stop either when it's equal to duration (see example)
    // or when it's bigger and the duration before is smaller or equal.
    while (l <= r) {
      int m = l + (r - l) ~/ 2;
      double current = _durations.real(m) - diff;
      if (current == duration) {
        // If m is the last index, no such playing value exists, otherwise
        // return the next m.
        return m < length - 1 ? m + 1 : -1;
      } else if (current > duration) {
        // since the next line has m - 1...
        if (m == 0) return 0;
        if (_durations.real(m - 1) - diff <= duration) return m;
        r = m - 1;
      } else {
        l = m + 1;
      }
    }
    // This is needed because the start could be different than 0...
    return -1;
  }

  /// Returns a new [Progression] with the same values where all durations
  /// have been multiplied by [ratio].
  /// Example:
  /// [Progression] p.durations => [1/4, 1/4, 1/4, 1/4].
  /// p.relativeTo(0.5).durations => [1/8, 1/8, 1/8, 1/8].
  Progression<T> relativeRhythmTo(double ratio) {
    return Progression.absolute(
      _values,
      _durations.realDurations,
      timeSignature: _timeSignature,
      ratio: ratio,
    );
  }

  List<Progression<T>> splitToMeasures({TimeSignature? timeSignature}) {
    timeSignature ??= _timeSignature;
    final double decimal = _timeSignature.decimal;
    if (duration < decimal) return [this];
    final List<Progression<T>> measures = [];
    Progression<T> currentMeasure =
        Progression.empty(timeSignature: timeSignature);
    double currentRhythmSum = 0.0;
    for (var i = 0; i < length; i++) {
      double newDur = _durations[i];
      if (currentRhythmSum + newDur > decimal) {
        double left = decimal - currentRhythmSum;
        if (left != 0) {
          currentMeasure.add(_values[i], left);
          newDur -= left;
        }
        currentRhythmSum = 0.0;
        measures.add(currentMeasure);
        currentMeasure = Progression.empty(timeSignature: timeSignature);
        while (newDur > decimal) {
          currentMeasure.add(_values[i], decimal);
          measures.add(currentMeasure);
          currentMeasure = Progression.empty(timeSignature: timeSignature);
          newDur -= decimal;
        }
      }
      currentRhythmSum += newDur;
      if (newDur > 0) {
        currentMeasure.add(_values[i], newDur);
      }
    }
    if (!currentMeasure.isEmpty) measures.add(currentMeasure);
    return measures;
  }

  void add(T? value, double newDuration) {
    if (newDuration <= 0) {
      throw NonPositiveDuration(value, newDuration);
    }
    T? last = _values.isEmpty ? null : _values.last;
    if (_values.isNotEmpty && adjacentValuesEqual(value, last)) {
      double dur = (newDuration + _durations.last) % _timeSignature.decimal;
      if (dur > 0) {
        checkValidDuration(
          value: value,
          duration: dur,
          // The overall duration is the progression's duration - the last
          // one since they're the same...
          overallDuration: duration - durations.last,
        );
        if (!_hasNull) _hasNull = value == null;
      }
      _durations.last += newDuration;
    } else {
      checkValidDuration(
          value: value, duration: newDuration, overallDuration: duration);
      _values.add(value);
      _durations.add(newDuration);
    }
    if (!_hasNull) _hasNull = value == null;
  }

  void addAll(Progression<T> progression) {
    if (!progression.isEmpty) {
      bool fullBefore = full;
      // In case the last of the current progression is equal to the first
      // of the added progression...
      add(progression.values.first, progression.durations.first);
      if (progression.length > 1) {
        if (fullBefore) {
          _values.addAll(progression.values.sublist(1));
          _durations.addAll(progression.durations, from: 1);
        } else {
          for (int i = 1; i < progression.length; i++) {
            add(progression.values[i], progression.durations[i]);
          }
        }
      }
      if (!_hasNull && progression._hasNull) _hasNull = true;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is! Progression<T> ||
        duration != other.duration ||
        length != other.length ||
        _hasNull != other._hasNull) {
      return false;
    }
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i] ||
          _durations.real(i) != other._durations.real(i)) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(_values), _durations);

  @override
  int get id => Identifiable.hash2(valuesID, _durations.id);

  int get valuesID {
    int hash = 0;
    if (_values.isEmpty) return hash;
    for (T? value in _values) {
      hash = Identifiable.combine(
          hash, value is Identifiable ? value.id : value.hashCode);
    }
    return Identifiable.finish(hash);
  }

  String valueFormat(T? value) =>
      value == null ? 'null' : notNullValueFormat(value);

  String notNullValueFormat(T value) => value.toString();

  String durationFormat(double duration) => duration.toString();

  @override
  String toString([detailed = false]) {
    String output = '';
    if (measureCount <= 1.0) {
      output = '| ';
      final double step = 1 / _timeSignature.denominator;
      double stepSum = 0.0;
      for (var i = 0; i < length; i++) {
        String durationFormatted =
            detailed ? durationFormat(_durations[i]) : '';
        final val = _values[i];
        final String valueFormatted = valueFormat(_values[i]);
        final String formatted = valueFormatted +
            (durationFormatted.isEmpty ? '' : '($durationFormatted)');
        double curDuration = _durations[i];
        if (curDuration + stepSum >= step) {
          stepSum = 0.0;
          output += '$formatted, ';
        } else {
          stepSum += curDuration;
          output += '$formatted ';
        }
      }
      if (!full) {
        final double rhythmLeft = timeSignature.decimal - duration;
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

  T? operator [](int index) => _values[index];

  void operator []=(int index, T value) {
    _values[index] = value;
  }

  bool get isEmpty => _values.isEmpty;

  Progression<T> sublist(int start, [int? end]) =>
      Progression._absoluteInternal(_values, _durations.realDurations,
          timeSignature: _timeSignature,
          start: start,
          end: end,
          durationDiff: start == 0 ? 0.0 : durations.realDurations[start - 1]);

  Progression<T> replaceMeasure(int index, Progression<T> newMeasure,
      {List<Progression<T>>? measures}) {
    measures ??= splitToMeasures();
    Progression<T> start = Progression<T>.empty(timeSignature: _timeSignature);
    // If for example we want to replace null(1.25) at the first measure
    // [null(1.0)] with null(0.75) we should be able to but not doing this
    // won't let us...
    if (!newMeasure.isEmpty &&
        measures.length - 1 > index &&
        !measures[index + 1].isEmpty &&
        adjacentValuesEqual(
            newMeasure.values.last, measures[index + 1].values.first)) {
      newMeasure.addAll(measures[index + 1]);
      measures.removeAt(index + 1);
    }
    for (int i = 0; i < index; i++) {
      start.addAll(measures[i]);
    }
    start.addAll(newMeasure);
    if (index < measures.length - 1) {
      for (int i = index + 1; i < measures.length; i++) {
        start.addAll(measures[i]);
      }
    }
    return start;
  }

  Progression<T> inTimeSignature(TimeSignature timeSignature) {
    Progression<T> newProg = Progression.empty(timeSignature: timeSignature);
    for (int i = 0; i < length; i++) {
      newProg.add(values[i], durations[i]);
    }
    return newProg;
  }

  /// Checks whether [duration] is valid.
  void checkValidDuration({
    required T? value,
    required double duration,
    required double overallDuration,
  }) {
    assert(overallDuration >= 0);
    double decimal = _timeSignature.decimal;
    if (duration < 0) {
      throw NonPositiveDuration(value, duration);
    } else if ((overallDuration % decimal) + duration <= decimal) {
      assertDurationValid(value: value, duration: duration);
    } else {
      // The duration the current measure has left before being full.
      double left = decimal - (overallDuration % decimal);
      // If left is decimal it's in fact 0.0 (since we have the whole measure left...).
      if (left != decimal && duration >= left) {
        assertDurationValid(value: value, duration: left);
      }
      // The duration that's left after the cut...
      double end = (overallDuration + duration) % decimal;
      // Since if this is true the rest is valid...
      if (end != 0) {
        assertDurationValid(value: value, duration: end);
      }
    }
  }

  void assertDurationValid({
    required T? value,
    required double duration,
  }) {
    if (value != null && !_timeSignature.validDuration(duration)) {
      throw NonValidDuration(
          value: value, duration: duration, timeSignature: _timeSignature);
    }
  }

  // TODO: Remove this. We needed it before we wrote PitchChord...
  static bool adjacentValuesEqual<T>(T val, T next) => val == next;
}
