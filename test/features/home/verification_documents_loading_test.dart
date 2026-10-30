import 'dart:async';

import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/repositories/verification_repository.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/onboarding_catalog.dart';
import 'package:app_t/features/Home/domain/entities/verification_document.dart';
import 'package:app_t/features/Home/domain/entities/verification_upload_request.dart';
import 'package:app_t/features/Home/presentation/pages/professional_verification_documents_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _rawError = 'INTERNAL picker/backend secret stack trace';
const _picked = VerificationPickedFile(
  name: 'test-license.pdf',
  mimeType: 'application/pdf',
  bytes: <int>[37, 80, 68, 70],
);
const _document = VerificationDocument(
  id: 'test-document',
  documentType: 'LICENSE',
  status: 'PENDING',
  storageProvider: 'test',
  mimeType: 'application/pdf',
  fileSizeBytes: 4,
  checksumProvided: false,
);
const _readiness = AccountReadiness(
  account: ReadinessAccount(
    role: 'PROFESSIONAL',
    status: 'ACTIVE',
    emailVerified: true,
  ),
  patient: null,
  professional: ProfessionalReadiness(
    applicationStatus: 'READY_TO_SUBMIT',
    verificationStatus: 'NOT_SUBMITTED',
    countryCode: 'NG',
    professionCode: 'MEDICAL_DOCTOR',
    regulatorCode: 'MDCN',
    requiredProfileFields: <String>[],
    requiredEvidence: <String>['GOVERNMENT_IDENTITY'],
    missingEvidence: <String>['GOVERNMENT_IDENTITY'],
  ),
  nextAction: 'PROFESSIONAL_UPLOAD_EVIDENCE',
  requiredActions: <String>['UPLOAD_GOVERNMENT_IDENTITY'],
);
const _catalog = OnboardingCatalog(
  launchCountry: 'NG',
  countries: <OnboardingCountry>[],
  nigeriaStates: <OnboardingRegion>[],
  professionalCatalog: <ProfessionalCatalogItem>[],
  verificationEvidenceTypes: <VerificationEvidenceType>[
    VerificationEvidenceType(
      code: 'GOVERNMENT_IDENTITY',
      label: 'Test identity evidence',
      documentType: 'IDENTITY',
    ),
  ],
  patientHealthInterestCatalog: <PatientHealthInterest>[],
);

class _Documents implements VerificationRepository {
  final calls = <Completer<List<VerificationDocument>>>[];
  final uploads = <VerificationUploadRequest>[];

  @override
  Future<List<VerificationDocument>> documents() {
    final pending = Completer<List<VerificationDocument>>();
    calls.add(pending);
    return pending.future;
  }

  @override
  Future<VerificationDocument> uploadDocument(
    VerificationUploadRequest request,
  ) async {
    uploads.add(request);
    return _document;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Onboarding implements OnboardingRepository {
  final catalogs = <Completer<OnboardingCatalog>>[];
  final readiness = <Completer<AccountReadiness>>[];

  @override
  Future<OnboardingCatalog> onboardingCatalog() {
    final pending = Completer<OnboardingCatalog>();
    catalogs.add(pending);
    return pending.future;
  }

  @override
  Future<AccountReadiness> accountReadiness() {
    final pending = Completer<AccountReadiness>();
    readiness.add(pending);
    return pending.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Picker implements VerificationDocumentPicker {
  final calls = <Completer<VerificationPickedFile?>>[];

  @override
  Future<VerificationPickedFile?> pick() {
    final pending = Completer<VerificationPickedFile?>();
    calls.add(pending);
    return pending.future;
  }
}

class _Harness {
  final documents = _Documents();
  final onboarding = _Onboarding();
  final picker = _Picker();

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 1200),
        builder:
            (_, __) => MaterialApp(
              home: ProfessionalVerificationDocumentsShellPage(
                verificationRepository: documents,
                onboardingRepository: onboarding,
                documentPicker: picker,
              ),
            ),
      ),
    );
    await tester.pump();
  }

  Future<void> finishReadiness(WidgetTester tester) async {
    onboarding.catalogs.last.complete(_catalog);
    await tester.pump();
    onboarding.readiness.last.complete(_readiness);
    await tester.pump();
  }

  Future<void> loaded(WidgetTester tester) async {
    await mount(tester);
    documents.calls.single.complete(<VerificationDocument>[_document]);
    await finishReadiness(tester);
    await tester.pump();
  }
}

Future<void> _refresh(WidgetTester tester) async {
  await tester.ensureVisible(find.byTooltip('Refresh'));
  await tester.tap(find.byTooltip('Refresh'));
  await tester.pump();
}

Future<void> _choose(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(ElevatedButton));
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
}

void _hasDocument() => expect(find.text('PDF document'), findsOneWidget);
void _noRawError() => expect(find.textContaining(_rawError), findsNothing);

void main() {
  for (final duringRefresh in <bool>[false, true]) {
    for (final documentsFirst in <bool>[false, true]) {
      testWidgets(
        'upload during ${duringRefresh ? 'manual refresh' : 'initial load'} waits for old reads '
        '(${documentsFirst ? 'documents' : 'readiness'} first) then fetches fresh sections',
        (tester) async {
          final h = _Harness();
          await h.mount(tester);
          if (duringRefresh) {
            h.documents.calls.single.complete(<VerificationDocument>[]);
            await h.finishReadiness(tester);
            await _refresh(tester);
          }
          h.onboarding.catalogs.last.complete(_catalog);
          await tester.pump();
          final oldDocuments = h.documents.calls.last;
          final oldReadiness = h.onboarding.readiness.last;
          final readsBeforeUpload = h.documents.calls.length;
          final catalogsBeforeUpload = h.onboarding.catalogs.length;
          final readinessBeforeUpload = h.onboarding.readiness.length;

          await _choose(tester);
          h.picker.calls.single.complete(_picked);
          await tester.pump();
          expect(h.documents.uploads, hasLength(1));
          expect(
            find.text('Document uploaded and pending review.'),
            findsOneWidget,
          );
          expect(h.documents.calls, hasLength(readsBeforeUpload));
          expect(h.onboarding.catalogs, hasLength(catalogsBeforeUpload));

          if (documentsFirst) {
            oldDocuments.complete(<VerificationDocument>[]);
          } else {
            oldReadiness.complete(_readiness);
          }
          await tester.pump();
          expect(h.documents.calls, hasLength(readsBeforeUpload));
          expect(h.onboarding.catalogs, hasLength(catalogsBeforeUpload));
          expect(find.text('PDF document'), findsNothing);

          if (documentsFirst) {
            oldReadiness.complete(_readiness);
          } else {
            oldDocuments.complete(<VerificationDocument>[]);
          }
          await tester.pump();
          expect(h.documents.calls, hasLength(readsBeforeUpload + 1));
          expect(h.onboarding.catalogs, hasLength(catalogsBeforeUpload + 1));
          expect(find.text('PDF document'), findsNothing);

          h.documents.calls.last.complete(<VerificationDocument>[_document]);
          h.onboarding.catalogs.last.complete(_catalog);
          await tester.pump();
          expect(h.onboarding.readiness, hasLength(readinessBeforeUpload + 1));
          h.onboarding.readiness.last.complete(_readiness);
          await tester.pump();
          _hasDocument();
          expect(find.text('Choose file to upload'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Refresh joins initial pending catalog and documents requests', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester);
    expect(h.documents.calls, hasLength(1));
    expect(h.onboarding.catalogs, hasLength(1));
    await _refresh(tester);
    await _refresh(tester);
    expect(h.documents.calls, hasLength(1));
    expect(h.onboarding.catalogs, hasLength(1));
    h.onboarding.catalogs.single.complete(_catalog);
    await tester.pump();
    expect(h.onboarding.readiness, hasLength(1));
    await _refresh(tester);
    await _refresh(tester);
    expect(h.documents.calls, hasLength(1));
    expect(h.onboarding.catalogs, hasLength(1));
    expect(h.onboarding.readiness, hasLength(1));
    h.documents.calls.single.complete(<VerificationDocument>[_document]);
    h.onboarding.readiness.single.complete(_readiness);
    await tester.pump();
    _hasDocument();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'loaded documents survive refresh pending and failure then recover on retry',
    (tester) async {
      final h = _Harness();
      await h.loaded(tester);
      _hasDocument();
      await _refresh(tester);
      expect(h.documents.calls, hasLength(2));
      _hasDocument();
      h.documents.calls.last.completeError(StateError(_rawError));
      await h.finishReadiness(tester);
      _hasDocument();
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      _noRawError();
      await _refresh(tester);
      expect(h.documents.calls, hasLength(3));
      h.documents.calls.last.complete(<VerificationDocument>[_document]);
      await h.finishReadiness(tester);
      _hasDocument();
      expect(
        find.text('Something went wrong. Please try again.'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'initial documents failure is safe and Refresh retries successfully',
    (tester) async {
      final h = _Harness();
      await h.mount(tester);
      h.documents.calls.single.completeError(StateError(_rawError));
      await h.finishReadiness(tester);
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      _noRawError();
      await _refresh(tester);
      expect(h.documents.calls, hasLength(2));
      h.documents.calls.last.complete(<VerificationDocument>[_document]);
      await h.finishReadiness(tester);
      _hasDocument();
      expect(
        find.text('Something went wrong. Please try again.'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'repeated upload taps while picker is pending invoke picker once',
    (tester) async {
      final h = _Harness();
      await h.loaded(tester);
      await _choose(tester);
      expect(find.text('Choosing file...'), findsOneWidget);
      expect(find.text('0% uploaded'), findsNothing);
      await _choose(tester);
      await _choose(tester);
      expect(h.picker.calls, hasLength(1));
      expect(h.documents.uploads, isEmpty);
      h.picker.calls.single.complete(null);
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'picker exception shows safe error and allows a successful retry',
    (tester) async {
      final h = _Harness();
      await h.loaded(tester);
      await _choose(tester);
      h.picker.calls.single.completeError(StateError(_rawError));
      await tester.pump();
      expect(tester.takeException(), isNull);
      _noRawError();
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      expect(h.documents.uploads, isEmpty);
      await _choose(tester);
      expect(h.picker.calls, hasLength(2));
      h.picker.calls.last.complete(_picked);
      await tester.pump();
      expect(h.documents.uploads, hasLength(1));
      expect(h.documents.uploads.single.originalFileName, _picked.name);
      h.documents.calls.last.complete(<VerificationDocument>[_document]);
      await tester.pump();
      expect(
        find.text('Document uploaded and pending review.'),
        findsOneWidget,
      );
      expect(
        find.text('Something went wrong. Please try again.'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'disposing while picker is pending never uploads late picked file',
    (tester) async {
      final h = _Harness();
      await h.loaded(tester);
      await _choose(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      h.picker.calls.single.complete(_picked);
      await tester.pump();
      expect(h.documents.uploads, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cancel while picker is pending discards late picked file', (
    tester,
  ) async {
    final h = _Harness();
    await h.loaded(tester);
    await _choose(tester);
    expect(find.text('Cancel upload'), findsOneWidget);
    await tester.tap(find.text('Cancel upload'));
    await tester.pump();
    h.picker.calls.single.complete(_picked);
    await tester.pump();
    expect(h.documents.uploads, isEmpty);
    expect(find.text('Document uploaded and pending review.'), findsNothing);
    await _choose(tester);
    expect(h.picker.calls, hasLength(2));
    h.picker.calls.last.complete(null);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  for (final fail in <bool>[false, true]) {
    testWidgets(
      'documents and readiness late ${fail ? 'failure' : 'success'} after dispose are safe',
      (tester) async {
        final h = _Harness();
        await h.mount(tester);
        h.onboarding.catalogs.single.complete(_catalog);
        await tester.pump();
        expect(h.onboarding.readiness, hasLength(1));
        await tester.pumpWidget(const SizedBox.shrink());
        if (fail) {
          h.documents.calls.single.completeError(StateError(_rawError));
          h.onboarding.readiness.single.completeError(StateError(_rawError));
        } else {
          h.documents.calls.single.complete(<VerificationDocument>[_document]);
          h.onboarding.readiness.single.complete(_readiness);
        }
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(h.documents.uploads, isEmpty);
      },
    );
  }

  testWidgets(
    'readiness failure does not erase successful concurrent documents',
    (tester) async {
      final h = _Harness();
      await h.mount(tester);
      h.documents.calls.single.complete(<VerificationDocument>[_document]);
      h.onboarding.catalogs.single.complete(_catalog);
      await tester.pump();
      h.onboarding.readiness.single.completeError(StateError(_rawError));
      await tester.pump();
      _hasDocument();
      expect(
        find.textContaining('Could not load verification requirements.'),
        findsOneWidget,
      );
      _noRawError();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'documents failure does not erase successful concurrent readiness',
    (tester) async {
      final h = _Harness();
      await h.mount(tester);
      await h.finishReadiness(tester);
      h.documents.calls.single.completeError(StateError(_rawError));
      await tester.pump();
      expect(find.text('Missing: Test identity evidence'), findsOneWidget);
      expect(
        find.text('1 required evidence item still need upload.'),
        findsOneWidget,
      );
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      _noRawError();
      expect(tester.takeException(), isNull);
    },
  );
}
