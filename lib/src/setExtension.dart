part of '../corextensions.dart';

extension SetExtension<E> on Set<E> {
  /// Returns `true` if there is only one element in `this`.
  bool get isSingle => length == 1;

  /// Returns `true` if the length of `this` is the same as the length of the provided `iterable`.
  ///
  /// Can be slow if the provided iterable isn't a list/set, or something that can efficiently index/calculate the length.
  bool hasSameLengthAs<L>(Iterable<L> iterable) => length == iterable.length;

  /// Returns `true` if `this` is equal to the another set provided.
  ///
  /// This is calculated by equating two elements within the two sets in some order, i.e. using [Object.==].
  bool equals(Set<E> another) => SetEquality().equals(this, another);
}

