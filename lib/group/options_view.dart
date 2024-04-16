import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/adaptive.dart';
import '../database/models.dart';
import '../settings/prefs_tile.dart';
import '../settings/prefs_value.dart';
import '../settings/settings.dart';
import '../widgets/progress_dialog.dart';
import '../widgets/selection_dialog.dart';
import 'group_controller.dart';

class OptionsView extends ConsumerWidget {
  const OptionsView({super.key});

  static var path = 'options';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var data = ref.watch(groupDataProvider);
    return SingleChildScrollView(
      controller: ScrollController(),
      child: AdaptivePageView(
        child: data.when(
          skipLoadingOnReload: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) =>
              Center(child: Text('Error loading group options: $e')),
          data: (d) => ListView(
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              PrefsGroupTile(
                children: [
                  PrefsStringTile(d.options.display),
                  PrefsStringTile(d.options.charset),
                  IdentityTile(d.options.identity),
                ],
              ),
              PrefsGroupTile(
                children: [
                  PrefsBoolTile(d.options.autoRefresh),
                  PrefsIntTile(d.options.refreshMax),
                  PrefsBoolTile(d.options.askIfMore),
                  PrefsIntTile(d.options.keepMessage),
                ],
              ),
              PrefsGroupTile(
                children: [
                  ListTile(
                    title: const Text('Refresh silently'),
                    onTap: () => ref.read(groupDataProvider.notifier).reload(
                        ProgressDialog(context), SelectionDialog(context),
                        silently: true),
                  ),
                  ListTile(
                    title: const Text('Mark all as read'),
                    onTap: () async =>
                        ref.read(groupDataProvider.notifier).markAllRead(),
                  ),
                  ListTile(
                    title: const Text('Reset group'),
                    onTap: () => ref
                        .read(groupDataProvider.notifier)
                        .resetGroup(ProgressDialog(context)),
                  ),
                  ListTile(
                    title: const Text('Delete group'),
                    onTap: () => ref
                        .read(groupDataProvider.notifier)
                        .deleteGroup(ProgressDialog(context)),
                  ),
                  ServerTile(d.server),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServerTile extends ConsumerWidget {
  const ServerTile(this.server, {super.key});

  final Server? server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return server == null
        ? const ListTile(title: Text('Error loading server data.'))
        : ListTile(
            title: const Text('Server'),
            subtitle: Text('${server!.address}:${server!.port}'),
            trailing: IconButton(
              icon: const Icon(Icons.remove),
              splashRadius: 20,
              onPressed: () async {
                var pd = ProgressDialog(context);
                var result = await showOkCancelAlertDialog(
                  context: context,
                  title: 'Delete server',
                  message:
                      'Are you sure to delete server and all groups from this server?',
                  style: AdaptiveStyle.material,
                  defaultType: OkCancelAlertDefaultType.cancel,
                );
                if (result == OkCancelResult.ok) {
                  ref
                      .read(groupDataProvider.notifier)
                      .deleteServer(server!, pd);
                }
              },
            ),
            onTap: () async {
              var result = await showTextInputDialog(
                context: context,
                title: 'Edit server',
                style: AdaptiveStyle.material,
                textFields: [
                  DialogTextField(
                      hintText: 'Address', initialText: server!.address),
                  DialogTextField(
                    hintText: 'Port',
                    initialText: server!.port.toString(),
                    keyboardType: TextInputType.number,
                    validator: (value) => int.tryParse(value!) != null
                        ? null
                        : 'Please enter a number',
                  ),
                ],
              );
              if (result != null) {
                server!.address = result[0];
                server!.port = int.tryParse(result[1])!;
                ref.read(groupDataProvider.notifier).editServer(server!);
              }
            },
          );
  }
}

class IdentityTile extends HookWidget {
  const IdentityTile(
    this.value, {
    super.key,
  });

  final PrefsValue<int> value;

  @override
  Widget build(BuildContext context) {
    var identities = Settings.identities.val;
    var id = value.val >= identities.length ? -1 : value.val;
    Map? identity = value.val == -1 ? null : identities[id];

    useListenable(value);

    return ListTile(
      title: Text(value.description ?? ''),
      subtitle: identity == null
          ? const Text('None')
          : Text('${identity['name']} <${identity['email']}>\n'
              '${identity['signature']}'),
      isThreeLine: (identity?['signature'] ?? '') != '',
      trailing: IconButton(
          icon: const Icon(Icons.remove),
          splashRadius: 20,
          onPressed: () {
            value.val = -1;
          }),
      onTap: () async {
        var result = await (SelectionDialog(context).show(value.prompt ?? '',
            identities.map((e) => '${e['name']} <${e['email']}>').toList()));
        if (result != null) {
          value.val = result;
        }
      },
    );
  }
}
