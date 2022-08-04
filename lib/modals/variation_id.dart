import 'dart:math';

import 'progression/degree_progression.dart';

class DryVariationId {
  /// The parts of the id, each part represents a root from the progression.
  ///
  /// The spec is described in [getCode].
  late final List<int> parts;

  DryVariationId(
    DegreeProgression progression, {
    double startDur = 0.0,
    int start = 0,
    double? endDur,
    int? end,
  }) : assert(start >= 0 &&
            startDur >= 0 &&
            (end ?? 1) > 0 &&
            (endDur ?? 1) > 0 &&
            start <= (end ?? progression.length) &&
            startDur <= progression.durations[start]) {
    final int lastIndex = end == null
        ? progression.values.lastIndexWhere((e) => e != null)
        : end - 1;
    endDur = min(endDur ?? 0, progression.durations[lastIndex]);

    final double lastDur = progression.durations[lastIndex];

    parts = List.generate(
      // This won't take us to the last interval
      lastIndex + 1 - start,
      (i) {
        final int index = i + start;
        // We don't care about the last interval since it's 0
        // and about the first duration since it's 0.
        final int semitones =
            progression.values[index]?.root.semitonesFromTonicInMajor ?? -1;
        final double duration = progression.durations[index];

        return getCode(duration, semitones, lastDur);
      },
      growable: false,
    );

    double startDurMod = progression.durations[0];
    if (startDur != 0.0) {
      startDurMod -= startDur;
      parts[0] = getCode(startDurMod, parts[0] % 100, lastDur);
    }
    if (endDur > progression.durations[lastIndex]) {
      // In case both the startDur and endDur affect the same
      // index (if parts.length == 1...). We'd still want the modification
      // of startDur on the part...
      double lastDurMod =
          start - lastIndex == 0 ? startDurMod : progression.durations.last;
      parts.last = getCode(lastDurMod - endDur, parts.last % 100, lastDur);
    }
  }

  /// [duration] is the number of steps the next root takes.
  /// [semitones] is the number of semitones between the root and the last
  /// non-null root.
  ///
  /// The spec is [duration] * 100 + [semitones].
  int getCode(double duration, int semitones, double last) {
    final double ratio = duration / last;
    // Since we know interval won't go past 12...
    return ((ratio * 100).toInt() * 100) + semitones;
  }

  DryVariationId.fromString(String str) {
    List<String> split = str.split(',');
    parts = List.generate(
      split.length,
      (index) => int.parse(split[index]),
      growable: false,
    );
  }

  DryVariationId.empty() : parts = const [];

  @override
  bool operator ==(Object other) {
    if (other is DryVariationId && parts.length == other.parts.length) {
      for (int i = 0; i < parts.length; i++) {
        if (parts[i] != other.parts[i]) return false;
      }
      return true;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll(parts);

  @override
  String toString() {
    String str = "";
    for (var part in parts) {
      str += '$part,';
    }
    return str.substring(0, str.length - 1);
  }
}

class SubVariationId extends DryVariationId {
  /// The number of steps from the beginning of the progression until
  /// changes take effect.
  late final int startCode;

  SubVariationId({
    required DegreeProgression progression,
    required double startChange,
    double startDur = 0.0,
    int start = 0,
    double? endDur,
    int? end,
  }) : super(
          progression,
          startDur: startDur,
          start: start,
          endDur: endDur,
          end: end,
        ) {
    _setFields(startChange, progression);
  }

  void _setFields(double startChange, DegreeProgression progression) {
    startCode = startChange ~/ progression.timeSignature.step;
  }

  SubVariationId.empty() : super.empty() {
    startCode = 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other && other is SubVariationId && startCode == other.startCode;

  @override
  int get hashCode => Object.hash(super.hashCode, startCode.hashCode);

  @override
  String toString() => '${super.toString()}|$startCode';
}
