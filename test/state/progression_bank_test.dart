import 'dart:convert';

import 'package:harmony_theory/modals/progression/degree_progression.dart';
import 'package:harmony_theory/modals/theory_base/degree/degree_chord.dart';
import 'package:harmony_theory/state/progression_bank.dart';
import 'package:harmony_theory/state/variation_group.dart';
import 'package:test/test.dart';

main() {
  group('Variation Groups', () {
    ProgressionBank.initializeBuiltIn();
    test('All variations have the same dry/not-dry ids.', () {
      DegreeChord tonic = DegreeChord.vi;
      var varBank = ProgressionBank.variationBank;
      for (int varId in varBank.keys) {
        final SavedVariationGroup vg = varBank[varId]!;
        final int dryVarId = vg.dryVariationId;
        DegreeProgression? last;
        for (int pid in vg.ids) {
          final entry = ProgressionBank.getByID(pid)!;
          expect(entry.variationId!, equals(varId));
          expect(entry.variationId, equals(entry.progression.variationId()));
          expect(dryVarId, equals(entry.progression.dryVariationId));

          final prog = entry.progression;
          if (last != null) {
            expect(prog.durations, equals(last.durations));
            expect(prog.values.map((e) => e?.root),
                equals(last.values.map((e) => e?.root)));
            expect(
                prog.tonicizedFor(tonic).variationId(),
                equals(
                    prog.variationId(tonicizedFor: tonic.root, dry: dryVarId)));
          }
          last = prog;
        }
        tonic =
            last?.values.firstWhere((e) => e != null && e.canBeTonic) ?? tonic;
      }
    });
  });
  group('Json', () {
    test('parsing', () {
      ProgressionBank.initializeBuiltIn();
      late final json;
      expect(
          () => json = jsonEncode(ProgressionBank.toJson()), returnsNormally);
      final pass1 = ProgressionBank.createComputePass().toString();
      expect(
        () => ProgressionBank.initializeFromJson(jsonDecode(json)),
        returnsNormally,
      );
      final pass2 = ProgressionBank.createComputePass().toString();
      expect(pass1, equals(pass2));
      expect(json, equals(jsonEncode(ProgressionBank.toJson())));
    });
  });
}
