import 'progression/degree_progression.dart';
import 'theory_base/degree/degree_chord.dart';

class SubstitutionMatch {
  final int baseIndex;
  final double baseOffset;
  final int subIndex;
  final double ratio;
  final SubstitutionMatchType type;
  final bool withSeventh;

  const SubstitutionMatch({
    required this.baseIndex,
    required this.baseOffset,
    required this.subIndex,
    required this.ratio,
    required this.type,
    this.withSeventh = false,
  });

  @override
  String toString() {
    return "base: $baseIndex(start $baseOffset), sub: $subIndex, "
        "type: ${type.name}, withSeventh: $withSeventh, ratio: $ratio.";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubstitutionMatch &&
          runtimeType == other.runtimeType &&
          baseIndex == other.baseIndex &&
          baseOffset == other.baseOffset &&
          subIndex == other.subIndex &&
          ratio == other.ratio &&
          type == other.type &&
          withSeventh == other.withSeventh;

  @override
  int get hashCode =>
      baseIndex.hashCode ^
      baseOffset.hashCode ^
      subIndex.hashCode ^
      ratio.hashCode ^
      type.hashCode ^
      withSeventh.hashCode;

  static SubstitutionMatchType? getMatchType(
      {required DegreeChord? base,
      required DegreeChord? sub,
      required bool isSubLast}) {
    if ((sub == null || base == null) || sub.weakEqual(base)) {
      return SubstitutionMatchType.dry;
    } else if (isSubLast &&
        sub.weakEqual(DegreeChord.majorTonicTriad) &&
        base.canBeTonic) {
      return SubstitutionMatchType.tonicization;
    }
    return null;
  }

  static DegreeProgression getSubstitution({
    required DegreeProgression progression,
    required SubstitutionMatchType type,
    required bool addSeventh,
    required double ratio,
    DegreeChord? tonic,
  }) {
    switch (type) {
      case SubstitutionMatchType.dry:
        if (addSeventh) {
          return progression.addSeventh(ratio: ratio);
        } else {
          return DegreeProgression.fromProgression(
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
