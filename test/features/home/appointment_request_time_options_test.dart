import 'package:app_t/features/Home/domain/entities/availability_window.dart';
import 'package:app_t/features/Home/domain/services/appointment_request_time_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Appointment request time options', () {
    const helper = AppointmentRequestTimeOptions();

    test('matches backend weekday convention for the next seven days', () {
      final options = helper.generate(
        now: DateTime(2026, 7, 14, 8),
        windows: const <AvailabilityWindow>[
          AvailabilityWindow(
            id: 'monday-window',
            weekday: DateTime.monday,
            startMinute: 9 * 60,
            endMinute: 10 * 60,
            timezone: 'Africa/Lagos',
            active: true,
          ),
        ],
      );

      expect(options, hasLength(3));
      expect(options.first.requestedStartAt, DateTime(2026, 7, 20, 9));
      expect(options.map((option) => option.durationMinutes), <int>[
        30,
        45,
        60,
      ]);
    });

    test('formats start and selected-duration end labels', () {
      final options = helper.generate(
        now: DateTime(2026, 7, 14, 8),
        durationMinutes: const <int>[45],
        windows: const <AvailabilityWindow>[
          AvailabilityWindow(
            id: 'tuesday-window',
            weekday: DateTime.tuesday,
            startMinute: 9 * 60 + 5,
            endMinute: 10 * 60,
            timezone: 'Africa/Lagos',
            active: true,
          ),
        ],
      );

      expect(options.single.startTimeLabel, '09:05');
      expect(options.single.endTimeLabel, '09:50');
      expect(options.single.timeRangeLabel, '09:05-09:50');
    });

    test('preserves backend timezone string on generated options', () {
      final options = helper.generate(
        now: DateTime(2026, 7, 14, 8),
        durationMinutes: const <int>[30],
        windows: const <AvailabilityWindow>[
          AvailabilityWindow(
            id: 'timezone-window',
            weekday: DateTime.tuesday,
            startMinute: 11 * 60,
            endMinute: 12 * 60,
            timezone: 'Asia/Kolkata',
            active: true,
          ),
        ],
      );

      expect(options.single.timezone, 'Asia/Kolkata');
    });

    test('generates UTC backend windows as UTC instants', () {
      final options = helper.generate(
        now: DateTime.utc(2026, 7, 16, 8),
        durationMinutes: const <int>[30],
        windows: const <AvailabilityWindow>[
          AvailabilityWindow(
            id: 'utc-window',
            weekday: DateTime.saturday,
            startMinute: 8 * 60 + 30,
            endMinute: 12 * 60,
            timezone: 'UTC',
            active: true,
          ),
        ],
      );

      expect(options.single.requestedStartAt, DateTime.utc(2026, 7, 18, 8, 30));
      expect(options.single.requestedStartAt.isUtc, isTrue);
    });

    test('keeps only durations that fit inside the availability window', () {
      final options = helper.generate(
        now: DateTime(2026, 7, 14, 8),
        windows: const <AvailabilityWindow>[
          AvailabilityWindow(
            id: 'short-window',
            weekday: DateTime.tuesday,
            startMinute: 9 * 60,
            endMinute: 9 * 60 + 30,
            timezone: 'Africa/Lagos',
            active: true,
          ),
        ],
      );

      expect(options, hasLength(1));
      expect(options.single.durationMinutes, 30);
      expect(options.single.requestedEndAt, DateTime(2026, 7, 14, 9, 30));
    });

    test('returns empty for empty, inactive, invalid, and past windows', () {
      expect(
        helper.generate(
          now: DateTime(2026, 7, 14, 8),
          windows: const <AvailabilityWindow>[],
        ),
        isEmpty,
      );

      final options = helper.generate(
        now: DateTime(2026, 7, 14, 10),
        windows: const <AvailabilityWindow>[
          AvailabilityWindow(
            id: 'inactive-window',
            weekday: DateTime.tuesday,
            startMinute: 11 * 60,
            endMinute: 12 * 60,
            timezone: 'Africa/Lagos',
            active: false,
          ),
          AvailabilityWindow(
            id: 'invalid-window',
            weekday: DateTime.tuesday,
            startMinute: 12 * 60,
            endMinute: 11 * 60,
            timezone: 'Africa/Lagos',
            active: true,
          ),
          AvailabilityWindow(
            id: 'past-window',
            weekday: DateTime.tuesday,
            startMinute: 9 * 60,
            endMinute: 10 * 60,
            timezone: 'Africa/Lagos',
            active: true,
          ),
        ],
      );

      expect(options, isEmpty);
    });
  });
}
