import 'dart:collection';

import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that holds a single value.
///
/// When [value] is replaced with something that is not equal to the old
/// value as evaluated by the equality operator ==, this class notifies its
/// listeners.
class LinkedHashMapNotifier<K, V> extends ChangeNotifier
    implements ValueListenable<LinkedHashMap<K, V>> {
  /// Creates a [ChangeNotifier] that wraps this value.
  LinkedHashMapNotifier(this._value);

  /// The current value stored in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old
  /// value as evaluated by the equality operator ==, this class notifies its
  /// listeners.
  @override
  LinkedHashMap<K, V> get value => _value;
  LinkedHashMap<K, V> _value;
  set value(LinkedHashMap<K, V> newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }

  void notify() => super.notifyListeners();

  /// The number of key/value pairs in the map.
  int get length => value.length;

  /// Whether this map inside the Notifier contains the given [key].
  bool containsKey(K? key) => value.containsKey(key);

  /// Updates the value for the provided [key].
  ///
  /// Returns the new value associated with the key.
  ///
  /// If the key is present, invokes [update] with the current value and stores
  /// the new value in the map.
  ///
  /// If the key is not present and [ifAbsent] is provided, calls [ifAbsent]
  /// and adds the key with the returned value to the map.
  ///
  /// If the key is not present, [ifAbsent] must be provided.
  V update(
    K key,
    V Function(V value) update, {
    V Function()? ifAbsent,
  }) {
    final updatedValue = value.update(key, update, ifAbsent: ifAbsent);
    super.notifyListeners();
    return updatedValue;
  }

  /// Removes [key] and its associated value, if present, from the map.
  V? remove(
    K? key, {
    bool notifyListeners = true,
  }) {
    final removedValue = value.remove(key);
    if (notifyListeners) super.notifyListeners();
    return removedValue;
  }

  /// Look up the value of [key], or add a new entry if it isn't there.
  ///
  /// Returns the value associated to [key], if there is one.
  /// Otherwise calls [ifAbsent] to get a new value, associates [key] to
  /// that value, and then returns the new value.
  /// Calling [ifAbsent] must not add or remove keys from the map.
  V putIfAbsent(K key, V Function() ifAbsent) {
    final valueAdded = value.putIfAbsent(key, ifAbsent);
    super.notifyListeners();
    return valueAdded;
  }

  void clear() => value.clear();

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
