import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/extensions/interval_extension.dart';
import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:thoery_test/modals/scale_degree.dart';
import 'package:thoery_test/modals/tonicized_scale_degree_chord.dart';
import 'package:tonic/tonic.dart';

class ScaleDegreeChord {
  late final ChordPattern _pattern;

  /// The root degree from which the chord is constructed.
  /// Examples:
  /// The [rootDegree] of ii in C (Dm) is the ii scale degree (D).
  /// The [rootDegree] of ♭ii in C (Dbm) is the ♭ii scale degree (Db).
  late final ScaleDegree _rootDegree;

  /*
  TODO: Implement inversions. i.e. V4/2. Maybe take a look at this:
        https://music.stackexchange.com/questions/73537/using-roman-numeral-notation-with-notes-in-the-bass-not-figured-bass
  */

  static final RegExp chordNamePattern = RegExp(
      r"^([#b♯♭𝄪𝄫]*(?:III|II|IV|I|VII|VI|V))(.*)$",
      caseSensitive: false);

  static const List<String> _majorChordPatternNames = [
    'Major',
    'Minor',
    'Minor',
    'Major',
    'Major',
    'Minor',
    'Diminished',
  ];

  static const List<String> _major7sChordPatternNames = [
    'Major 7th',
    'Minor 7th',
    'Minor 7th',
    'Major 7th',
    'Dominant 7th',
    'Minor 7th',
    'Diminished 7♭5',
  ];

  static const List<String> _canBeTonicizedPatterns = [
    'Major',
    'Minor',
    'Major 7th',
    'Minor 7th',
    'Dominant 7th',
  ];

  ScaleDegreeChord(PitchScale scale, Chord chord) {
    _pattern = chord.pattern;
    Pitch cRoot = chord.root, tRoot = scale.majorTonic;
    int semitones = (cRoot.semitones - tRoot.semitones) % 12;
    int number = 1 + cRoot.letterIndex - tRoot.letterIndex;
    if (number <= 0) number += 7;
    _rootDegree = ScaleDegree.rawInterval(
        scalePattern: scale.pattern,
        intervalNumber: number,
        intervalSemitones: semitones);
  }

  ScaleDegreeChord.raw(ChordPattern pattern, ScaleDegree rootDegree)
      : _pattern = pattern,
        _rootDegree = rootDegree;

  ScaleDegreeChord.copy(ScaleDegreeChord chord)
      : _pattern = ChordPattern(
            name: chord._pattern.name,
            fullName: chord._pattern.fullName,
            abbrs: chord._pattern.abbrs,
            intervals: chord._pattern.intervals),
        _rootDegree = ScaleDegree.copy(chord._rootDegree);

  ScaleDegreeChord.parse(String chord) {
    final match = chordNamePattern.matchAsPrefix(chord);
    if (match == null) {
      throw FormatException("invalid ScaleDegreeChord name: $chord");
    }
    // If the degree is lowercased (meaning the chord contains a minor triad.
    ChordPattern _cPattern = ChordPattern.parse(match[2]!.replaceAll('b', '♭'));
    if (match[1]!.toLowerCase() == match[1]) {
      // We don't want to change any of the generated chord patterns (for some
      // reason they aren't const so I can change them and screw up that entire
      // ChordPattern.
      // The ... operator de-folds the list.
      final List<Interval> _intervals = [..._cPattern.intervals];
      // TODO: Make sure this is stable.
      // Make the 2nd interval (the one between the root and the 3rd) minor.
      _intervals[1] = Interval.m3;
      _cPattern = ChordPattern.fromIntervals(_intervals);
    }
    _pattern = _cPattern;
    _rootDegree = ScaleDegree.parse(match[1]!);
  }

  ChordPattern get pattern => _pattern;

  ScaleDegree get rootDegree => _rootDegree;

  /// Returns a list of [ScaleDegree] that represents the degrees that make up
  /// the [ScaleDegreeChord] in the major scale.
  List<ScaleDegree> get degrees =>
      _pattern.intervals.map((i) => _rootDegree.add(i)).toList();

  int get degreesLength => _pattern.intervals.length;

  // FIXME: Optimize this!
  /// Returns true if the chord is diatonic in the major scale.
  bool get isDiatonic => degrees.every((degree) => degree.isDiatonic);

  // TODO: Optimize this...
  bool get canBeTonic {
    if (_canBeTonicizedPatterns.contains(_pattern.name)) return true;
    final List<Interval> _intervals = _pattern.intervals;
    if ((_intervals[2] - _intervals[0]).equals(Interval.P5)) {
      final Interval third = _intervals[1] - _intervals[0];
      if (third.equals(Interval.M3) || third.equals(Interval.m3)) {
        if (_intervals.length < 4) return true;
        final Interval seventh = (_intervals[3] - _intervals[0]);
        if (seventh.equals(Interval.m7)) {
          return true;
        }
        return third.equals(Interval.M3) || seventh.equals(Interval.M7);
      }
    }
    return false;
  }

  // TODO: The other checks here might be redundant...
  bool get containsSeventh {
    if (degreesLength >= 4) {
      if (_pattern.intervals[3].number == 7) {
        return true;
      } else {
        for (int i = degreesLength - 1; i >= 0; i--) {
          if (_pattern.intervals[i].number == 7) return true;
        }
      }
    }
    return false;
  }

  // TODO: This only works for major based modes...
  /// Returns a new [ScaleDegreeChord] representing the current
  /// [ScaleDegreeChord] in a different mode (from [fromMode] to [toMode]),
  /// i.e it's mode equivalent.
  /// Ionian's (Major) mode number is 0 and so on...
  /// Example: ii.modeShift(0, 5) [major to minor] => iv.
  ScaleDegreeChord modeShift(int fromMode, int toMode) =>
      ScaleDegreeChord.raw(_pattern, rootDegree.modeShift(fromMode, toMode));

  /// Returns a new [ScaleDegreeChord] converted such that [tonic] is the new
  /// tonic. Everything is still represented in the major scale, besides to degree the function is called on...
  ///
  /// Example: V.tonicizedFor(VI) => III, I.tonicizedFor(VI) => VI,
  /// ii.tonicizedFor(VI) => vii.
  ScaleDegreeChord tonicizedFor(ScaleDegreeChord tonic) {
    if (tonic.rootDegree == ScaleDegree.tonic) {
      return ScaleDegreeChord.copy(this);
    } else if (weakEqual(majorTonicTriad)) {
      return ScaleDegreeChord.raw(
          tonic.pattern, rootDegree.tonicizedFor(tonic.rootDegree));
    }
    return TonicizedScaleDegreeChord(
      tonic: tonic,
      tonicizedToTonic: ScaleDegreeChord.copy(this),
      tonicizedToMajorScale: ScaleDegreeChord.raw(
          _pattern, rootDegree.tonicizedFor(tonic.rootDegree)),
    );
  }

  /// We get a tonic and a chord and decide what chord it is for the new tonic
  ScaleDegreeChord shiftFor(ScaleDegreeChord tonic) {
    if (weakEqual(tonic)) {
      return ScaleDegreeChord.copy(ScaleDegreeChord.majorTonicTriad);
    } else {
      return ScaleDegreeChord.raw(
          _pattern, rootDegree.shiftFor(tonic.rootDegree));
    }
  }

  // TDC: Not sure about this...
  /// Will return a new [ScaleDegreeChord] with an added 7th if possible.
  /// [harmonicFunction] can be given for slightly more relevant results.
  ScaleDegreeChord addSeventh({HarmonicFunction? harmonicFunction}) {
    switch (_pattern.name) {
      case "Minor":
        return ScaleDegreeChord.raw(
            ChordPattern.parse('Minor 7th'), _rootDegree);
      case "Major":
        if (_rootDegree == ScaleDegree.V ||
            (harmonicFunction != null &&
                harmonicFunction == HarmonicFunction.dominant)) {
          return ScaleDegreeChord.raw(
              ChordPattern.parse('Dominant 7th'), _rootDegree);
        } else {
          return ScaleDegreeChord.raw(
              ChordPattern.parse('Major 7th'), _rootDegree);
        }
      case "Augmented":
        return ScaleDegreeChord.raw(
            ChordPattern.parse('Augmented 7th'), _rootDegree);
      case "Diminished":
        // not sure if to add 'Diminished 7th' here somehow...
        return ScaleDegreeChord.raw(
            ChordPattern.parse('Minor 7th ♭5'), _rootDegree);
      default:
        return ScaleDegreeChord.copy(this);
    }
  }

  String get rootDegreeString {
    if (_pattern.intervals[1] == Interval.m3) {
      return _rootDegree.toString().toLowerCase();
    }
    return _rootDegree.toString();
  }

  String get patternString {
    String _patternStr = _pattern.abbr;
    if (_pattern.intervals[1] == Interval.m3) {
      switch (_pattern.name) {
        case 'Minor':
          _patternStr = '';
          break;
        case 'Min 7th':
          _patternStr = '7';
      }
    }
    return _patternStr;
  }

  Chord inScale(PitchScale scale) =>
      Chord(pattern: _pattern, root: _rootDegree.inScale(scale));

  @override
  String toString() {
    return rootDegreeString + patternString;
  }

  @override
  bool operator ==(Object other) =>
      other is ScaleDegreeChord &&
      (other._pattern.equals(_pattern) && other._rootDegree == _rootDegree);

  @override
  int get hashCode => Object.hash(_pattern.fullName, _rootDegree);

  // TDC: Check if this works correctly!!
  /// Returns true if the chord is equal to [other], such that their triads + 7
  /// are equal. Tensions aren't taken into consideration.
  /// If there's no 7 in only one of the chords we treat it as if it had the
  /// relevant diatonic 7, base on the Major Scale. Meaning that in a major key
  /// a ii would be weakly equal to a ii7 but not a iimaj7.
  bool weakEqual(ScaleDegreeChord other) {
    if (_rootDegree != other._rootDegree) {
      return false;
    } else if (_pattern == other._pattern) {
      return true;
    }
    List<Interval> ownIntervals = _pattern.intervals.sublist(1, 3);
    List<Interval> otherIntervals = other._pattern.intervals.sublist(1, 3);
    for (int i = 0; i < 2; i++) {
      if (!ownIntervals[i].equals(otherIntervals[i])) return false;
    }
    if (_pattern.intervals.length >= 4) {
      if (other._pattern.intervals.length >= 4) {
        if (!_pattern.intervals[3].equals(other._pattern.intervals[3])) {
          return false;
        }
      } else {
        if (!_rootDegree.add(_pattern.intervals[3]).isDiatonic) {
          return false;
        }
      }
    } else {
      if (other._pattern.intervals.length >= 4) {
        if (!other._rootDegree.add(other._pattern.intervals[3]).isDiatonic) {
          return false;
        }
      }
    }
    return true;
  }

  // TDC: Only works for the major scale, is this correct?
  // TDC: Check if this works correctly!!
  /* TDC: Needs to be better realized, doesn't really match with the regular
          hash. */

  /// Returns a hash of the chord with no tensions. 7th are hashed in if
  /// they're not diatonic (based on the major scale).
  int get weakHash {
    List<Interval> intervals = _pattern.intervals.sublist(1, 3);
    if (intervals.length >= 4) {
      if (!_rootDegree.add(_pattern.intervals[3]).isDiatonic) {
        intervals.add(_pattern.intervals[3]);
      }
    }
    return Object.hash(
        _rootDegree,
        Object.hashAll(
            [for (Interval interval in intervals) interval.getHash]));
  }

  HarmonicFunction deriveHarmonicFunction({ScaleDegreeChord? next}) {
    int weakHash = this.weakHash;
    if (defaultFunctions.containsKey(weakHash)) {
      Map<List<int>?, HarmonicFunction> forChord = defaultFunctions[weakHash]!;
      if (next != null) {
        int nextHash = next.weakHash;
        for (MapEntry<List<int>?, HarmonicFunction> entry in forChord.entries) {
          if (entry.key != null && entry.key!.contains(weakHash)) {
            return entry.value;
          }
        }
      }
      return forChord[null]!;
    }
    // TDC: Actually implement this function...
    return HarmonicFunction.undefined;
  }

  // TDC: Maybe skip defining where it goes entirely and just do things with percentages...
  static final Map<int, Map<List<int>?, HarmonicFunction>> defaultFunctions =
      <ScaleDegreeChord, Map<List<String>?, HarmonicFunction>>{
    ScaleDegreeChord.majorTonicTriad: {
      null: HarmonicFunction.tonic,
    },
    ScaleDegreeChord.ii: {
      null: HarmonicFunction.subDominant,
    },
    ScaleDegreeChord.parse('iidim'): {
      null: HarmonicFunction.subDominant,
    },
    ScaleDegreeChord.parse('bVII'): {
      null: HarmonicFunction.subDominant,
    },
    ScaleDegreeChord.iii: {
      null: HarmonicFunction.tonic,
    },
    /*TODO: Are you sure about this? this means that a V - I could be replaced
            by a III - I and vice versa - although other weights would take
            care of that.
     */
    ScaleDegreeChord.parse('III'): {
      null: HarmonicFunction.dominant,
    },
    ScaleDegreeChord.parse('iv'): {
      null: HarmonicFunction.subDominant,
    },
    ScaleDegreeChord.IV: {
      null: HarmonicFunction.subDominant,
    },
    ScaleDegreeChord.V: {
      null: HarmonicFunction.dominant,
    },
    // TODO: Could also be sub. do the same with viidim.
    ScaleDegreeChord.vi: {
      null: HarmonicFunction.tonic,
      ['V', 'V7', 'viidim']: HarmonicFunction.subDominant,
    },
    // TODO: Instead, check where it's going, if to C it's dom and to Am it's sub etc...
    ScaleDegreeChord.viidim: {
      null: HarmonicFunction.dominant,
      ['I']: HarmonicFunction.dominant,
      ['vi']: HarmonicFunction.subDominant,
    }
  }.map((ScaleDegreeChord key, Map<List<String>?, HarmonicFunction> value) =>
          MapEntry<int, Map<List<int>?, HarmonicFunction>>(key.weakHash, {
            for (MapEntry<List<String>?, HarmonicFunction> entry
                in value.entries)
              (entry.key == null
                  ? null
                  : [
                      for (String chord in entry.key!)
                        ScaleDegreeChord.parse(chord).weakHash
                    ]): entry.value
          }));

  static final ScaleDegreeChord majorTonicTriad = ScaleDegreeChord.parse('I');
  static final ScaleDegreeChord ii = ScaleDegreeChord.parse('ii');
  static final ScaleDegreeChord iii = ScaleDegreeChord.parse('iii');
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
