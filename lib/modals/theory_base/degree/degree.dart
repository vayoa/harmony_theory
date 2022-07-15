import 'package:tonic/tonic.dart';

import '../../../extensions/scale_pattern_extension.dart';
import '../../identifiable.dart';
import '../pitch_scale.dart';

class Degree implements Identifiable {
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
  late final int _accidentals;

  /// The scale degree number.
  /// Examples:
  /// The [degree] for III is 2.
  /// The [degree] for V is 4.
  int get degree => _degree;

  /// Negative for flats and positive for sharps.
  /// Max value is 11 (as 12 will be an octave...).
  int get accidentals => _accidentals;

  bool get isDiatonic => _accidentals == 0;

  Degree.raw(int degree, int accidentals)
      : assert(degree >= 0 && degree <= 6),
        _degree = degree,
        _accidentals = accidentals.sign * (accidentals.abs() % 12);

  Degree.copy(Degree other)
      : _degree = other._degree,
        _accidentals = other._accidentals;

  Degree(ScalePattern scalePattern, Interval interval)
      : this.rawInterval(
            scalePattern: scalePattern,
            intervalNumber: interval.number,
            intervalSemitones: interval.semitones);

  factory Degree.fromPitch(PitchScale scale, Pitch pitch) {
    Pitch tRoot = scale.majorTonic;
    int semitones = (pitch.semitones - tRoot.semitones) % 12;
    int number = 1 + pitch.letterIndex - tRoot.letterIndex;
    if (number <= 0) number += 7;
    return Degree.rawInterval(
      scalePattern: scale.pattern,
      intervalNumber: number,
      intervalSemitones: semitones,
    );
  }

  /// A separate function from the default constructor to avoid
  /// [Interval.fromSemitones] construction errors we don't care about.
  /// Will always assume it gets the parameters for a degree in a major scale.
  Degree.rawInterval({
    required ScalePattern scalePattern,
    required int intervalNumber,
    required int intervalSemitones,
  }) {
    final List<int> semitones = ScalePatternExtension.majorKeySemitones;
    _degree = (intervalNumber - 1) % 7;
    int accidentals = (intervalSemitones - semitones[_degree]) % 12;
    int down = (semitones[_degree] - intervalSemitones) % 12;
    if (down < accidentals) accidentals = -1 * down;
    _accidentals = accidentals;
  }

  Degree.parse(String degree) {
    final int startIndex =
        degree.indexOf(RegExp(r'[iv]', caseSensitive: false));
    String degreeStr = degree.substring(startIndex);
    String offsetStr = degree.substring(0, startIndex);
    int index = degrees.indexOf(degreeStr.toUpperCase()) + 1;
    if (index == 0) {
      throw FormatException("invalid Degree name: $degree");
    }
    _degree = index - 1;
    if (offsetStr.isNotEmpty) {
      if (offsetStr.startsWith(RegExp(r'[#b♯♭𝄪𝄫]'))) {
        _accidentals = offsetStr[0].allMatches(offsetStr).length *
            (offsetStr[0].contains(RegExp(r'[b♭𝄫]')) ? -1 : 1);
      } else {
        throw FormatException("invalid Degree name: $degree");
      }
    } else {
      _accidentals = 0;
    }
  }

  Degree.fromJson(Map<String, dynamic> json)
      : _degree = json['d'],
        _accidentals = json['a'];

  Map<String, dynamic> toJson() => {
        'd': _degree,
        'a': _accidentals,
      };

  static final tonic = Degree.parse('I');
  static final V = Degree.parse('V');
  static final vii = Degree.parse('vii');
  static final vi = Degree.parse('vi');

  /// We assume we're shifting from a scale where I is the tonic.
  Degree shiftFor(Degree other) {
    Interval normal = ScalePatternExtension.majorKey.intervals[_degree] -
        ScalePatternExtension.majorKey.intervals[other.degree];
    Interval from = this.from(other);
    // We do this so that if a II.shiftFor(V) will always be a V of sorts no
    // matter the accidentals...
    return Degree.raw(
      normal.number - 1,
      (from - normal).semitones,
    );
  }

  /// Returns a new [Degree] converted such that [tonic] is the new tonic.
  /// Everything is still represented in the major scale, besides to degree
  /// the function is called on...
  /// Example: V.tonicizedFor(VI) => III, I.tonicizedFor(VI) => VI.
  Degree tonicizedFor(Degree tonic) {
    if (tonic == Degree.tonic) return Degree.copy(this);
    return tonic.add(from(Degree.tonic));
  }

  Pitch inScale(PitchScale scale) {
    int index = _degree;
    if (scale.isMinor) index = (_degree - 5) % 7;
    Pitch diatonic = scale.tonic + scale.intervals[index];
    return Pitch(
        chromaticIndex:
            (diatonic.semitones - diatonic.accidentalSemitones) % 12,
        accidentalSemitones: diatonic.accidentalSemitones + _accidentals);
  }

  /// Returns a new [Degree] that is [interval] far away from the current
  /// one, in the major scale.
  /// Notice: The degree will always be [interval.number] away from [_degree].
  /// Example: ###I.add(Interval.P5) => ###V.
  Degree add(Interval interval) {
    final List<int> semitones = ScalePatternExtension.majorKeySemitones;
    Interval scaleDegree =
        Interval.fromSemitones(semitones[_degree] + _accidentals);
    Interval fromTonic =
        Interval.fromSemitones(interval.semitones + scaleDegree.semitones);
    int number = (_degree + interval.number - 1) % 7;
    return Degree.raw(number, fromTonic.semitones - semitones[number]);
  }

  /* TDC: Some intervals can't be parsed (like a doubly-augmented 4th), we might
          need to rewrite the Interval class to support them. */
  Interval from(Degree other, {bool enforceNumber = true}) {
    var number = ((degree - other.degree) % 7) + 1;
    var semitones =
        (_semitonesFromTonicInMajor - other._semitonesFromTonicInMajor) % 12;
    if (number == 1 && semitones == 11) number = 8;
    return Interval.fromSemitones(
      semitones,
      number: enforceNumber ? number : null,
    );
  }

  Interval? tryFrom(Degree other) {
    try {
      return from(other);
    } on ArgumentError {
      return null;
    }
  }

  int get _semitonesFromTonicInMajor {
    int semitones =
        ScalePatternExtension.majorKey.intervals[_degree].semitones +
            _accidentals;
    if (semitones < 0) return 12 + semitones;
    return semitones;
  }

  @override
  String toString() =>
      ((_accidentals.isNegative ? 'b' : '#') * _accidentals.abs()) +
      degrees[_degree];

  @override
  bool operator ==(Object other) =>
      other is Degree &&
      (other._degree == _degree && other._accidentals == _accidentals);

  @override
  int get hashCode => Object.hash(_degree, _accidentals);

  @override
  int get id => Identifiable.hash2(_degree, _accidentals);
}
