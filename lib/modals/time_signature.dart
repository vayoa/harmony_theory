class Fraction {
  final int numerator;
  final int denominator;

  const Fraction(this.numerator, this.denominator);

  // Taken from https://www.geeksforgeeks.org/convert-given-decimal-number-into-an-irreducible-fraction/.
  factory Fraction.fromDecimal(double decimal) {
    // Fetch integral value of the decimal
    double intVal = decimal.floor().toDouble();

    // Fetch fractional part of the decimal
    double fVal = decimal - intVal;

    // Consider precision value to convert fractional part to integral
    // equivalent
    const int pVal = 1000000000;

    // Calculate GCD of integral
    // equivalent of fractional
    // part and precision value
    int gcdVal = gcd((fVal * pVal).round(), pVal);

    // Calculate num and deno
    int num = (fVal * pVal).round() ~/ gcdVal;
    int deno = pVal ~/ gcdVal;
    return Fraction(num, deno);
  }

  static int gcd(int a, int b) {
    if (a == 0) return b;
    if (b == 0) return a;
    if (a < b) return gcd(a, b % a);
    return gcd(b, a % b);
  }

  double get decimal => numerator / denominator;
}

class TimeSignature extends Fraction {
  /// Constructs a 4/4 [TimeSignature] object.
  const TimeSignature.evenTime() : super(4, 4);
}
