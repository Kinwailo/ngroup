import 'package:flutter/material.dart';
import 'package:patterns_canvas/patterns_canvas.dart';

class BlockPainter extends CustomPainter {
  const BlockPainter(this.bg, this.fg);

  final Color bg;
  final Color fg;

  @override
  void paint(Canvas canvas, Size size) {
    DiagonalStripesThick(
            bgColor: bg.withOpacity(0.2),
            fgColor: fg.withOpacity(0.2),
            featuresCount: 36)
        .paintOnWidget(canvas, size,
            patternScaleBehavior: PatternScaleBehavior.canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
