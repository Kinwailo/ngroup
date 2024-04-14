import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../database/models.dart';
import '../settings/settings.dart';
import 'group_controller.dart';
import 'group_options.dart';

class GroupReorder {
  GroupReorder(this.context);

  final BuildContext context;

  Future<int?> show(List<Group> groups,
      {double? width, bool dismissible = true}) async {
    var theme = Theme.of(context);
    return showDialog<int>(
      barrierDismissible: dismissible,
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          return PopScope(
            canPop: dismissible,
            onPopInvoked: (didPop) => ref.invalidate(groupListProvider),
            child: Dialog(
              child: SizedBox(
                width: width ?? 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Text('Group Reorder',
                          style: theme.textTheme.titleLarge),
                    ),
                    const Divider(),
                    Flexible(
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return ReorderableListView(
                            shrinkWrap: true,
                            buildDefaultDragHandles: false,
                            scrollController: ScrollController(),
                            onReorder: (int oldIndex, int newIndex) {
                              if (oldIndex < newIndex) newIndex--;
                              groups.insert(
                                  newIndex, groups.removeAt(oldIndex));
                              Settings.groupOrder.val =
                                  groups.map((e) => e.id!).toList();
                              setState(() {});
                            },
                            children: groups
                                .map((e) => (e, GroupOptions(e)))
                                .mapIndexed((i, e) =>
                                    ReorderableDragStartListener(
                                      key: ValueKey(e.$1.name),
                                      index: i,
                                      child: ListTile(
                                        dense: true,
                                        visualDensity: VisualDensity
                                            .adaptivePlatformDensity,
                                        title: Center(
                                            child: Text(
                                          e.$2.display.val,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleMedium,
                                        )),
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
