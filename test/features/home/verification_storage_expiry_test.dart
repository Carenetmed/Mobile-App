import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Home/data/repositories/verification_repository.dart';
import 'package:app_t/features/Home/data/services/verification_api_client.dart';
import 'package:app_t/features/Home/domain/entities/verification_storage_failure.dart';
import 'package:app_t/features/Home/domain/entities/verification_upload_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const _expired =
    '<?xml version="1.0" encoding="UTF-8"?>'
    '<Error><Code>ExpiredToken</Code>'
    '<Message>The provided token has expired.</Message>'
    '<Details>Private provider details must not escape.</Details></Error>';
const _expired403 =
    '<Error><Code>AccessDenied</Code>'
    '<Message>Request has expired.</Message></Error>';
String _xml(String code, String message) =>
    '<Error><Code>$code</Code><Message>$message</Message></Error>';

void main() {
  final cases = <
    ({String name, int status, String body, String mime, bool expiry})
  >[
    (
      name: 'real expired token',
      status: 400,
      body: _expired,
      mime: 'application/xml',
      expiry: true,
    ),
    (
      name: 'text XML expiration',
      status: 400,
      body: _expired,
      mime: 'text/xml; charset=UTF-8',
      expiry: true,
    ),
    (
      name: 'explicit expired access denial',
      status: 403,
      body: _expired403,
      mime: 'application/xml',
      expiry: true,
    ),
    (
      name: 'permission denial',
      status: 403,
      body: _xml('AccessDenied', 'Permission denied.'),
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'signature mismatch',
      status: 403,
      body: _xml('SignatureDoesNotMatch', 'Request has expired.'),
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'wrong 400 code',
      status: 400,
      body: _expired403,
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'wrong 403 code',
      status: 403,
      body: _expired,
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'unconfirmed message',
      status: 400,
      body: _xml('ExpiredToken', 'Invalid request'),
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'expiry word boundary',
      status: 403,
      body: _xml('AccessDenied', 'Request has expiredness'),
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'unknown outcome 412',
      status: 412,
      body: _expired,
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'storage 401 not session rejection',
      status: 401,
      body: _expired,
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'server failure',
      status: 503,
      body: _expired,
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'JSON mime',
      status: 400,
      body: jsonEncode({'Code': 'ExpiredToken'}),
      mime: 'application/json',
      expiry: false,
    ),
    (
      name: 'HTML mime',
      status: 400,
      body: _expired,
      mime: 'text/html',
      expiry: false,
    ),
    (
      name: 'malformed XML',
      status: 400,
      body: '<Error><Code>ExpiredToken',
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'duplicate codes',
      status: 400,
      body: _expired.replaceFirst(
        '</Code>',
        '</Code><Code>ExpiredToken</Code>',
      ),
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'duplicate messages',
      status: 400,
      body: _expired.replaceFirst(
        '</Message>',
        '</Message><Message>The provided token has expired.</Message>',
      ),
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'nested code',
      status: 400,
      body: _expired.replaceFirst(
        '<Details>',
        '<Details><Code>ExpiredToken</Code>',
      ),
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'markup code',
      status: 400,
      body: _xml('<b>ExpiredToken</b>', 'The provided token has expired.'),
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'missing message',
      status: 400,
      body: '<Error><Code>ExpiredToken</Code></Error>',
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'namespace ambiguity',
      status: 400,
      body: _expired.replaceFirst('<Error>', '<Error xmlns="urn:untrusted">'),
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'attribute ambiguity',
      status: 400,
      body: _expired.replaceFirst('<Code>', '<Code reason="other">'),
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'DTD',
      status: 400,
      body: '<!DOCTYPE Error SYSTEM "https://untrusted.example/dtd">$_expired',
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'entity declaration',
      status: 400,
      body: '<!ENTITY x "ExpiredToken">$_expired',
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'oversized body',
      status: 400,
      body: '$_expired${' ' * 16384}',
      mime: 'application/xml',
      expiry: false,
    ),
    (
      name: 'UTF8 byte bound',
      status: 400,
      body: _expired.replaceFirst('</Details>', '${'\u20ac' * 6000}</Details>'),
      mime: 'application/xml',
      expiry: false,
    ),
  ];
  for (final sample in cases) {
    test('storage XML classification: ${sample.name}', () async {
      final storage = _Adapter([
        _Reply(sample.body, sample.status, sample.mime),
      ]);
      final client = _client(storage: storage);
      try {
        await client.uploadBytes(
          signedUploadUrl: 'https://storage.example/private-capability',
          fileBytes: [1, 2, 3],
          mimeType: 'application/pdf',
        );
        fail('Storage error must not succeed');
      } on VerificationStorageFailure catch (failure) {
        expect(
          failure.reason,
          sample.expiry
              ? VerificationStorageFailureReason.expiredCapability
              : VerificationStorageFailureReason.other,
        );
        expect(failure.statusCode, sample.status);
        expect(failure.shouldClearSession, isFalse);
        expect(
          failure.toString(),
          'Could not upload the document. Please try again.',
        );
        expect(failure.toString(), isNot(contains('Private provider')));
      }
      expect(storage.requests, hasLength(1));
      expect(
        storage.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });
  }

  for (final body in [
    'Permission denied.$_expired403',
    '$_expired403 Permission denied.',
    '<![CDATA[Permission denied.]]>$_expired403',
  ]) {
    test('text outside XML root cannot authorize renewal: $body', () async {
      final storage = _Adapter([_Reply(body, 403, 'application/xml')]);
      await expectLater(
        _client(storage: storage).uploadBytes(
          signedUploadUrl: 'https://storage.example/private-capability',
          fileBytes: [1, 2, 3],
          mimeType: 'application/pdf',
        ),
        throwsA(
          isA<VerificationStorageFailure>().having(
            (failure) => failure.reason,
            'reason',
            VerificationStorageFailureReason.other,
          ),
        ),
      );
    });
  }

  for (final status in [400, 403]) {
    test(
      'raw XML $status expiry renews exact same document through real adapters',
      () async {
        final store = InMemorySessionStore();
        await store.save(
          AuthSessionModel.fromJson({
            'accessToken': 'test-owner-token',
            'refreshToken': 'test-refresh',
            'tokenType': 'Bearer',
            'expiresIn': 900,
            'user': {
              'id': 'owner',
              'email': 'owner@example.test',
              'role': 'PROFESSIONAL',
              'status': 'ACTIVE',
              'emailVerified': true,
            },
          }),
        );
        final api = _Adapter([
          _Reply.json(_capability('initial')),
          _Reply.json(_capability('renewed')),
          _Reply.json({
            'document': {
              'id': 'document-1',
              'documentType': 'LICENSE',
              'status': 'PENDING',
              'storageProvider': 'gcs',
              'mimeType': 'application/pdf',
              'fileSizeBytes': 3,
              'checksumProvided': true,
            },
          }),
        ]);
        final storage = _Adapter([
          _Reply(
            status == 400 ? _expired : _expired403,
            status,
            'application/xml',
          ),
          const _Reply('', 200, 'application/octet-stream'),
        ]);
        final repository = VerificationRepository(
          apiClient: _client(storage: storage, api: api),
          sessionStore: store,
          clock: () => DateTime.utc(2026, 11, 4),
        );
        final document = await repository.uploadDocument(
          const VerificationUploadRequest(
            documentType: 'LICENSE',
            originalFileName: 'test.pdf',
            mimeType: 'application/pdf',
            fileBytes: [1, 2, 3],
          ),
        );
        expect(document.id, 'document-1');
        expect(api.requests.map((r) => r.uri.path), [
          '/verification/documents/upload-init',
          '/verification/documents/document-1/upload-renew',
          '/verification/documents/document-1/upload-complete',
        ]);
        expect(storage.requests.map((r) => r.uri.path), [
          '/initial',
          '/renewed',
        ]);
        expect(storage.payloads, [
          [1, 2, 3],
          [1, 2, 3],
        ]);
        for (final request in storage.requests) {
          expect(request.headers['Content-Length'], '3');
          expect(request.headers['x-goog-if-generation-match'], '0');
          expect(request.headers.containsKey('Authorization'), isFalse);
        }
        expect((await store.read())?.user.id, 'owner');
        expect(api.replies, isEmpty);
      },
    );
  }
}

Map<String, dynamic> _capability(String path) => {
  'document': {
    'id': 'document-1',
    'documentType': 'LICENSE',
    'status': 'PENDING',
    'storageProvider': 'gcs',
    'mimeType': 'application/pdf',
    'fileSizeBytes': 3,
  },
  'upload': {
    'signedUrl': 'https://storage.example/$path',
    'expiresInSeconds': 300,
    'expiresAt': '2030-01-01T00:00:00Z',
    'requiredHeaders': {
      'content-type': 'application/pdf',
      'content-length': '3',
      'x-goog-if-generation-match': '0',
    },
  },
};

VerificationApiClient _client({required _Adapter storage, _Adapter? api}) =>
    VerificationApiClient(
      config: const CareNetApiConfig(baseUrl: 'https://api.example.test'),
      dio: Dio()..httpClientAdapter = api ?? _Adapter([]),
      uploadDio: Dio()..httpClientAdapter = storage,
    );

class _Reply {
  const _Reply(this.body, this.status, this.mime);
  factory _Reply.json(Object body) =>
      _Reply(jsonEncode(body), 200, 'application/json');
  final String body;
  final int status;
  final String mime;
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.replies);
  final List<_Reply> replies;
  final requests = <RequestOptions>[];
  final payloads = <List<int>>[];
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    payloads.add(await requestStream?.expand((bytes) => bytes).toList() ?? []);
    if (replies.isEmpty) throw StateError('Unexpected test request');
    final reply = replies.removeAt(0);
    return ResponseBody.fromString(
      reply.body,
      reply.status,
      headers: {
        Headers.contentTypeHeader: [reply.mime],
      },
    );
  }
}
