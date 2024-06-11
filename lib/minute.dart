import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:tuple/tuple.dart';

import './timelineSettings.dart';
import './second.dart';

class MinuteRender {
  final DateTime datetime;
  final Canvas canvas;
  final Size size;
  final double Function(DateTime time) offsetByTime;
  final DateTime Function(double offset) timeByOffset;
  final Tuple2<DateTime, DateTime> timeRange;
  final TimelineSettings settings;

  MinuteRender({
    required this.datetime,
    required this.canvas,
    required this.size,
    required this.offsetByTime,
    required this.timeByOffset,
    required this.timeRange,
    required this.settings,
  });

  draw() {
    if (!settings.minutes.shouldDrawTicks10) return;

    _drawSeconds();

    if (datetime.minute == 0) return;

    double x = offsetByTime(datetime);

    if (datetime.minute % 10 == 0) {
      _drawTick(
        x,
        settings.minutes.tickYBottom,
        settings.minutes.tick10YTop,
        settings.minutes.thickness,
        settings.minutes.tick10Color,
      );
    } else if (settings.minutes.shouldDrawMinutes10 && datetime.minute % 5 == 0) {
      _drawTick(
        x,
        settings.minutes.tickYBottom,
        settings.minutes.tick5YTop,
        settings.minutes.thickness,
        settings.minutes.tickOtherColor,
      );
    } else if (settings.minutes.shouldDrawMinutes10) {
      _drawTick(
        x,
        settings.minutes.tickYBottom,
        settings.minutes.tickOtherYTop,
        settings.minutes.thickness,
        settings.minutes.tickOtherColor,
      );
    }

    if (!settings.minutes.shouldDrawMinutes10) return;

    String labelText = '${datetime.hour}:${datetime.minute}';
    if (datetime.minute < 10) {
      labelText = '${datetime.hour}:0${datetime.minute}';
    }

    if (settings.minutes.shouldDrawMinutes10 && datetime.minute % 10 == 0) {
      _drawLabel(
        x,
        settings.minutes.tick10YTop,
        settings.minutes.fontSize,
        settings.minutes.minutes10ScaleFactor,
        settings.minutes.minutes10Color,
        labelText,
      );
    } else if (settings.minutes.shouldDrawMinutes5 && datetime.minute % 5 == 0) {
      _drawLabel(
        x,
        settings.minutes.tick10YTop,
        settings.minutes.fontSize,
        settings.minutes.minutes5ScaleFactor,
        settings.minutes.minutes5Color,
        labelText,
      );
    } else if (settings.minutes.shouldDrawMinutesOther) {
      _drawLabel(
        x,
        settings.minutes.tick10YTop,
        settings.minutes.fontSize,
        settings.minutes.minutesOtherScaleFactor,
        settings.minutes.minutesOtherColor,
        labelText,
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
    double canvasY = tickYTop - (scaledTextHeight / 2) - 12;
    canvas.save();
    canvas.translate(canvasX, canvasY);
    canvas.scale(scaleFactor, scaleFactor);
    tp.paint(canvas, Offset(0, 0));
    canvas.restore();
  }

  _drawSeconds() {
    if (settings.seconds.shouldDrawTicks10) {
      int firstSecond = 1;
      if (timeRange.item1.year == datetime.year && timeRange.item1.month == datetime.month && timeRange.item1.day == datetime.day && timeRange.item1.hour == datetime.hour && timeRange.item1.minute == datetime.minute) {
        firstSecond = timeRange.item1.second;
      }
      int lastSecond = 59;
      if (timeRange.item2.year == datetime.year && timeRange.item2.month == datetime.month && timeRange.item2.day == datetime.day && timeRange.item2.hour == datetime.hour && timeRange.item2.minute == datetime.minute) {
        lastSecond = timeRange.item2.second;
      }
      for (int second = firstSecond; second <= lastSecond; second += 1) {
        DateTime dt = DateTime(datetime.year, datetime.month, datetime.day, datetime.hour, datetime.minute, second);
        SecondRender secondRender = SecondRender(datetime: dt, canvas: canvas, size: size, offsetByTime: offsetByTime, timeByOffset: timeByOffset, timeRange: timeRange, settings: settings);
        secondRender.draw();
      }
    }
  }
}
