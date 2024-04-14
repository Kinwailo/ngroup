import 'dart:convert';

import '../database/database.dart';
import '../database/models.dart';
import '../settings/prefs_value.dart';

class GroupOptions {
  late _OptionsStorage _storage;

  late PrefsValue<int> lastView;
  late PrefsValue<int> lastDownload;

  late PrefsValue<String> display;
  late PrefsValue<String> charset;
  late PrefsValue<int> identity;
  late PrefsValue<bool> autoRefresh;
  late PrefsValue<int> refreshMax;
  late PrefsValue<bool> askIfMore;
  late PrefsValue<int> keepMessage;

  GroupOptions(Group group) {
    _storage = _OptionsStorage(group);

    lastView = PrefsValue('lastView', -1, _storage);
    lastDownload = PrefsValue('lastDownload', -1, _storage);

    display = PrefsValue(
      'display',
      '',
      _storage,
      description: 'Display name',
      prompt: 'Enter the display name',
      // onChanged: (v) => GroupController.to.name.value = v,
    );

    charset = PrefsValue(
      'charset',
      '',
      _storage,
      description: 'Fallback charset',
      prompt: 'Enter the charset name',
    );

    identity = PrefsValue(
      'identity',
      -1,
      _storage,
      description: 'Default identity',
      prompt: 'Select the identity',
    );

    autoRefresh = PrefsValue(
      'autoRefresh',
      false,
      _storage,
      description: 'Refresh when select group',
    );

    refreshMax = PrefsValue(
      'refreshMax',
      3000,
      _storage,
      description: 'Maximum messages to download',
      prompt: 'Enter the value',
    );

    askIfMore = PrefsValue(
      'askIfMore',
      false,
      _storage,
      description: 'Ask if more message to download',
    );

    keepMessage = PrefsValue(
      'keepMessage',
      3000,
      _storage,
      description: 'Keep messages on local storage',
      prompt: 'Enter the value',
    );
  }
}

class _OptionsStorage implements PrefsStorage {
  late int _id;
  late Map<String, dynamic> _options;

  _OptionsStorage(Group group) {
    _id = group.id!;
    if (group.options.isEmpty) group.options = '{}';
    _options = jsonDecode(group.options);
    _options.putIfAbsent('display', () => jsonEncode(group.name));
  }

  @override
  String? load(String key) {
    return _options[key];
  }

  @override
  void save(String key, String value) async {
    _options[key] = value;
    var group = await Database.getGroup(_id);
    group!.options = jsonEncode(_options);
    await Database.updateGroup(group);
  }
}
