import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../prefs_value.dart';

class PrefsPatternsTile extends HookWidget {
  const PrefsPatternsTile(
    this.value, {
    super.key,
    this.onChanged,
  });

  final PrefsValue<List> value;
  final Function(List<String>)? onChanged;

  @override
  Widget build(BuildContext context) {
    useListenable(value);
    return ListTile(
      title: Text(value.description ?? ''),
      subtitle: value.val.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ...value.val.cast<String>().asMap().entries.map(
                        (e) => GestureDetector(
                          onTap: () {
                            showDialog(context, e.value, (v) {
                              value.val[e.key] = v;
                              value.update();
                              onChanged?.call(value.val.cast());
                            });
                          },
                          child: Chip(
                            label: Text(e.value),
                            labelPadding: const EdgeInsets.only(left: 4),
                            elevation: 2,
                            onDeleted: () {
                              value.val.removeAt(e.key);
                              value.update();
                              onChanged?.call(value.val.cast());
                            },
                          ),
                        ),
                      )
                ],
              ),
            ),
      trailing: IconButton(
        splashRadius: 20,
        icon: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context,
            '',
            (v) {
              value.val.add(v);
              value.update();
              onChanged?.call(value.val.cast());
            },
          );
        },
      ),
    );
  }

  void showDialog(
      BuildContext context, String text, void Function(String) callback) async {
    var result = await showTextInputDialog(
      context: context,
      title: value.prompt,
      style: AdaptiveStyle.material,
      textFields: [DialogTextField(initialText: text)],
    );
    if (result != null) {
      callback.call(result[0]);
    }
  }
}
