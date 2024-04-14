import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/adaptive.dart';
import '../core/filter.dart';
import '../database/models.dart';
import '../post/post_controller.dart';

final filterProvider = Provider<FilterController>(
    (_) => FilterController(Adaptive.useTwoPaneUI ? true : false, false));

class FilterController extends ChangeNotifier {
  FilterController(this._enThread, this._enPost);

  final _filters = [
    NewFilter(),
    ReadFilter(),
    UnreadFilter(),
    TotalFilter(),
    SubjectFilter(),
    SenderFilter(),
    ContentFilter(),
    DateFilter(),
    SizeFilter(),
    ImageFilter(),
    FileFilter(),
    LinkFilter(),
  ];
  List<Filter> get filters => _filters;

  var _enabled = false;
  bool get enabled => _enabled;
  var _allPost = false;
  bool get allPost => _allPost;

  bool _enThread;
  bool get enThread => _enThread;
  bool _enPost;
  bool get enPost => _enPost;

  void toggle() {
    _enabled = !_enabled;
    if (!_enThread && !_enPost) _enThread = true;
    notifyListeners();
  }

  void toggleAllPost() {
    _allPost = !_allPost;
    for (var f in filters) {
      f.allPost = _allPost;
    }
    notifyListeners();
  }

  void toggleThreadFilter(bool combine) {
    _enabled = true;
    if (!combine || _enPost) _enThread = !_enThread;
    notifyListeners();
  }

  void togglePostFilter(bool combine) {
    _enabled = true;
    if (!combine || _enThread) _enPost = !_enPost;
    notifyListeners();
  }

  bool filterThread(Thread data) {
    if (!enabled || !enThread) return true;
    for (var f in filters) {
      if (f.useInThread && !f.matchThread(data)) return false;
    }
    return true;
  }

  bool filterPost(PostData data) {
    if (!enabled || !enPost) return true;
    for (var f in filters) {
      if (f.useInPost && !f.matchPost(data)) return false;
    }
    return true;
  }
}
