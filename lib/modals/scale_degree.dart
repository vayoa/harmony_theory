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

  late final int _degree;
  late final int _offset;

  /// The scale degree number.
  /// Examples:
  /// The [degree] for III is 3.
  /// The [degree] for V is 5.
  int get degree => _degree;

  /// Negative for flats and positive for sharps.
  int get offset => _offset;

  ScaleDegree(ScalePattern scalePattern, Interval interval) {
    final List<int> _semitones =
        scalePattern.intervals.map<int>((e) => e.semitones).toList();
    interval = Interval.fromSemitones(interval.semitones % 12);
    _degree = interval.number;
    _offset = interval.semitones - _semitones[_degree - 1];
  }

  /// Returns a [ScaleDegree] from the given [Interval], based on a major scale.
  ScaleDegree.fromInterval(Interval interval)
      : this(ScalePattern.findByName('Diatonic Major'), interval);

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

  @override
  String toString() =>
      ((_offset.isNegative ? 'b' : '#') * _offset.abs()) + degrees[_degree - 1];

  @override
  bool operator ==(Object other) =>
      other is ScaleDegree &&
      (other._degree == _degree && other._offset == _offset);

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(_degree, _offset);
}
