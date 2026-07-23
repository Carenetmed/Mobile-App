import 'dart:async';

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/domain/entities/patient_profile.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';
import 'package:app_t/features/Home/domain/entities/public_professional.dart';
import 'package:app_t/features/Home/presentation/pages/search_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _phoneSize = Size(430, 1200);

const List<PublicProfessional> _professionals = <PublicProfessional>[
  PublicProfessional(
    id: 'pro_heart',
    displayName: 'Dr Ada Heart',
    category: 'Doctor',
    specialty: 'Cardiology',
    bio: 'Supports long-term heart health.',
    verified: true,
  ),
  PublicProfessional(
    id: 'pro_mind',
    displayName: 'Dr Nneka Mind',
    category: 'Psychologist',
    specialty: 'Mental wellness',
    verified: true,
  ),
];

typedef _ListingLoad = Future<List<PublicProfessional>> Function();

Future<void> _pumpSearch(
  WidgetTester tester, {
  required ProfileRepository profileRepository,
  Key? pageKey,
  List<RouteSettings>? pushedRoutes,
  bool settle = true,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: _phoneSize,
      builder:
          (_, __) => MaterialApp(
            home: SearchShellPage(
              key: pageKey,
              profileRepository: profileRepository,
            ),
            onGenerateRoute: (settings) {
              pushedRoutes?.add(settings);
              return MaterialPageRoute<void>(
                settings: settings,
                builder:
                    (_) => Scaffold(
                      body: Text(
                        'route:${settings.name}:${settings.arguments}',
                      ),
                    ),
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
  _FakeProfileRepository(this.loads);

  factory _FakeProfileRepository.results(
    List<PublicProfessional> professionals,
  ) {
    return _FakeProfileRepository(<_ListingLoad>[() async => professionals]);
  }

  final List<_ListingLoad> loads;
  int publicListingCalls = 0;

  @override
  Future<List<PublicProfessional>> publicProfessionals() {
    final index = publicListingCalls;
    publicListingCalls += 1;
    final safeIndex = index < loads.length ? index : loads.length - 1;
    return loads[safeIndex]();
  }

  @override
  Future<PublicProfessional?> publicProfessionalById({
    required String professionalProfileId,
  }) async {
    final items = await publicProfessionals();
    for (final item in items) {
      if (item.id == professionalProfileId) {
        return item;
      }
    }
    return null;
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
    DateTime? dateOfBirth,
    String? city,
    String? state,
    String? country,
    String? healthInterests,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ProfessionalProfile> updateProfessionalMe({
    required String displayName,
    required String category,
    String? legalName,
    String? specialty,
    String? bio,
    String? licenseNumber,
    String? licensingCouncil,
    String? qualifications,
    int? yearsOfExperience,
    String? practiceName,
    String? practiceAddress,
    String? practiceCity,
    String? practiceState,
    String? practiceCountry,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('initial load is honest and calls the listing once', (
    tester,
  ) async {
    final pending = Completer<List<PublicProfessional>>();
    final repository = _FakeProfileRepository(<_ListingLoad>[
      () => pending.future,
    ]);

    await _pumpSearch(tester, profileRepository: repository, settle: false);

    expect(find.text('Loading verified professionals'), findsOneWidget);
    expect(repository.publicListingCalls, 1);
    expect(find.text('Dr. Uzo Blessing'), findsNothing);

    pending.complete(_professionals);
    await tester.pumpAndSettle();

    expect(find.text('Dr Ada Heart'), findsOneWidget);
    expect(repository.publicListingCalls, 1);
  });

  testWidgets('cards show only supported backend identity fields', (
    tester,
  ) async {
    final repository = _FakeProfileRepository.results(<PublicProfessional>[
      ..._professionals,
      const PublicProfessional(
        id: 'unverified',
        displayName: 'Unverified Person',
        category: 'Doctor',
        bio: 'Must not be shown.',
        verified: false,
      ),
      const PublicProfessional(
        id: '',
        displayName: 'Malformed Person',
        category: 'Doctor',
        verified: true,
      ),
    ]);

    await _pumpSearch(tester, profileRepository: repository);

    expect(find.text('Dr Ada Heart'), findsOneWidget);
    expect(find.text('Doctor - Cardiology'), findsOneWidget);
    expect(find.text('Supports long-term heart health.'), findsOneWidget);
    expect(find.text('Dr Nneka Mind'), findsOneWidget);
    expect(find.text('Verified professional profile.'), findsNothing);
    expect(find.text('Unverified Person'), findsNothing);
    expect(find.text('Malformed Person'), findsNothing);
    expect(find.text('Verified'), findsNWidgets(2));
    expect(find.textContaining('rating'), findsNothing);
    expect(find.textContaining('reviews'), findsNothing);
    expect(find.textContaining('fee'), findsNothing);
    expect(find.textContaining('location'), findsNothing);
    expect(find.textContaining('experience'), findsNothing);
  });

  testWidgets('name search is trimmed and case insensitive without reloading', (
    tester,
  ) async {
    final repository = _FakeProfileRepository.results(_professionals);
    await _pumpSearch(tester, profileRepository: repository);

    await tester.enterText(find.byType(TextFormField), '  ADA HEART  ');
    await tester.pump();

    expect(find.text('Dr Ada Heart'), findsOneWidget);
    expect(find.text('Dr Nneka Mind'), findsNothing);
    expect(repository.publicListingCalls, 1);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(find.text('Dr Ada Heart'), findsOneWidget);
    expect(find.text('Dr Nneka Mind'), findsOneWidget);
    expect(repository.publicListingCalls, 1);
  });

  testWidgets('category and specialty are supported search fields', (
    tester,
  ) async {
    final repository = _FakeProfileRepository.results(_professionals);
    await _pumpSearch(tester, profileRepository: repository);

    await tester.enterText(find.byType(TextFormField), 'psychologist');
    await tester.pump();
    expect(find.text('Dr Nneka Mind'), findsOneWidget);
    expect(find.text('Dr Ada Heart'), findsNothing);

    await tester.enterText(find.byType(TextFormField), 'cardiology');
    await tester.pump();
    expect(find.text('Dr Ada Heart'), findsOneWidget);
    expect(find.text('Dr Nneka Mind'), findsNothing);
    expect(repository.publicListingCalls, 1);
  });

  testWidgets('bio text does not participate in search', (tester) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository.results(_professionals),
    );

    await tester.enterText(find.byType(TextFormField), 'long-term heart');
    await tester.pump();

    expect(find.text('No matching professionals'), findsOneWidget);
    expect(find.text('Dr Ada Heart'), findsNothing);
  });

  testWidgets('category chips filter loaded results without another request', (
    tester,
  ) async {
    final repository = _FakeProfileRepository.results(_professionals);
    await _pumpSearch(tester, profileRepository: repository);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Cardiology'));
    await tester.pump();

    expect(find.text('Dr Ada Heart'), findsOneWidget);
    expect(find.text('Dr Nneka Mind'), findsNothing);
    expect(repository.publicListingCalls, 1);
  });

  testWidgets('backend-empty listing has a dedicated honest state', (
    tester,
  ) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository.results(
        const <PublicProfessional>[],
      ),
    );

    expect(
      find.text('No verified professionals are listed yet'),
      findsOneWidget,
    );
    expect(find.text('No matching professionals'), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('filtered no-results is distinct from backend-empty', (
    tester,
  ) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository.results(_professionals),
    );

    await tester.enterText(find.byType(TextFormField), 'no such specialist');
    await tester.pump();

    expect(find.text('No matching professionals'), findsOneWidget);
    expect(find.text('No verified professionals are listed yet'), findsNothing);
  });

  testWidgets('initial failure shows safe error and retry can recover', (
    tester,
  ) async {
    final repository = _FakeProfileRepository(<_ListingLoad>[
      () => Future<List<PublicProfessional>>.error(
        const AuthFailure(
          type: AuthFailureType.server,
          message: 'raw private failure',
        ),
      ),
      () async => _professionals,
    ]);

    await _pumpSearch(tester, profileRepository: repository);

    expect(find.text('Find Care is unavailable'), findsOneWidget);
    expect(
      find.text('Service is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('raw private failure'), findsNothing);
    expect(find.text('Dr Ada Heart'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Dr Ada Heart'), findsOneWidget);
    expect(repository.publicListingCalls, 2);
  });

  testWidgets('refresh failure retains prior data and offers retry', (
    tester,
  ) async {
    final repository = _FakeProfileRepository(<_ListingLoad>[
      () async => _professionals,
      () => Future<List<PublicProfessional>>.error(
        const AuthFailure(
          type: AuthFailureType.network,
          message: 'raw refresh failure',
        ),
      ),
      () async => _professionals,
    ]);
    await _pumpSearch(tester, profileRepository: repository);
    await tester.enterText(find.byType(TextFormField), 'ada');
    await tester.pump();

    await tester.tap(find.byTooltip('Refresh Find Care'));
    await tester.pumpAndSettle();

    expect(find.text('Dr Ada Heart'), findsOneWidget);
    expect(find.text('Could not refresh Find Care'), findsOneWidget);
    expect(find.textContaining('Previous results are still shown.'), findsOne);
    expect(find.text('raw refresh failure'), findsNothing);
    expect(find.text('ada'), findsOneWidget);

    await tester.tap(find.byTooltip('Retry Find Care refresh'));
    await tester.pumpAndSettle();

    expect(find.text('Could not refresh Find Care'), findsNothing);
    expect(find.text('Dr Ada Heart'), findsOneWidget);
    expect(repository.publicListingCalls, 3);
  });

  testWidgets('repeated refresh requests share one repository load', (
    tester,
  ) async {
    final refresh = Completer<List<PublicProfessional>>();
    final repository = _FakeProfileRepository(<_ListingLoad>[
      () async => _professionals,
      () => refresh.future,
    ]);
    await _pumpSearch(tester, profileRepository: repository);

    final onRefresh =
        tester
            .widget<RefreshIndicator>(find.byType(RefreshIndicator))
            .onRefresh;
    unawaited(onRefresh());
    unawaited(onRefresh());
    await tester.pump();

    expect(repository.publicListingCalls, 2);

    refresh.complete(_professionals);
    await tester.pumpAndSettle();
    expect(repository.publicListingCalls, 2);
  });

  testWidgets('stale older completion cannot replace a newer accepted load', (
    tester,
  ) async {
    final stale = Completer<List<PublicProfessional>>();
    final oldRepository = _FakeProfileRepository(<_ListingLoad>[
      () => stale.future,
    ]);
    final newRepository =
        _FakeProfileRepository.results(const <PublicProfessional>[
          PublicProfessional(
            id: 'current',
            displayName: 'Dr Current Result',
            category: 'Doctor',
            verified: true,
          ),
        ]);
    const pageKey = ValueKey<String>('canonical-find-care');

    await _pumpSearch(
      tester,
      profileRepository: oldRepository,
      pageKey: pageKey,
      settle: false,
    );
    await _pumpSearch(
      tester,
      profileRepository: newRepository,
      pageKey: pageKey,
    );

    expect(find.text('Dr Current Result'), findsOneWidget);

    stale.complete(const <PublicProfessional>[
      PublicProfessional(
        id: 'stale',
        displayName: 'Dr Stale Result',
        category: 'Doctor',
        verified: true,
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Dr Current Result'), findsOneWidget);
    expect(find.text('Dr Stale Result'), findsNothing);
  });

  testWidgets('pending load completion after disposal does not update state', (
    tester,
  ) async {
    final pending = Completer<List<PublicProfessional>>();
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository(<_ListingLoad>[
        () => pending.future,
      ]),
      settle: false,
    );

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    pending.complete(_professionals);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('selection opens specialist details with exact backend id', (
    tester,
  ) async {
    final routes = <RouteSettings>[];
    await _pumpSearch(
      tester,
      profileRepository:
          _FakeProfileRepository.results(const <PublicProfessional>[
            PublicProfessional(
              id: 'backend-professional-id',
              displayName: 'Dr Exact Id',
              category: 'Doctor',
              verified: true,
            ),
          ]),
      pushedRoutes: routes,
    );

    await tester.tap(find.text('View profile'));
    await tester.pumpAndSettle();

    expect(routes.single.name, RouteName.specialistDetails);
    expect(routes.single.arguments, 'backend-professional-id');
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Request appointment'), findsNothing);
  });

  testWidgets('unsupported discovery capabilities are not advertised', (
    tester,
  ) async {
    await _pumpSearch(
      tester,
      profileRepository: _FakeProfileRepository.results(_professionals),
    );

    expect(
      find.text('Search by professional name, category, or specialty'),
      findsOneWidget,
    );
    expect(find.textContaining('symptom'), findsNothing);
    expect(find.textContaining('condition'), findsNothing);
    expect(find.textContaining('disease'), findsNothing);
    expect(find.textContaining('available now'), findsNothing);
    expect(find.textContaining('consultation mode'), findsNothing);
  });
}
