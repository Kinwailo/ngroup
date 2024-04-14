import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/adaptive.dart';
import '../core/theme.dart';
import '../core/filter.dart';
import '../group/group_controller.dart';
import '../widgets/selection_dialog.dart';
import 'filter_controller.dart';

class FilterBar extends HookConsumerWidget {
  const FilterBar(this.controller, {super.key})
      : thread = true,
        post = true;

  const FilterBar.thread(this.controller, {super.key})
      : thread = true,
        post = false;

  const FilterBar.post(this.controller, {super.key})
      : thread = false,
        post = true;

  final FilterController controller;
  final bool thread;
  final bool post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    var noGroup = ref.watch(selectedGroupProvider) == -1;
    var en = controller.enabled;
    if (thread && !post) en = controller.enThread;
    if (!thread && post) en = controller.enPost;
    useListenable(controller);
    return AnimatedSwitcher(
      duration: Durations.short4,
      transitionBuilder: (child, anime) =>
          SizeTransition(sizeFactor: anime, child: child),
      child: !en || noGroup
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(2),
              color: theme.colorScheme.secondaryContainer,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: ScrollController(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ActionChipItems([
                      if (thread && post)
                        (
                          Icons.view_headline,
                          controller.enThread,
                          () => controller.toggleThreadFilter(true),
                        ),
                      if (thread && post)
                        (
                          Icons.chat,
                          controller.enPost,
                          () => controller.togglePostFilter(true),
                        ),
                      if (thread || !post)
                        (
                          FontAwesomeIcons.solidCommentDots,
                          controller.allPost,
                          controller.toggleAllPost,
                        ),
                    ]),
                    ...controller.filters
                        .where((f) =>
                            (controller.enThread ? f.useInThread : false) ||
                            (controller.enPost ? f.useInPost : false))
                        .map(
                          (e) => AnimatedSize(
                              clipBehavior: Clip.none,
                              duration: Durations.short2,
                              child: FilterChipItem(controller, e)),
                        ),
                  ],
                ),
              ),
            ),
    );
  }
}

class ActionChipItems extends HookConsumerWidget {
  const ActionChipItems(this.items, {super.key});

  final List<(IconData, bool, VoidCallback)> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var chipTheme = Theme.of(context).chipTheme;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(6, 2, 2, 2),
      color: chipTheme.backgroundColor,
      shadowColor: colorScheme.shadow,
      shape: StadiumBorder(
          side: BorderSide(color: colorScheme.outline.withOpacity(0.12))),
      child: Row(
        children: [
          ...items.mapIndexed((i, e) {
            var (icon, en, onTap) = e;
            return InkWell(
              onTap: onTap,
              child: Ink(
                color: en ? chipTheme.selectedColor : chipTheme.backgroundColor,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      i == 0 ? 8 : 6, 4, i >= items.length - 1 ? 8 : 6, 4),
                  child: Icon(icon, size: 16),
                ),
              ),
            );
          }).expandIndexed((i, e) sync* {
            if (i == 0) {
              yield e;
            } else {
              var en = items[i - 1].$2 && items[i].$2;
              var en2 = items[i - 1].$2 || items[i].$2;
              yield Container(
                  width: 1,
                  height: 24,
                  color:
                      en ? chipTheme.selectedColor : chipTheme.backgroundColor,
                  child: Center(
                    child: SizedBox(
                      height: 18,
                      child: VerticalDivider(
                        width: 1,
                        color: en2
                            ? colorScheme.surface.withOpacity(0.4)
                            : colorScheme.outline.withOpacity(0.4),
                      ),
                    ),
                  ));
              yield e;
            }
          }),
        ],
      ),
    );
  }
}

class FilterChipItem extends HookConsumerWidget {
  const FilterChipItem(this.controller, this.filter, {super.key});

  final FilterController controller;
  final Filter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    var theme = Theme.of(context).extension<NGroupTheme>()!;
    var chipTheme = Theme.of(context).chipTheme;
    var parameter = filter is! FilterParam ? null : filter as FilterParam;

    useListenable(filter);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(6, 2, 2, 2),
      color:
          filter.enabled ? chipTheme.selectedColor : chipTheme.backgroundColor,
      shadowColor: colorScheme.shadow,
      shape: StadiumBorder(
          side: BorderSide(
              color: filter.enabled
                  ? colorScheme.outline.withOpacity(0.12)
                  : colorScheme.surface.withOpacity(0.12))),
      child: InkWell(
        onTap: () => filter.toggle(),
        onSecondaryTap: () => filter.enabled = !filter.enabled,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 6, vertical: Adaptive.isDesktop ? 2 : 4),
          child: Row(
            children: [
              if (filter.enabled)
                Icon(filter.invert ? Icons.block : Icons.done, size: 16),
              const SizedBox(width: 2),
              Text(filter.name),
              if (parameter != null) ...[
                if (parameter.mode == FilterModes.between) ...[
                  GestureDetector(
                    onTap: () => showStartDateDialog(context, parameter),
                    child: Text(' ${parameter.paramString2}',
                        style: TextStyle(color: theme.sender)),
                  ),
                ],
                GestureDetector(
                  onTap: () => showModeDialog(context, parameter),
                  child: Text(' ${parameter.mode.text} ',
                      style: TextStyle(color: theme.sender)),
                ),
                GestureDetector(
                  onTap: () => showParameterDialog(context, parameter),
                  child: Text(parameter.paramString,
                      style: TextStyle(color: theme.sender)),
                ),
              ],
              const SizedBox(width: 2),
            ],
          ),
        ),
      ),
    );
  }

  void showModeDialog(BuildContext context, FilterParam parameter) async {
    var result = await SelectionDialog(context)
        .show('Filter ${filter.name}', parameter.modes);
    if (result != null) {
      parameter.setMode(result);
    }
  }

  void showStartDateDialog(BuildContext context, FilterParam parameter) async {
    var value = parameter.param as DateTimeRange;
    var result = await showDatePicker(
        context: context,
        initialDate: value.start,
        firstDate: DateTime.utc(1900),
        lastDate: DateTime.utc(2100));
    if (result != null) {
      var end = value.end.isAfter(result) ? value.end : result;
      parameter.param = DateTimeRange(start: result, end: end);
    }
  }

  void showParameterDialog(BuildContext context, FilterParam parameter) async {
    switch (parameter.param) {
      case String value:
        var result = await showTextInputDialog(
          context: context,
          title: 'Filter ${filter.name}',
          style: AdaptiveStyle.material,
          textFields: [
            DialogTextField(hintText: filter.name, initialText: value),
          ],
        );
        if (result != null) parameter.param = result[0];
        break;
      case int value:
        var result = await showTextInputDialog(
          context: context,
          title: 'Filter ${filter.name}',
          style: AdaptiveStyle.material,
          textFields: [
            DialogTextField(
              initialText: '$value',
              keyboardType: TextInputType.number,
              validator: (value) =>
                  int.tryParse(value!) != null ? null : 'Please enter a number',
            )
          ],
        );
        if (result != null) parameter.param = int.tryParse(result[0])!;
        break;
      case DateTimeRange value:
        var result = await showDatePicker(
            context: context,
            initialDate: value.end,
            firstDate: DateTime.utc(1900),
            lastDate: DateTime.utc(2100));
        if (result != null) {
          var start = value.start.isBefore(result) ? value.start : result;
          parameter.param = DateTimeRange(start: start, end: result);
        }
      default:
    }
  }
}
