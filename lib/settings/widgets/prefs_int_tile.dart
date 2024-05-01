import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../prefs_value.dart';

class PrefsIntTile extends HookWidget {
  const PrefsIntTile(
    this.value, {
    super.key,
    this.min = 0,
    this.step = 1,
    this.onChanged,
  });

  final PrefsValue<int> value;
  final int min;
  final int step;
  final Function(int)? onChanged;

  void setValue(int v) {
    if (v < min) v = min;
    value.val = v;
    onChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final delta = useValueNotifier(0.0);
    useListenable(value);
    return GestureDetector(
      onHorizontalDragStart: (_) => delta.value = 0.0,
      onHorizontalDragUpdate: (details) {
        delta.value += details.primaryDelta ?? 0.0;
        setValue(value.val + step * (delta.value ~/ 10.0));
        delta.value = delta.value.remainder(10.0);
      },
      child: ListTile(
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
                validator: (value) => int.tryParse(value!) != null
                    ? null
                    : 'Please enter a number',
              )
            ],
          );
          if (result != null) setValue(int.tryParse(result[0])!);
        },
      ),
    );
  }
}
