import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../widgets/shortcut_dialog.dart';
import '../prefs_value.dart';

class PrefsShortcutTile extends HookWidget {
  const PrefsShortcutTile(
    this.value, {
    super.key,
    this.onChanged,
  });

  final PrefsValue<SingleActivator> value;
  final Function(SingleActivator)? onChanged;

  @override
  Widget build(BuildContext context) {
    var keys = [
      if (value.val.control) 'Control',
      if (value.val.shift) 'Shift',
      if (value.val.alt) 'Alt',
      value.val.trigger.keyLabel,
    ];
    useListenable(value);
    return ListTile(
      title: Text(value.description ?? ''),
      subtitle: Text(keys.join(' + ')),
      onTap: () async {
        var result =
            await (ShortcutDialog(context).show(value.prompt ?? '', value.val));
        if (result != null) {
          value.val = result;
          onChanged?.call(value.val);
        }
      },
    );
  }
}
