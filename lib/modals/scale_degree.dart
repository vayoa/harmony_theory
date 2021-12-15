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

  static final majorKey = ScalePattern.findByName('Diatonic Major');

  late final int _degree;
  late final int _offset;

  /// The scale degree number.
  /// Examples:
  /// The [degree] for III is 3.
  /// The [degree] for V is 5.
  int get degree => _degree;

  /// Negative for flats and positive for sharps.
  int get offset => _offset;

  ScaleDegree.raw(int degree, int offset)
      : _degree = degree,
        _offset = offset;

  ScaleDegree(ScalePattern scalePattern, Interval interval) {
    final List<int> _semitones =
        scalePattern.intervals.map<int>((e) => e.semitones).toList();
    interval = Interval.fromSemitones(interval.semitones % 12);
    _degree = interval.number;
    _offset = interval.semitones - _semitones[_degree - 1];
  }

  /// Returns a [ScaleDegree] from the given [Interval], based on a major scale.
  ScaleDegree.fromInterval(Interval interval) : this(majorKey, interval);

  ScaleDegree.parse(String degree) {
    final int startIndex = degree.indexOf(RegExp(r'i|v', caseSensitive: false));
    String degreeStr = degree.substring(startIndex);
    String offsetStr = degree.substring(0, startIndex);
    int index = degrees.indexOf(degreeStr.toUpperCase()) + 1;
    if (index == 0) {
      throw FormatException("invalid ScaleDegree name: $degree");
    }
    _degree = index;
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

  PitchClass inScale(Scale scale) => PitchClass.fromSemitones(
      scale.pitchClasses[_degree - 1].integer + _offset);

  ScaleDegree add(ScalePattern pattern, Interval interval) {
    final List<int> _semitones =
        pattern.intervals.map<int>((e) => e.semitones).toList();
    Interval scaleDegree =
        Interval.fromSemitones(_semitones[_degree - 1] + _offset);
    interval = Interval.fromSemitones(
        (interval.semitones + scaleDegree.semitones) % 12);
    return ScaleDegree.raw(
        interval.number, interval.semitones - _semitones[interval.number - 1]);
  }

  ScaleDegree addInMajor(Interval interval) => add(majorKey, interval);

  @override
  String toString() =>
      ((_offset.isNegative ? 'b' : '#') * _offset.abs()) + degrees[_degree - 1];

  @override
  bool operator ==(Object other) =>
      other is ScaleDegree &&
      (other._degree == _degree && other._offset == _offset);

  @override
  int get hashCode => Object.hash(_degree, _offset);
}
