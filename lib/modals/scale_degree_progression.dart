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


  List<List<int>> getFittingMatchLocations(ScaleDegreeProgression base) {
    // Explanation to why this is done is below...
    // if we (as a saved progression) can't fit in the base progression...
    if (length > base.length) return const [];

    // List containing lists of match locations (first element is location in
    // base and second is location here).
    final List<List<int>> matchLocations = [];

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
    for (var chordPos = 0; chordPos < length; chordPos++) {
      for (var baseChordPos = 0; baseChordPos < base.length; baseChordPos++) {
        // If the two chords are equal.
        if (this[chordPos] == base[baseChordPos]) {
          // If there's enough space for this progression to substitute in
          // place for the current chord.
          if (baseChordPos >= chordPos ||
              base.length - baseChordPos >= length - chordPos) {
            // Add the location to the list of match locations and continue
            // searching.
            // The first element is the location in base and the second is the
            // location here...
            matchLocations.add([baseChordPos, chordPos]);
          }
        }
      }
    }
    return matchLocations;
  }

  /// Get a comparing score of this [ScaleDegreeProgression] against a base
  /// one ([base]), which we're meant to substitute.
  /* TODO: There isn't really a perception of rhythm in this function, beyond
            one list cell = one bar. You should implement an actual rhythm
            system... (of course the ScaleDegreeProgression has to support
            a way to represent a chord's duration...).
   */
  double percentMatchedWith(ScaleDegreeProgression base) {
    // Explanation to why this is done is below...
    // if we (as a saved progression) can't fit in the base progression...
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

  /// Returns a substituted [base] from the current progression if possible.
  /// If not, returns [base].
  /* TODO: Don't just copy the code, also it's inefficient to calculate these
      things twice.
  */
  List<ScaleDegreeProgression> getPossibleSubstitutions(
      ScaleDegreeProgression base) {
    final List<List<int>> matchLocations = getFittingMatchLocations(base);
    final List<ScaleDegreeProgression> substitutions = [];

    for (List<int> location in matchLocations) {
      int baseChord = location[0];
      int chord = location[1];
      ScaleDegreeProgression substitution =
          ScaleDegreeProgression(base.sublist(0, baseChord - chord));
      for (var i = 0; i < length; i++) {
        final ScaleDegreeChord chordToSubstitute = this[i];
        final ScaleDegreeChord existingChord = base[baseChord - chord + i];
        if (chordToSubstitute != existingChord) {
          substitution.add(chordToSubstitute);
        } else {
          substitution.add(existingChord);
        }
      }
      substitution.addAll(base.sublist(baseChord - chord + length));
      substitutions.add(substitution);
    }
    // TODO: This makes sure the results will be unique, make it more efficient.
    return substitutions.toSet().toList();
  }

  @override
  bool operator ==(Object other) {
    if (other is! ScaleDegreeProgression || length != other.length) {
      return false;
    }
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(this);
}
