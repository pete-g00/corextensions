part of '../corextensions.dart';

extension MapCorextension<K, V> on Map<K, V> {
  /// Returns `true` if there's precisely one key/value pair in the map.
  bool get isSingle => length == 1;

  /// Returns the first entry that satisfies the predicate.
  ///
  /// If none match, the `orElse` function will be run. If not provided, a [StateError] is thrown.
  MapEntry<K, V> firstEntryWhere(bool Function(K key, V value) f,
      {MapEntry<K, V> Function() orElse}) {
    for (final entry in entries) {
      if (f(entry.key, entry.value)) return entry;
    }
    if (orElse != null) return orElse();
    throw StateError('No entry satisfies the function!');
  }

  /// Returns the first key that satisfies the predicate.
  ///
  /// If none match, the `orElse` function will be run. If not provided, a [StateError] is thrown.
  K firstKeyWhere(bool Function(K key, V value) f, {K Function() orElse}) {
    for (final entry in entries) {
      if (f(entry.key, entry.value)) {
        return entry.key;
      }
    }
    if (orElse != null) return orElse();
    throw StateError('No entry satisfies the function!');
  }

  /// Returns the first value that satisfies the predicate.
  ///
  /// If none match, the `orElse` function will be run. If not provided, a [StateError] is thrown.
  V firstValueWhere(bool Function(K key, V value) f, {V Function() orElse}) {
    for (final entry in entries) {
      if (f(entry.key, entry.value)) {
        return entry.value;
      }
    }
    if (orElse != null) return orElse();
    throw StateError('No entry satisfies the function!');
  }

  /// Returns the single entry that satisfies the predicate.
  ///
  /// If none match, the `orElse` function will be run. If not provided, a [StateError] is thrown.
  ///
  /// Multiple matches will always throw a [StateError].
  MapEntry<K, V> singleEntryWhere(bool Function(K key, V value) f,
      {MapEntry<K, V> Function() orElse}) {
    var alreadyFound = false;
    MapEntry<K, V> match;
    for (final entry in entries) {
      if (f(entry.key, entry.value)) {
        if (alreadyFound == true) throw StateError('Too many matches!');
        match = entry;
        alreadyFound = true;
      }
    }
    if (alreadyFound) return match;
    if (orElse != null) return orElse();
    throw StateError('No entry satisfies the function!');
  }

  /// Returns the single key that satisfies the predicate.
  ///
  /// If none match, the `orElse` function will be run. If not provided, a [StateError] is thrown.
  ///
  /// Multiple matches will always throw a [StateError].
  K singleKeyWhere(bool Function(K key, V value) f, {K Function() orElse}) {
    var alreadyFound = false;
    K match;
    for (final entry in entries) {
      if (f(entry.key, entry.value)) {
        if (alreadyFound == true) throw StateError('Too many matches!');
        match = entry.key;
        alreadyFound = true;
      }
    }
    if (alreadyFound) return match;
    if (orElse != null) return orElse();
    throw StateError('No entry satisfies the function!');
  }

  /// Returns the single value that satisfies the predicate.
  ///
  /// If none match, the `orElse` function will be run. If not provided, a [StateError] is thrown.
  ///
  /// Multiple matches will always throw a [StateError].
  V singleValueWhere(bool Function(K key, V value) f, {V Function() orElse}) {
    var alreadyFound = false;
    V match;
    for (final key in keys) {
      if (f(key, this[key])) {
        if (alreadyFound == true) throw StateError('Too many matches!');
        match = this[key];
        alreadyFound = true;
      }
    }
    if (alreadyFound) return match;
    if (orElse != null) return orElse();
    throw StateError('No entry satisfies the function!');
  }

  /// Returns the map where the keys and values within `this` are returned.
  ///
  /// If the values aren't unique, the key associated with the final occurence of the value becomes the value of the new map.
  ///
  /// For exmaple,
  ///
  /// ````
  ///  Map<String, int> stringToNumber = {'one': 1, 'two': 2, 'three': 3, 'four': 4};
  ///  Map<int, String> numbersToString = stringToNumber.reverse();
  ///  print(numbersToString); // {1: 'one', 2: 'two', 3: 'three', 4: 'four'}
  /// ````
  Map<V, K> reverse() {
    final map = <V, K>{};
    for (final key in keys) {
      map[this[key]] = key;
    }
    return map;
  }

  /// Expands a [Map] by iterating over every entry and replacing it with another [Map].
  ///
  /// Doesn't modify `this`.
  Map<RK, RV> expand<RK, RV>(Map<RK, RV> Function(K key, V value) f) {
    final map = <RK, RV>{};
    forEach((key, value) {
      map.addAll(f(key, value));
    });
    return map;
  }
}
