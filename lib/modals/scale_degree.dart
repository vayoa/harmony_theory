import 'package:thoery_test/extensions/scale_extension.dart';
import 'package:thoery_test/modals/pitch_scale.dart';
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

  ScaleDegree.raw(int degree, int accidentals)
      : assert(degree >= 0 && degree <= 6),
        _degree = degree,
        _accidentals = accidentals.sign * (accidentals.abs() % 12);

  ScaleDegree.copy(ScaleDegree other)
      : _degree = other._degree,
        _accidentals = other._accidentals;

  ScaleDegree(ScalePattern scalePattern, Interval interval)
      : this.rawInterval(
            scalePattern: scalePattern,
            intervalNumber: interval.number,
            intervalSemitones: interval.semitones);

  /// A separate function from the default constructor to avoid
  /// [Interval.fromSemitones] construction errors we don't care about.
  /// Will always assume it gets the parameters for a degree in a major scale.
  ScaleDegree.rawInterval({
    required ScalePattern scalePattern,
    required int intervalNumber,
    required int intervalSemitones,
  }) {
    final List<int> _semitones = ScalePatternExtension.majorKeySemitones;
    _degree = (intervalNumber - 1) % 7;
    int accidentals = (intervalSemitones - _semitones[_degree]) % 12;
    int down = (_semitones[_degree] - intervalSemitones) % 12;
    if (down < accidentals) accidentals = -1 * down;
    _accidentals = accidentals;
  }

  /// Returns a [ScaleDegree] from the given [Interval], based on a major scale!
  ScaleDegree.fromInterval(Interval interval)
      : this(ScalePatternExtension.majorKey, interval);

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
        _accidentals = offsetStr[0].allMatches(offsetStr).length *
            (offsetStr[0].contains(RegExp(r'[b♭𝄫]')) ? -1 : 1);
      } else {
        throw FormatException("invalid ScaleDegree name: $degree");
      }
    } else {
      _accidentals = 0;
    }
  }

  ScaleDegree.fromJson(Map<String, dynamic> json)
      : _degree = json['d'],
        _accidentals = json['a'];

  Map<String, dynamic> toJson() => {
        'd': _degree,
        'a': _accidentals,
      };

  static final tonic = ScaleDegree.parse('I');
  static final V = ScaleDegree.parse('V');
  static final vii = ScaleDegree.parse('vii');
  static final vi = ScaleDegree.parse('vi');

  // TODO: This only works for major based modes...,
  /// Returns a new [ScaleDegree] converted from the [fromMode] mode to [toMode]
  /// mode.
  /// Ionian's (Major) mode number is 0 and so on...
  /// Example: I.modeShift(0, 5) [major to minor] => VI.
  ScaleDegree modeShift(int fromMode, int toMode) {
    assert(fromMode >= 0 && fromMode <= 7 && toMode >= 0 && toMode <= 7);
    return ScaleDegree.raw((_degree + (toMode - fromMode)) % 7, _accidentals);
  }

  /// We assume we're shifting from a scale where I is the tonic.
  ScaleDegree shiftFor(ScaleDegree other) {
    Interval normal = ScalePatternExtension.majorKey.intervals[_degree] -
        ScalePatternExtension.majorKey.intervals[other.degree];
    Interval from = this.from(other);
    // We do this so that if a II.shiftFor(V) will always be a V of sorts no
    // matter the accidentals...
    return ScaleDegree.raw(
      normal.number - 1,
      (from - normal).semitones,
    );
  }

  /// Returns a new [ScaleDegree] converted such that [tonic] is the new tonic.
  /// Everything is still represented in the major scale, besides to degree
  /// the function is called on...
  /// Example: V.tonicizedFor(VI) => III, I.tonicizedFor(VI) => VI.
  ScaleDegree tonicizedFor(ScaleDegree tonic) {
    if (tonic == ScaleDegree.tonic) return ScaleDegree.copy(this);
    return tonic.add(from(ScaleDegree.tonic));
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

  /// Returns a new [ScaleDegree] that is [interval] far away from the current
  /// one, in the major scale.
  /// Notice: The degree will always be [interval.number] away from [_degree].
  /// Example: ###I.add(Interval.P5) => ###V.
  ScaleDegree add(Interval interval) {
    final List<int> _semitones = ScalePatternExtension.majorKeySemitones;
    Interval scaleDegree =
        Interval.fromSemitones(_semitones[_degree] + _accidentals);
    Interval fromTonic =
        Interval.fromSemitones(interval.semitones + scaleDegree.semitones);
    int number = (_degree + interval.number - 1) % 7;
    return ScaleDegree.raw(number, fromTonic.semitones - _semitones[number]);
  }

  Interval from(ScaleDegree other) => Interval.fromSemitones(
      (_semitonesFromTonicInMajor - other._semitonesFromTonicInMajor) % 12);

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
      other is ScaleDegree &&
      (other._degree == _degree && other._accidentals == _accidentals);

  @override
  int get hashCode => Object.hash(_degree, _accidentals);
}
