import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ScrollControl {
  var itemScrollController = ItemScrollController();
  var itemPositionsListener = ItemPositionsListener.create();
  var index = 0;
  var offset = 0.0;
  var lastId = '';
  var lastIndex = 0;
  var lastOffset = 0.0;

  ScrollControl() {
    itemPositionsListener.itemPositions.addListener(() {
      var item = itemPositionsListener.itemPositions.value.firstOrNull;
      if (item != null && item.index >= 0) {
        index = item.index;
        offset = item.itemLeadingEdge;
      }
    });
  }

  void saveLast(String Function(int) getId) {
    lastId = getId(index);
    lastIndex = index;
    lastOffset = offset;
  }

  void jumpTop() {
    index = 0;
    offset = 0.0;
    lastId = '';
    lastIndex = 0;
    lastOffset = 0.0;
    if (itemScrollController.isAttached) {
      itemScrollController.jumpTo(index: 0);
    }
  }

  bool itemVisible(int i) {
    for (var item in itemPositionsListener.itemPositions.value) {
      if (item.index == i) return true;
    }
    return false;
  }

  void scrollTo(int i, {bool onlyNotVisible = false}) {
    if (onlyNotVisible && itemVisible(i)) return;
    if (itemScrollController.isAttached) {
      itemScrollController.jumpTo(index: index, alignment: offset);
      Future.delayed(
        Durations.short1,
        () =>
            itemScrollController.scrollTo(index: i, duration: Durations.short3),
      );
    }
  }

  void jumpLast() {
    if (itemScrollController.isAttached) {
      itemScrollController.jumpTo(index: lastIndex, alignment: lastOffset);
    }
  }

  void jumpLastId(int Function(String) getIndex) {
    if (itemScrollController.isAttached) {
      itemScrollController.jumpTo(
          index: getIndex(lastId), alignment: lastOffset);
    }
  }
}
