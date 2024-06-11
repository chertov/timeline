import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:tuple/tuple.dart';

import './timelineSettings.dart';
import './minute.dart';

class HourRender {
  final BuildContext context;
  final DateTime datetime;
  final Canvas canvas;
  final Size timelineSize;
  final double Function(DateTime time) offsetByTime;
  final DateTime Function(double offset) timeByOffset;
  final Tuple2<DateTime, DateTime> timeRange;
  final TimelineSettings settings;

  HourRender({
    required this.context,
    required this.datetime,
    required this.canvas,
    required this.timelineSize,
    required this.offsetByTime,
    required this.timeByOffset,
    required this.timeRange,
    required this.settings,
  });

  draw() {
    if (!settings.hours.shouldDraw) return;

    _drawMinutes();

    if (datetime.hour == 0) return;

    double x = offsetByTime(datetime);

    _drawTick(
      x,
      settings.hours.tickYBottom,
      datetime.hour % 3 == 0 ? settings.hours.tickYTop : settings.hours.tickYTopShort,
      settings.hours.thickness,
      settings.hours.tickColor,
    );

    if (settings.hours.shouldDrawHours3 && datetime.hour % 3 == 0) {
      _drawLabel(
        x,
        settings.hours.tickYTop,
        settings.hours.fontSize,
        settings.hours.hours3ScaleFactor,
        settings.hours.hours3Color,
        '${datetime.hour}:00',
      );
    } else if (settings.hours.shouldDrawHoursOther) {
      _drawLabel(
        x,
        settings.hours.tickYTop,
        settings.hours.fontSize,
        settings.hours.hoursOtherScaleFactor,
        settings.hours.hoursOtherColor,
        '${datetime.hour}:00',
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
    //path.moveTo(x.round()+0.5, tickYBottom);  // рисуем чётко по пиксельной сетке
    //path.lineTo(x.round()+0.5, tickYTop);
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

  _drawMinutes() {
    if (settings.minutes.shouldDrawTicks10) {
      int firstMinute = 0;
      if (timeRange.item1.year == datetime.year && timeRange.item1.month == datetime.month && timeRange.item1.day == datetime.day && timeRange.item1.hour == datetime.hour) {
        firstMinute = timeRange.item1.minute;
      }
      int lastMinute = 59;
      if (timeRange.item2.year == datetime.year && timeRange.item2.month == datetime.month && timeRange.item2.day == datetime.day && timeRange.item2.hour == datetime.hour) {
        lastMinute = timeRange.item2.minute;
      }
      for (int minute = firstMinute; minute <= lastMinute; minute += 1) {
        DateTime dt = DateTime(datetime.year, datetime.month, datetime.day, datetime.hour, minute);
        MinuteRender minuteRender = MinuteRender(datetime: dt, canvas: canvas, size: timelineSize, offsetByTime: offsetByTime, timeByOffset: timeByOffset, timeRange: timeRange, settings: settings);
        minuteRender.draw();
      }
    }
  }
}
