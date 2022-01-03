import 'package:thoery_test/modals/scale_degree_chord.dart';

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

  static SubstitutionMatchType? getMatchType(
      {required ScaleDegreeChord base,
      required ScaleDegreeChord sub,
      required bool isSubLast}) {
    if (sub.weakEqual(base)) {
      return SubstitutionMatchType.dry;
    } else if (isSubLast &&
        sub.weakEqual(ScaleDegreeChord.majorTonicTriad) &&
        base.canBeTonic) {
      return SubstitutionMatchType.tonicization;
    }
  }
}

enum SubstitutionMatchType {
  dry,
  tonicization,
}
