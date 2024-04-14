import 'package:flutter/material.dart';

class PrefsGroupTile extends StatelessWidget {
  const PrefsGroupTile({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: children.length,
        itemBuilder: (_, index) {
          return children[index];
        },
        separatorBuilder: (_, index) {
          return const Divider(indent: 16, endIndent: 16);
        },
      ),
    );
  }
}
