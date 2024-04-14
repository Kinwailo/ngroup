import 'dart:convert';

import 'package:flutter/material.dart';

abstract class PrefsStorage {
  void save(String key, String value);
  String? load(String key);
}

class PrefsEnum<T extends Enum> extends PrefsValue<T> {
  PrefsEnum(
    super.key,
    super.defaultValue,
    this.values,
    super.storage, {
    super.description,
    super.prompt,
  });

  final List<T> values;

  @override
  String _encode(T v) {
    return jsonEncode(v.name);
  }

  @override
  T _decode(String v) {
    String name = jsonDecode(v);
    if (!values.map((e) => e.name).contains(name)) name = values[0].name;
    return values.byName(name);
  }
}

class PrefsColor extends PrefsValue<Color> {
  PrefsColor(
    super.key,
    super.defaultValue,
    super.storage, {
    super.description,
    super.prompt,
  });

  @override
  String _encode(Color v) {
    return jsonEncode(v.value);
  }

  @override
  Color _decode(String v) {
    return Color(jsonDecode(v));
  }
}

class PrefsValue<T> extends ChangeNotifier {
  final String key;
  final T defaultValue;
  final PrefsStorage storage;

  final String? description;
  final String? prompt;

  bool ready = false;
  late T _value;

  T get val => _get();
  set val(T v) => _set(v);

  PrefsValue(
    this.key,
    this.defaultValue,
    this.storage, {
    this.description,
    this.prompt,
  });

  void _init() {
    if (ready) return;
    ready = true;

    _value = defaultValue;
    var v = storage.load(key);
    if (v != null) {
      _value = _decode(v);
    }
  }

  String _encode(T v) {
    return jsonEncode(v);
  }

  T _decode(String v) {
    return jsonDecode(v) as T;
  }

  T _get() {
    _init();
    return _value;
  }

  void _set(T v) {
    _init();
    _value = v;
    _save(v);
    notifyListeners();
  }

  void update() {
    _save(_value);
    notifyListeners();
  }

  void _save(T value) async {
    storage.save(key, _encode(value));
  }
}
