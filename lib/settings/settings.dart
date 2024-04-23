import 'package:flutter/material.dart';

import '../database/database.dart';
import '../database/models.dart';
import 'prefs_value.dart';

class Identity {
  var name = '';
  var email = '';
  var signature = '';
}

enum ShowQuote { always, smart, never }

enum NextThread { next, nextWithUnread, nextWithNew }

enum NextDirection { newer, older }

enum SortMode { hierarchy, order }

class Settings {
  static final _storage = _SettingsStorage();

  static Future<void> init() async {
    await _SettingsStorage.init();
  }

  static var width = PrefsValue('width', 800.0, _storage);
  static var height = PrefsValue('height', 600.0, _storage);
  static var left = PrefsValue('left', 50.0, _storage);
  static var top = PrefsValue('top', 50.0, _storage);
  static var center = PrefsValue('center', true, _storage);
  static var maximize = PrefsValue('maximize', false, _storage);

  static var group = PrefsValue('group', -1, _storage);
  static var groupOrder = PrefsValue('groupOrder', [], _storage);
  static var menuWeight = PrefsValue('menuWeight', 0.2, _storage);
  static var messageWeight = PrefsValue('messageWeight', 0.6, _storage);

  static var captureLeft = PrefsValue('captureLeft', 0.2, _storage);
  static var captureRight = PrefsValue('captureRight', 0.2, _storage);

  static var replyTip = PrefsValue('replyTip', true, _storage);

  static var theme = PrefsEnum(
    'theme',
    ThemeMode.dark,
    ThemeMode.values,
    _storage,
    description: 'Theme mode',
    prompt: 'Select theme mode',
  );

  static var customFrame = PrefsValue(
    'customFrame',
    true,
    _storage,
    description: 'Use custom window frame',
  );

  static var twoPane = PrefsValue(
    'twoPane',
    false,
    _storage,
    description: 'Use two pane layout',
  );

  static var contentScale = PrefsValue(
    'contentScale',
    100,
    _storage,
    description: 'Content text scale (%)',
  );

  static var identities = PrefsValue(
    'identities',
    [],
    _storage,
    description: 'Identities',
    prompt: 'Enter the identity',
  );

  static var stripText = PrefsValue(
    'stripText',
    true,
    _storage,
    description: 'Strip unimportant text',
  );

  static var stripSignature = PrefsValue(
    'stripSignature',
    <dynamic>[r'^-- ?$'],
    _storage,
    description: 'Signature',
    prompt: 'Enter the regex pattern',
  );

  static var stripQuote = PrefsValue(
    'stripQuote',
    true,
    _storage,
    description: 'Quote',
  );

  static var stripSameContent = PrefsValue(
    'stripSameContent',
    true,
    _storage,
    description: 'Same content as parent',
  );

  static var stripMultiEmptyLine = PrefsValue(
    'stripMultiEmptyLine',
    true,
    _storage,
    description: 'Multiple empty lines',
  );

  static var stripUnicodeEmojiModifier = PrefsValue(
    'stripUnicodeEmojiModifier',
    false,
    _storage,
    description: 'Unicode emoji modifier',
    prompt: 'Some old OS may crash to display it',
  );

  static var stripCustomPattern = PrefsValue(
    'stripCustomPattern',
    [],
    _storage,
    description: 'Custom pattern',
    prompt: 'Enter the regex pattern',
  );

  static var sortMode = PrefsEnum(
    'sortMode',
    SortMode.hierarchy,
    SortMode.values,
    _storage,
    description: 'Sort mode',
    prompt: 'Select preferred option',
  );

  static var showQuote = PrefsEnum(
    'showQuote',
    ShowQuote.smart,
    ShowQuote.values,
    _storage,
    description: 'Show quote',
    prompt: 'Select preferred option',
  );

  static var shortReply = PrefsValue(
    'shortReply',
    true,
    _storage,
    description: 'Show short reply inside post',
  );

  static var shortReplySize = PrefsValue(
    'shortReplySize',
    50,
    _storage,
    description: 'Short reply size',
    prompt: 'Enter the value',
  );

  static var linkPreview = PrefsValue(
    'linkPreview',
    true,
    _storage,
    description: 'Link preview',
  );

  static var smallPreview = PrefsValue(
    'smallPreview',
    true,
    _storage,
    description: 'Image preview in small size',
  );

  static var attachmentSize = PrefsValue(
    'attachmentSize',
    10000,
    _storage,
    description: 'Attachment size',
  );

  static var hideText = PrefsValue(
    'hideText',
    8,
    _storage,
    description: 'Hide long text',
  );

  static var chopQuote = PrefsValue(
    'chopQuote',
    500,
    _storage,
    description: 'Chop long quote',
  );

  static var unreadOnNext = PrefsValue(
    'unreadOnNext',
    true,
    _storage,
    description: 'Show unread on next button',
  );

  static var threadOnNext = PrefsValue(
    'threadOnNext',
    true,
    _storage,
    description: 'Next thread when no unread',
  );

  static var nextThreadMode = PrefsEnum(
    'nextThreadMode',
    NextThread.next,
    NextThread.values,
    _storage,
    description: 'Next thread mode',
    prompt: 'Select preferred option',
  );

  static var nextThreadDirection = PrefsEnum(
    'nextThreadDirection',
    NextDirection.newer,
    NextDirection.values,
    _storage,
    description: 'Next thread direction',
    prompt: 'Select preferred option',
  );
}

class _SettingsStorage implements PrefsStorage {
  static var _initialValue = <String, String>{};

  static Future<void> init() async {
    var settings = await Database.settingList();
    _initialValue = {for (var e in settings) e.key: e.value};
  }

  @override
  String? load(String key) {
    return _initialValue[key];
  }

  @override
  void save(String key, String value) async {
    var setting = await Database.getSetting(key);
    setting ??= Setting()..key = key;
    setting.value = value;
    await Database.updateSetting(setting);
  }
}
