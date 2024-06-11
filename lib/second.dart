import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:tuple/tuple.dart';

import './timelineSettings.dart';

class SecondRender {
  final DateTime datetime;
  final Canvas canvas;
  final Size size;
  final double Function(DateTime time) offsetByTime;
  final DateTime Function(double offset) timeByOffset;
  final Tuple2<DateTime, DateTime> timeRange;
  final TimelineSettings settings;

  SecondRender({
    required this.datetime,
    required this.canvas,
    required this.size,
    required this.offsetByTime,
    required this.timeByOffset,
    required this.timeRange,
    required this.settings,
  });

  draw() {
    if (!settings.seconds.shouldDrawTicks10) return;

    if (datetime.second == 0) return;

    double x = offsetByTime(datetime);

    if (datetime.second % 10 == 0) {
      _drawTick(
        x,
        settings.seconds.tickYBottom,
        settings.seconds.tick10YTop,
        settings.seconds.thickness,
        settings.seconds.tick10Color,
      );
    } else if (settings.seconds.shouldDrawSeconds10 && datetime.second % 5 == 0) {
      _drawTick(
        x,
        settings.seconds.tickYBottom,
        settings.seconds.tick5YTop,
        settings.seconds.thickness,
        settings.seconds.tickOtherColor,
      );
    } else if (settings.seconds.shouldDrawSeconds10) {
      _drawTick(
        x,
        settings.seconds.tickYBottom,
        settings.seconds.tick1YTop,
        settings.seconds.thickness,
        settings.seconds.tickOtherColor,
      );
    }

    if (!settings.seconds.shouldDrawSeconds10) return;

    if (settings.seconds.shouldDrawSeconds10 && datetime.second % 10 == 0) {
      _drawLabel(
        x,
        settings.seconds.tick10YTop,
        settings.seconds.fontSize,
        settings.seconds.seconds10ScaleFactor,
        settings.seconds.seconds10Color,
        '${datetime.second}',
      );
    }
  }

  _drawTick(
    double x,
    double tickYBottom,
    double tickYTop,
    double thickness,
    Color tickColor,
  ) {
    var paint = Paint()
      ..color = tickColor
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;
    var path = Path();
    path.moveTo(x, tickYBottom);
    path.lineTo(x, tickYTop);
    canvas.drawPath(path, paint);
  }

  _drawLabel(
    double x,
    double tickYTop,
    double fontSize,
    double scaleFactor,
    Color color,
    String text,
  ) {
    TextSpan span = TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize));
    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: ui.TextDirection.ltr);
    tp.layout();
    double scaledTextWidth = tp.width * scaleFactor;
    double scaledTextHeight = tp.height * scaleFactor;

    double canvasX = x - (scaledTextWidth / 2);
    double canvasY = tickYTop - (scaledTextHeight / 2) - 8;
    canvas.save();
    canvas.translate(canvasX, canvasY);
    canvas.scale(scaleFactor, scaleFactor);
    tp.paint(canvas, Offset(0, 0));
    canvas.restore();
  }
}
