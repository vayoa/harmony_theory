import 'package:collection/collection.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:tonic/tonic.dart';

class ScaleDegreeProgression extends DelegatingList<ScaleDegreeChord> {
  ScaleDegreeProgression(List<ScaleDegreeChord> base) : super(base);

  /// Gets a list of [String] each representing a ScaleDegreeChord and returns
  /// a new [ScaleDegreeProgression].
  ScaleDegreeProgression.fromList(List<String> base)
      : super(
          base.map((String chord) => ScaleDegreeChord.parse(chord)).toList(),
        );

  ScaleDegreeProgression.fromChords(Scale scale, List<Chord> chords)
      : super(
          chords.map((Chord chord) => ScaleDegreeChord(scale, chord)).toList(),
        );

  /// Get a comparing score of this [ScaleDegreeProgression] against a base
  /// one ([base]), which we're meant to substitute.
  /* TODO: There isn't really a perception of rhythm in this function, beyond
            one list cell = one bar. You should implement an actual rhythm
            system... (of course the ScaleDegreeProgression has to support
            a way to represent a chord's duration...).
   */
  double percentMatchedWith(ScaleDegreeProgression base) {
    // Explanation to why this is done is below...
    // if we (as a saved progression) can't
    if (length > base.length) return 0.0;
    int baseChord = 0;
    int chord = 0;
    bool found = false;
    for (; !found && baseChord < base.length;) {
      for (chord = 0; !found && chord < length;) {
        found = base[baseChord] == this[chord];
        if (!found) chord++;
      }
      if (!found) baseChord++;
    }
    if (!found) return 0.0;
    // TODO: Check if it's the way this needs to be
    // Each progression is treated differently. By that I mean that if a user
    // has a [1, 2, 3, 4] saved, as well as a [1, 2] and a [3, 4] for example,
    // they will all be treated as different progressions. This is why we're
    // doing things this way.
    // If we don't have enough chord spaces to finish the progression,
    // i.e. if we are [1, 2, 3, 4] comparing against  [5, 2, 3], we'll match
    // on 2 but we won't have enough to complete, so we stop.
    // This is also true if we are a [1, 2, 3] comparing against a [2, 3, 4].
    // This is also true if we are a [1, 2, 3] comparing against a [4, 5, 6, 1].
    // We'll match on 2 but won't have enough spaces backwards to continue
    // moving.
    if (baseChord < chord || base.length - baseChord < length - chord) {
      return 0.0;
    }

    // If we reached this, we can start matching by placements.
    // We add a point every time a chord exists in both progressions at the
    // same relative position.
    // For instance, if we're a [1, 2, 0, 3] comparing against a
    // [4, 2, 5, 3, 6], we'll  finish with 2 points [2, 3].
    // Keep in mind that if we were [1, 2, 3] instead, we would only get 1
    // points. The order is important.
    int points = 1;
    for (var i = 1; i + chord < length; i++) {
      if (this[chord + i] == base[baseChord + i]) points++;
    }

    // We finish with a score relative to the length of ourselves. A
    // progressions who completely exists within the base progression
    // (remember, order matters!) will get a score of 1.0.
    return points / length;
  }

  /* TODO: Don't just copy the code, also it's inefficient to calculate these
      things twice.
  */

  /// Returns a substituted [base] from the current progression if possible.
  /// If not, returns [base].
  ScaleDegreeProgression substitute(ScaleDegreeProgression base) {
    // Explanation to why this is done is below...
    // if we (as a saved progression) can't
    if (length > base.length) return base;
    int baseChord = 0;
    int chord = 0;
    bool found = false;
    for (; !found && baseChord < base.length;) {
      for (chord = 0; !found && chord < length;) {
        found = base[baseChord] == this[chord];
        if (!found) chord++;
      }
      if (!found) baseChord++;
    }
    if (!found) return base;
    // TODO: Check if it's the way this needs to be
    // Each progression is treated differently. By that I mean that if a user
    // has a [1, 2, 3, 4] saved, as well as a [1, 2] and a [3, 4] for example,
    // they will all be treated as different progressions. This is why we're
    // doing things this way.
    // If we don't have enough chord spaces to finish the progression,
    // i.e. if we are [1, 2, 3, 4] comparing against  [5, 2, 3], we'll match
    // on 2 but we won't have enough to complete, so we stop.
    // This is also true if we are a [1, 2, 3] comparing against a [2, 3, 4].
    // This is also true if we are a [1, 2, 3] comparing against a [4, 5, 6, 1].
    // We'll match on 2 but won't have enough spaces backwards to continue
    // moving.
    if (baseChord < chord || base.length - baseChord < length - chord) {
      return base;
    }

    ScaleDegreeProgression substitution =
        ScaleDegreeProgression(base.sublist(0, baseChord - chord));
    for (var i = 0; i + chord < length; i++) {
      if (this[chord + i] != base[baseChord + i]) {
        substitution.add(this[chord + i]);
      } else {
        substitution.add(base[baseChord + i]);
      }
    }
    // substitution.addAll(base.sublist(baseChord + length - 1));
    return substitution;
  }
}
