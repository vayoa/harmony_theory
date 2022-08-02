import 'package:harmony_theory/modals/substitution.dart';

import '../modals/progression/degree_progression.dart';
import '../state/progression_bank_entry.dart';

/// Describes a group of [DegreeProgression]s who are all variations of
/// each other.
///
/// Two [DegreeProgression]s are considered variations of each other if
/// both have the same roots with the same exact durations in the
/// same order.
class SavedVariationGroup {
  /// All [DegreeProgression.id] of the progressions relating to the group.
  final List<int> ids;

  /// The group's [DegreeProgression.dryVariationId] (variation id
  /// without taking into account the last root).
  final int dryVariationId;

  SavedVariationGroup(ProgressionBankEntry entry)
      : ids = [],
        dryVariationId = entry.progression.dryVariationId;

  SavedVariationGroup.fromJson(Map<String, dynamic> json)
      : ids = json['ids'].cast<int>(),
        dryVariationId = json['dry'];

  Map<String, dynamic> toJson() => {
        'ids': ids,
        'dry': dryVariationId,
      };

  @override
  String toString() => 'dry: $dryVariationId,\nids:$ids.';
}

class VariationGroup {
  /// All [Substitution]s relating to the group.
  final List<Substitution> members;

  /// The group's [DegreeProgression.substitutionVariationId] (variation id
  /// without taking into account the last root).
  final int subVariationId;

  VariationGroup(this.subVariationId, this.members, [bool? sorted]);

  sort() =>
      members.sort((Substitution a, Substitution b) => -1 * a.compareTo(b));

  /// Only works if [sort] was called on the latest mutation of [members].
  Substitution get best => members.first;

  int compareTo(VariationGroup other) => best.compareTo(other.best);
}
