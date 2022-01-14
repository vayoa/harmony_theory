/// Represents a musical time signature.
class TimeSignature {
  /// Represents the time signature's numerator (number of beats in one bar).
  final int numerator;

  /// Represents the time signature's denominator (duration/note value of a
  /// beat).
  final int denominator;

  const TimeSignature(this.numerator, this.denominator);

  /// Constructs a 4/4 [TimeSignature] object.
  const TimeSignature.evenTime() : this(4, 4);

  /// Returns the time signature's decimal fraction
  /// ([numerator] / [denominator]...)
  double get decimal => numerator / denominator;

  @override
  bool operator ==(Object other) =>
      other is TimeSignature &&
      numerator == other.numerator &&
      denominator == other.denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);
}
