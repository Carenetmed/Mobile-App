import 'package:app_t/app.dart';
import 'package:app_t/core/config/carenet_locale.dart';
import 'package:app_t/core/presentation/carenet_presentation.dart';
import 'package:app_t/features/Home/domain/services/money_formatter.dart';
import 'package:app_t/features/Home/domain/services/professional_time_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  test(
    'initialization is reusable and never changes the ambient locale',
    () async {
      final previous = Intl.defaultLocale;
      Intl.defaultLocale = 'fr_FR';
      addTearDown(() => Intl.defaultLocale = previous);
      await CareNetPresentation.initialize();
      await CareNetPresentation.initialize();
      expect(Intl.defaultLocale, 'fr_FR');
      expect(CareNetPresentation.dateLocale, 'en_GB');
      expect(CareNetPresentation.numberLocale, 'en_NG');
    },
  );

  test('money grouping remains exact and independent of ambient language', () {
    Intl.withLocale('fr_FR', () {
      expect(formatNgnMinor(123456), 'NGN 1,234.56');
      expect(formatNgnMinor(-12345), '-NGN 123.45');
      expect(formatNgnMinor(1), 'NGN 0.01');
    });
  });

  test('presentation locale never changes the monetary input contract', () {
    Intl.withLocale('fr_FR', () {
      expect(parseNgnMajorToMinor('1234.56'), 123456);
      expect(parseNgnMajorToMinor('1,234.56'), isNull);
      expect(parseNgnMajorToMinor('1234,56'), isNull);
    });
  });

  test(
    'professional labels remain English and preserve the supplied IANA zone',
    () {
      final formatter = ProfessionalTimeFormatter();
      final instant = DateTime.utc(2026, 10, 14, 13, 5);
      final labels = Intl.withLocale(
        'fr_FR',
        () => formatter.format(
          utcStartAt: instant,
          professionalTimezone: 'Africa/Lagos',
        ),
      );
      expect(labels.professionalDate, 'Wed, 14 Oct 2026');
      expect(labels.professionalTime, '2:05 pm');
      expect(labels.professionalTimezone, 'Africa/Lagos');
      expect(instant.toIso8601String(), '2026-10-14T13:05:00.000Z');
    },
  );

  test('locale setup does not replace DST conversion with a fixed offset', () {
    final formatter = ProfessionalTimeFormatter();
    final before = formatter.format(
      utcStartAt: DateTime.utc(2026, 3, 8, 6, 30),
      professionalTimezone: 'America/New_York',
    );
    final after = formatter.format(
      utcStartAt: DateTime.utc(2026, 3, 8, 7, 30),
      professionalTimezone: 'America/New_York',
    );
    expect(before.professionalTime, '1:30 am');
    expect(after.professionalTime, '3:30 am');
  });

  testWidgets(
    'app controls use day-first dates and explicit twelve-hour time',
    (tester) async {
      late BuildContext localized;
      await tester.pumpWidget(
        MaterialApp(
          locale: CareNetLocale.locale,
          supportedLocales: CareNetLocale.supportedLocales,
          localizationsDelegates: CareNetLocale.delegates,
          builder: CareNetLocale.builder,
          home: Builder(
            builder: (context) {
              localized = context;
              return const Scaffold(body: Text('locale fixture'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final material = MaterialLocalizations.of(localized);
      expect(Localizations.localeOf(localized), const Locale('en', 'NG'));
      expect(material.formatCompactDate(DateTime(2026, 10, 14)), '14/10/2026');
      expect(material.parseCompactDate('14/10/2026'), DateTime(2026, 10, 14));
      expect(material.dateHelpText, 'dd/mm/yyyy');
      expect(
        material.formatTimeOfDay(const TimeOfDay(hour: 14, minute: 5)),
        '2:05 pm',
      );
      expect(MediaQuery.of(localized).alwaysUse24HourFormat, isFalse);
    },
  );

  testWidgets(
    'clock policy preserves enlarged text and other media preferences',
    (tester) async {
      late MediaQueryData data;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(3.2),
              alwaysUse24HourFormat: true,
              disableAnimations: true,
            ),
            child: Builder(
              builder:
                  (context) => CareNetLocale.builder(
                    context,
                    Builder(
                      builder: (context) {
                        data = MediaQuery.of(context);
                        return const SizedBox();
                      },
                    ),
                  ),
            ),
          ),
        ),
      );
      expect(data.alwaysUse24HourFormat, isFalse);
      expect(data.textScaler.scale(10), 32);
      expect(data.disableAnimations, isTrue);
    },
  );

  testWidgets(
    'actual app locale does not follow an unsupported device language',
    (tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale('fr', 'FR')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(const CarenetApp());
      await tester.pump();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.locale, const Locale('en', 'NG'));
      expect(app.supportedLocales, [const Locale('en', 'NG')]);
      expect(app.localizationsDelegates, CareNetLocale.delegates);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    },
  );
}
