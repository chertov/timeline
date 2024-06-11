import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:tuple/tuple.dart';
import 'package:intl/intl.dart';

import './timelineSettings.dart';
import './day.dart';

class MonthRender {
  final BuildContext context;
  final DateTime datetime;
  final Canvas canvas;
  final Size size;
  final double Function(DateTime time) offsetByTime;
  final DateTime Function(double offset) timeByOffset;
  final Tuple2<DateTime, DateTime> timeRange;
  final TimelineSettings settings;

  MonthRender({
    required this.context,
    required this.datetime,
    required this.canvas,
    required this.size,
    required this.offsetByTime,
    required this.timeByOffset,
    required this.timeRange,
    required this.settings,
  });

  final DateFormat monthFormatter = new DateFormat.MMMM('ru');

  draw() {
    _drawDays();

    if (datetime.month != 1) {
      _drawTick(
        offsetByTime(datetime),
        settings.months.tickYBottom,
        settings.months.tickYTop,
        settings.months.thickness,
        settings.months.tickColor,
      );
    }

    DateTime dateStart = datetime;
    DateTime dateEnd = DateTime(datetime.year, datetime.month + 1);
    double leftBoundary;
    double rightBoundary;

    if (dateStart.isBefore(timeRange.item1)) {
      leftBoundary = offsetByTime(timeRange.item1) + settings.months.textMargin;
    } else {
      leftBoundary = offsetByTime(dateStart) + settings.months.textMargin;
    }

    if (dateEnd.isAfter(timeRange.item2)) {
      rightBoundary = offsetByTime(timeRange.item2) - settings.months.textMargin;
    } else {
      rightBoundary = offsetByTime(dateEnd) - settings.months.textMargin;
    }

    _drawLabel(
      leftBoundary,
      rightBoundary,
      settings.months.tickYTop,
      settings.months.fontSize,
      settings.months.monthsColor,
      monthFormatter.format(datetime),
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
    Color color,
    String text,
  ) {
    TextSpan span = TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize));
    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: ui.TextDirection.ltr);
    tp.layout();
    double textWidth = tp.width;
    double textHeight = tp.height;
    double y = tickYTop - (textHeight / 2) + 10;
    double x = leftBoundary;

    double availableWidth = rightBoundary - leftBoundary;
    if (textWidth < availableWidth) {
      x = leftBoundary + (availableWidth / 2) - (textWidth / 2);
    } else if (leftBoundary < size.width / 2) {
      x = rightBoundary - textWidth;
    }

    tp.paint(canvas, Offset(x, y));
  }

  _drawDays() {
    int firstDay = 1;
    if (timeRange.item1.year == datetime.year && timeRange.item1.month == datetime.month) {
      firstDay = timeRange.item1.day;
    }
    int lastDay = 31;
    if (timeRange.item2.year == datetime.year && timeRange.item2.month == datetime.month) {
      lastDay = timeRange.item2.day;
    }
    for (int day = firstDay; day <= lastDay; day += 1) {
      DateTime dt = DateTime(datetime.year, datetime.month, day);
      if (dt.day == day) {
        DayRender dayRender = DayRender(context: context, datetime: dt, canvas: canvas, size: size, offsetByTime: offsetByTime, timeByOffset: timeByOffset, timeRange: timeRange, settings: settings);
        dayRender.draw();
      }
    }
  }
}
