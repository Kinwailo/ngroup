import 'package:flutter/material.dart';

class SelectionDialog {
  SelectionDialog(this.context);

  final BuildContext context;

  Future<int?> show(String title, List<String> items,
      {double? width, bool dismissible = true}) async {
    var theme = Theme.of(context);
    return showDialog<int>(
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
                Flexible(
                  child: ListView(
                    controller: ScrollController(),
                    shrinkWrap: true,
                    children: items
                        .asMap()
                        .entries
                        .map((e) => ListTile(
                              title: Text(e.value),
                              onTap: () {
                                Navigator.pop<int>(context, e.key);
                              },
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
