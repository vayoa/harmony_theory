import '../../modals/substitution_match.dart';
import '../../state/progression_bank.dart';
import 'progression/degree_progression.dart';

class SubstitutionContext {
  final DegreeProgression originalSubstitution;
  final SubstitutionMatch match;
  final double variationStart;
  final double variationEnd;
  final double insertStart;
  final double insertEnd;
  final EntryLocation? location;

  const SubstitutionContext({
    required this.originalSubstitution,
    required this.variationStart,
    required this.variationEnd,
    required this.insertStart,
    required this.insertEnd,
    required this.match,
    this.location,
  });
}
