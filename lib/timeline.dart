import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';  // for date locale

import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math' as math;

import 'package:tuple/tuple.dart';

import 'timelineSettings.dart';

import 'year.dart';

double getOffsetForTime(DateTime time, DateTime anchor, double anchorOffset, double secondPerPixel) {
    // рассчитываем дельту в секундах между current и time
    double deltaSec = (time.millisecondsSinceEpoch - anchor.millisecondsSinceEpoch) / 1000.0;
    double deltaPos = deltaSec / secondPerPixel;
    return anchorOffset + deltaPos;
}
DateTime getTimeByOffset(double offset, DateTime anchor, double anchorOffset, double secondPerPixel) {
    double millisecondsSinceEpoch = anchor.millisecondsSinceEpoch + (offset - anchorOffset) * secondPerPixel * 1000.0;
    return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch.round());
}

class Ancor {
    Ancor({required this.anchor, required this.anchorOffset, required this.secondPerPixel});
    DateTime anchor;
    double anchorOffset;
    double secondPerPixel;       // текущий масштаб - секунд на пиксель
}

class TimelinePainter extends CustomPainter {
    late ValueNotifier<Ancor> _notifier;
    late BuildContext _context;
    late TimelineSettings settings;

    DateTime left() { return _getTimeByOffset(0); }
    DateTime right(Size size) { return _getTimeByOffset(size.width); }

    TimelinePainter({required BuildContext context, required ValueNotifier<Ancor> notifier}) : super(repaint: notifier) {
        _notifier = notifier;
        _context = context;
        settings = TimelineSettings(_context, _notifier.value.secondPerPixel, 120.0);
    }

    // получить положение в пикселях для произвольной даты
    // при расчете отталкиваемся от значения _currentTimePos, offset и secondPerPixel
    double _getOffsetForTime(DateTime time) {
        return getOffsetForTime(time, _notifier.value.anchor, _notifier.value.anchorOffset, _notifier.value.secondPerPixel);
    }
    DateTime _getTimeByOffset(double offset) {
        return getTimeByOffset(offset, _notifier.value.anchor, _notifier.value.anchorOffset, _notifier.value.secondPerPixel);
    }

    Tuple2<DateTime, DateTime> getViewRange(Size size) {
        DateTime left = this.left();
        DateTime right = this.right(size);
        return Tuple2<DateTime, DateTime>(left, right);
    }

    @override
    void paint(Canvas canvas, Size size) {
        canvas.drawRect(Offset.zero & size, Paint()..color = Theme.of(_context).scaffoldBackgroundColor);

        Tuple2<DateTime, DateTime> timeRange = getViewRange(size);
        double secondPerPixel = _notifier.value.secondPerPixel;

        if (timeRange != null) {
            DateTime t1 = timeRange.item1;
            DateTime t2 = timeRange.item2;

            var paint = Paint()
                ..color = Theme.of(_context).colorScheme.primary.withAlpha(64)
                ..strokeWidth = 1
                ..style = PaintingStyle.stroke;
            var path = Path();
            path.moveTo(_getOffsetForTime(t1), (size.height - 5.5));
            path.lineTo(_getOffsetForTime(t2), (size.height - 5.5));
            canvas.drawPath(path, paint);
        }

        //settings.updateFor(secondPerPixel);

        {
            Tuple2<DateTime, DateTime> timeRange = getViewRange(size);
            if (timeRange != null) {
                for (int year = timeRange.item1.year; year <= timeRange.item2.year; year += 1) {
                    YearRender yearRender = YearRender(context:_context, datetime: DateTime(year), canvas: canvas, size: size, 
                        offsetByTime: _getOffsetForTime, timeByOffset: _getTimeByOffset, timeRange: timeRange,
                        settings: settings);
                    yearRender.draw();
                }
            }
        }
    }

    @override
    bool shouldRepaint(TimelinePainter p) {
        // if (_notifier.value != p._notifier.value) return true;
        if (_notifier.value.anchor != p._notifier.value.anchor) return true;
        if (_notifier.value.anchorOffset != p._notifier.value.anchorOffset) return true;
        if (_notifier.value.secondPerPixel != p._notifier.value.secondPerPixel) return true;
        return false;
    }
}


class CurrentTimePainter extends CustomPainter {
    late BuildContext _context;
    late ValueNotifier<Ancor> _notifier;
    late ValueNotifier<DateTime> _currentTimeNotifier;

    final DateFormat formatter = DateFormat('HH : mm : ss');

    CurrentTimePainter({required BuildContext context, required ValueNotifier<Ancor> notifier, required ValueNotifier<DateTime> currentTimeNotifier}): super(repaint: Listenable.merge([notifier, currentTimeNotifier])) {
        _notifier = notifier;
        _context = context;
        _currentTimeNotifier = currentTimeNotifier;
    }

    drawCurrentTime(Canvas canvas, Size size) {
        double pos = getOffsetForTime(_currentTimeNotifier.value, _notifier.value.anchor, _notifier.value.anchorOffset, _notifier.value.secondPerPixel);

        final textStyle = ui.TextStyle(color: Theme.of(_context).colorScheme.secondary, fontSize: 11);
        final paragraphStyle = ui.ParagraphStyle(textAlign: ui.TextAlign.center, textDirection: ui.TextDirection.ltr);
        final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
            ..pushStyle(textStyle)
            ..addText(this.formatter.format(_currentTimeNotifier.value)); // + " ${_currentTimeNotifier.value.millisecond}");
        final constraints = ui.ParagraphConstraints(width: size.height);
        final paragraph = paragraphBuilder.build();
        paragraph.layout(constraints);
        canvas.save();
        canvas.translate(pos, size.height);
        canvas.rotate(-math.pi / 2);
        canvas.drawParagraph(paragraph, Offset(0, 2));
        canvas.restore();

        var paint = Paint()
            ..color = Theme.of(_context).colorScheme.secondary
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;
        var path = Path();
        path.moveTo(pos, 0);
        path.lineTo(pos, size.height);
        canvas.drawPath(path, paint);
    }

    @override
    void paint(Canvas canvas, Size size) {
        this.drawCurrentTime(canvas, size);
    }

    @override
    bool shouldRepaint(CurrentTimePainter p) {
        if (_notifier.value != p._notifier.value) return true;
        return false;
    }
}

class Timeline extends StatefulWidget {
    @override
    createState() => TimelineState();
}

class TimelineState extends State<Timeline> with TickerProviderStateMixin {
    late int positionPts;
    late int beginPts;
    late int endPts;

    late Timer timer;
    double startX = 0, startY = 0, currentX = 0;
    bool vertical = true;

    final double _maxSecondPerPixel = 25000.0;
    final double _minSecondPerPixel = 0.2;
    double startAnchorOffset = 0.0;
    late AnimationController _anchorOffsetAC;

    ValueNotifier<Ancor> _notifier = ValueNotifier(Ancor(secondPerPixel: 50.0, anchor: DateTime.now(), anchorOffset: 0.0));
    ValueNotifier<DateTime> _currentTimeNotifier = ValueNotifier(DateTime.now());

    @override
    void initState() {
        super.initState();
        initializeDateFormatting();
        timer = Timer.periodic(Duration(milliseconds: 30), (Timer t) {
            if (this.mounted) {
                _currentTimeNotifier.value = DateTime.now();
                _currentTimeNotifier.notifyListeners();
            }
        });
        _anchorOffsetAC = AnimationController.unbounded(vsync: this);
        _anchorOffsetAC.addListener(() {
            // print('anchorOffsetAC ${anchorOffsetAC.value}');
            _notifier.value.anchorOffset = _anchorOffsetAC.value;
            if (this.mounted) _notifier.notifyListeners();
        });
    }

    @override
    void dispose() {
        _anchorOffsetAC.dispose();
        super.dispose();
    }

    void setAnchorOffsetValue(double value) {
        _notifier.value.anchorOffset = value;
        _anchorOffsetAC.value = value;
        if (this.mounted) _notifier.notifyListeners();
    }

    void setStartXY(bool vertical, double x, double y) {
        setState(() {
            this.vertical = vertical;
            this.startX = x;
            this.startY = y;
            if (this.vertical) {
                _notifier.value.anchor = getTimeByOffset(x, _notifier.value.anchor, _notifier.value.anchorOffset, _notifier.value.secondPerPixel);
                setAnchorOffsetValue(x);
            } else {
                _notifier.value.anchor = getTimeByOffset(0, _notifier.value.anchor, _notifier.value.anchorOffset, _notifier.value.secondPerPixel);
                setAnchorOffsetValue(0.0);
                this.startAnchorOffset = _notifier.value.anchorOffset;
            }
        });
    }
    void setCurrentXY(double x, double y) {
        setState(() {
            this.currentX = x;
            if (this.vertical) {
                double deltaY = y - this.startY;
                double k = 1.0 - deltaY*0.01;
                double secondPerPixel = _notifier.value.secondPerPixel * k;
                if (secondPerPixel < _minSecondPerPixel) secondPerPixel = _minSecondPerPixel;
                if (secondPerPixel > _maxSecondPerPixel) secondPerPixel = _maxSecondPerPixel;
                _notifier.value.secondPerPixel = secondPerPixel;
                if (this.mounted) _notifier.notifyListeners();

                this.startY = y;
            } else {
                double deltaX = this.currentX - this.startX;
                setAnchorOffsetValue(this.startAnchorOffset + deltaX);
            }
        });
    }
    void endDrag(double velocity) {
        if (this.vertical) {
            // print("Vertical drag ends");
        } else {
            // print("Horizontal drag ends");
            _anchorOffsetAC.animateWith(
                FrictionSimulation(
                    0.05, // the bigger this value, the less friction is applied
                    _notifier.value.anchorOffset,
                    velocity
                )
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                GestureDetector(
                    onHorizontalDragStart:  (DragStartDetails details)  { this.setStartXY(false, details.globalPosition.dx.floorToDouble(), details.globalPosition.dy.floorToDouble()); },
                    onHorizontalDragUpdate: (DragUpdateDetails details) { this.setCurrentXY(details.globalPosition.dx.floorToDouble(), details.globalPosition.dy.floorToDouble()); },
                    onHorizontalDragEnd:    (DragEndDetails details)    { this.endDrag(details.primaryVelocity!); },
                    onVerticalDragStart:    (DragStartDetails details)  { this.setStartXY(true, details.globalPosition.dx.floorToDouble(), details.globalPosition.dy.floorToDouble()); },
                    onVerticalDragUpdate:   (DragUpdateDetails details) { this.setCurrentXY(details.globalPosition.dx.floorToDouble(), details.globalPosition.dy.floorToDouble()); },
                    onVerticalDragEnd:      (DragEndDetails details)    { this.endDrag(0); },

                    behavior: HitTestBehavior.translucent,
                    child: SizedBox(
                        width: double.infinity,
                        height: 120.0,
                        child: RepaintBoundary(
                            child: CustomPaint(
                                painter: TimelinePainter(context: context, notifier: _notifier),
                                child: RepaintBoundary(
                                    child: CustomPaint(
                                        painter: CurrentTimePainter(context: context, notifier: _notifier, currentTimeNotifier: _currentTimeNotifier),
                                        // child: Text("secondPerPixel: ${_notifier.value.secondPerPixel}"),
                                    ),
                                ),
                            ),
                        ),
                    ),
                ),
                // TimelineSettings()
            ],
        );
    }
}
