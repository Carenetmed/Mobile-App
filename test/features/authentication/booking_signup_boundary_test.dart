import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_role_selection.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/storage/booking_intent_store.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/booking_intent.dart';
import 'package:app_t/features/Home/domain/services/booking_resume_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() async {
    await sl.reset();
  });

  testWidgets('booking-origin signup offers only a patient account', (
    tester,
  ) async {
    final store = InMemoryBookingIntentStore();
    await store.save(_intent());
    _registerResumeService(store);

    await _pumpRoleSelection(tester);

    expect(find.text('Create a patient account'), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Medical professional'), findsNothing);
    expect(find.textContaining('require a patient account'), findsOneWidget);
  });

  testWidgets('normal signup keeps both role choices', (tester) async {
    final store = InMemoryBookingIntentStore();
    _registerResumeService(store);

    await _pumpRoleSelection(tester);

    expect(find.text('How will you use CareNet?'), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Medical professional'), findsOneWidget);
  });
}

Future<void> _pumpRoleSelection(WidgetTester tester) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(430, 932),
      builder:
          (_, __) => const MaterialApp(
            home: SignUpRoleSelectionPage(passwordSignUp: true),
          ),
    ),
  );
  await tester.pumpAndSettle();
}

void _registerResumeService(BookingIntentStore store) {
  sl.registerSingleton<BookingResumeService>(
    BookingResumeService(
      bookingIntentStore: store,
      sessionStore: InMemorySessionStore(),
      onboardingRepository: const _FakeOnboardingRepository(),
    ),
  );
}

BookingIntent _intent() {
  final now = DateTime.now().toUtc();
  return BookingIntent(
    professionalProfileId: 'pro-1',
    startAt: now.add(const Duration(hours: 3)),
    endAt: now.add(const Duration(hours: 3, minutes: 30)),
    durationMinutes: 30,
    idempotencyKey: 'booking-key-12345678',
    resumeRoute: RouteName.specialistDetails,
    createdAt: now,
    expiresAt: now.add(const Duration(hours: 24)),
  );
}

class _FakeOnboardingRepository implements OnboardingRepository {
  const _FakeOnboardingRepository();

  @override
  Future<AccountReadiness> accountReadiness() async {
    throw UnimplementedError();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
