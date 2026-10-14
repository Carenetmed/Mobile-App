import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import '../presentation/carenet_presentation.dart';

class CareNetLocale {
  CareNetLocale._();

  static const locale = Locale('en', 'NG');
  static const supportedLocales = [locale];
  static const delegates = <LocalizationsDelegate<dynamic>>[
    _MaterialDelegate(),
    _CupertinoDelegate(),
    GlobalWidgetsLocalizations.delegate,
  ];

  static Widget builder(BuildContext context, Widget? child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
    child: child ?? const SizedBox.shrink(),
  );
}

class _MaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialDelegate();

  @override
  bool isSupported(Locale locale) => locale == CareNetLocale.locale;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    if (CareNetPresentation.isInitialized) {
      return SynchronousFuture(_EnglishDayFirstMaterial());
    }
    return CareNetPresentation.initialize().then(
      (_) => _EnglishDayFirstMaterial(),
    );
  }

  @override
  bool shouldReload(_MaterialDelegate old) => false;
}

class _EnglishDayFirstMaterial extends MaterialLocalizationEnGb {
  _EnglishDayFirstMaterial()
    : super(
        fullYearFormat: DateFormat.y(CareNetPresentation.dateLocale),
        compactDateFormat: DateFormat.yMd(CareNetPresentation.dateLocale),
        shortDateFormat: DateFormat.yMMMd(CareNetPresentation.dateLocale),
        mediumDateFormat: DateFormat.MMMEd(CareNetPresentation.dateLocale),
        longDateFormat: DateFormat.yMMMMEEEEd(CareNetPresentation.dateLocale),
        yearMonthFormat: DateFormat.yMMMM(CareNetPresentation.dateLocale),
        shortMonthDayFormat: DateFormat.MMMd(CareNetPresentation.dateLocale),
        decimalFormat: NumberFormat.decimalPattern(
          CareNetPresentation.numberLocale,
        ),
        twoDigitZeroPaddedFormat: NumberFormat(
          '00',
          CareNetPresentation.numberLocale,
        ),
      );

  @override
  String get anteMeridiemAbbreviation => 'am';

  @override
  String get postMeridiemAbbreviation => 'pm';

  @override
  TimeOfDayFormat timeOfDayFormat({bool alwaysUse24HourFormat = false}) =>
      alwaysUse24HourFormat
          ? TimeOfDayFormat.HH_colon_mm
          : TimeOfDayFormat.h_colon_mm_space_a;
}

class _CupertinoDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CupertinoDelegate();

  @override
  bool isSupported(Locale locale) => locale == CareNetLocale.locale;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en', 'GB'));

  @override
  bool shouldReload(_CupertinoDelegate old) => false;
}
