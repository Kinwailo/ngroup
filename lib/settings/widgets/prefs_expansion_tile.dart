import 'package:flutter/material.dart';

class PrefsExpansionTile extends StatelessWidget {
  const PrefsExpansionTile(
      {super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ExpansionTile(
            title: Text(title),
            controlAffinity: ListTileControlAffinity.leading,
            children: [
          ...children
              .map((e) => [const Divider(indent: 16, endIndent: 16), e])
              .expand((e) => e)
        ]));
  }
}
