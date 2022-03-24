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

  bool _full = false;

  /// Whether the [Progression] leaves no empty spaces in a measure, based on
  /// its [_timeSignature].
  bool get full => duration % _timeSignature.decimal == 0;

  /// The overall duration of the [Progression].
  double get duration => _durations.realLast;

  /// The number of measures the [Progression] takes.
  int get measureCount => (duration / _timeSignature.decimal).ceil();

  double _minDuration = double.infinity;

  /// The minimum duration in the progression.
  /// If there's a value with a duration of 1.25 in a 4/4 time signature, and
  /// no other duration is smaller than 0.25, that will be the minimum duration
  /// since 1.25 - [TimeSignature.decimal] is 0.25...
  double get minDuration => _minDuration;

  /// Internal constructor.
  /// [timeSignature] is [TimeSignature.evenTime()] by default.
  /// [ratio] would be multiplied for all durations (1.0 by default).
  /// [absolute] determines whether [durations] is absolute.
  Progression._internal(
    List<T?> values,
    List<double> durations, {
    TimeSignature? timeSignature,
    bool absolute = false,
    double? ratio,
  })  : assert(values.length == durations.length),
        _timeSignature = timeSignature ?? const TimeSignature.evenTime(),
        _values = [] {
    ratio ??= 1.0;
    List<double> _durations = [];
    if (values.isNotEmpty) {
      double overallDuration = 0.0;
      double durSum = 0.0;
      for (int i = 0; i < values.length; i++) {
        double relativeDur = durations[i] * ratio;
        if (relativeDur <= 0) {
          throw Exception('A non-positive duration at index $i'
              ' (${_values[i]} -> ${_durations[i]})');
        }
        // Fails if we made it to the last index or if adjacent values aren't
        // equal...
        if (i < values.length - 1 &&
            adjacentValuesEqual(values[i], values[i + 1])) {
          durSum += relativeDur;
        } else {
          durSum += relativeDur;
          T? val = values[i];
          _minDuration = min(
              _checkValidDuration(
                  value: val,
                  duration: durSum,
                  overallDuration: overallDuration),
              _minDuration);
          overallDuration += durSum;
          _durations.add(absolute ? durSum : overallDuration);
          _values.add(val);
          durSum = 0;
        }
      }
    }
    this._durations = AbsoluteDurations(_durations);
  }

  /// Creates a new [Progression] object, where all durations are positive
  /// and smaller than 1 (if an element in [durations] isn't, we split it).
  Progression(List<T?> values, List<double> durations,
      {TimeSignature? timeSignature, double? ratio})
      : this._internal(values, durations,
            timeSignature: timeSignature, ratio: ratio, absolute: false);

  Progression.real(List<T?> values, List<double> durations,
      {TimeSignature? timeSignature, double? ratio})
      : this._internal(values, durations,
            timeSignature: timeSignature, ratio: ratio, absolute: true);

  /// Doesn't check for duplicates or full and just sets the values for the
  /// fields.
  Progression.raw({
    required List<T?> values,
    required AbsoluteDurations durations,
    required TimeSignature timeSignature,
  })  : _values = values,
        _durations = durations,
        _timeSignature = timeSignature,
        _full = durations.realLast % timeSignature.decimal == 0;

  Progression.empty({TimeSignature? timeSignature})
      : this.real([], [], timeSignature: timeSignature);

  Progression.evenTime(List<T?> base,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : this.real(
            base,
            List.generate(base.length,
                (index) => (index + 1) * (1 / timeSignature.denominator)),
            timeSignature: timeSignature);

  bool updateFull() {
    _full = _durations.realLast % _timeSignature.decimal == 0;
    return _full;
  }

  /// Sums [durations] from [start] to [end], not including [end].
  double sumDurations([int start = 0, int? end]) {
    assert(end == null || start <= end);
    if (start == 0 && end == null) return duration;
    end ??= length - 1;
    return _durations.real(end - start);
  }

  // ADC: Convert to absolute durations!
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
    return Progression.real(
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

  void add(T? value, double duration) {
    if (duration <= 0) {
      throw NonPositiveDuration(value, duration);
    }
    T? last = _values.isEmpty ? null : _values.last;
    if (_values.isNotEmpty && adjacentValuesEqual(value, last)) {
      double dur = (duration + _durations.last) % _timeSignature.decimal;
      if (dur > 0) {
        _minDuration = min(
            _checkValidDuration(
              value: value,
              duration: dur,
              // The overall duration is the progression's duration - the last
              // one since they're the same...
              overallDuration: duration - durations.last,
            ),
            _minDuration);
      }
      _durations.last += duration;
    } else {
      _minDuration = min(
          _minDuration,
          _checkValidDuration(
              value: value, duration: duration, overallDuration: duration));
      _values.add(value);
      _durations.add(duration);
    }
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
          _minDuration = min(_minDuration, progression._minDuration);
          _values.addAll(progression.values.sublist(1));
          _durations.addAll(progression.durations, from: 1);
          updateFull();
        } else {
          for (int i = 1; i < progression.length; i++) {
            add(progression.values[i], progression.durations[i]);
          }
        }
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is! Progression<T> ||
        duration != other.duration ||
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

  /* TDC: Optimize! We go through durations twice (durations.sublist and the
          constructor...). */
  Progression<T> sublist(int start, [int? end]) => Progression.real(
      _values.sublist(start, end), _durations.sublist(start, end).realDurations,
      timeSignature: _timeSignature);

  Progression<T> replaceMeasure(int index, Progression<T> newMeasure,
      {List<Progression<T>>? measures}) {
    measures ??= splitToMeasures();
    double measure = _timeSignature.decimal;
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

  /// Checks whether [duration] is valid and returns what the smallest
  /// duration it can be is (for instance a dur of 1.0 added to an overall
  /// duration of 0.5 in an even time signature will produce a dur of 0.5 in
  /// it's start, which is the smallest it can be).
  double _checkValidDuration({
    required T? value,
    required double duration,
    required double overallDuration,
  }) {
    double decimal = _timeSignature.decimal;
    if (duration < 0) {
      throw NonPositiveDuration(value, duration);
    } else if ((overallDuration % decimal) + duration <= decimal) {
      assertDurationValid(value: value, duration: duration);
      return duration;
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
      return currentMinDuration;
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
