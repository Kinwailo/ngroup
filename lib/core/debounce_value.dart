import 'dart:async';

class DebounceValue<T> {
  T _value;
  final Duration _duration;
  final void Function(T value)? _callback;
  Timer? _timer;

  DebounceValue(this._value, this._duration, this._callback);

  T get val => _value;
  set val(T v) => _set(v);

  void _set(T v) {
    _timer?.cancel();
    if (v == _value) return;
    _timer = Timer(_duration, () {
      _value = v;
      _callback?.call(v);
    });
  }
}
