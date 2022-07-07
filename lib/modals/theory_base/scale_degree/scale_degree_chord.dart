import 'dart:convert';

import 'package:harmony_theory/extensions/scale_pattern_extension.dart';
import 'package:tonic/tonic.dart';

import '../../../extensions/chord_extension.dart';
import '../../../extensions/interval_extension.dart';
import '../../analysis_tools/pair_map.dart';
import '../../identifiable.dart';
import '../../pitch_chord.dart';
import '../generic_chord.dart';
import '../pitch_scale.dart';
import 'scale_degree.dart';
import 'tonicized_scale_degree_chord.dart';

class ScaleDegreeChord extends GenericChord<ScaleDegree>
    implements Identifiable {
  final Interval? _bassToRoot;

  Interval? get bassToRoot => _bassToRoot;

  final bool _isInversion;

  /// Returns true if [bass] is a degree in the current [ScaleDegreeChord], meaning an inversion.
  ///
  /// If [bass] is the same as [root] will still return true.
  bool get isInversion => _isInversion;

  ScaleDegreeChord get tonic => majorTonicTriad;

  static const int maxInversionNumbers = 2;

  static final RegExp chordNamePattern = RegExp(
      r"^([#b♯♭𝄪𝄫]*(?:III|II|IV|I|VII|VI|V))([^\^]*)(?:\^([#b♯♭𝄪𝄫]*\d))?$",
      caseSensitive: false);

  static const List<String> _canBeTonicizedPatterns = [
    'Major',
    'Minor',
    'Major 7th',
    'Minor 7th',
    'Dominant 7th',
  ];

  // TODO: Optimize.
  // TODO: When we get a chord like A/B we need it to become B11 for instance...
  /// If the bass isn't an inversion and there's a problem with calculating an
  /// interval, this constructor takes the in-harmonic equivalent of the bass.
  ///
  /// Example: In C major, a ScaleDegreeChord that was parsed from C/F##
  /// will turn to I⁶₄ (C/G)...
  factory ScaleDegreeChord._inharmonicityHandler(
    ChordPattern pattern,
    ScaleDegree rootDegree, {
    ScaleDegree? bass,
  }) {
    if (bass == null) {
      return ScaleDegreeChord.raw(pattern, rootDegree);
    }
    Interval? tryFrom = rootDegree.tryFrom(bass);
    if (tryFrom == null) {
      int semitones = ScalePatternExtension.majorKeySemitones[bass.degree] +
          bass.accidentals;
      bass = ScaleDegree.fromPitch(
          PitchScale.cMajor, Pitch.fromMidiNumber(semitones));
    }
    return ScaleDegreeChord.raw(pattern, rootDegree, bass: bass);
  }

  factory ScaleDegreeChord(PitchScale scale, PitchChord chord) =>
      ScaleDegreeChord._inharmonicityHandler(
        chord.pattern,
        ScaleDegree.fromPitch(scale, chord.root),
        bass: !chord.hasDifferentBass
            ? null
            : ScaleDegree.fromPitch(scale, chord.bass),
      );

  ScaleDegreeChord.raw(
    ChordPattern pattern,
    ScaleDegree rootDegree, {
    ScaleDegree? bass,
    Interval? bassToRoot,
    bool? isInversion,
  })  : _bassToRoot = bassToRoot ??
            (bass == null ? Interval.P1 : bass.tryFrom(rootDegree)),
        // TODO: bassToRoot gets calculated twice...
        _isInversion = isInversion ??
            (bass == null
                ? true
                : pattern.intervals.contains(bass.tryFrom(rootDegree))),
        super(pattern, rootDegree, bass: bass);

  ScaleDegreeChord.copy(ScaleDegreeChord chord)
      : _bassToRoot = chord._bassToRoot,
        _isInversion = chord._isInversion,
        super(
          ChordPattern(
              name: chord.pattern.name,
              fullName: chord.pattern.fullName,
              abbrs: chord.pattern.abbrs,
              intervals: chord.pattern.intervals),
          ScaleDegree.copy(chord.root),
          bass: ScaleDegree.copy(chord.bass),
        );

  factory ScaleDegreeChord.parse(String name) {
    List<String> split = name.split(r'/');
    if (split.length == 1) {
      return _parseInternal(name);
    } else {
      return _parseInternal(split[0]).tonicizedFor(_parseInternal(split[1]));
    }
  }

  static ScaleDegreeChord _parseInternal(String chord) {
    final match = chordNamePattern.matchAsPrefix(chord);
    if (match == null) {
      throw FormatException("invalid ScaleDegreeChord name: $chord");
    }
    // If the degree is a lowercase letter (meaning the chord contains a minor
    // triad).
    ChordPattern cPattern = ChordPattern.parse(match[2]!.replaceAll('b', '♭'));
    if (match[1]!.toLowerCase() == match[1]) {
      // We don't want to change any of the generated chord patterns (for some
      // reason they aren't const so I can change them and screw up that entire
      // ChordPattern.
      // The ... operator de-folds the list.
      final List<Interval> intervals = [...cPattern.intervals];
      // Make the 2nd interval (the one between the root and the 3rd) minor.
      intervals[1] = Interval.m3;
      cPattern = ChordPattern.fromIntervals(intervals);
    }
    ScaleDegree rootDegree = ScaleDegree.parse(match[1]!);
    String? bass = match[3];
    return ScaleDegreeChord._inharmonicityHandler(
      cPattern,
      rootDegree,
      bass: _parseBass(bass, rootDegree, cPattern),
    );
  }

  /// Returns [degree, accidentals].
  static ScaleDegree? _parseBass(
      String? name, ScaleDegree root, ChordPattern pattern) {
    if (name == null || name.isEmpty) return null;
    int degree, accidentals;
    final int startIndex = name.indexOf(RegExp(r'\d', caseSensitive: false));
    String degreeStr = name.substring(startIndex);
    String offsetStr = name.substring(0, startIndex);
    degree = int.parse(degreeStr) - 1;
    if (degree < 0 || degree > 7) {
      throw FormatException("invalid bass interval name: $name");
    }
    if (offsetStr.isNotEmpty) {
      if (offsetStr.startsWith(RegExp(r'[#b♯♭𝄪𝄫]'))) {
        accidentals = offsetStr[0].allMatches(offsetStr).length *
            (offsetStr[0].contains(RegExp(r'[b♭𝄫]')) ? -1 : 1);
      } else {
        throw FormatException("invalid bass interval name: $name");
      }
    } else {
      accidentals = 0;
    }
    if (degree == 0 && accidentals == 0) return null;
    Interval regular;
    // If the number is odd and there's such degree in the pattern use it from
    // the pattern...
    // degree is the number parsed - 1...
    /* TODO: Make a harmonic analysis to choose which interval to use on the
             7th when the chord doesn't have one - for instance a V should have
             a min7 like other minor chords instead of a maj7 like other maj
             chords etc... */
    if (degree % 2 == 0 && degree ~/ 2 < pattern.intervals.length) {
      regular = pattern.intervals[degree ~/ 2];
    } else {
      // else default it to major / perfect...
      regular = Interval(number: degree + 1);
    }
    ScaleDegree bass = root.add(regular);
    return ScaleDegree.raw(bass.degree, bass.accidentals + accidentals);
  }

  ScaleDegreeChord.fromJson(Map<String, dynamic> json)
      : this.raw(
          ChordPatternExtension.fromFullName(json['p']),
          ScaleDegree.fromJson(json['rd']),
          bass: json['b'] == null ? null : ScaleDegree.fromJson(json['b']),
        );

  Map<String, dynamic> toJson() => {
        'rd': root.toJson(),
        'p': pattern.fullName,
        if (hasDifferentBass) 'b': bass.toJson(),
      };

  @override
  List<ScaleDegree> get patternMapped =>
      pattern.intervals.map((i) => root.add(i)).toList();

  /// Returns a list of [ScaleDegree] that represents the degrees that make up
  /// the [ScaleDegreeChord] in the major scale.
  List<ScaleDegree> get degrees => patternMapped;

  int get degreesLength => patternLength;

  /// Returns true if the chord is diatonic in the major scale.
  bool get isDiatonic =>
      bass.isDiatonic && degrees.every((degree) => degree.isDiatonic);

  bool get canBeTonic {
    if (_canBeTonicizedPatterns.contains(pattern.name)) return true;
    final List<Interval> intervals = pattern.intervals;
    if ((intervals[2] - intervals[0]).equals(Interval.P5)) {
      final Interval third = intervals[1] - intervals[0];
      if (third.equals(Interval.M3) || third.equals(Interval.m3)) {
        if (intervals.length < 4) return true;
        final Interval seventh = (intervals[3] - intervals[0]);
        if (seventh.equals(Interval.m7)) {
          return true;
        }
        return third.equals(Interval.M3) || seventh.equals(Interval.M7);
      }
    }
    return false;
  }

  /// Returns a new [ScaleDegreeChord] converted such that [tonic] is the new
  /// tonic. Everything is still represented in the major scale, besides to degree the function is called on...
  ///
  /// Example: V.tonicizedFor(VI) => III, I.tonicizedFor(VI) => VI,
  /// ii.tonicizedFor(VI) => vii.
  ScaleDegreeChord tonicizedFor(ScaleDegreeChord tonic) {
    if (tonic.root == ScaleDegree.tonic) {
      return ScaleDegreeChord.copy(this);
    } else if (weakEqual(majorTonicTriad)) {
      return ScaleDegreeChord.raw(
        tonic.pattern,
        tonic.root,
        bass: tonic.bass,
        isInversion: tonic._isInversion,
        bassToRoot: tonic._bassToRoot,
      );
    }
    return TonicizedScaleDegreeChord(
      tonic: tonic,
      tonicizedToTonic: ScaleDegreeChord.copy(this),
      tonicizedToMajorScale: ScaleDegreeChord.raw(
        pattern,
        root.tonicizedFor(tonic.root),
        bass: bass.tonicizedFor(tonic.root),
      ),
    );
  }

  ScaleDegreeChord reverseTonicization(ScaleDegreeChord tonic) {
    if (tonic.root == ScaleDegree.tonic) {
      return ScaleDegreeChord.copy(this);
    } else if (weakEqual(majorTonicTriad)) {
      return ScaleDegreeChord.copy(tonic);
    } else if (weakEqual(tonic)) {
      return ScaleDegreeChord.raw(
        pattern,
        ScaleDegree.tonic,
        bass: ScaleDegree(ScalePatternExtension.majorKey, bass.from(root)),
        isInversion: isInversion,
        bassToRoot: bassToRoot,
      );
    }
    return TonicizedScaleDegreeChord(
      tonic: tonic,
      tonicizedToMajorScale: ScaleDegreeChord.copy(this),
      tonicizedToTonic: ScaleDegreeChord.raw(
        pattern,
        ScaleDegree(ScalePatternExtension.majorKey, root.from(tonic.root)),
        bass:
            ScaleDegree(ScalePatternExtension.majorKey, bass.from(tonic.root)),
      ),
    );
  }

  /// We get a tonic and a chord and decide what chord it is for the new tonic
  ScaleDegreeChord shiftFor(ScaleDegreeChord tonic) {
    if (weakEqual(tonic)) {
      return ScaleDegreeChord.copy(ScaleDegreeChord.majorTonicTriad);
    } else {
      return ScaleDegreeChord.raw(pattern, root.shiftFor(tonic.root));
    }
  }

  /// Will return a new [ScaleDegreeChord] with an added 7th if possible.
  /// [harmonicFunction] can be given for slightly more relevant results.
  @override
  ScaleDegreeChord addSeventh({HarmonicFunction? harmonicFunction}) {
    if (pattern.intervals.length >= 4) return ScaleDegreeChord.copy(this);
    switch (pattern.fullName) {
      case "Minor":
        return ScaleDegreeChord.raw(ChordPattern.parse('Minor 7th'), root);
      case "Major":
        if (root == ScaleDegree.V ||
            (harmonicFunction != null &&
                harmonicFunction == HarmonicFunction.dominant)) {
          return ScaleDegreeChord.raw(ChordPattern.parse('Dominant 7th'), root);
        } else {
          return ScaleDegreeChord.raw(ChordPattern.parse('Major 7th'), root);
        }
      case "Augmented":
        return ScaleDegreeChord.raw(ChordPattern.parse('Augmented 7th'), root);
      case "Diminished":
        // not sure if to add 'Diminished 7th' here somehow...
        return ScaleDegreeChord.raw(ChordPattern.parse('Minor 7th ♭5'), root);
      default:
        return ScaleDegreeChord.copy(this);
    }
  }

  @override
  String get rootString {
    if (pattern.hasMinor3rd) {
      return root.toString().toLowerCase();
    }
    return root.toString();
  }

  List<int>? get inversionNumbers {
    if (!_isInversion) return null;
    Interval bassToRoot = bass.from(root);
    int first = degrees[0].from(bass).number;
    switch (bassToRoot.number) {
      case 3:
        if (patternLength > 3) {
          return [first, degrees.last.from(bass).number];
        } else {
          return [first];
        }
      case 5:
        if (patternLength > 3) {
          return [first, degrees.last.from(bass).number];
        } else {
          int third = degrees[1].from(bass).number;
          return [third, first];
        }
      case 7:
        int third = degrees[1].from(bass).number;
        return [third, first];
      default:
        return [
          for (int i = 0; i < patternLength; i++)
            if (pattern.intervals[i] != bassToRoot) degrees[i].from(bass).number
        ]..sort((a, b) => -1 * a.compareTo(b));
    }
  }

  static const String _upperBass = '⁰¹²³⁴⁵⁶⁷⁸⁹';
  static const String _lowerBass = '₀₁₂₃₄₅₆₇₈₉';

  @override
  String get bassString {
    if (!hasDifferentBass) return '';
    List<int>? nums = inversionNumbers;
    if (nums == null) return _generateInputBass;
    switch (nums.length) {
      case 1:
      case 2:
        String str = '', bass = _upperBass;
        for (int i = 0; i < nums.length; i++) {
          str += bass[nums[i]];
          bass = _lowerBass;
        }
        return str;
      default:
        return '^(${nums.join('-')})';
    }
  }

  @override
  String toString() =>
      rootString + (hasDifferentBass ? bassString : patternString);

  String get inputString =>
      rootString + patternString + (hasDifferentBass ? _generateInputBass : '');

  String get _generateInputBass {
    Interval bassToRoot = bass.from(root);
    int degree = bassToRoot.number, accidentals;
    List<int> nums =
        pattern.intervals.map((e) => e.number).toList(growable: false);
    int index = nums.indexOf(degree);
    Interval d;
    if (index == -1) {
      /* TODO: Make a harmonic analysis to choose which interval to use on the
             7th when the chord doesn't have one - for instance a V should have
             a min7 like other minor chords instead of a maj7 like other maj
             chords etc... */
      d = Interval(number: degree);
    } else {
      d = pattern.intervals[index];
    }
    accidentals = bassToRoot.semitones - d.semitones;
    return '^${(accidentals < 0 ? 'b' : '#') * accidentals.abs()}$degree';
  }

  PitchChord inScale(PitchScale scale) => PitchChord(
      pattern: pattern, root: root.inScale(scale), bass: bass.inScale(scale));

  @override
  bool operator ==(Object other) =>
      other is ScaleDegreeChord &&
      (other.pattern.equals(pattern) &&
          other.root == root &&
          bass == other.bass);

  /// Returns true if the chord is equal to [other], such that their triads + 7
  /// are equal. Tensions aren't taken into consideration.
  /// If there's no 7 in only one of the chords we treat it as if it had the
  /// relevant diatonic 7, base on the Major Scale. Meaning that in a major key
  /// a ii would be weakly equal to a ii7 but not a iimaj7.
  ///
  /// Same chords with different inversions are considered weakly equal.
  /// If the same chords have different bases that aren't inversions, they're not
  /// considered weakly equal.
  bool weakEqual(ScaleDegreeChord other) {
    if (root != other.root ||
        (!_isInversion && !other._isInversion && bass != other.bass)) {
      return false;
    } else if (pattern == other.pattern) {
      return true;
    }
    List<Interval> ownIntervals = pattern.intervals.sublist(1, 3);
    List<Interval> otherIntervals = other.pattern.intervals.sublist(1, 3);
    for (int i = 0; i < 2; i++) {
      if (!ownIntervals[i].equals(otherIntervals[i])) return false;
    }
    if (pattern.intervals.length >= 4) {
      if (other.pattern.intervals.length >= 4) {
        if (!pattern.intervals[3].equals(other.pattern.intervals[3])) {
          return false;
        }
      } else {
        if (!root.add(pattern.intervals[3]).isDiatonic) {
          return false;
        }
      }
    } else {
      if (other.pattern.intervals.length >= 4) {
        if (!other.root.add(other.pattern.intervals[3]).isDiatonic) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        root,
        bass,
        Object.hashAll(pattern.intervals.sublist(1)),
      );

  /// Returns a hash of the chord with no tensions. 7th are hashed in if
  /// they're not diatonic (based on the major scale).
  int get weakHash {
    List<Interval> intervals = pattern.intervals.sublist(1, 3);
    if (pattern.intervals.length >= 4) {
      if (!root.add(pattern.intervals[3]).isDiatonic) {
        intervals.add(pattern.intervals[3]);
      }
    }
    return Object.hash(
      root,
      !_isInversion ? bass : root,
      Object.hashAll(intervals),
    );
  }

  @override
  int get id => Identifiable.hashAllInts([
        root.id,
        bass.id,
        Identifiable.hashAllInts(utf8.encode(pattern.fullName)),
      ]);

  /// Like [weakHash] but is consistent over executions.
  int get weakID {
    List<Interval> intervals = pattern.intervals.sublist(1, 3);
    if (intervals.length >= 4) {
      if (!root.add(pattern.intervals[3]).isDiatonic) {
        intervals.add(pattern.intervals[3]);
      }
    }
    return Identifiable.hashAllInts([
      root.id,
      if (!_isInversion) bass.id,
      Identifiable.hashAllInts(
          [for (Interval interval in intervals) interval.id])
    ]);
  }

  HarmonicFunction deriveHarmonicFunction({ScaleDegreeChord? next}) =>
      defaultFunctions.getMatch(this, next) ?? HarmonicFunction.undefined;

  static final PairMap<HarmonicFunction> defaultFunctions = PairMap({
    'I': {
      HarmonicFunction.tonic: null,
    },
    'I^5': {
      HarmonicFunction.tonic: null,
      HarmonicFunction.dominant: ['V'],
    },
    'ii': {
      HarmonicFunction.subDominant: null,
    },
    'iidim': {
      HarmonicFunction.subDominant: null,
    },
    'bVII': {
      HarmonicFunction.subDominant: null,
    },
    'iii': {
      HarmonicFunction.tonic: null,
    },
    'III': {
      HarmonicFunction.dominant: null,
    },
    'iv': {
      HarmonicFunction.subDominant: null,
    },
    'IV': {
      HarmonicFunction.subDominant: null,
    },
    'V': {
      HarmonicFunction.dominant: null,
    },
    'vi': {
      HarmonicFunction.tonic: null,
      HarmonicFunction.subDominant: ['V', 'viidim'],
    },
    'vi^5': {
      HarmonicFunction.tonic: null,
      HarmonicFunction.dominant: ['III'],
      // TODO: Ask yuval if this ^ is ok...
    },
    'viidim': {
      HarmonicFunction.dominant: null,
      HarmonicFunction.subDominant: ['vi'],
    },
    'viidim7': {
      HarmonicFunction.dominant: null,
      HarmonicFunction.subDominant: ['vi'],
      // TODO: Ask yuval if this ^ is true...
    }
  });

  static final ScaleDegreeChord majorTonicTriad = ScaleDegreeChord.parse('I');
  static final ScaleDegreeChord ii = ScaleDegreeChord.parse('ii');
  static final ScaleDegreeChord iii = ScaleDegreeChord.parse('iii');

// ignore: non_constant_identifier_names
  static final ScaleDegreeChord IV = ScaleDegreeChord.parse('IV');
  static final ScaleDegreeChord V = ScaleDegreeChord.parse('V');
  static final ScaleDegreeChord vi = ScaleDegreeChord.parse('vi');
  static final ScaleDegreeChord viidim = ScaleDegreeChord.parse('viidim');
}

enum HarmonicFunction {
  tonic,
  subDominant,
  dominant,
  undefined,
}
