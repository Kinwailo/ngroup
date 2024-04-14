import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../prefs_value.dart';

class PrefsIntTile extends HookWidget {
  const PrefsIntTile(
    this.value, {
    super.key,
    this.onChanged,
  });

  final PrefsValue<int> value;
  final Function(int)? onChanged;

  @override
  Widget build(BuildContext context) {
    useListenable(value);
    return ListTile(
      title: Text(value.description ?? ''),
      subtitle: Text(value.val.toString()),
      onTap: () async {
        var result = await showTextInputDialog(
          context: context,
          title: value.prompt,
          style: AdaptiveStyle.material,
          textFields: [
            DialogTextField(
              initialText: value.val.toString(),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  int.tryParse(value!) != null ? null : 'Please enter a number',
            )
          ],
        );
        if (result != null) {
          value.val = int.tryParse(result[0])!;
          onChanged?.call(value.val);
        }
      },
    );
  }
}
