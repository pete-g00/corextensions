part of '../corextensions.dart';

class _MappedListIterable<S, E> extends Iterable<S> {
  const _MappedListIterable(this.list, this.transform);

  final S Function(E element, int i) transform;
  final List<E> list;

  @override
  Iterator<S> get iterator => _MappedListIterator(list, transform);

  @override
  int get length => list.length;

  @override
  S elementAt(int i) => transform(list[i], i);
}

class _MappedListIterator<S, E> extends Iterator<S> {
  _MappedListIterator(this.list, this.transform) : i = -1;
  int i;
  final S Function(E element, int i) transform;
  final List<E> list;
  @override
  bool moveNext() {
    i++;
    return i < list.length;
  }

  @override
  S get current => i < list.length && i >= 0 ? transform(list[i], i) : null;
}

extension ListCorextension<E> on List<E> {
  /// Returns a new lazy iterable with elements that are created by calling `f` on each element of this `List` in iteration order.
  ///
  /// Unlike the [map] method, we are also provided with the index at which the value is.
  Iterable<S> mapWithIndex<S>(S Function(E element, int i) f) =>
      _MappedListIterable(this, f);

  /// Returns `true` if there is only one element in `this`.
  bool get isSingle => length == 1;

  /// Returns `true` if the length of `this` is the same as the length of the provided `iterable`.
  ///
  /// Can be slow if the provided iterable isn't a list/set, or something that can efficiently index/calculate the `length`.
  bool hasSameLengthAs<L>(Iterable<L> iterable) => length == iterable.length;

  /// Returns `true` if `this` has any duplicates present.
  ///
  /// This is done via comparing the length of `this` as a list and as a set.
  /// Therefore, it uses the equality operator [Object.==] for each element in `this` to determine whether there are duplicates.
  bool get hasDuplicates => toSet().length != length;

  /// Returns `true` if the elements within `this` and the other list are the same. The order in which they appear is irrelevant.
  ///
  /// This is checked by computing the equality between the two lists as sets. The equality used is from the operator [Object.==].
  bool hasSameElementsAs(List<E> list) => toSet().equals(list.toSet());

  /// Returns a new list where the provided `addition` is added in between every 2 elements in `this`.
  ///
  /// The element is not added to the start or the end of the list.
  ///
  /// For example,
  ///
  ///```
  ///  List<int> numbers = [1, 2, 3];
  ///  numbers.addWithin(5);
  ///  print(numbers); // [1, 5, 2, 5, 3]
  /// ```
  void addWithin(E addition) {
    ArgumentError.checkNotNull(addition, 'addition');
    
    final length = this.length;
    for (var i = 0; i < length - 1; i++) {
      insert(2 * i + 1, addition);
    }
  }

  /// Given two indices in `this`, swaps elements at those indices within this list.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 2, 3];
  /// numbers.swap(0, 1);
  /// print(numbers); // [2, 1, 3]
  /// ```
  void swap(int i, int j) {
    ArgumentError.checkNotNull(i, 'i');
    ArgumentError.checkNotNull(j, 'j');
    RangeError.checkValidIndex(i, this, 'i');
    RangeError.checkValidIndex(j, this, 'j');

    if (i == j) return;

    final value = this[i];
    this[i] = this[j];
    this[j] = value;
  }

  /// Permutes the elements in the list given a list of indices, in that order.
  ///
  /// So, if the indices list is `[0, 2, 1]`,
  ///
  /// * `this[0]` becomes `this[2]`;
  /// * `this[2]` becomes `this[i]`; and
  /// * `this[1]` becomes `this[0]`.
  ///
  /// Every index can only appear once in the list. Any index not appearing in the list remains unaffected.
  ///
  /// For example,
  ///
  /// ```
  /// List<String> sentence = ['I', 'would', 'have', 'known', 'not', 'that'];
  /// sentence.permute([2, 3, 4]);
  /// print(sentences); // ['I', 'would', 'not', 'have', 'known', 'that']
  /// ```
  void permute(List<int> indices) {
    ArgumentError.checkNotNull(indices, 'indices');

    if (indices.isEmpty || indices.isSingle) return;
    if (indices.hasDuplicates) {
      throw ArgumentError('The list of indices has duplicates!');
    }

    ArgumentError.checkNotNull(indices.first, 'indices[0]');
    RangeError.checkValidIndex(indices.first, this, 'indices[0]');

    final value = this[indices[indices.length - 1]];
    for (var i = indices.length - 2; i >= 0; i--) {
      ArgumentError.checkNotNull(indices[i + 1], 'indices[${i + 1}]');
      RangeError.checkValidIndex(indices[i + 1], this, 'indices[${i + 1}]');
      this[indices[i + 1]] = this[indices[i]];
    }
    this[indices[0]] = value;
  }

  /// Given a function that we can run 2 consecutive elements of `this`, partitions the list by the result.
  ///
  /// If `true`, the two elements lie in the same partition.
  ///
  /// If `false`, the first element and the second element lie in a different partition.
  ///
  /// For example,
  ///
  /// ```
  ///  List<int> numbers = [1, 2, 3, 5, 6, 10, 12, 13];
  ///  List<List<int>> numbersPartitioned = numbers.partitionInOrder(
  ///    // in the same partition if their difference is 1.
  ///    (previousValue, thisValue, i, thisPartition) => previousValue + 1 == thisValue
  ///  );
  ///  print(numbersPartitioned); // [[1, 2, 3], [5, 6], [10], [12, 13]]
  /// ```
  List<List<E>> partitionInOrder(
      bool Function(E previousValue, E thisValue, int i, List<E> thisPartition)
          function) {
    ArgumentError.checkNotNull(function, 'function');

    if (isEmpty) return [];
    final partitioned = <List<E>>[];
    var thisPartition = [first];
    for (var i = 0; i < length - 1; i++) {
      if (function(this[i], this[i + 1], i, thisPartition)) {
        thisPartition.add(this[i + 1]);
      } else {
        partitioned.add(thisPartition);
        thisPartition = [this[i + 1]];
      }
    }
    partitioned.add(thisPartition);
    return partitioned;
  }

  /// Returns all the permutations of `this`.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 2, 3];
  /// Iterable<List<int>> numberPermutations = number.allPermutations();
  /// print(numberPermutations); // ([1, 2, 3], [1, 3, 2], .., [3, 2, 1])
  /// ```
  ///
  /// This uses the [Permutations] class from the `trotter` package.
  Iterable<List<E>> allPermutations() => Permutations(length, this)();

  /// Returns all the permutations of `this`, excluding this one.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 2, 3];
  /// Iterable<List<int>> numberPermutations = number.otherPermutations();
  /// print(numberPermutations.toList()); // ([1, 3, 2], [2, 3, 1], .., [3, 2, 1])
  /// ```
  Iterable<List<E>> otherPermutations() =>
      allPermutations().where((element) => !shallowEquals(element));

  /// Returns a version of `this` where the elements in the list appear in the provided `newOrder`.
  ///
  /// For example,
  ///
  /// ```
  /// List<String> sentence = ['I', 'went', 'there', 'yesterday'];
  /// List<String> reOrderedSentence = sentence.withOrder([3, 0, 1, 2]);
  /// print(reOrderedSentence); // ['yesterday', 'I', 'went', 'there']
  /// ```
  ///
  /// The list provided must be made of all the indices from `0` to `length - 1` precisely once.
  List<E> withOrder(List<int> newOrder) {
    if (newOrder.hasDuplicates) throw ArgumentError('The list has duplicates!');
    if (!hasSameLengthAs(newOrder)) {
      throw ArgumentError(
          "The list of indices doesn't contain all the indices in this list!");
    }
    final reordered = <E>[];
    for (var i = 0; i < length; i++) {
      final j = newOrder[i];
      RangeError.checkValidIndex(j, this, 'newOrder[$i]');
      reordered.add(this[j]);
    }
    return reordered;
  }

  /// Finds the index of the first difference between `this` and a `permutation` provided.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 2, 3, 4];
  /// List<int> numbersPermuted = [1, 3, 2, 4];
  /// int firstDifferenceIndex = numbers.firstDifferenceTo(numbersPermuted);
  /// print(firstDifferenceIndex); // 1
  /// ```
  int firstDifferenceTo(List<E> permutation) {
    ArgumentError.checkNotNull(permutation, 'permutation');
    if (!hasSameLengthAs(permutation)) {
      throw ArgumentError("The two lists don't have the same length!");
    }

    for (var i = 0; i < length; i++) {
      if (this[i] != permutation[i]) return i;
    }
    throw StateError(
        'The two lists are the same or aren\'t permutations of each other!');
  }

  /// Finds the distance between `this` and its `permutation`.
  ///
  /// This is done by counting the number of indices where the elements in the two lists is different.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 2, 3, 4];
  /// List<int> numbersPermuted = [1, 3, 2, 4];
  /// int distance = numbers.distanceTo(numbersPermuted);
  /// print(distance); // 2
  ///```
  int distanceTo(List<E> permutation) {
    ArgumentError.checkNotNull(permutation, 'permutation');

    var distance = 0;
    for (var i = 0; i < length; i++) {
      if (this[i] != permutation[i]) {
        distance++;
      }
    }
    return distance;
  }

  /// Finds all the indices of the element in `this`.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 1, 2, 3, 1, 5];
  /// List<int> indicesOf1 = numbers.allIndicesOf(1);
  /// print(indicesOf1); // [0, 1, 4]
  /// List<int> indicesOf4 = numbers.allIndicesOf(4);
  /// print(indicesOf4); // []
  /// ```
  List<int> allIndicesOf(E element) {
    final matches = <int>[];
    for (var i = 0; i < length; i++) {
      if (this[i] == element) {
        matches.add(i);
      }
    }
    return matches;
  }

  /// Finds all the indices of the elements in `this` that satisfy the provided `function`.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 1, 2, 3, 1, 5];
  /// List<int> evenIndices = numbers.allIndicesWhere((element) => element.isEven);
  /// print(evenIndices); // [2]
  /// List<int> negativeIndices = numbers.allIndicesOf((element) => element.isNegative);
  /// print(negativeIndices); // []
  /// ```
  List<int> allIndicesWhere(bool Function(E element) f) {
    final matches = <int>[];
    for (var i = 0; i < length; i++) {
      if (f(this[i])) {
        matches.add(i);
      }
    }
    return matches;
  }

  /// Gets all the possible choices from `this`.
  ///
  /// For example,
  ///
  /// ```
  /// List<int> numbers = [1, 2];
  /// List<List<int>> choicesOfNumber = numbers.allChoices;
  /// print(choicesOfNumber); // [[], [1], [2], [1, 2]]
  /// ```
  ///
  /// This is done with help of the class [Combinations] from the `trotter` package.
  List<List<E>> get allChoices {
    final choices = <List<E>>[];
    for (var i = 0; i <= length; i++) {
      choices.addAll(Combinations(i, this)());
    }
    return choices;
  }

  /// Replace elements within `this` by reorganising the elements.
  ///
  /// The elements between the `startIndex` (inclusive) and the `endIndex` (exclusive) will be replaced by elements at indices within the `changeArray`.
  ///
  /// For example,
  ///
  /// ```
  /// List<String> fruits = ['apple', 'banana', 'carrot', 'mango', 'pineapple'];
  /// fruits.replaceElementsByReorganisation(1, 3, [1, 0]);
  /// print(fruits); // ['apple', 'carrot', 'banana', 'mango', 'pineapple']
  /// fruits.replaceElementsByReorganisation(1, 4, [2, 2]);
  /// print(fruits); // ['apple', 'mango', 'mango', 'pineapple']
  /// ```
  ///
  /// The indices within `changeArray` must be between `0` (inclusive) and `endIndex - startIndex` (exclusive).
  /// They are added with the start index when reorganised.
  void replaceElementsByReorganisation(
      int startIndex, int endIndex, List<int> changeArray) {
    RangeError.checkValidRange(startIndex, endIndex, length);

    if (changeArray
        .any((element) => element < 0 || element >= endIndex - startIndex)) {
      throw RangeError(
          'The change array must be made of elements within the replacing part!');
    }
    final replacement = changeArray.map((i) => this[startIndex + i]);
    replaceRange(startIndex, endIndex, replacement);
  }

  /// Returns `true` if `this` starts with the elements in the provided list `values`.
  /// The equality of the values is evaluated directly.
  ///
  /// For example,
  ///
  /// ```
  /// List<int> numbers = [1, 2, 1, 1, 3];
  /// List<int> numbersSubset1 = [1, 2, 1];
  /// List<int> numbersSubset2 = [1, 2, 3];
  /// print(numbers.startsWith(numbersSubset1)); // true
  /// print(numbers.startsWith(numbersSubset2)); // false
  /// ```
  bool startsWith(List<E> values) {
    ArgumentError.checkNotNull(values, 'values');

    if (length < values.length) return false;
    for (var i = 0; i < values.length; i++) {
      if (this[i] != values[i]) return false;
    }
    return true;
  }

  /// Returns `true` if `this` ends with the elements in the provided list `values`.
  /// The equality of the values is evaluated directly.
  ///
  /// For example,
  /// ```
  /// List<int> numbers = [1, 2, 1, 1, 3];
  /// List<int> numbersSubset1 = [1, 1, 1];
  /// List<int> numbersSubset2 = [1, 1, 3];
  /// print(numbers.endsWith(numbersSubset1)); // false
  /// print(numbers.endsWith(numbersSubset2)); // true
  /// ```
  bool endsWith(List<E> values) {
    ArgumentError.checkNotNull(values, 'values');

    if (length < values.length) return false;
    for (var i = 0; i < values.length; i++) {
      if (this[length - 1 - i] != values[values.length - 1 - i]) return false;
    }
    return true;
  }

  /// Returns `true` if the provided elements are found in the list, in the specified order.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 2, 3, 4, 2];
  /// List<int> numbersSubset1 = [2, 3, 4];
  /// List<int> numbersSubset1 = [1, 3, 4];
  /// print(numbers.containsInOrder(numbersSubset1)); // true
  /// print(numbers.containsInOrder(numbersSubset2)); // false
  /// ```
  bool containsInOrder(List<E> subset) {
    if (subset.isEmpty) return isEmpty;

    var j = 0;
    for (var i = 0; i < length; i++) {
      if (this[i] == subset[j]) {
        if (j == subset.length - 1) return true;
        j++;
      } else {
        j = this[i] == subset[0] ? 1 : 0;
      }
    }
    return j == subset.length - 1;
  }

  /// Updates the value of all the elements in `this` using the function.
  ///
  /// For example,
  /// ````
  ///  List<int> numbers = [0, 1, 2, 3];
  ///  numbers.updateAll((value) => value * 2);
  ///  print(numbers); // [0, 2, 4, 6]
  /// ````
  void updateAll(E Function(E element) f) {
    for (var i = 0; i < length; i++) {
      this[i] = f(this[i]);
    }
  }

  /// Counts the number of times the value is present in the iterable.
  int count(E element) {
    var count = 0;
    for (var i = 0; i < length; i++) {
      if (element == this[i]) {
        count++;
      }
    }
    return count;
  }

  /// Counts the number of elements in the iterable that satisfy the `fn`.
  int countWhere(bool Function(E element) fn) {
    var count = 0;
    for (var i = 0; i < length; i++) {
      if (fn(this[i])) {
        count++;
      }
    }
    return count;
  }
}
