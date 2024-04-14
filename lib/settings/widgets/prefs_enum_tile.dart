import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:recase/recase.dart';

import '../../widgets/selection_dialog.dart';
import '../prefs_value.dart';

class PrefsEnumTile extends HookWidget {
  const PrefsEnumTile(
    this.value, {
    super.key,
    this.onChanged,
  });

  final PrefsEnum value;
  final Function(Enum)? onChanged;

  @override
  Widget build(BuildContext context) {
    useListenable(value);
    return ListTile(
      title: Text(value.description ?? ''),
      subtitle: Text(value.val.name.titleCase),
      onTap: () async {
        var result = await (SelectionDialog(context).show(value.prompt ?? '',
            value.values.map((e) => e.name.titleCase).toList()));
        if (result != null) {
          value.val = value.values[result];
          onChanged?.call(value.val);
        }
      },
    );
  }
}
