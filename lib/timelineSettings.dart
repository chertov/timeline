import 'package:flutter/material.dart';

class TimelineSettings {
  final TimelineYearsSettings years;
  final TimelineMonthsSettings months;
  final TimelineDaysSettings days;
  final TimelineHoursSettings hours;
  final TimelineMinutesSettings minutes;
  final TimelineSecondsSettings seconds;

  TimelineSettings(BuildContext context, double scaleValue, double timelineHeight)
      : years = TimelineYearsSettings(context, timelineHeight),
        months = TimelineMonthsSettings(context, timelineHeight),
        days = TimelineDaysSettings(context, scaleValue, timelineHeight),
        hours = TimelineHoursSettings(context, scaleValue, timelineHeight),
        minutes = TimelineMinutesSettings(context, scaleValue, timelineHeight),
        seconds = TimelineSecondsSettings(context, scaleValue, timelineHeight) {
    //updateFor(scaleValue);
  }

  /*void updateFor(scaleValue) {
    this.hours.updateFor(scaleValue);
  }*/
}

/* -------------------------------------------------------- Года --- */
class TimelineYearsSettings {
  final BuildContext _context;
  final double _timelineHeight;

  static const int _tickColorAlpha = 128;
  static const int _yearsColorAlpha = 64;

  late double tickYBottom;
  double tickYTop = 8;
  late Color tickColor;
  late Color yearsColor;
  late Color baseColor;
  double thickness = 1;
  double fontSize = 14;
  double textMargin = 10;

  TimelineYearsSettings(this._context, this._timelineHeight) {
    tickYBottom = _timelineHeight - 1;
    baseColor = Theme.of(_context).textTheme.labelMedium!.color!;
    tickColor = baseColor.withAlpha(_tickColorAlpha);
    yearsColor = baseColor.withAlpha(_yearsColorAlpha);
  }
}

/* -------------------------------------------------------- Месяцы --- */
class TimelineMonthsSettings {
  final BuildContext _context;
  final double _timelineHeight;

  static const int _tickColorAlpha = 128;
  static const int _monthsColorAlpha = 96;

  late double tickYBottom;
  double tickYTop = 30;
  late Color tickColor;
  late Color monthsColor;
  late Color baseColor;
  double thickness = 1;
  double fontSize = 16;
  double textMargin = 10;

  TimelineMonthsSettings(this._context, this._timelineHeight) {
    tickYBottom = _timelineHeight - 1;
    baseColor = Theme.of(_context).textTheme.headlineSmall!.color!;
    tickColor = baseColor.withAlpha(_tickColorAlpha);
    monthsColor = baseColor.withAlpha(_monthsColorAlpha);
  }
}

/* -------------------------------------------------------- Дни --- */
class TimelineDaysSettings {
  final BuildContext _context;
  final double _scaleValue;
  final double _timelineHeight;

  static const double _tickHeight = 67;
  static const double _daysNumbersAppearStart = 3000;
  static const double _daysNumbersAppearEnd = 1800;
  static const double _weekdaysShortAppearStart = 1200;
  static const double _weekdaysFullAppearStart = 600;
  static const int _colorAlpha = 128;

  bool shouldDrawDaysNumbers = false;
  bool shouldDrawWeekdaysShort = false;
  bool shouldDrawWeekdaysFull = false;
  late double tickYBottom;
  late double tickYTop;
  late Color tickColor;
  late Color daysColor;
  late double daysScaleFactor;
  late Color baseColor;
  double thickness = 1;
  double fontSize = 16;
  double textMargin = 10;

  void updateFor(double scaleValue) {
    shouldDrawDaysNumbers = scaleValue < _daysNumbersAppearStart;
    if (!shouldDrawDaysNumbers) return;
    {
      double appearFactor = (_daysNumbersAppearStart - scaleValue) / (_daysNumbersAppearStart - _daysNumbersAppearEnd);
      if (appearFactor > 1) appearFactor = 1;
      daysColor = baseColor.withAlpha((_colorAlpha * appearFactor).round());
      daysScaleFactor = appearFactor;
    }

    shouldDrawWeekdaysShort = scaleValue < _weekdaysShortAppearStart;
    if (!shouldDrawWeekdaysShort) return;

    shouldDrawWeekdaysFull = scaleValue < _weekdaysFullAppearStart;
  }

  TimelineDaysSettings(this._context, this._scaleValue, this._timelineHeight) {
    tickYBottom = _timelineHeight - 1;
    tickYTop = _timelineHeight - _tickHeight;
    baseColor = Theme.of(_context).textTheme.headlineSmall!.color!;
    tickColor = baseColor.withAlpha(_colorAlpha);
    updateFor(_scaleValue);
  }
}

/* -------------------------------------------------------- Часы --- */
class TimelineHoursSettings {
  final BuildContext _context;
  final double _scaleValue;
  final double _timelineHeight;

  static const double _tickBottomOffset = 2;
  static const double _tickHeight = 12;
  static const double _tickHeightShort = 7;
  static const double _tickAppearStart = 1400;
  static const double _tickAppearEnd = 700;
  static const double _hours3AppearStart = 400;
  static const double _hours3AppearEnd = 200;
  static const double _hoursOtherAppearStart = 100;
  static const double _hoursOtherAppearEnd = 50;
  static const int _colorAlpha = 255;

  bool shouldDraw = false;
  bool shouldDrawHours3 = false;
  bool shouldDrawHoursOther = false;
  late double tickYBottom;
  late double tickYTop;
  late double tickYTopShort;
  late Color tickColor;
  late Color hours3Color;
  late double hours3ScaleFactor;
  late Color hoursOtherColor;
  late double hoursOtherScaleFactor;
  late Color baseColor;
  double thickness = 1;
  double fontSize = 16;

  void updateFor(double scaleValue) {
    shouldDraw = scaleValue < _tickAppearStart;
    if (!shouldDraw) return;
    {
      double appearFactor = (_tickAppearStart - scaleValue) / (_tickAppearStart - _tickAppearEnd);
      if (appearFactor > 1) appearFactor = 1;
      tickColor = baseColor.withAlpha((_colorAlpha * appearFactor).round());
    }

    shouldDrawHours3 = scaleValue < _hours3AppearStart;
    if (!shouldDrawHours3) return;
    {
      double appearFactor = (_hours3AppearStart - scaleValue) / (_hours3AppearStart - _hours3AppearEnd);
      if (appearFactor > 1) appearFactor = 1;
      hours3Color = baseColor.withAlpha((_colorAlpha * appearFactor).round());
      hours3ScaleFactor = appearFactor;
    }

    shouldDrawHoursOther = scaleValue < _hoursOtherAppearStart;
    if (!shouldDrawHoursOther) return;
    {
      double appearFactor = (_hoursOtherAppearStart - scaleValue) / (_hoursOtherAppearStart - _hoursOtherAppearEnd);
      if (appearFactor > 1) appearFactor = 1;
      hoursOtherColor = baseColor.withAlpha((_colorAlpha * appearFactor).round());
      hoursOtherScaleFactor = appearFactor;

      double shortTickGrowFactor = (_hoursOtherAppearStart - scaleValue) / (_hoursOtherAppearStart - _hoursOtherAppearEnd);
      if (shortTickGrowFactor < 0) shortTickGrowFactor = 0;
      if (shortTickGrowFactor > 1) shortTickGrowFactor = 1;
      double currentShortTickHeight = _tickHeightShort + (_tickHeight - _tickHeightShort) * shortTickGrowFactor;
      tickYTopShort = _timelineHeight - _tickBottomOffset - currentShortTickHeight;
    }
  }

  TimelineHoursSettings(this._context, this._scaleValue, this._timelineHeight) {
    tickYBottom = _timelineHeight - _tickBottomOffset;
    tickYTop = _timelineHeight - _tickBottomOffset - _tickHeight;
    tickYTopShort = _timelineHeight - _tickBottomOffset - _tickHeightShort;
    baseColor = Theme.of(_context).colorScheme.secondary;
    updateFor(_scaleValue);
  }
}

/* -------------------------------------------------------- Минуты --- */
class TimelineMinutesSettings {
  final BuildContext _context;
  final double _scaleValue;
  final double _timelineHeight;

  static const double _tickBottomOffset = 2;
  static const double _tickHeight = 12;
  static const double _tickHeightShort = 7;
  static const double _tick10AppearStart = 100;
  static const double _tick10AppearEnd = 50;
  static const double _minutes10AppearStart = 20;
  static const double _minutes10AppearEnd = 12;
  static const double _minutes5AppearStart = 9;
  static const double _minutes5AppearEnd = 5;
  static const double _minutesOtherAppearStart = 2;
  static const double _minutesOtherAppearEnd = 1;
  static const int _colorAlpha = 160;

  bool shouldDrawTicks10 = false;
  bool shouldDrawMinutes10 = false;
  bool shouldDrawMinutes5 = false;
  bool shouldDrawMinutesOther = false;
  late double tickYBottom;
  late double tick10YTop;
  late double tick5YTop;
  late double tickOtherYTop;
  late Color tick10Color;
  late Color tickOtherColor;
  late Color minutes10Color;
  late double minutes10ScaleFactor;
  late Color minutes5Color;
  late double minutes5ScaleFactor;
  late Color minutesOtherColor;
  late double minutesOtherScaleFactor;
  late Color baseColor;
  double thickness = 1;
  double fontSize = 16;

  void updateFor(double scaleValue) {
    shouldDrawTicks10 = scaleValue < _tick10AppearStart;
    if (!shouldDrawTicks10) return;
    {
      double appearFactor = (_tick10AppearStart - scaleValue) / (_tick10AppearStart - _tick10AppearEnd);
      if (appearFactor > 1) appearFactor = 1;
      tick10Color = baseColor.withAlpha((_colorAlpha * appearFactor).round());
    }

    shouldDrawMinutes10 = scaleValue < _minutes10AppearStart;
    if (!shouldDrawMinutes10) return;
    {
      double appearFactor = (_minutes10AppearStart - scaleValue) / (_minutes10AppearStart - _minutes10AppearEnd);
      if (appearFactor > 1) appearFactor = 1;
      minutes10Color = baseColor.withAlpha((_colorAlpha * appearFactor).round());
      minutes10ScaleFactor = appearFactor;

      tickOtherColor = baseColor.withAlpha((_colorAlpha * appearFactor).round());

      double currentShortTickHeight = _tickHeightShort + (_tickHeight - _tickHeightShort) * appearFactor;
      tick10YTop = _timelineHeight - _tickBottomOffset - currentShortTickHeight;
    }

    shouldDrawMinutes5 = scaleValue < _minutes5AppearStart;
    if (!shouldDrawMinutes5) return;
    {
      double appearFactor = (_minutes5AppearStart - scaleValue) / (_minutes5AppearStart - _minutes5AppearEnd);
      if (appearFactor > 1) appearFactor = 1;
      minutes5Color = baseColor.withAlpha((_colorAlpha * appearFactor).round());
      minutes5ScaleFactor = appearFactor;

      double currentShortTickHeight = _tickHeightShort + (_tickHeight - _tickHeightShort) * appearFactor;
      tick5YTop = _timelineHeight - _tickBottomOffset - currentShortTickHeight;
    }

    shouldDrawMinutesOther = scaleValue < _minutesOtherAppearStart;
    if (!shouldDrawMinutesOther) return;
    {
      double appearFactor = (_minutesOtherAppearStart - scaleValue) / (_minutesOtherAppearStart - _minutesOtherAppearEnd);
      if (appearFactor > 1) appearFactor = 1;
      minutesOtherColor = baseColor.withAlpha((_colorAlpha * appearFactor).round());
      minutesOtherScaleFactor = appearFactor;

      double currentShortTickHeight = _tickHeightShort + (_tickHeight - _tickHeightShort) * appearFactor;
      tickOtherYTop = _timelineHeight - _tickBottomOffset - currentShortTickHeight;
    }
  }

  TimelineMinutesSettings(this._context, this._scaleValue, this._timelineHeight) {
    tickYBottom = _timelineHeight - _tickBottomOffset;
    tick10YTop = _timelineHeight - _tickBottomOffset - _tickHeightShort;
    tick5YTop = _timelineHeight - _tickBottomOffset - _tickHeightShort;
    tickOtherYTop = _timelineHeight - _tickBottomOffset - _tickHeightShort;
    baseColor = Theme.of(_context).textTheme.headlineSmall!.color!;
    updateFor(_scaleValue);
  }
}

/* -------------------------------------------------------- Секунды --- */
class TimelineSecondsSettings {
  final BuildContext _context;
  final double _scaleValue;
  final double _timelineHeight;

  static const double _tickBottomOffset = 2;
  static const double _tick10Height = 7;
  static const double _tick5Height = 6;
  static const double _tick1Height = 2;
  static const double _tick10AppearStart = 2;
  static const double _tick10AppearEnd = 1;
  static const double _seconds10AppearStart = 0.5;
  static const double _seconds10AppearEnd = 0.3;
  static const int _colorAlpha = 255;

  bool shouldDrawTicks10 = false;
  bool shouldDrawSeconds10 = false;
  late double tickYBottom;
  late double tick10YTop;
  late double tick5YTop;
  late double tick1YTop;
  late Color tick10Color;
  late Color tickOtherColor;
  late Color seconds10Color;
  late double seconds10ScaleFactor;
  late Color baseColor;
  double thickness = 1;
  double fontSize = 12;

  void updateFor(double scaleValue) {
    shouldDrawTicks10 = scaleValue < _tick10AppearStart;
    if (!shouldDrawTicks10) return;
    {
      double appearFactor = (_tick10AppearStart - scaleValue) / (_tick10AppearStart - _tick10AppearEnd);
      if (appearFactor > 1) appearFactor = 1;
      tick10Color = baseColor.withAlpha((_colorAlpha * appearFactor).round());
    }

    shouldDrawSeconds10 = scaleValue < _seconds10AppearStart;
    if (!shouldDrawSeconds10) return;
    {
      double appearFactor = (_seconds10AppearStart - scaleValue) / (_seconds10AppearStart - _seconds10AppearEnd);
      if (appearFactor > 1) appearFactor = 1;
      seconds10Color = baseColor.withAlpha((_colorAlpha * appearFactor).round());
      seconds10ScaleFactor = appearFactor;

      tickOtherColor = baseColor.withAlpha((_colorAlpha * appearFactor).round());
    }
  }

  TimelineSecondsSettings(this._context, this._scaleValue, this._timelineHeight) {
    tickYBottom = _timelineHeight - _tickBottomOffset;
    tick10YTop = _timelineHeight - _tickBottomOffset - _tick10Height;
    tick5YTop = _timelineHeight - _tickBottomOffset - _tick5Height;
    tick1YTop = _timelineHeight - _tickBottomOffset - _tick1Height;
    baseColor = Theme.of(_context).colorScheme.primary;
    updateFor(_scaleValue);
  }
}
