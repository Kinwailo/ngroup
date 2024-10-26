import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/adaptive.dart';
import '../group/group_controller.dart';
import '../sync/cloud_settings_tile.dart';
import '../sync/google_drive.dart';
import 'prefs_tile.dart';
import 'prefs_value.dart';
import 'settings.dart';

class SettingsView extends HookConsumerWidget {
  const SettingsView({super.key});

  static var path = 'settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var colorScheme = Theme.of(context).colorScheme;
    useListenable(GoogleDrive.i);
    return DefaultTabController(
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: colorScheme.tertiaryContainer,
            child: const Center(
              child: TabBar(
                isScrollable: true,
                indicatorWeight: 1,
                tabs: [
                  Tab(text: 'General', height: 32),
                  Tab(text: 'Read', height: 32),
                  Tab(text: 'Sync', height: 32),
                  Tab(text: 'Link', height: 32),
                  Tab(text: 'Navigation', height: 32),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                SettingsTabChild(
                  children: [
                    PrefsGroupTile(
                      children: [
                        PrefsEnumTile(Settings.theme),
                        if (!kIsWeb && Adaptive.isDesktop)
                          PrefsBoolTile(Settings.customFrame),
                        if (!Adaptive.isDesktop || Adaptive.forceMobile)
                          PrefsBoolTile(Settings.twoPane),
                        if (kIsWeb)
                          PrefsBoolTile(Settings.disableWebContextMenu),
                        if (kIsWeb)
                          PrefsIntTile(Settings.webappMaxWidth,
                              min: 800, step: 50),
                        if (!kIsWeb) PrefsBoolTile(Settings.useHTTPBridge),
                        PrefsEnumTile(Settings.sortMode),
                        PrefsEnumTile(Settings.htmlMode),
                        PrefsBoolTile(Settings.jumpTop),
                      ],
                    ),
                    PrefsShortcutsTile(children: [
                      PrefsShortcutTile(Settings.shortcutRefresh),
                      PrefsShortcutTile(Settings.shortcutMarkAllRead),
                      PrefsShortcutTile(Settings.shortcutSmartNext),
                    ]),
                    PrefsGroupTile(children: [
                      PrefsIdentitiesTile(
                        Settings.identities,
                        onRemoved: ref
                            .read(groupDataProvider.notifier)
                            .identityRemoved,
                      ),
                    ]),
                    PrefsGroupTile(children: [
                      PrefsPatternsTile(Settings.blockSenders),
                    ]),
                  ],
                ),
                SettingsTabChild(
                  children: [
                    PrefsGroupTile(children: [
                      PrefsIntTile(Settings.contentScale, min: 80, step: 5),
                      PrefsBoolTile(Settings.convertChinese),
                      PrefsEnumTile(Settings.showQuote),
                      PrefsBoolTile(Settings.shortReply),
                      PrefsIntTile(Settings.shortReplySize, min: 10),
                    ]),
                    PrefsStripTile(
                      Settings.stripText,
                      children: [
                        PrefsPatternsTile(Settings.stripSignature),
                        PrefsBoolTile(Settings.stripQuote),
                        PrefsBoolTile(Settings.stripSameContent),
                        PrefsBoolTile(Settings.stripMultiEmptyLine),
                        PrefsBoolTile(Settings.stripUnicodeEmojiModifier),
                        PrefsPatternsTile(Settings.stripCustomPattern),
                      ],
                    ),
                    PrefsGroupTile(children: [
                      PrefsIntTile(Settings.attachmentSize,
                          min: 1000, step: 1000),
                      PrefsIntTile(Settings.hideText, min: 5),
                      PrefsIntTile(Settings.chopQuote, min: 50, step: 50),
                      PrefsBoolTile(Settings.smallPreview),
                    ]),
                  ],
                ),
                SettingsTabChild(
                  children: [
                    PrefsGroupTile(children: [
                      const GoogleDriveSignInTile(),
                      PrefsBoolTile(Settings.autoLoginCloud),
                    ]),
                    if (GoogleDrive.i.isLoggedIn) ...[
                      const CloudGroupListTile(),
                    ],
                  ],
                ),
                SettingsTabChild(
                  children: [
                    PrefsGroupTile(children: [
                      PrefsBoolTile(Settings.showLinkPreview),
                      PrefsBoolTile(Settings.embedLinkPreview),
                      PrefsBoolTile(Settings.showLinkedImage),
                      PrefsBoolTile(Settings.embedLinkedImage),
                      PrefsIntTile(Settings.linkedImageMaxWidth,
                          min: 50, step: 50),
                    ]),
                  ],
                ),
                SettingsTabChild(
                  children: [
                    PrefsGroupTile(children: [
                      PrefsBoolTile(Settings.unreadOnNext),
                      PrefsBoolTile(Settings.threadOnNext),
                      PrefsBoolTile(Settings.nextTitle),
                      PrefsEnumTile(Settings.nextThreadMode),
                      PrefsEnumTile(Settings.nextThreadDirection),
                      const ListTile(
                          title: Text('Tips on next thread'),
                          subtitle: Text(
                              'You can long press the next button to toggle direction, pull from the top to perform next action.\n')),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsTabChild extends StatelessWidget {
  const SettingsTabChild({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: AdaptivePageView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...children,
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class PrefsShortcutsTile extends HookWidget {
  const PrefsShortcutsTile({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ExpansionTile(
            title: const Text('Shortcuts'),
            controlAffinity: ListTileControlAffinity.leading,
            children: [
          ...children
              .map((e) => [const Divider(indent: 16, endIndent: 16), e])
              .expand((e) => e)
        ]));
  }
}

class PrefsStripTile extends HookWidget {
  const PrefsStripTile(
    this.value, {
    super.key,
    required this.children,
  });

  final PrefsValue<bool> value;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    useListenable(value);
    return Card(
        child: ExpansionTile(
            title: Text(value.description!),
            trailing:
                Checkbox(value: value.val, onChanged: (v) => value.val = v!),
            controlAffinity: ListTileControlAffinity.leading,
            children: [
          ...children
              .map((e) => [const Divider(indent: 16, endIndent: 16), e])
              .expand((e) => e)
        ]));
  }
}
