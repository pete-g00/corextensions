part of '../corextensions.dart';

/// Creates a [RegExp] that matches all the [sources].
RegExp regExpForMultipleMatches(Iterable<String> sources,
    {bool multiLine = false,
    bool caseSensitive = true,
    bool unicode = false,
    bool dotAll = false}) {
  final value = sources.fold<String>(
      '',
      (previousValue, element) =>
          previousValue.isEmpty ? '$element' : '$previousValue|\\$element');
  return RegExp(value,
      multiLine: multiLine,
      caseSensitive: caseSensitive,
      unicode: unicode,
      dotAll: dotAll);
}

extension StringExtension on String {
  /// Capitalises the first letter of `this` and returns that value.
  ///
  /// If this string is empty, returns the same empty string.
  String capitalise() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Splits the string by the first occurence of the provided pattern.
  ///
  /// If the pattern is not found, a list with only this element will be provided.
  ///
  /// For example,
  ///
  /// ```
  /// String word = 'happy';
  /// print(word.splitFirst('p')); // ['ha', 'py']
  /// print(word.splitFirst('pp')); // ['ha', 'y']
  /// print(word.splitFirst('z')); // ['happy']
  /// ```
  List<String> splitFirst(String pattern) {
    for (var i = 0; i < length; i++) {
      if (startsWith(pattern, i)) {
        return [substring(0, i), substring(i + pattern.length)];
      }
    }
    return [this];
  }

  /// Splits the string by the last occurence of the provided pattern.
  ///
  /// For example,
  ///
  /// ```
  /// String word = 'happy';
  /// print(word.splitLast('p')); // ['hap', 'y']
  /// print(word.splitLast('pp')); // ['ha', 'y']
  /// print(word.splitLast('z')); // ['happy']
  /// ```
  /// If the pattern is not found, a list with only this element will be provided.
  List<String> splitLast(String pattern) {
    for (var i = length; i > 0; i--) {
      if (substring(0, i).endsWith(pattern)) {
        return [substring(0, i - pattern.length), substring(i)];
      }
    }
    return [this];
  }

  /// Removes most of the whitespace within the string.
  ///
  /// Breaks the word by the space ' ', and trims each of the result, and join back by the space ' '.
  ///
  /// For example,
  ///
  /// ```
  /// String sentence = 'I want   to   be  free.    ';
  /// String trimmedSentence = sentence.removeSpace();
  /// print(trimmedSentence); // 'I want to be free.'
  /// ```
  String removeExtraSpace() {
    final trimmedSentence = <String>[];
    for (var word in split(' ')) {
      word = word.trim();
      if (word.isNotEmpty) {
        trimmedSentence.add(word);
      }
    }
    return trimmedSentence.join(' ');
  }

  /// Splits `this` by all the provided delimiters.
  ///
  /// The empty delimiter ('') cannot be used, and is implictly removed from the provided list.
  ///
  /// Also removes any empty strings from the list before returning.
  ///
  /// For example,
  ///
  /// ```
  ///  String sentence = 'Happy, sad and angry';
  ///  Iterable<String> splittedSentence = sentence.splitByAll([',', ' ']);
  ///  print(splittedSentence); // ('Happy', 'sad', 'and', 'angry')
  /// ```
  Iterable<String> splitByAll(Iterable<String> delimiters) {
    ArgumentError.checkNotNull(delimiters, 'delimiters');
    if (delimiters.isEmpty) {
      throw ArgumentError('The list of delimiters cannot be empty!');
    }

    delimiters = delimiters.where((element) => element.isNotEmpty);
    final exp = regExpForMultipleMatches(delimiters);
    return split(exp).where((element) => element.isNotEmpty).map((word) =>
        word.endsWithOneOf(delimiters)
            ? word.substring(0, word.length - 1)
            : word);
  }

  /// Checks whether some element in the iterable starts with this string.
  ///
  /// For example,
  ///
  /// ```
  /// String value = 'value';
  /// List<String> consonants = ['b', 'v', 'l', 'n', 'w'];
  /// List<String> vowels = ['a', 'e', 'i', 'o'];
  /// print(value.startsWithOneOf(consonants)); // true
  /// print(value.startsWithOneOf(vowels)); // false
  /// ```
  bool startsWithOneOf(Iterable<String> iterable) {
    ArgumentError.checkNotNull(iterable, 'iterable');
    return iterable.any((String string) => startsWith(string));
  }

  /// Checks whether some element in the iterable ends with this string.
  ///
  /// For example,
  ///
  /// ```
  /// String value = 'value';
  /// List<String> consonants = ['b', 'v', 'l', 'n', 'w'];
  /// List<String> vowels = ['a', 'e', 'i', 'o'];
  /// print(value.endsWithOneOf(consonants)); // true
  /// print(value.endsWithOneOf(vowels)); // false
  /// ```
  bool endsWithOneOf(Iterable<String> iterable) {
    ArgumentError.checkNotNull(iterable, 'iterable');
    return iterable.any((String string) => endsWith(string));
  }

  /// Returns a new string in which the last occurrence of `from` in this string is replaced with `to`, going back from at `endIndex`:
  ///
  /// ```
  /// '0.0001'.replaceFirst(new RegExp(r'0'), ''); // '0.001'
  /// '0.0001'.replaceFirst(new RegExp(r'0'), '7', 3); // '0.0701'
  /// ```
  String replaceLast(Pattern from, String to, [int endIndex]) {
    ArgumentError.checkNotNull(from, 'from');
    ArgumentError.checkNotNull(to, 'to');

    endIndex ??= length - 1;
    final lastIndex = lastIndexOf(from, endIndex);
    if (lastIndex == -1) return this;
    return replaceFirst(from, to, lastIndex);
  }

  /// Finds the indices of the start of all the matches of all the provided values.
  ///
  /// For example,
  ///
  /// ```
  /// String sentence = 'I am here';
  /// List<RegExpMatch> matches = sentence.matchAll(['a', 'e']).toList();
  /// print(matches.map((match) => match.start)); // (2, 6, 8)
  /// ```
  Iterable<RegExpMatch> matchAll(Iterable<String> values) {
    final exp = regExpForMultipleMatches(values);
    return exp.allMatches(this);
  }
}
