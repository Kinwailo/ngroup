import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/adaptive.dart';
import '../database/database.dart';
import '../database/models.dart';
import '../home/home_controller.dart';
import '../nntp/nntp.dart';
import '../nntp/nntp_service.dart';
import '../post/thread_view.dart';
import 'group_controller.dart';
import 'group_options.dart';
import 'options_view.dart';

final serversProvider = StreamProvider<List<Server>>((ref) {
  return AppDatabase.get.serverListStream();
});

final selectedServerProvider = StateProvider<int>((ref) {
  ref.watch(serversProvider);
  return -1;
});

final stepProvider = NotifierProvider<StepNotifier, int>(StepNotifier.new);

final selectionProvider =
    AsyncNotifierProvider<SelectionNotifier, Map<GroupInfo, bool>>(
        SelectionNotifier.new);

class StepNotifier extends Notifier<int> {
  void Function()? onBack;
  void Function()? onFinish;

  @override
  int build() {
    return 0;
  }

  String get nextLabel {
    return state < 2 ? 'Next' : 'Save';
  }

  String get cancelLabel {
    return state == 0 ? 'Cancel' : 'Back';
  }

  Function()? get onNext {
    var selection = ref.read(selectionProvider);
    if (state == 2) {
      if (selection.hasValue && selection.requireValue.values.any((e) => e)) {
        return nextStep;
      }
      return null;
    }
    return state == 1 && (selection.hasError || selection.isLoading)
        ? null
        : nextStep;
  }

  Function()? get onCancel {
    var selection = ref.read(selectionProvider);
    var groups = ref.read(groupListProvider);
    var cancel = groups.hasValue && groups.requireValue.isNotEmpty;
    if (state == 1) return selection.isLoading ? null : cancelStep;
    return state > 0 || cancel ? cancelStep : null;
  }

  StepState stepState(int step) {
    if (step == 1 && ref.read(selectionProvider).hasError) {
      return StepState.error;
    }
    if (step == state) return StepState.editing;
    if (step < state) return StepState.complete;
    if (step > state) return StepState.disabled;
    return StepState.indexed;
  }

  bool isStepActive(int step) {
    return step <= state;
  }

  void cancelStep() {
    ref.read(selectionProvider.notifier).reset();
    switch (state) {
      case 0:
        if (ref.read(selectedGroupProvider) != -1) _close();
        break;
      case 1:
        state--;
        break;
      case 2:
        state -= 2;
        break;
      default:
    }
  }

  Future<void> nextStep() async {
    switch (state) {
      case 0:
        state++;
        await ref.read(selectionProvider.notifier).connect();
        break;
      case 1:
        if (!ref.read(selectionProvider).hasError) state++;
        break;
      case 2:
        var group = await ref.read(selectionProvider.notifier).addGroups();
        ref.read(selectedGroupProvider.notifier).selectGroup(group?.id! ?? -1);
        _close();
        state = 0;
      default:
    }
  }

  void _close() {
    Adaptive.useTwoPaneUI
        ? ref.read(rightNavigator).goto(OptionsView.path)
        : ref.read(leftNavigator).goto(ThreadView.path);
  }
}

class SelectionNotifier extends AsyncNotifier<Map<GroupInfo, bool>> {
  NNTPService? _nntp;
  final Map<GroupInfo, bool> _selectionMap = {};

  Server server = Server()
    ..address = ''
    ..port = -1;
  String charset = '';

  var addressFocusNode = FocusNode();
  var portFocusNode = FocusNode();
  var userFocusNode = FocusNode();
  var passwordFocusNode = FocusNode();
  var charsetFocusNode = FocusNode();
  var filterFocusNode = FocusNode();

  @override
  FutureOr<Map<GroupInfo, bool>> build() => {};

  Future<void> connect() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _connect();
    });
  }

  Future<Map<GroupInfo, bool>> _connect() async {
    _nntp = await NNTPService.connect(server);

    _selectionMap.clear();
    var list = await _nntp!.getGroupList();
    list = list
        .map((e) => e
          ..display = charset.isEmpty
              ? e.name
              : Charset.decode(latin1.encode(e.name), charset))
        .sorted((a, b) => a.name.compareTo(b.name));
    _selectionMap.addAll({for (var item in list) item: false});

    return _selectionMap;
  }

  Set<FocusNode> getAllFocusNode() {
    return <FocusNode>{
      addressFocusNode,
      portFocusNode,
      userFocusNode,
      passwordFocusNode,
      charsetFocusNode,
      filterFocusNode,
    };
  }

  void reset() {
    _selectionMap.clear();
    state = AsyncData(_selectionMap);
  }

  void toggle(GroupInfo key) {
    _selectionMap.update(key, (value) => !value);
    state = AsyncData(_selectionMap);
  }

  Future<Group?> addGroups() async {
    var list = state.requireValue.entries
        .where((e) => e.value)
        .map((e) {
          var group = Group()
            ..name = e.key.name
            ..serverId = e.key.serverId;
          var options = GroupOptions(group)
            ..display.val = e.key.display
            ..charset.val = charset;
          return group..options = options.json;
        })
        .cast<Group>()
        .toList();
    list = await _nntp!.addGroups(list);
    return list.firstOrNull;
  }
}
