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

  // TDC: Check this!!
  /// Returns whether [duration] is valid for this TimeSignature or not.
  bool validDuration(double duration) =>
      (duration % decimal == 0) ||
      duration >= step && (log(duration / step) / ln2) % 1 == 0;

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
