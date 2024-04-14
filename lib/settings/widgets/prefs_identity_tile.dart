import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../widgets/selection_dialog.dart';
import '../prefs_value.dart';

class PrefsIdentityTile extends HookWidget {
  const PrefsIdentityTile(
    this.value,
    this.list, {
    super.key,
    this.onChanged,
  });

  final PrefsValue<Map> value;
  final List<dynamic> list;
  final Function(Map<String, String>)? onChanged;

  @override
  Widget build(BuildContext context) {
    useListenable(value);
    return ListTile(
      title: Text(value.description ?? ''),
      subtitle: value.val['name'] == ''
          ? const Text('None')
          : Text('${value.val['name']} <${value.val['email']}>\n'
              '${value.val['signature']}'),
      isThreeLine: value.val['signature'] != '',
      trailing: IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            value.val = value.defaultValue;
            onChanged?.call(value.val.cast());
          }),
      onTap: () async {
        var result = await (SelectionDialog(context).show(value.prompt ?? '',
            list.map((e) => '${e['name']} <${e['email']}>').toList()));
        if (result != null) {
          value.val = list[result];
          onChanged?.call(value.val.cast());
        }
      },
    );
  }
}
