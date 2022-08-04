import '../modals/progression/progression.dart';

abstract class Utilities {
  static void mergeMaps<T, E>(Map<T, List<E>> m1, Map<T, List<E>> m2) {
    for (var key in m2.keys) {
      final lst1 = m1.putIfAbsent(key, () => []);
      for (var value in m2[key]!) {
        if (!lst1.contains(value)) {
          lst1.add(value);
        }
      }
    }
  }

  static void twoProgressionsIterator<T>(
    Progression<T> p1,
    Progression<T> p2, {
    required bool Function(int i1, int i2) iterate,
    int startP1At = 0,
    int startP2At = 0,
  }) {
    assert(p1.duration == p2.duration);
    int i1 = startP1At, i2 = startP2At;
    while (i1 < p1.length && i2 < p2.length) {
      if (iterate(i1, i2)) break;
      final double nextDurSum1 = p1.durations.real(i1);
      final double nextDurSum2 = p2.durations.real(i2);
      if (nextDurSum2 >= nextDurSum1) {
        i1++;
      }
      if (nextDurSum1 >= nextDurSum2) {
        i2++;
      }
    }
  }
}
