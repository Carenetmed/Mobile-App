import 'package:app_t/features/Home/data/models/verification_document_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> response() => <String, dynamic>{
  'document': <String, dynamic>{
    'mimeType': 'application/pdf',
    'fileSizeBytes': 3,
  },
  'upload': <String, dynamic>{
    'signedUrl': 'https://storage.example/signed-upload',
    'expiresInSeconds': 900,
    'expiresAt': '2026-10-31T12:00:00.000Z',
    'requiredHeaders': <String, dynamic>{
      'Content-Type': 'application/pdf',
      'Content-Length': '3',
      'X-Goog-If-Generation-Match': '0',
    },
  },
};

void main() {
  test('legacy response and original const constructor remain supported', () {
    final json = response();
    final upload = json['upload'] as Map<String, dynamic>;
    upload.remove('expiresAt');
    upload.remove('requiredHeaders');
    final model = VerificationUploadInitModel.fromJson(json);
    expect(model.expiresAt, isNull);
    expect(model.requiredHeaders, isEmpty);
    expect(model.expiresInSeconds, 900);
    const original = VerificationUploadInitModel(
      document: VerificationDocumentModel(
        id: '',
        documentType: '',
        status: '',
        storageProvider: '',
        mimeType: '',
        checksumProvided: false,
      ),
      signedUploadUrl: '',
      expiresInSeconds: 0,
    );
    expect(original.requiredHeaders, isEmpty);
    expect(VerificationUploadInitModel.fromJson({}).expiresInSeconds, 0);
  });

  test(
    'new metadata is typed, normalized, immutable and defensively copied',
    () {
      final json = response();
      final model = VerificationUploadInitModel.fromJson(json);
      expect(model.expiresAt, DateTime.utc(2026, 10, 31, 12));
      expect(model.expiresAt!.isUtc, isTrue);
      expect(model.signedUploadUrl, 'https://storage.example/signed-upload');
      expect(model.requiredHeaders, {
        'content-type': 'application/pdf',
        'content-length': '3',
        'x-goog-if-generation-match': '0',
      });
      expect(
        () => model.requiredHeaders['content-length'] = '4',
        throwsUnsupportedError,
      );
      (json['upload']['requiredHeaders'] as Map).clear();
      expect(model.requiredHeaders, hasLength(3));
    },
  );

  for (final mime in ['application/pdf', 'image/jpeg', 'image/png']) {
    test('accepts approved MIME $mime with absent document metadata', () {
      final json = response();
      json['document'] = <String, dynamic>{};
      json['upload']['requiredHeaders']['Content-Type'] = mime;
      expect(
        VerificationUploadInitModel.fromJson(
          json,
        ).requiredHeaders['content-type'],
        mime,
      );
    });
  }

  final badExpiry = <dynamic>[
    null,
    900,
    '',
    'tomorrow',
    '2026-10-31T12:00:00',
    '2026-10-31T12:00:00+01:00',
    '2026-02-30T12:00:00Z',
    '2026-10-31T25:00:00Z',
  ];
  for (var i = 0; i < badExpiry.length; i++) {
    test('rejects malformed absolute expiry $i', () {
      final json = response();
      json['upload']['expiresAt'] = badExpiry[i];
      expect(
        () => VerificationUploadInitModel.fromJson(json),
        throwsFormatException,
      );
    });
  }
  for (final value in <dynamic>[null, '900', 1.5, 0, -1, true]) {
    test('rejects explicit invalid duration $value', () {
      final json = response();
      json['upload']['expiresInSeconds'] = value;
      expect(
        () => VerificationUploadInitModel.fromJson(json),
        throwsFormatException,
      );
    });
  }
  for (final missing in ['expiresAt', 'requiredHeaders']) {
    test('rejects partial metadata missing $missing', () {
      final json = response();
      (json['upload'] as Map).remove(missing);
      expect(
        () => VerificationUploadInitModel.fromJson(json),
        throwsFormatException,
      );
    });
  }
  final invalidHeaders = <dynamic>[
    null,
    [],
    'headers',
    {},
    {'content-type': 'application/pdf'},
    {
      'Content-Type': 'application/pdf',
      'content-type': 'application/pdf',
      'Content-Length': '3',
      'X-Goog-If-Generation-Match': '0',
    },
    {1: 'value'},
  ];
  for (var i = 0; i < invalidHeaders.length; i++) {
    test('rejects malformed header map $i', () {
      final json = response();
      json['upload']['requiredHeaders'] = invalidHeaders[i];
      expect(
        () => VerificationUploadInitModel.fromJson(json),
        throwsFormatException,
      );
    });
  }
  final invalidValues = <String, List<dynamic>>{
    'Content-Type': [
      null,
      3,
      '',
      'text/plain',
      'image/jpg',
      'application/pdf\r\nAuthorization: secret',
      'image/png',
    ],
    'Content-Length': [
      null,
      3,
      '',
      '0',
      '-1',
      '1.5',
      ' 3',
      '+3',
      '3\r\nHost: evil',
      '999999999999999999999999',
      '4',
    ],
    'X-Goog-If-Generation-Match': [null, 0, '', '1', '00', ' 0'],
    'Authorization': ['Bearer secret'],
    'Cookie': ['session=secret'],
    'Host': ['evil.example'],
    'X-Other': ['value'],
    ' Content-Type': ['application/pdf'],
  };
  for (final entry in invalidValues.entries) {
    for (var i = 0; i < entry.value.length; i++) {
      test('rejects invalid ${entry.key} value $i', () {
        final json = response();
        json['upload']['requiredHeaders'][entry.key] = entry.value[i];
        expect(
          () => VerificationUploadInitModel.fromJson(json),
          throwsFormatException,
        );
      });
    }
  }
  test('rejects explicitly null document size', () {
    final json = response();
    json['document']['fileSizeBytes'] = null;
    expect(
      () => VerificationUploadInitModel.fromJson(json),
      throwsFormatException,
    );
  });
}
