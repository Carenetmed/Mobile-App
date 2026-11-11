import 'dart:async';
import 'dart:typed_data';

import 'package:app_t/features/Education/data/repositories/education_content_repository.dart';
import 'package:app_t/features/Education/domain/entities/education_content.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:dio/dio.dart';

class FakeEducationContentDataSource implements EducationContentDataSource {
  FakeEducationContentDataSource([
    Iterable<EducationContent> initial = const [],
  ]) : items = initial.toList();

  final List<EducationContent> items;
  int listCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;
  int uploadCalls = 0;
  int submitCalls = 0;
  int archiveCalls = 0;
  bool failNextList = false;
  AuthFailure? nextListFailure;
  AuthFailure? nextCreateFailure;
  AuthFailure? listFailureAfterSubmit;
  bool commitThenFailCreate = false;
  Completer<void>? listGate;
  final List<Completer<void>?> listGates = <Completer<void>?>[];
  Completer<EducationContent>? createGate;

  @override
  Future<List<EducationContent>> listMine({CancelToken? cancelToken}) async {
    listCalls++;
    final snapshot = List<EducationContent>.of(items);
    final gate =
        listCalls <= listGates.length ? listGates[listCalls - 1] : listGate;
    await gate?.future;
    final authFailure = nextListFailure;
    if (authFailure != null) {
      nextListFailure = null;
      throw authFailure;
    }
    if (failNextList) {
      failNextList = false;
      throw StateError('test list failure');
    }
    return snapshot;
  }

  @override
  Future<EducationContent> createDraft({
    required EducationContentType type,
    required String title,
    String? body,
    String? caption,
  }) async {
    createCalls++;
    if (createGate != null) await createGate!.future;
    final created = EducationContent(
      id: 'created-$createCalls',
      type: type,
      status: 'DRAFT',
      title: title,
      body: body,
      caption: caption,
      mediaDurationMs: null,
      rejectionCode: null,
      createdAt: DateTime.utc(2026, 11, 11),
      updatedAt: DateTime.utc(2026, 11, 11),
      submittedAt: null,
      publishedAt: null,
    );
    if (commitThenFailCreate) items.insert(0, created);
    final createFailure = nextCreateFailure;
    if (createFailure != null) {
      nextCreateFailure = null;
      commitThenFailCreate = false;
      throw createFailure;
    }
    if (!commitThenFailCreate) items.insert(0, created);
    commitThenFailCreate = false;
    return created;
  }

  @override
  Future<EducationContent> updateDraft({
    required EducationContent content,
    required String title,
    String? body,
    String? caption,
  }) async {
    updateCalls++;
    final index = items.indexWhere((item) => item.id == content.id);
    final updated = EducationContent(
      id: content.id,
      type: content.type,
      status: 'DRAFT',
      title: title,
      body: body,
      caption: caption,
      mediaDurationMs: content.mediaDurationMs,
      rejectionCode: null,
      createdAt: content.createdAt,
      updatedAt: DateTime.utc(2026, 11, 11),
      submittedAt: content.submittedAt,
      publishedAt: content.publishedAt,
    );
    if (index >= 0) items[index] = updated;
    return updated;
  }

  @override
  Future<EducationVideoUploadReceipt> uploadVideo({
    required String contentId,
    required String fileName,
    required Uint8List bytes,
    required CancelToken cancelToken,
    void Function(double progress)? onProgress,
  }) async {
    uploadCalls++;
    onProgress?.call(1);
    final item = items.firstWhere((value) => value.id == contentId);
    final index = items.indexOf(item);
    items[index] = EducationContent(
      id: item.id,
      type: item.type,
      status: item.status,
      title: item.title,
      body: item.body,
      caption: item.caption,
      mediaDurationMs: 30000,
      rejectionCode: item.rejectionCode,
      createdAt: item.createdAt,
      updatedAt: DateTime.utc(2026, 11, 11),
      submittedAt: item.submittedAt,
      publishedAt: item.publishedAt,
    );
    return EducationVideoUploadReceipt(
      id: contentId,
      status: item.status,
      durationMs: 30000,
    );
  }

  @override
  Future<void> submit({required String contentId}) async {
    submitCalls++;
    final index = items.indexWhere((item) => item.id == contentId);
    if (index >= 0) {
      items[index] = items[index].copyWith(status: 'PENDING_REVIEW');
    }
    nextListFailure = listFailureAfterSubmit;
    listFailureAfterSubmit = null;
  }

  @override
  Future<void> archive({required String contentId}) async {
    archiveCalls++;
    final index = items.indexWhere((item) => item.id == contentId);
    if (index >= 0) items[index] = items[index].copyWith(status: 'ARCHIVED');
  }
}

EducationContent educationContent({
  String id = 'content-1',
  EducationContentType type = EducationContentType.textPost,
  String status = 'DRAFT',
  String title = 'General health education',
  String? body = 'A factual, general health education post.',
  String? caption,
  String? rejectionCode,
  int? mediaDurationMs,
}) => EducationContent(
  id: id,
  type: type,
  status: status,
  title: title,
  body: body,
  caption: caption,
  mediaDurationMs: mediaDurationMs,
  rejectionCode: rejectionCode,
  createdAt: DateTime.utc(2026, 11, 11),
  updatedAt: DateTime.utc(2026, 11, 11),
  submittedAt: null,
  publishedAt: null,
);
