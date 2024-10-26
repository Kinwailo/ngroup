import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PrefsExpansionTile extends HookWidget {
  const PrefsExpansionTile({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.selected,
    this.onSelected,
    required this.children,
  });

  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final bool? selected;
  final List<Widget> children;
  final void Function(bool value)? onSelected;

  @override
  Widget build(BuildContext context) {
    var checked = useState(selected);
    var callback = useCallback((_) {
      checked.value = !checked.value!;
      onSelected?.call(checked.value!);
    });
    useValueChanged(selected, (_, void __) => checked.value = selected);
    return Card(
        child: ExpansionTile(
            initiallyExpanded: true,
            leading: leading,
            title: Text(title ?? ''),
            trailing: trailing ??
                (checked.value == null
                    ? null
                    : Checkbox(value: checked.value, onChanged: callback)),
            controlAffinity: ListTileControlAffinity.leading,
            children: [
          ...children
              .map((e) => [const Divider(indent: 16, endIndent: 16), e])
              .expand((e) => e)
        ]));
  }
}
