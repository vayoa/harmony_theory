import 'dart:math';

import 'package:tonic/tonic.dart';

class ScaleDegree {
  static const List<String> degrees = [
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII'
  ];

  // TODO: Move this...
  static final majorKey = ScalePattern.findByName('Diatonic Major');
  static final minorKey = ScalePattern.findByName('Natural Minor');

  late final int _degree;
  late final int _offset;

  /// The scale degree number.
  /// Examples:
  /// The [degree] for III is 2.
  /// The [degree] for V is 4.
  int get degree => _degree;

  /// Negative for flats and positive for sharps.
  int get offset => _offset;

  bool get isDiatonic => _offset == 0;

  ScaleDegree.raw(int degree, int offset)
      : assert(degree > 0 && degree < 8),
        _degree = degree,
        _offset = offset;

  ScaleDegree(ScalePattern scalePattern, Interval interval) {
    final List<int> _semitones =
        scalePattern.intervals.map<int>((e) => e.semitones).toList();
    interval = Interval.fromSemitones(interval.semitones % 12);
    _degree = interval.number - 1;
    _offset = interval.semitones - _semitones[_degree];
  }

  /// Returns a [ScaleDegree] from the given [Interval], based on a major scale!
  ScaleDegree.fromInterval(Interval interval) : this(majorKey, interval);

  ScaleDegree.parse(String degree) {
    final int startIndex = degree.indexOf(RegExp(r'i|v', caseSensitive: false));
    String degreeStr = degree.substring(startIndex);
    String offsetStr = degree.substring(0, startIndex);
    int index = degrees.indexOf(degreeStr.toUpperCase()) + 1;
    if (index == 0) {
      throw FormatException("invalid ScaleDegree name: $degree");
    }
    _degree = index - 1;
    // TODO: Test offset handling.
    if (offsetStr.isNotEmpty) {
      if (offsetStr.startsWith(RegExp(r'[#b♯♭𝄪𝄫]'))) {
        _offset = offsetStr[0].allMatches(offsetStr).length *
            (offsetStr[0].contains(RegExp(r'[b♭𝄫]')) ? -1 : 1);
      } else {
        throw FormatException("invalid ScaleDegree name: $degree");
      }
    } else {
      _offset = 0;
    }
  }

  // TODO: This only works for major based modes...,
  /// Returns a new [ScaleDegree] converted from the [fromMode] mode to [toMode]
  /// mode.
  /// Ionian's (Major) mode number is 0 and so on...
  /// Example: I.modeShift(0, 5) [major to minor] => IV.
  ScaleDegree modeShift(int fromMode, int toMode) {
    assert(fromMode >= 0 && fromMode <= 7 && toMode >= 0 && toMode <= 7);
    return ScaleDegree.raw((_degree + (toMode - fromMode)) % 7, _offset);
  }

  PitchClass inScale(Scale scale) {
    return PitchClass.fromSemitones(
        scale.pitchClasses[_degree].integer + _offset);
  }

  ScaleDegree add(ScalePattern scalePattern, Interval interval) {
    final List<int> _semitones =
        scalePattern.intervals.map<int>((e) => e.semitones).toList();
    Interval scaleDegree =
        Interval.fromSemitones(_semitones[_degree] + _offset);
    interval = Interval.fromSemitones(
        (interval.semitones + scaleDegree.semitones) % 12);
    return ScaleDegree.raw(
        interval.number, interval.semitones - _semitones[interval.number - 1]);
  }

  ScaleDegree addInMajor(Interval interval) => add(majorKey, interval);

  Interval from(ScalePattern scalePattern, ScaleDegree other) =>
      Interval.fromSemitones((scalePattern.intervals
                  .sublist(
                      min(_degree, other._degree), max(_degree, other._degree))
                  .fold<int>(0, (prev, e) => prev + e.semitones) +
              _offset +
              other._offset) %
          12);

  @override
  String toString() =>
      ((_offset.isNegative ? 'b' : '#') * _offset.abs()) + degrees[_degree];

  @override
  bool operator ==(Object other) =>
      other is ScaleDegree &&
      (other._degree == _degree && other._offset == _offset);

  @override
  int get hashCode => Object.hash(_degree, _offset);
}
