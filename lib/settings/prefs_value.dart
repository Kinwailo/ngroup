import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class PrefsStorage {
  Future<void> save(String key, String value);
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

class PrefsShortcut extends PrefsValue<SingleActivator> {
  PrefsShortcut(
    super.key,
    super.defaultValue,
    super.storage, {
    super.description,
    super.prompt,
  });

  @override
  String _encode(SingleActivator v) {
    var map = {
      'key': v.trigger.keyId,
      'control': v.control,
      'shift': v.shift,
      'alt': v.alt,
      'repeat': v.includeRepeats,
    };
    return jsonEncode(map);
  }

  @override
  SingleActivator _decode(String v) {
    var map = jsonDecode(v);
    var key = LogicalKeyboardKey.findKeyByKeyId(map['key']) ??
        LogicalKeyboardKey.space;
    var control = map['control'];
    var shift = map['shift'];
    var alt = map['alt'];
    var repeat = map['repeat'];
    var s = SingleActivator(key,
        control: control, shift: shift, alt: alt, includeRepeats: repeat);
    return s;
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

  Future<void> update() async {
    await _save(_value);
    notifyListeners();
  }

  Future<void> _save(T value) async {
    await storage.save(key, _encode(value));
  }
}
