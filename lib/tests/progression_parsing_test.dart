import '../modals/analysis_tools/progression_analyzer.dart';
import '../modals/progression/degree_progression.dart';

abstract class ProgressionParsingTest {
  static ProgressionParsingTestResult test(String input, {bool hard = false}) {
    DegreeProgression progression;
    try {
      progression = DegreeProgression.parse(input);
    } on Exception catch (e) {
      return ProgressionParsingTestResult(error: e);
    }
    return ProgressionParsingTestResult.of(progression, hard: hard);
  }
}

class ProgressionParsingTestResult {
  late final String? result;
  late final DegreeProgression? object;
  late final String? analyzedResult;
  late final DegreeProgression? analyzedObject;
  late final Exception? error;

  ProgressionParsingTestResult({
    this.result,
    this.object,
    this.analyzedResult,
    this.analyzedObject,
    this.error,
  }) : assert(((result == null) == (object == null) &&
                (object == null) == (analyzedResult == null) &&
                (analyzedResult == null) == (analyzedObject == null)) &&
            (result == null) != (error == null));

  ProgressionParsingTestResult.of(DegreeProgression progression,
      {required bool hard}) {
    object = progression;
    result = progression.toString();
    analyzedObject = ProgressionAnalyzer.analyze(progression, hard: hard);
    analyzedResult = analyzedObject.toString();
    error = null;
  }

  @override
  String toString() {
    if (error != null) return 'Error!\n$error';
    return result!;
  }
}
