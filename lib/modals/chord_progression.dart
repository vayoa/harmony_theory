import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/time_signature.dart';
import 'package:tonic/tonic.dart';

class ChordProgression extends Progression<Chord> {
  ChordProgression(List<Chord?> base, List<double> durations,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : super(base, durations, timeSignature: timeSignature);

  /// Returns a new [ChordProgression] where all the chords are of 1/4 duration.
  ChordProgression.evenTime(List<Chord?> base,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : super.evenTime(base, timeSignature: timeSignature);

  ChordProgression.empty(
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : super.empty(timeSignature: timeSignature);

  List<Scale> matchWithScales() {
    List<String> chordNames = values
        .map((Chord? chord) => chord == null ? 'null' : chord.getCommonName())
        .toList();
    Map<String, int> counts = {};
    Map<String, int> results = {};

    // for each key, count how many chords of the key match the chords the
    // user chose
    Set<String> chordsSet = chordNames.toSet();
    for (MapEntry entries in ScaleMatchUtilities.keys.entries) {
      final String key = entries.key;
      final List<String> keyChords = entries.value;
      Set<String> keyChordsSet = keyChords.toSet();
      counts[key] = keyChordsSet.intersection(chordsSet).length;
    }

    // results is now a Hash of Key => count pairs, e.g. {'A Major': 0,
    // 'Bb Major': 5, ...}
    // get the highest count
    if (counts.isNotEmpty) {
      var max = counts.entries.reduce((e1, e2) {
        if (e1.value > e2.value) return e1;
        return e2;
      });
      counts.remove(max.key);
      // Count the times the chords have the root chord of the scale found.
      Set<String> maxSet = {ScaleMatchUtilities.getRootChord(max.key)};
      results[max.key] = chordsSet.intersection(maxSet).length;

      // Add the name of the key if its count is = to the max
      for (MapEntry<String, int> entry in counts.entries) {
        if (entry.value == max.value) {
          // Count the times the chords have the root chord of the scale found.
          maxSet = {ScaleMatchUtilities.getRootChord(entry.key)};
          results[entry.key] = chordsSet.intersection(maxSet).length;
        }
      }
    }

    List<String> stringScales = results.keys.toList();
    stringScales.sort((a, b) => results[a]!.compareTo(results[b]!) * -1);

    /*FIXME: We should cast as soon as we add. This is a prototype anyways so
           it doesn't matter. */
    List<Scale> scales = [];
    for (String scale in stringScales) {
      final List<String> parts = scale.split(' ');
      parts[1] = parts[1] == 'Major' ? 'Diatonic Major' : 'Natural Minor';
      scales.add(Scale(
        pattern: ScalePattern.findByName(parts[1]),
        tonic: PitchClass.parse(parts[0]),
      ));
    }
    return scales;
  }

  @override
  String notNullValueFormat(Chord value) => value.getCommonName();
}

abstract class ScaleMatchUtilities {
  static String getRootChord(String scale) {
    List<String> sep = scale.split(' ');
    final String type = sep[1] == "Major" ? '' : 'm';
    return sep[0] + type;
  }

  static const Map<String, List<String>> keys = {
    'C Major': [
      'C',
      'Cmaj7',
      'Dm',
      'Dm7',
      'Em',
      'Em7',
      'F',
      'Fmaj7',
      'G',
      'G7',
      'Am',
      'Am7',
      'Bdim'
    ],
    'C# Major': [
      'C#',
      'C#maj7',
      'D#m',
      'D#m7',
      'E#m',
      'E#m7',
      'F#',
      'F#maj7',
      'G#',
      'G#7',
      'A#m',
      'A#m7',
      'B#dim'
    ],
    'Db Major': [
      'Db',
      'Dbmaj7',
      'Ebm',
      'Ebm7',
      'Fm',
      'Fm7',
      'Gb',
      'Gbmaj7',
      'Ab',
      'Ab7',
      'Bbm',
      'Bbm7',
      'Cdim'
    ],
    'D Major': [
      'D',
      'Dmaj7',
      'Em',
      'Em7',
      'F#m',
      'F#m7',
      'G',
      'Gmaj7',
      'A',
      'A7',
      'Bm',
      'Bm7',
      'C#dim'
    ],
    'D# Major': [
      'D#',
      'D#maj7',
      'E#m',
      'E#m7',
      'F##m',
      'F##m7',
      'G#',
      'G#maj7',
      'A#',
      'A#7',
      'B#m',
      'B#m7',
      'C##dim'
    ],
    'Eb Major': [
      'Eb',
      'Ebmaj7',
      'Fm',
      'Fm7',
      'Gm',
      'Gm7',
      'Ab',
      'Abmaj7',
      'Bb',
      'Bb7',
      'Cm',
      'Cm7',
      'Ddim'
    ],
    'E Major': [
      'E',
      'Emaj7',
      'F#m',
      'F#m7',
      'G#m',
      'G#m7',
      'A',
      'Amaj7',
      'B',
      'B7',
      'C#m',
      'C#m7',
      'D#dim'
    ],
    'F Major': [
      'F',
      'Fmaj7',
      'Gm',
      'Gm7',
      'Am',
      'Am7',
      'Bb',
      'Bbmaj7',
      'C',
      'C7',
      'Dm',
      'Dm7',
      'Edim'
    ],
    'F# Major': [
      'F#',
      'F#maj7',
      'G#m',
      'G#m7',
      'A#m',
      'A#m7',
      'B',
      'Bmaj7',
      'C#',
      'C#7',
      'D#m',
      'D#m7',
      'E#dim'
    ],
    'Gb Major': [
      'Gb',
      'Gbmaj7',
      'Abm',
      'Abm7',
      'Bbm',
      'Bbm7',
      'Cb',
      'Cbmaj7',
      'Db',
      'Db7',
      'Ebm',
      'Ebm7',
      'Fdim'
    ],
    'G Major': [
      'G',
      'Gmaj7',
      'Am',
      'Am7',
      'Bm',
      'Bm7',
      'C',
      'Cmaj7',
      'D',
      'D7',
      'Em',
      'Em7',
      'F#dim'
    ],
    'G# Major': [
      'G#',
      'G#maj7',
      'A#m',
      'A#m7',
      'B#m',
      'B#m7',
      'C#',
      'C#maj7',
      'D#',
      'D#7',
      'E#m',
      'E#m7',
      'F##dim'
    ],
    'Ab Major': [
      'Ab',
      'Abmaj7',
      'Bbm',
      'Bbm7',
      'Cm',
      'Cm7',
      'Db',
      'Dbmaj7',
      'Eb',
      'Eb7',
      'Fm',
      'Fm7',
      'Gdim'
    ],
    'A Major': [
      'A',
      'Amaj7',
      'Bm',
      'Bm7',
      'C#m',
      'C#m7',
      'D',
      'Dmaj7',
      'E',
      'E7',
      'F#m',
      'F#m7',
      'G#dim'
    ],
    'A# Major': [
      'A#',
      'A#maj7',
      'B#m',
      'B#m7',
      'C##m',
      'C##m7',
      'D#',
      'D#maj7',
      'E#',
      'E#7',
      'F##m',
      'F##m7',
      'G##dim'
    ],
    'Bb Major': [
      'Bb',
      'Bbmaj7',
      'Cm',
      'Cm7',
      'Dm',
      'Dm7',
      'Eb',
      'Ebmaj7',
      'F',
      'F7',
      'Gm',
      'Gm7',
      'Adim'
    ],
    'B Major': [
      'B',
      'Bmaj7',
      'C#m',
      'C#m7',
      'D#m',
      'D#m7',
      'E',
      'Emaj7',
      'F#',
      'F#7',
      'G#m',
      'G#m7',
      'A#dim'
    ],
    'C Minor': [
      'Eb',
      'Ebmaj7',
      'Fm',
      'Fm7',
      'Gm',
      'Gm7',
      'G',
      'G7',
      'Ab',
      'Abmaj7',
      'Bb',
      'Bb7',
      'Cm',
      'Cm7',
      'Ddim'
    ],
    'G Minor': [
      'Bb',
      'Bbmaj7',
      'Cm',
      'Cm7',
      'Dm',
      'Dm7',
      'D',
      'D7',
      'Eb',
      'Ebmaj7',
      'F',
      'F7',
      'Gm',
      'Gm7',
      'Adim'
    ],
    'D Minor': [
      'F',
      'Fmaj7',
      'Gm',
      'Gm7',
      'Am',
      'Am7',
      'A',
      'A7',
      'Bb',
      'Bbmaj7',
      'C',
      'C7',
      'Dm',
      'Dm7',
      'Edim'
    ],
    'A Minor': [
      'C',
      'Cmaj7',
      'Dm',
      'Dm7',
      'Em',
      'Em7',
      'E',
      'E7',
      'F',
      'Fmaj7',
      'G',
      'G7',
      'Am',
      'Am7',
      'Bdim'
    ],
    'E Minor': [
      'G',
      'Gmaj7',
      'Am',
      'Am7',
      'Bm',
      'Bm7',
      'B',
      'B7',
      'C',
      'Cmaj7',
      'D',
      'D7',
      'Em',
      'Em7',
      'F#dim'
    ],
    'B Minor': [
      'D',
      'Dmaj7',
      'Em',
      'Em7',
      'F#m',
      'F#m7',
      'F#',
      'F#7',
      'G',
      'Gmaj7',
      'A',
      'A7',
      'Bm',
      'Bm7',
      'C#dim'
    ],
    'F# Minor': [
      'A',
      'Amaj7',
      'Bm',
      'Bm7',
      'C#m',
      'C#m7',
      'C#',
      'C#7',
      'D',
      'Dmaj7',
      'E',
      'E7',
      'F#m',
      'F#m7',
      'G#dim'
    ],
    'C# Minor': [
      'E',
      'Emaj7',
      'F#m',
      'F#m7',
      'G#m',
      'G#m7',
      'G#',
      'G#7',
      'A',
      'Amaj7',
      'B',
      'B7',
      'C#m',
      'C#m7',
      'D#dim'
    ],
    'Db Minor': [
      'E',
      'Emaj7',
      'F#m',
      'F#m7',
      'G#m',
      'G#m7',
      'G#',
      'G#7',
      'A',
      'Amaj7',
      'B',
      'B7',
      'C#m',
      'C#m7',
      'D#dim'
    ],
    'Ab Minor': [
      'B',
      'Bmaj7',
      'C#m',
      'C#m7',
      'D#m',
      'D#m7',
      'D#',
      'D#7',
      'E',
      'Emaj7',
      'F#',
      'F#7',
      'G#m',
      'G#m7',
      'A#dim'
    ],
    'Eb Minor': [
      'Gb',
      'Gbmaj7',
      'Abm',
      'Abm7',
      'Bbm',
      'Bbm7',
      'Bb',
      'Bb7',
      'Cb',
      'Cbmaj7',
      'Db',
      'Db7',
      'Ebm',
      'Ebm7',
      'Fdim'
    ],
    'Bb Minor': [
      'Db',
      'Dbmaj7',
      'Ebm',
      'Ebm7',
      'Fm',
      'Fm7',
      'F',
      'F7',
      'Gb',
      'Gbmaj7',
      'Ab',
      'Ab7',
      'Bbm',
      'Bbm7',
      'Cdim'
    ],
    'F Minor': [
      'Ab',
      'Abmaj7',
      'Bbm',
      'Bbm7',
      'Cm',
      'Cm7',
      'C',
      'C7',
      'Db',
      'Dbmaj7',
      'Eb',
      'Eb7',
      'Fm',
      'Fm7',
      'Gdim'
    ]
  };
}
