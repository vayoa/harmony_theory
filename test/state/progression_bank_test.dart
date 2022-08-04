import 'dart:convert';

import 'package:harmony_theory/state/progression_bank.dart';
import 'package:test/test.dart';

main() {
  group('Json', () {
    test('parsing', () {
      ProgressionBank.initializeBuiltIn();
      late final String json;
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
