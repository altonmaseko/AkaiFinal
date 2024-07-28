import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:akai/utils/constants/colors.dart';

class TCalendarTheme {
  TCalendarTheme._();


  static final CalendarTheme = CalendarStyle(
    todayDecoration:
        BoxDecoration(color: TColors.beige, shape: BoxShape.circle),
    selectedDecoration:
        BoxDecoration(color: TColors.watermelonPink, shape: BoxShape.circle),
    rangeHighlightColor: TColors.rosePink.withOpacity(0.5),

    rangeEndDecoration:  BoxDecoration(color: TColors.watermelonPink, shape: BoxShape.circle),
    rangeStartDecoration:  BoxDecoration(color: TColors.watermelonPink, shape: BoxShape.circle),

  );
}
