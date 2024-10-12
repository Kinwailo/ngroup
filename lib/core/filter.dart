import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ngroup/conv/conv.dart';

import '../post/post_controller.dart';
import '../settings/settings.dart';
import '/core/string_utils.dart';
import '../database/models.dart';

abstract class Filter extends ChangeNotifier {
  String get name;

  bool _enabled = false;
  bool _invert = false;
  bool _allPost = false;

  bool useInThread = false;
  bool useInPost = false;

  bool get enabled => _enabled;
  set enabled(bool v) {
    _enabled = v;
    notifyListeners();
  }

  bool get invert => _invert;
  set invert(bool v) {
    _invert = v;
    notifyListeners();
  }

  bool get allPost => _allPost;
  set allPost(bool v) {
    _allPost = v;
    notifyListeners();
  }

  bool _matchThread(Thread data);
  bool _matchPost(PostData data);

  void toggle() {
    if (!enabled) {
      enabled = true;
      invert = false;
    } else if (!invert) {
      invert = true;
    } else {
      invert = false;
      enabled = false;
    }
  }

  bool matchThread(Thread data) {
    if (!enabled) return true;
    var match = _matchThread(data);
    return invert ? !match : match;
  }

  bool matchPost(PostData data) {
    if (!enabled) return true;
    if (data.body == null) return true;
    var match = _matchPost(data);
    return invert ? !match : match;
  }
}

enum FilterModes {
  equal('='),
  less('≤'),
  more('≥'),
  contains('≈'),
  regexp('∫'),
  before('≤'),
  after('≥'),
  between('↔');

  const FilterModes(this.text);
  final String text;
}

mixin FilterParam<T> on Filter {
  List<FilterModes> get _modes;

  FilterModes? _mode;
  FilterModes get mode => _mode!;
  set mode(FilterModes mode) {
    _mode ??= mode;
    if (_mode == mode) return;
    _mode = mode;
    enabled = true;
  }

  T? _param;
  T get param => _param!;
  set param(T param) {
    _param ??= param;
    if (_param == param) return;
    _param = param;
    enabled = true;
  }

  List<String> get modes => _modes.map((e) => e.name).toList();

  String get paramString => _param.toString();
  String get paramString2 => paramString;

  void setMode(int index) {
    mode = _modes[index];
  }
}

mixin FilterParamInt on FilterParam<int> {
  @override
  final List<FilterModes> _modes = [
    FilterModes.equal,
    FilterModes.less,
    FilterModes.more,
  ];
}

mixin FilterParamString on FilterParam<String> {
  @override
  final List<FilterModes> _modes = [
    FilterModes.equal,
    FilterModes.contains,
    FilterModes.regexp,
  ];
  @override
  String get paramString => param.isEmpty ? '__' : param;
}

mixin FilterParamDate on FilterParam<DateTimeRange> {
  @override
  final List<FilterModes> _modes = [
    FilterModes.equal,
    FilterModes.before,
    FilterModes.after,
    FilterModes.between,
  ];
  @override
  String get paramString => DateFormat("dd/MM/y").format(param.end);
  @override
  String get paramString2 => DateFormat("dd/MM/y").format(param.start);
}

class NewFilter extends Filter {
  @override
  String get name => 'New';
  @override
  bool get useInThread => true;
  @override
  bool get useInPost => true;

  @override
  bool _matchThread(Thread data) {
    return allPost ? data.newCount > 0 : data.isNew;
  }

  @override
  bool _matchPost(PostData data) {
    return data.state.isNew;
  }
}

class ReadFilter extends Filter {
  @override
  String get name => 'Read';
  @override
  bool get useInThread => true;
  @override
  bool get useInPost => true;

  @override
  bool _matchThread(Thread data) {
    return allPost ? data.unreadCount != data.totalCount : data.isRead;
  }

  @override
  bool _matchPost(PostData data) {
    return data.state.isRead;
  }
}

class UnreadFilter extends Filter {
  @override
  String get name => 'Unread';
  @override
  bool get useInThread => true;
  @override
  bool get useInPost => true;

  @override
  bool _matchThread(Thread data) {
    return allPost ? data.unreadCount > 0 : !data.isRead;
  }

  @override
  bool _matchPost(PostData data) {
    return !data.state.isRead;
  }
}

class TotalFilter extends Filter with FilterParam<int>, FilterParamInt {
  TotalFilter() {
    mode = FilterModes.more;
    param = 10;
  }

  @override
  String get name => 'Total';
  @override
  bool get useInThread => true;

  @override
  bool _matchThread(Thread data) {
    return switch (mode) {
      FilterModes.less => data.totalCount <= param,
      FilterModes.more => data.totalCount >= param,
      _ => data.totalCount == param,
    };
  }

  @override
  bool _matchPost(PostData data) {
    return true;
  }
}

class SubjectFilter extends Filter with FilterParam<String>, FilterParamString {
  SubjectFilter() {
    mode = FilterModes.contains;
    param = '';
  }

  @override
  String get name => 'Subject';
  @override
  bool get useInThread => true;

  @override
  bool _matchThread(Thread data) {
    return switch (mode) {
      FilterModes.equal => data.subject.toLowerCase() == param.toLowerCase(),
      FilterModes.contains =>
        data.subject.toLowerCase().contains(param.toLowerCase()),
      _ => RegExp(param, caseSensitive: false).hasMatch(data.subject),
    };
  }

  @override
  bool _matchPost(PostData data) {
    return true;
  }
}

class SenderFilter extends Filter with FilterParam<String>, FilterParamString {
  SenderFilter() {
    mode = FilterModes.contains;
    param = '';
  }

  @override
  String get name => 'Sender';
  @override
  bool get useInThread => true;
  @override
  bool get useInPost => true;

  bool _matchSender(String sender) {
    sender = sender.toLowerCase();
    return switch (mode) {
      FilterModes.equal => sender == param.toLowerCase(),
      FilterModes.contains => sender.contains(param.toLowerCase()),
      _ => RegExp(param).hasMatch(sender),
    };
  }

  @override
  bool _matchThread(Thread data) {
    return allPost
        ? data.senders.any((e) => _matchSender(e.convUseSetting))
        : _matchSender(data.from.sender.convUseSetting);
  }

  @override
  bool _matchPost(PostData data) {
    var sender = data.post.from.sender.convUseSetting.toLowerCase();
    return switch (mode) {
      FilterModes.equal => sender == param.toLowerCase(),
      FilterModes.contains => sender.contains(param.toLowerCase()),
      _ => RegExp(param).hasMatch(sender),
    };
  }
}

class ContentFilter extends Filter with FilterParam<String>, FilterParamString {
  ContentFilter() {
    mode = FilterModes.contains;
    param = '';
  }

  @override
  String get name => 'Content';
  @override
  bool get useInPost => true;

  @override
  bool _matchThread(Thread data) {
    return true;
  }

  @override
  bool _matchPost(PostData data) {
    if (data.body == null) return true;
    var text = data.body!.text.toLowerCase();
    return switch (mode) {
      FilterModes.equal => text == param.toLowerCase(),
      FilterModes.contains => text.contains(param.toLowerCase()),
      _ => RegExp(param, caseSensitive: false).hasMatch(text),
    };
  }
}

class DateFilter extends Filter
    with FilterParam<DateTimeRange>, FilterParamDate {
  DateFilter() {
    mode = FilterModes.before;
    param = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  }

  @override
  String get name => 'Date';
  @override
  bool get useInThread => true;
  @override
  bool get useInPost => true;

  bool _matchDate(DateTime dateTime) {
    var date = DateUtils.dateOnly(dateTime);
    var range = DateUtils.datesOnly(param);
    return switch (mode) {
      FilterModes.before => !date.isAfter(range.end),
      FilterModes.after => !date.isBefore(range.end),
      FilterModes.between =>
        !date.isBefore(range.start) && !date.isAfter(range.end),
      _ => date.isAtSameMomentAs(range.end),
    };
  }

  @override
  bool _matchThread(Thread data) {
    return allPost
        ? data.dates.any((e) => _matchDate(e))
        : _matchDate(data.dateTime);
  }

  @override
  bool _matchPost(PostData data) {
    var date = DateUtils.dateOnly(data.post.dateTime);
    var range = DateUtils.datesOnly(param);
    return switch (mode) {
      FilterModes.before => !date.isAfter(range.end),
      FilterModes.after => !date.isBefore(range.end),
      FilterModes.between =>
        !date.isBefore(range.start) && !date.isAfter(range.end),
      _ => date.isAtSameMomentAs(range.end),
    };
  }
}

class SizeFilter extends Filter with FilterParam<int>, FilterParamInt {
  SizeFilter() {
    mode = FilterModes.more;
    param = Settings.attachmentSize.val;
  }

  @override
  String get name => 'Size';
  @override
  bool get useInThread => true;

  bool _matchSize(int size) {
    return switch (mode) {
      FilterModes.less => size <= param,
      FilterModes.more => size >= param,
      _ => size == param,
    };
  }

  @override
  bool _matchThread(Thread data) {
    return allPost
        ? data.sizes.any((e) => _matchSize(e))
        : _matchSize(data.bytes);
  }

  @override
  bool _matchPost(PostData data) {
    return switch (mode) {
      FilterModes.less => data.post.bytes <= param,
      FilterModes.more => data.post.bytes >= param,
      _ => data.post.bytes == param,
    };
  }
}

class ImageFilter extends Filter {
  @override
  String get name => 'Image';
  @override
  bool get useInPost => true;

  @override
  bool _matchThread(Thread data) {
    return true;
  }

  @override
  bool _matchPost(PostData data) {
    return data.body?.images.isNotEmpty ?? true;
  }
}

class FileFilter extends Filter {
  @override
  String get name => 'File';
  @override
  bool get useInPost => true;

  @override
  bool _matchThread(Thread data) {
    return true;
  }

  @override
  bool _matchPost(PostData data) {
    return data.body?.files.isNotEmpty ?? true;
  }
}

class LinkFilter extends Filter {
  @override
  String get name => 'Link';
  @override
  bool get useInPost => true;

  @override
  bool _matchThread(Thread data) {
    return true;
  }

  @override
  bool _matchPost(PostData data) {
    return data.body?.links.isNotEmpty ?? true;
  }
}
