import 'time_signature.dart';

class NonPositiveDuration<T> implements Exception {
  final T? value;
  final double duration;

  const NonPositiveDuration(this.value, this.duration);

  @override
  String toString() =>
      '$value, with a non-positive duration ($duration) was added to a '
          'progression.';
}

class NonValidDuration<T> implements Exception {
  final T? value;
  final double duration;
  final TimeSignature timeSignature;

  const NonValidDuration({
    required this.value,
    required this.duration,
    required this.timeSignature,
  });

  @override
  String toString() =>
      '$value($duration), an invalid duration for a time signature of '
          '$timeSignature was added to a progression.';
}