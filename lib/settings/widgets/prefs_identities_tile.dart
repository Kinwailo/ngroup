import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../prefs_value.dart';

class PrefsIdentitiesTile extends HookWidget {
  const PrefsIdentitiesTile(
    this.value, {
    super.key,
    this.onChanged,
    this.onAdded,
    this.onRemoved,
  });

  final PrefsValue<List> value;
  final Function(List<Map>)? onChanged;
  final Function(Map)? onAdded;
  final Function(int)? onRemoved;

  @override
  Widget build(BuildContext context) {
    useListenable(value);
    return ExpansionTile(
      title: Text(value.description ?? ''),
      controlAffinity: ListTileControlAffinity.leading,
      trailing: IconButton(
        splashRadius: 20,
        icon: const Icon(Icons.add),
        onPressed: () {
          showDialog(context, '', '', '', (v) {
            var data = {'name': v[0], 'email': v[1], 'signature': v[2]};
            value.val.add(data);
            value.update();
            onAdded?.call(data);
          });
        },
      ),
      children: [
        ...value.val
            .cast<Map>()
            .asMap()
            .entries
            .map((e) => [
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    title: Text('${e.value['name']} <${e.value['email']}>'),
                    subtitle: Text(e.value['signature']),
                    onTap: () {
                      showDialog(context, e.value['name'], e.value['email'],
                          e.value['signature'], (v) {
                        value.val[e.key] = {
                          'name': v[0],
                          'email': v[1],
                          'signature': v[2],
                        };
                        value.update();
                        onChanged?.call(value.val.cast());
                      });
                    },
                    trailing: IconButton(
                        icon: const Icon(Icons.remove),
                        splashRadius: 20,
                        onPressed: () {
                          onRemoved?.call(e.key);
                          value.val.removeAt(e.key);
                          value.update();
                        }),
                  )
                ])
            .expand((e) => e)
      ],
    );
  }

  void showDialog(BuildContext context, String name, String email,
      String signature, void Function(List<String>) callback) async {
    var result = await showTextInputDialog(
      context: context,
      title: value.prompt,
      style: AdaptiveStyle.material,
      textFields: [
        DialogTextField(hintText: 'Name', initialText: name),
        DialogTextField(hintText: 'Email', initialText: email),
        DialogTextField(
            hintText: 'Signature', initialText: signature, maxLines: 5),
      ],
    );
    if (result != null) {
      callback.call(result);
    }
  }
}
