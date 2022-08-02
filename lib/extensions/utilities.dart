abstract class Utilites {
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
}
