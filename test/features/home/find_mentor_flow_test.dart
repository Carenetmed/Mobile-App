import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/domain/entities/patient_profile.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/presentation/pages/find_mentor_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

Future<void> _pumpFindMentor(
  WidgetTester tester, {
  required ProfileRepository profileRepository,
  List<String>? pushedRoutes,
  List<Object?>? pushedArguments,
  bool settle = true,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final routes = pushedRoutes ?? <String>[];
  final arguments = pushedArguments ?? <Object?>[];

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: FindMentorShellPage(profileRepository: profileRepository),
            onGenerateRoute: (settings) {
              routes.add(settings.name ?? '');
              arguments.add(settings.arguments);
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => Scaffold(body: Text('route:${settings.name}')),
              );
            },
          ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({
    this.publicListing,
    this.pendingPublicListing,
    this.failure,
  });

  final List<PublicProfessional>? publicListing;
  final Future<List<PublicProfessional>>? pendingPublicListing;
  final Object? failure;

  @override
  Future<List<PublicProfessional>> publicProfessionals() async {
    final pending = pendingPublicListing;
    if (pending != null) {
      return pending;
    }
    final error = failure;
    if (error != null) {
      throw error;
    }
    return publicListing ??
        const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Backend Mentor',
            category: 'Cardiology',
            specialty: 'Heart health',
            bio: 'Backend mentor bio.',
            verified: true,
          ),
        ];
  }

  @override
  Future<PatientProfile?> patientMe() => throw UnimplementedError();

  @override
  Future<ProfessionalProfile?> professionalMe() => throw UnimplementedError();

  @override
  Future<PatientProfile> updatePatientMe({
    required String name,
    int? age,
    String? location,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ProfessionalProfile> updateProfessionalMe({
    required String displayName,
    required String category,
    String? specialty,
    String? bio,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('find mentor reads backend public professionals', (tester) async {
    await _pumpFindMentor(tester, profileRepository: _FakeProfileRepository());

    expect(find.text('Find a Mentor'), findsOneWidget);
    expect(find.text('Dr Backend Mentor'), findsOneWidget);
    expect(find.text('Cardiology - Heart health'), findsOneWidget);
    expect(find.text('Backend mentor bio.'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('Booking in details'), findsOneWidget);
    expect(find.text('Dr. Uzo Blessing'), findsNothing);
    expect(find.text('Saturday'), findsNothing);
    expect(find.text('10:00am'), findsNothing);
    expect(find.text('Book Appointment'), findsNothing);
  });

  testWidgets(
    'find mentor shows backend loading state without local fallback',
    (tester) async {
      final pendingPublicListing = Completer<List<PublicProfessional>>();

      await _pumpFindMentor(
        tester,
        profileRepository: _FakeProfileRepository(
          pendingPublicListing: pendingPublicListing.future,
        ),
        settle: false,
      );

      expect(find.text('Loading verified professionals...'), findsOneWidget);
      expect(find.text('Dr. Uzo Blessing'), findsNothing);
      expect(find.text('Book Appointment'), findsNothing);

      pendingPublicListing.complete(const <PublicProfessional>[]);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('find mentor shows backend empty state without local fallback', (
    tester,
  ) async {
    await _pumpFindMentor(
      tester,
      profileRepository: _FakeProfileRepository(
        publicListing: const <PublicProfessional>[],
      ),
    );

    expect(
      find.text('No verified professionals are available yet.'),
      findsOneWidget,
    );
    expect(find.text('Dr. Uzo Blessing'), findsNothing);
    expect(find.text('Saturday'), findsNothing);
    expect(find.text('10:00am'), findsNothing);
    expect(find.text('Book Appointment'), findsNothing);
  });

  testWidgets('find mentor filters backend professionals by category', (
    tester,
  ) async {
    await _pumpFindMentor(
      tester,
      profileRepository: _FakeProfileRepository(
        publicListing: const <PublicProfessional>[
          PublicProfessional(
            id: 'pro_1',
            displayName: 'Dr Backend Heart',
            category: 'Cardiology',
            specialty: 'Heart health',
            verified: true,
          ),
          PublicProfessional(
            id: 'pro_2',
            displayName: 'Dr Backend Mind',
            category: 'Psychology',
            specialty: 'Mental wellness',
            verified: true,
          ),
        ],
      ),
    );

    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Psychology'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Psychology'));
    await tester.pumpAndSettle();

    expect(find.text('Dr Backend Mind'), findsOneWidget);
    expect(find.text('Dr Backend Heart'), findsNothing);
  });

  testWidgets('find mentor passes backend id to specialist details', (
    tester,
  ) async {
    final pushedRoutes = <String>[];
    final pushedArguments = <Object?>[];

    await _pumpFindMentor(
      tester,
      profileRepository: _FakeProfileRepository(),
      pushedRoutes: pushedRoutes,
      pushedArguments: pushedArguments,
    );

    await tester.tap(find.text('View details').first);
    await tester.pumpAndSettle();

    expect(pushedRoutes, contains(RouteName.specialistDetails));
    expect(pushedArguments, contains('pro_1'));
  });

  testWidgets('find mentor backend failure shows safe error without fallback', (
    tester,
  ) async {
    await _pumpFindMentor(
      tester,
      profileRepository: _FakeProfileRepository(
        failure: const AuthFailure(
          type: AuthFailureType.server,
          message: 'raw public listing failure',
        ),
      ),
    );

    expect(
      find.text('Service is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('raw public listing failure'), findsNothing);
    expect(find.text('Dr. Uzo Blessing'), findsNothing);
    expect(find.text('Saturday'), findsNothing);
    expect(find.text('10:00am'), findsNothing);
    expect(find.text('Book Appointment'), findsNothing);
  });
}
