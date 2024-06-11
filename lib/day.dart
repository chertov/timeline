import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:tuple/tuple.dart';
import 'package:intl/intl.dart';

import './timelineSettings.dart';
import './hour.dart';

class DayRender {
  final BuildContext context;
  final DateTime datetime;
  final Canvas canvas;
  final Size size;
  final double Function(DateTime time) offsetByTime;
  final DateTime Function(double offset) timeByOffset;
  final Tuple2<DateTime, DateTime> timeRange;
  final TimelineSettings settings;

  DayRender({
    required this.context,
    required this.datetime,
    required this.canvas,
    required this.size,
    required this.offsetByTime,
    required this.timeByOffset,
    required this.timeRange,
    required this.settings,
  });

  final DateFormat shortWeekDayFormatter = DateFormat.E('ru');
  final DateFormat fullWeekDayFormatter = DateFormat.EEEE('ru');

  draw() {
    _drawHours();

    if (datetime.day != 1) {
      _drawTick(
        offsetByTime(datetime),
        settings.days.tickYBottom,
        settings.days.tickYTop,
        settings.days.thickness,
        settings.days.tickColor,
      );
    }

    if (!settings.days.shouldDrawDaysNumbers) return;

    DateTime dateStart = datetime;
    DateTime dateEnd = datetime.add(Duration(days: 1));
    double leftBoundary;
    double rightBoundary;

    if (dateStart.isBefore(timeRange.item1)) {
      leftBoundary = offsetByTime(timeRange.item1) + settings.days.textMargin;
    } else {
      leftBoundary = offsetByTime(dateStart) + settings.days.textMargin;
    }

    if (dateEnd.isAfter(timeRange.item2)) {
      rightBoundary = offsetByTime(timeRange.item2) - settings.days.textMargin;
    } else {
      rightBoundary = offsetByTime(dateEnd) - settings.days.textMargin;
    }

    String labelText = '${datetime.day}';
    if (settings.days.shouldDrawWeekdaysFull) {
      labelText = '${fullWeekDayFormatter.format(datetime)} ${datetime.day}';
    } else if (settings.days.shouldDrawWeekdaysShort) {
      labelText = '${shortWeekDayFormatter.format(datetime)} ${datetime.day}';
    }

    _drawLabel(
      leftBoundary,
      rightBoundary,
      settings.days.tickYTop,
      settings.days.fontSize,
      settings.days.daysScaleFactor,
      settings.days.daysColor,
      labelText,
    );
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
    double leftBoundary,
    double rightBoundary,
    double tickYTop,
    double fontSize,
    double scaleFactor,
    Color color,
    String text,
  ) {
    TextSpan span = TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize));
    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: ui.TextDirection.ltr);
    tp.layout();
    double scaledTextWidth = tp.width * scaleFactor;
    double scaledTextHeight = tp.height * scaleFactor;
    double x = leftBoundary;

    double availableWidth = rightBoundary - leftBoundary;
    if (scaledTextWidth < availableWidth) {
      x = leftBoundary + (availableWidth / 2) - (scaledTextWidth / 2);
    } else if (leftBoundary < size.width / 2) {
      x = rightBoundary - scaledTextWidth;
    }

    double canvasX = x;
    double canvasY = tickYTop - (scaledTextHeight / 2) + 10;
    canvas.save();
    canvas.translate(canvasX, canvasY);
    canvas.scale(scaleFactor, scaleFactor);
    tp.paint(canvas, Offset(0, 0));
    canvas.restore();
  }

  _drawHours() {
    int firstHour = 0;
    if (timeRange.item1.year == datetime.year && timeRange.item1.month == datetime.month && timeRange.item1.day == datetime.day) {
      firstHour = timeRange.item1.hour;
    }
    int lastHour = 23;
    if (timeRange.item2.year == datetime.year && timeRange.item2.month == datetime.month && timeRange.item2.day == datetime.day) {
      lastHour = timeRange.item2.hour;
    }
    for (int hour = firstHour; hour <= lastHour; hour += 1) {
      DateTime dt = DateTime(datetime.year, datetime.month, datetime.day, hour);
      HourRender hourRender = HourRender(context: context, datetime: dt, canvas: canvas, timelineSize: size, offsetByTime: offsetByTime, timeByOffset: timeByOffset, timeRange: timeRange, settings: settings);
      hourRender.draw();
    }
  }
}
