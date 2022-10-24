class NonPositiveDuration<T> implements Exception {
  final T? value;
  final double duration;

  const NonPositiveDuration(this.value, this.duration);

  @override
  String toString() =>
      '$value, with a non-positive duration ($duration) was added to a '
          'progression.';
}