import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../prefs_value.dart';

class PrefsStringTile extends HookWidget {
  const PrefsStringTile(
    this.value, {
    super.key,
    this.onChanged,
  });

  final PrefsValue<String> value;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    useListenable(value);
    return ListTile(
      title: Text(value.description ?? ''),
      subtitle: Text(value.val),
      onTap: () async {
        var result = await showTextInputDialog(
          context: context,
          title: value.prompt,
          style: AdaptiveStyle.material,
          textFields: [DialogTextField(initialText: value.val)],
        );
        if (result != null) {
          value.val = result[0];
          onChanged?.call(result[0]);
        }
      },
    );
  }
}
