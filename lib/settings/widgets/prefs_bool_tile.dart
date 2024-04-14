import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../prefs_value.dart';

class PrefsBoolTile extends HookWidget {
  const PrefsBoolTile(
    this.value, {
    super.key,
    this.onChanged,
  });

  final PrefsValue<bool> value;
  final Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    useListenable(value);
    return CheckboxListTile(
      title: Text(value.description ?? ''),
      subtitle: value.prompt == null ? null : Text(value.prompt!),
      value: value.val,
      onChanged: (result) {
        if (result != null) {
          value.val = result;
          onChanged?.call(result);
        }
      },
    );
  }
}
