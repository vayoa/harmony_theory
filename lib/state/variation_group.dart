import '../modals/substitution.dart';
import '../modals/variation_id.dart';

class VariationGroup {
  /// All [Substitution]s relating to the group.
  final List<Substitution> members;

  /// The group's [SubVariationId].
  final SubVariationId subVariationId;

  VariationGroup(this.subVariationId, this.members, [bool? sorted]);

  sort() =>
      members.sort((Substitution a, Substitution b) => -1 * a.compareTo(b));

  /// Only works if [sort] was called on the latest mutation of [members].
  Substitution get best => members.first;

  int compareTo(VariationGroup other) => best.compareTo(other.best);
}
