import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution_match.dart';
import 'package:thoery_test/modals/weights/weight.dart';

class Substitution {
  final ScaleDegreeProgression substitutedBase;
  final ScaleDegreeProgression originalSubstitution;
  final double rating;
  final Map<String, double> detailedRating;
  final SubstitutionMatch? substitutionMatch;

  const Substitution(
      {required this.substitutedBase,
      required this.originalSubstitution,
      this.rating = 0.0,
      this.detailedRating = const {},
      this.substitutionMatch});
}
