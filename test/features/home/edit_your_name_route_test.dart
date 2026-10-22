import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/constants/navigators/router.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/domain/entities/professional_profile.dart';
import 'package:app_t/features/Home/presentation/pages/edit_your_name_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _profile = ProfessionalProfile(
  displayName: 'Backend professional',
  category: 'Cardiology',
  specialty: 'Heart health',
  bio: 'Existing professional biography',
);

class _ProfileRepository implements ProfileRepository {
  _ProfileRepository({this.profile, this.failure});

  final ProfessionalProfile? profile;
  final Object? failure;
  int updateCalls = 0;
  ProfessionalProfile? saved;

  @override
  Future<ProfessionalProfile?> professionalMe() async {
    if (failure != null) throw failure!;
    return profile;
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
  }) async {
    updateCalls++;
    return saved = ProfessionalProfile(
      displayName: displayName,
      category: category,
      specialty: specialty,
      bio: bio,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _openRoute(
  WidgetTester tester,
  _ProfileRepository? repository,
) async {
  if (repository != null) sl.registerSingleton<ProfileRepository>(repository);
  tester.view.physicalSize = const Size(430, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(430, 1200),
      builder:
          (_, __) => MaterialApp(
            home: const Scaffold(body: Text('Route host')),
            onGenerateRoute: generateRoute,
          ),
    ),
  );
  Navigator.of(
    tester.element(find.text('Route host')),
  ).pushNamed(RouteName.editYourName);
  await tester.pumpAndSettle();
  expect(find.byType(EditYourNameShellPage), findsOneWidget);
}

void main() {
  setUp(() => sl.pushNewScope());
  tearDown(() async => sl.popScope());

  final failures = <String, Object?>{
    'null profile': null,
    '401': const AuthFailure(
      type: AuthFailureType.unauthorized,
      message: 'Private backend failure',
    ),
    '403': const AuthFailure(
      type: AuthFailureType.forbidden,
      message: 'Private backend failure',
    ),
    'network': const AuthFailure(
      type: AuthFailureType.network,
      message: 'Private backend failure',
    ),
    'unexpected failure': StateError('Private backend failure'),
  };
  for (final entry in failures.entries) {
    testWidgets('canonical name route has no fake identity for ${entry.key}', (
      tester,
    ) async {
      final repository = _ProfileRepository(failure: entry.value);
      await _openRoute(tester, repository);
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller!.text, isEmpty);
      expect(find.textContaining('Lagbaja'), findsNothing);
      expect(find.text('Private backend failure'), findsNothing);
      final message = switch (entry.key) {
        'null profile' => 'Professional profile has not been created yet.',
        '401' => 'Please sign in again.',
        '403' => 'This account cannot edit this profile.',
        'network' => 'Service is unavailable. Please try again.',
        _ => 'Something went wrong. Please try again.',
      };
      expect(find.text(message), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Requested name');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repository.updateCalls, 0);
      expect(find.text('Display name saved'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('canonical name route fails safely with missing DI', (
    tester,
  ) async {
    expect(sl.isRegistered<ProfileRepository>(), isFalse);
    await _openRoute(tester, null);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      isEmpty,
    );
    expect(find.textContaining('Lagbaja'), findsNothing);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextFormField), 'Requested name');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Display name saved'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'canonical name route preserves backend identity and save fields',
    (tester) async {
      final repository = _ProfileRepository(profile: _profile);
      await _openRoute(tester, repository);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        _profile.displayName,
      );
      expect(repository.updateCalls, 0);
      await tester.enterText(
        find.byType(TextFormField),
        'Updated professional',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repository.updateCalls, 1);
      expect(repository.saved!.displayName, 'Updated professional');
      expect(repository.saved!.category, _profile.category);
      expect(repository.saved!.specialty, _profile.specialty);
      expect(repository.saved!.bio, _profile.bio);
      expect(find.text('Display name saved'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
