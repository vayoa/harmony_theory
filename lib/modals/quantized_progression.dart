import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/progression.dart';
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
class QuantizedProgression<T> extends Progression<T> {
  /// Creates a new [QuantizedProgression] object, where all durations are positive
  /// and smaller than 1 (if an element in [durations] isn't, we split it).
  /// [timeSignature] is [TimeSignature.evenTime()] by default.
  /// [ratio] would be multiplied for all durations (1.0 by default).
  QuantizedProgression(List<T?> values, List<double> durations,
      {TimeSignature? timeSignature, double? ratio})
      : assert(values.length == durations.length),
        super.empty(timeSignature: timeSignature) {
    ratio ??= 1.0;
    List<double> _durationList = this.durations.realDurations;
    if (values.isNotEmpty) {
      double overallDuration = 0.0;
      double durSum = 0.0;
      for (int i = 0; i < values.length; i++) {
        if (durations[i] <= 0) {
          throw NonPositiveDuration(this.values[i], this.durations[i]);
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
          if (!hasNull) hasNull = values[i] == null;
          overallDuration += durSum;
          _durationList.add(overallDuration);
          values.add(val);
          durSum = 0;
        }
      }
    }
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
  QuantizedProgression._absoluteInternal(
    List<T?> values,
    List<double> durations, {
    TimeSignature? timeSignature,
    double? ratio,
    int start = 0,
    int? end,
    double durationDiff = 0.0,
  })  : assert(values.length == durations.length),
        super.empty(timeSignature: timeSignature) {
    ratio ??= 1.0;
    end ??= values.length;
    List<double> _durationList = this.durations.realDurations;
    if (values.isNotEmpty) {
      double previousDuration = 0.0;
      for (int i = start; i < end; i++) {
        if (durations[i] <= 0) {
          throw NonPositiveDuration(this.values[i], this.durations[i]);
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
          if (!hasNull) hasNull = values[i] == null;
          previousDuration += nonAbsoluteDuration;
          _durationList.add(previousDuration);
          values.add(val);
        }
      }
    }
  }

  /// Constructs a progression where [durations] is a list of absolute durations.
  /// [timeSignature] is [TimeSignature.evenTime()] by default.
  /// [ratio] would be multiplied for all durations (1.0 by default).
  QuantizedProgression.absolute(List<T?> values, List<double> durations,
      {TimeSignature? timeSignature, double? ratio})
      : this._absoluteInternal(values, durations,
            timeSignature: timeSignature, ratio: ratio);

  /// Doesn't check for duplicates or full and just sets the values for the
  /// fields.
  QuantizedProgression.raw({
    required List<T?> values,
    required AbsoluteDurations durations,
    required TimeSignature timeSignature,
    required bool hasNull,
  }) : super.raw(
          values: values,
          durations: durations,
          timeSignature: timeSignature,
          hasNull: hasNull,
        );

  QuantizedProgression.evenTime(List<T?> base,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : this.absolute(
            base,
            List.generate(base.length,
                (index) => (index + 1) * (1 / timeSignature.denominator)),
            timeSignature: timeSignature);

  @override
  void add(T? value, double newDuration) {
    if (newDuration <= 0) {
      throw NonPositiveDuration(value, newDuration);
    }
    T? last = values.isEmpty ? null : values.last;
    if (values.isNotEmpty && adjacentValuesEqual(value, last)) {
      double dur = (newDuration + durations.last) % timeSignature.decimal;
      if (dur > 0) {
        checkValidDuration(
          value: value,
          duration: dur,
          // The overall duration is the progression's duration - the last
          // one since they're the same...
          overallDuration: duration - durations.last,
        );
        if (!hasNull) hasNull = value == null;
      }
      durations.last += newDuration;
    } else {
      checkValidDuration(
          value: value, duration: newDuration, overallDuration: duration);
      values.add(value);
      durations.add(newDuration);
    }
    if (!hasNull) hasNull = value == null;
  }

  @override
  void addAll(Progression<T> progression) {
    if (!progression.isEmpty) {
      bool fullBefore = full;
      // In case the last of the current progression is equal to the first
      // of the added progression...
      add(progression.values.first, progression.durations.first);
      if (progression.length > 1) {
        if (fullBefore) {
          values.addAll(progression.values.sublist(1));
          durations.addAll(progression.durations, from: 1);
        } else {
          for (int i = 1; i < progression.length; i++) {
            add(progression.values[i], progression.durations[i]);
          }
        }
      }
      if (!hasNull && progression.hasNull) hasNull = true;
    }
  }

  @override
  QuantizedProgression<T> sublist(int start, [int? end]) =>
      QuantizedProgression._absoluteInternal(values, durations.realDurations,
          timeSignature: timeSignature,
          start: start,
          end: end,
          durationDiff: start == 0 ? 0.0 : durations.realDurations[start - 1]);

  /// Checks whether [duration] is valid.
  void checkValidDuration({
    required T? value,
    required double duration,
    required double overallDuration,
  }) {
    assert(overallDuration >= 0);
    double decimal = timeSignature.decimal;
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
    if (!timeSignature.validDuration(duration)) {
      throw NonValidDuration(
          value: value, duration: duration, timeSignature: timeSignature);
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
