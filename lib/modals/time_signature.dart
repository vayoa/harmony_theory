import 'dart:math';

/// Represents a musical time signature.
class TimeSignature {
  /// Represents the time signature's numerator (number of beats in one bar).
  final int numerator;

  /// Represents the time signature's denominator (duration/note value of a
  /// beat).
  final int denominator;

  final double step;

  /// The time signature's decimal fraction ([numerator] / [denominator]...).
  final double decimal;

  const TimeSignature(this.numerator, this.denominator)
      : assert(numerator > 0 && denominator > 0),
        decimal = numerator / denominator,
        step = 1 / denominator;

  /// Constructs a 4/4 [TimeSignature] object.
  const TimeSignature.evenTime() : this(4, 4);

  // I'm not saving step and decimal since we can very easily calculate them
  // and it'll save space in the json.
  /// Only works with the one digit time signatures that exists currently.
  TimeSignature.fromString(String string)
      : this(int.parse(string[0]), int.parse(string[2]));

  /// Returns whether [duration] is valid for this TimeSignature or not.
  bool validDuration(double duration) =>
      (duration % decimal == 0) ||
      duration >= step && (log(duration / step) / ln2) % 1 == 0;

  bool validDurationPos(double duration, double durationTo) {
    if (durationTo < 0 || duration < 0) return false;
    if ((durationTo % decimal) + duration <= decimal) {
      return validDuration(duration);
    } else {
      // The duration the current measure has left before being full.
      double left = decimal - (durationTo % decimal);
      // If left is decimal it's in fact 0.0 (since we have the whole measure left...).
      if (left != decimal && duration >= left) {
        return validDuration(left);
      }
      // The duration that's left after the cut...
      double end = (durationTo + duration) % decimal;
      // Since if this is true the rest is valid...
      if (end != 0) {
        return validDuration(end);
      } else {
        return true;
      }
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      other is TimeSignature &&
      numerator == other.numerator &&
      denominator == other.denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);

  @override
  String toString() => '$numerator/$denominator';
}
