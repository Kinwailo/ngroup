import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_sign_in/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../settings/prefs_tile.dart';
import 'cloud_controller.dart';
import 'google_drive.dart';
import 'google_button_web.dart' if (dart.library.io) 'google_button_stub.dart';

class GoogleDriveSignInTile extends HookWidget {
  const GoogleDriveSignInTile({super.key});

  @override
  Widget build(BuildContext context) {
    useListenable(GoogleDrive.i);
    useListenable(GoogleDrive.i.syncing);
    return !GoogleDrive.i.isLoggedIn
        ? ListTile(
            title: const Text('Google Drive'),
            subtitle: kIsWeb ? null : const Text('Sign in'),
            trailing: kIsWeb ? googleSignInButton() : null,
            onTap: kIsWeb ? null : GoogleDrive.i.signIn,
          )
        : ListTile(
            leading: GoogleUserCircleAvatar(identity: GoogleDrive.i.user!),
            title: Text(GoogleDrive.i.user!.displayName ?? ''),
            subtitle: const Text('Sign out'),
            trailing: !GoogleDrive.i.syncing.value
                ? null
                : const CircularProgressIndicator(),
            onTap: GoogleDrive.i.signOut,
          );
  }
}

class CloudGroupListTile extends HookConsumerWidget {
  const CloudGroupListTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var cloud = ref.read(cloudProvider);
    var selected = useState(<String, DataEntry>{});
    var all = useState(false);
    var local = cloud.getGroupList(cloud.localData.value);
    var common = cloud.getCommonGroups();
    var groups = useValueNotifier(<DataEntry>[]);
    groups.value = [
      ...local,
      ...cloud
          .getGroupList(cloud.cloudData.value)
          .whereNot((e) => common.contains(cloud.getGroupId(e)))
    ];
    useEffect(() {
      cloud.loadLocalData();
      cloud.loadCloudData();
      return null;
    }, []);
    useListenable(cloud.localData);
    useListenable(cloud.cloudData);
    return PrefsExpansionTile(
      selected: all.value,
      title: 'Groups',
      onSelected: (bool? v) {
        all.value = v!;
        v
            ? selected.value = {
                for (var e in groups.value) cloud.getGroupId(e): e
              }
            : selected.value = {};
      },
      children: [
        if (groups.value.isNotEmpty)
          ListTile(
            title: OutlinedButtonTheme(
              data: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact)),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.devices, size: 16),
                        Icon(Icons.arrow_right, size: 16),
                        Icon(Icons.cloud, size: 16),
                      ],
                    ),
                    onPressed: () => cloud.syncToCloud(selected.value),
                  ),
                  OutlinedButton(
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.devices, size: 16),
                        Icon(Icons.arrow_left, size: 16),
                        Icon(Icons.cloud, size: 16),
                      ],
                    ),
                    onPressed: () => cloud.syncFromCloud(selected.value),
                  ),
                  OutlinedButton(
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete, size: 16),
                        Icon(Icons.arrow_left, size: 16),
                        Icon(Icons.cloud, size: 16),
                      ],
                    ),
                    onPressed: () => cloud.deleteOnCloud(selected.value),
                  ),
                ],
              ),
            ),
          ),
        ...groups.value.map((e) {
          var id = cloud.getGroupId(e);
          var onDevice = local.map((l) => cloud.getGroupId(l)).contains(id);
          var onCloud = common.contains(id) || !onDevice;
          return CheckboxListTile(
            title: Text(cloud.getGroupDisplay(e)),
            subtitle: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('${e['server']}'),
                if (onDevice) const Icon(Icons.devices, size: 16),
                if (onCloud) const Icon(Icons.cloud, size: 16),
              ],
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            value: selected.value.containsKey(id),
            onChanged: (bool? value) => selected.value = value!
                ? {...selected.value..update(id, (_) => e, ifAbsent: () => e)}
                : {...selected.value..remove(id)},
          );
        })
      ],
    );
  }
}

class GroupImportTile extends HookConsumerWidget {
  const GroupImportTile({super.key, this.onSelected});

  final void Function(Map<String, DataEntry> value)? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var cloud = ref.read(cloudProvider);
    var selected = useState(<String, DataEntry>{});
    var all = useState(false);
    var groups = useValueNotifier(<DataEntry>[]);
    groups.value = cloud.getGroupList(cloud.cloudData.value);
    useEffect(() {
      cloud.loadCloudData();
      return null;
    }, []);
    useListenable(cloud.cloudData);
    return PrefsExpansionTile(
      selected: all.value,
      title: 'Groups',
      onSelected: (bool? v) {
        all.value = v!;
        v
            ? selected.value = {
                for (var e in groups.value) cloud.getGroupId(e): e
              }
            : selected.value = {};
        onSelected?.call(selected.value);
      },
      children: [
        ...groups.value.map((e) {
          var id = cloud.getGroupId(e);
          return CheckboxListTile(
            title: Text(cloud.getGroupDisplay(e)),
            subtitle: Text('${e['server']}'),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            value: selected.value.containsKey(id),
            onChanged: (bool? value) {
              selected.value = value!
                  ? {...selected.value..update(id, (_) => e, ifAbsent: () => e)}
                  : {...selected.value..remove(id)};
              onSelected?.call(selected.value);
            },
          );
        })
      ],
    );
  }
}
