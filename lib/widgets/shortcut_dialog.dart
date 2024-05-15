import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ShortcutDialog {
  ShortcutDialog(this.context);

  final BuildContext context;

  Future<SingleActivator?> show(String title, SingleActivator shortcut,
      {double? width, bool dismissible = true}) async {
    var theme = Theme.of(context);
    return showDialog<SingleActivator>(
      barrierDismissible: dismissible,
      context: context,
      builder: (context) => PopScope(
        canPop: dismissible,
        child: Dialog(
          child: SizedBox(
            width: width ?? 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(title, style: theme.textTheme.titleLarge),
                ),
                const Divider(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ShortcutSetting(shortcut),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShortcutSetting extends HookWidget {
  const ShortcutSetting(
    this.shortcut, {
    super.key,
  });

  final SingleActivator shortcut;

  @override
  Widget build(BuildContext context) {
    final control = useState(shortcut.control);
    final shift = useState(shortcut.shift);
    final alt = useState(shortcut.alt);
    final focusNode = useMemoized(() => FocusNode());
    focusNode.requestFocus();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ChoiceChip(
          label: const Text('Control'),
          padding: const EdgeInsets.all(0),
          selected: control.value,
          onSelected: (v) => control.value = v,
        ),
        ChoiceChip(
          label: const Text('Shift'),
          padding: const EdgeInsets.all(0),
          selected: shift.value,
          onSelected: (v) => shift.value = v,
        ),
        ChoiceChip(
          label: const Text('Alt'),
          padding: const EdgeInsets.all(0),
          selected: alt.value,
          onSelected: (v) => alt.value = v,
        ),
        Focus(
          focusNode: focusNode,
          onKeyEvent: (_, e) {
            var s = SingleActivator(e.logicalKey,
                control: control.value,
                shift: shift.value,
                alt: alt.value,
                includeRepeats: shortcut.includeRepeats);
            Navigator.pop<SingleActivator>(context, s);
            return KeyEventResult.handled;
          },
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Text('Press a key'),
          ),
        ),
      ],
    );
  }
}
