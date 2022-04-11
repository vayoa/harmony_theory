import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';

class SubstitutionMatch {
  final int baseIndex;
  final int subIndex;
  final SubstitutionMatchType type;
  final bool withSeventh;

  const SubstitutionMatch({
    required this.baseIndex,
    required this.subIndex,
    required this.type,
    this.withSeventh = false,
  });

  @override
  String toString() {
    return "base: $baseIndex, sub: $subIndex, type: ${type.name}, "
        "withSeventh: $withSeventh.";
  }

  static SubstitutionMatchType? getMatchType(
      {required ScaleDegreeChord? base,
      required ScaleDegreeChord? sub,
      required bool isSubLast}) {
    if ((sub == null || base == null) || sub.weakEqual(base)) {
      return SubstitutionMatchType.dry;
    } else if (isSubLast &&
        sub.weakEqual(ScaleDegreeChord.majorTonicTriad) &&
        base.canBeTonic) {
      return SubstitutionMatchType.tonicization;
    }
    return null;
  }

  static ScaleDegreeProgression getSubstitution({
    required ScaleDegreeProgression progression,
    required SubstitutionMatchType type,
    required bool addSeventh,
    required double ratio,
    ScaleDegreeChord? tonic,
  }) {
    switch (type) {
      case SubstitutionMatchType.dry:
        if (addSeventh) {
          return progression.addSeventh(ratio: ratio);
        } else {
          return ScaleDegreeProgression.fromProgression(
            progression.relativeRhythmTo(ratio));
        }
      case SubstitutionMatchType.tonicization:
        return progression.tonicizedFor(
          tonic!,
          addSeventh: addSeventh,
          ratio: ratio,
        );
    }
  }
}

enum SubstitutionMatchType {
  dry,
  tonicization,
}
