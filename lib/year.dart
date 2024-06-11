import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:tuple/tuple.dart';

import './timelineSettings.dart';
import './month.dart';

class YearRender {
  final BuildContext context;
  final DateTime datetime;
  final Canvas canvas;
  final Size size;
  final double Function(DateTime time) offsetByTime;
  final DateTime Function(double offset) timeByOffset;
  final Tuple2<DateTime, DateTime> timeRange;
  final TimelineSettings settings;

  YearRender({
    required this.context,
    required this.datetime,
    required this.canvas,
    required this.size,
    required this.offsetByTime,
    required this.timeByOffset,
    required this.timeRange,
    required this.settings,
  });

  draw() {
    _drawMonths();

    _drawTick(
      offsetByTime(datetime),
      settings.years.tickYBottom,
      settings.years.tickYTop,
      settings.years.thickness,
      settings.years.tickColor,
    );

    DateTime dateStart = datetime;
    DateTime dateEnd = DateTime(datetime.year + 1);
    double leftBoundary;
    double rightBoundary;

    if (dateStart.isBefore(timeRange.item1)) {
      leftBoundary = offsetByTime(timeRange.item1) + settings.years.textMargin;
    } else {
      leftBoundary = offsetByTime(dateStart) + settings.years.textMargin;
    }

    if (dateEnd.isAfter(timeRange.item2)) {
      rightBoundary = offsetByTime(timeRange.item2) - settings.years.textMargin;
    } else {
      rightBoundary = offsetByTime(dateEnd) - settings.years.textMargin;
    }

    _drawLabel(
      leftBoundary,
      rightBoundary,
      settings.years.tickYTop,
      settings.years.fontSize,
      settings.years.yearsColor,
      '${datetime.year} год',
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

  _drawMonths() {
    int firstMonth = 1;
    if (timeRange.item1.year == datetime.year) {
      firstMonth = timeRange.item1.month;
    }
    int lastMonth = 12;
    if (timeRange.item2.year == datetime.year) {
      lastMonth = timeRange.item2.month;
    }
    for (int month = firstMonth; month <= lastMonth; month += 1) {
      MonthRender monthRender = MonthRender(
        context: context,
        datetime: DateTime(datetime.year, month),
        canvas: canvas,
        size: size,
        offsetByTime: offsetByTime,
        timeByOffset: timeByOffset,
        timeRange: timeRange,
        settings: settings,
      );
      monthRender.draw();
    }
  }
}
