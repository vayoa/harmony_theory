import 'dart:math';

import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/time_signature.dart';
import 'package:tonic/tonic.dart';

import 'absolute_durations.dart';
import 'exceptions.dart';

/// Describes a progression of any sort - a set of values, each with a duration.
///
/// The durations have to be all valid ([TimeSignature.validDuration]).
/// If a duration is bigger than [TimeSignature.decimal], it is determined as
/// valid if it's remainder from [TimeSignature.decimal] is valid.
///
/// If 2 adjacent values are the same, their durations are summed and they
/// become one value. This is done to save space as the cases in which we need
/// them to be split are less common then the cases where it doesn't matter.
class Progression<T> {
  late final List<T?> _values;

  List<T?> get values => _values;
  late final AbsoluteDurations _durations;

  AbsoluteDurations get durations => _durations;

  final TimeSignature _timeSignature;

  TimeSignature get timeSignature => _timeSignature;

  /* TDC: This doesn't need to be a field since it can now be calculated in
          O(n)... */
  bool _full;

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
        _full = false,
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
    updateFull();
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
        _full = false,
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
          double relativeDur = nonAbsoluteDuration * ratio;
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
    updateFull();
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
        _hasNull = hasNull,
        _full = durations.isEmpty
            ? true
            : durations.realLast % timeSignature.decimal == 0;

  Progression.empty({TimeSignature? timeSignature})
      : this.absolute([], [], timeSignature: timeSignature);

  Progression.evenTime(List<T?> base,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : this.absolute(
            base,
            List.generate(base.length,
                (index) => (index + 1) * (1 / timeSignature.denominator)),
            timeSignature: timeSignature);

  bool updateFull() {
    _full = duration % _timeSignature.decimal == 0;
    return _full;
  }

  /// Sums [durations] from [start] to [end], not including [end].
  /// If [start] == [end], returns 0.0.
  double sumDurations([int start = 0, int? end]) {
    assert(start >= 0 && (end == null || (end <= length && start <= end)));
    if (start == 0 && end == null) return duration;
    end ??= length;
    // This is done like this since every element includes its own duration...
    return (end == 0 ? 0.0 : _durations.real(end - 1)) -
        (start == 0 ? 0.0 : _durations.real(start - 1));
  }

  /* TDC: This function makes absolutely no sense and is not consistent.
          Look at all of its uses and try to fit getPlayingIndex() in there
          instead.
  */
  /// Returns a list index such that the duration from that index to [from] is
  /// [duration]. Negative [durations] also work.
  /// If no such index exits, returns -1.
  int getIndexFromDuration(double duration, {int from = 0}) {
    if (duration > this.duration) {
      return -1;
    }
    int playing = getPlayingIndex(duration, from: from);
    if (duration < 0) return playing;
    double diff = 0.0;
    if (from != 0) diff = _durations.real(from - 1);
    if (duration + diff == this.duration) {
      return length - 1;
    }
    if (playing == length - 1 ||
        (duration == _durations.real(playing) - _durations[playing] - diff)) {
      return playing;
    }
    return playing + 1;
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

  // ADC: Convert for absolute durations!!!
  /// Use this only for printing purposes as it can split a chord that goes
  /// over one measures into two chords (thus ruining the original progression).
  List<Progression<T>> splitToMeasures({TimeSignature? timeSignature}) {
    timeSignature ??= _timeSignature;
    if (duration < _timeSignature.decimal) return [this];
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
    updateFull();
  }

  void addAll(Progression<T> progression) {
    if (!progression.isEmpty) {
      bool fullBefore = _full;
      // In case the last of the current progression is equal to the first
      // of the added progression...
      add(progression.values.first, progression.durations.first);
      if (progression.length > 1) {
        if (fullBefore) {
          _values.addAll(progression.values.sublist(1));
          _durations.addAll(progression.durations, from: 1);
          updateFull();
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

  String valueFormat(T? value) =>
      value == null ? 'null' : notNullValueFormat(value);

  String notNullValueFormat(T value) => value.toString();

  String durationFormat(double duration) => duration.toString();

  /* TODO: Support chords with duration bigger than a step (like a 1/2 in a 1/4
      step, which would just not display the second 1/4 of it currently) and
      chords that move between measures. */
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
        /* FIXME: This is written badly but I can't think of another way to
                  make it work */
        final String valueFormatted =
            val is Chord ? val.commonName : valueFormat(_values[i]);
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
      double currentMinDuration = duration;
      // If left is 1.0 it's in fact 0.0 (since we have the whole measure left...).
      if (left != 1 && duration >= left) {
        assertDurationValid(value: value, duration: left);
        currentMinDuration = left;
      }
      // The duration that's left after the cut...
      double end = (overallDuration + duration) % decimal;
      // Since if this is true the rest is valid...
      if (end != 0) {
        assertDurationValid(value: value, duration: end);
        currentMinDuration = min(currentMinDuration, end);
      }
    }
  }

  void assertDurationValid({
    required T? value,
    required double duration,
  }) {
    if (!_timeSignature.validDuration(duration)) {
      throw NonValidDuration(
          value: value, duration: duration, timeSignature: _timeSignature);
    }
  }

  static bool adjacentValuesEqual<T>(T val, T next) =>
      val is Chord ? val.equals(next) : val == next;
}

class ProgressionEntry<T> {
  final T? value;
  final double duration;

  const ProgressionEntry({required this.value, required this.duration});

  @override
  String toString() => '$value($duration)';
}
