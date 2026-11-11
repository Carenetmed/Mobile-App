import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/data/repositories/education_content_repository.dart';
import 'package:app_t/features/Education/domain/entities/education_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class EducationStudioController extends ChangeNotifier {
  EducationStudioController(this._repository);

  final EducationContentDataSource _repository;
  final List<EducationContent> _items = <EducationContent>[];
  Future<void>? _loadOperation;
  CancelToken? _listCancelToken;
  CancelToken? _uploadCancelToken;
  bool _disposed = false;
  bool _hasLoaded = false;
  bool _loading = false;
  bool _mutating = false;
  double _uploadProgress = 0;
  String? _loadError;
  String? _actionError;
  String? _notice;
  bool _authoringUnavailable = false;
  _EducationDraftRequest? _uncertainCreate;
  _EducationDraftRequest? _reconciledCreateRequest;
  EducationContent? _reconciledCreateContent;

  List<EducationContent> get items =>
      List<EducationContent>.unmodifiable(_items);
  bool get hasLoaded => _hasLoaded;
  bool get isLoading => _loading && !_hasLoaded;
  bool get isRefreshing => _loading && _hasLoaded;
  bool get isMutating => _mutating;
  double get uploadProgress => _uploadProgress;
  String? get loadError => _loadError;
  String? get actionError => _actionError;
  String? get notice => _notice;
  bool get authoringUnavailable => _authoringUnavailable;
  bool get hasUncertainCreate => _uncertainCreate != null;

  Future<void> load() {
    if (_disposed) return Future<void>.value();
    final active = _loadOperation;
    if (active != null) return active;
    return _startLoad();
  }

  Future<void> refresh() async {
    if (_disposed || _loading) return;
    await _startLoad();
  }

  Future<EducationContent?> createDraft({
    required EducationContentType type,
    required String title,
    String? body,
    String? caption,
  }) => _saveDraft(
    _EducationDraftRequest(
      type: type,
      title: title,
      body: body,
      caption: caption,
    ),
  );

  Future<EducationContent?> retryUncertainCreate() {
    final request = _uncertainCreate;
    if (request == null || _mutating || _disposed) {
      return Future<EducationContent?>.value();
    }
    _uncertainCreate = null;
    _notify();
    return _saveDraft(request, explicitRetry: true);
  }

  Future<EducationContent?> _saveDraft(
    _EducationDraftRequest request, {
    bool explicitRetry = false,
  }) async {
    if (_disposed || _mutating) return null;
    final reconciled = _takeReconciledCreate(request);
    if (!explicitRetry && reconciled != null) return reconciled;
    if (!explicitRetry && _uncertainCreate != null) {
      _actionError =
          'A previous save may have reached CareNet. Check your posts before starting another save.';
      _notify();
      return null;
    }
    EducationContent? created;
    final succeeded = await _runMutation(() async {
      try {
        created = await _repository.createDraft(
          type: request.type,
          title: request.title,
          body: request.body,
          caption: request.caption,
        );
      } on AuthFailure catch (failure) {
        if (failure.type == AuthFailureType.network ||
            failure.type == AuthFailureType.server) {
          _uncertainCreate = request;
        }
        rethrow;
      } on DioException catch (failure) {
        if (failure.type != DioExceptionType.cancel) {
          _uncertainCreate = request;
        }
        rethrow;
      }
      _uncertainCreate = null;
      _upsert(created!);
    }, successMessage: 'Draft saved.');
    if (succeeded) return created;
    if (_disposed) return null;
    if (_uncertainCreate != request) {
      return _takeReconciledCreate(request);
    }

    await _reloadAfterMutation();
    final matched = _takeReconciledCreate(request);
    if (matched != null) return matched;
    if (!_disposed) {
      _actionError =
          'CareNet did not confirm whether this draft was saved. Refresh your posts. Retrying may create a duplicate.';
      _notify();
    }
    return null;
  }

  Future<bool> updateDraft({
    required EducationContent content,
    required String title,
    String? body,
    String? caption,
  }) => _runMutation(() async {
    final updated = await _repository.updateDraft(
      content: content,
      title: title,
      body: body,
      caption: caption,
    );
    _upsert(updated);
  }, successMessage: 'Draft updated.');

  Future<bool> uploadVideo({
    required String contentId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (_mutating || _disposed) return false;
    final cancelToken = CancelToken();
    _uploadCancelToken = cancelToken;
    final succeeded = await _runMutation(() async {
      final receipt = await _repository.uploadVideo(
        contentId: contentId,
        fileName: fileName,
        bytes: bytes,
        cancelToken: cancelToken,
        onProgress: (progress) {
          if (_disposed || cancelToken.isCancelled) return;
          _uploadProgress = progress;
          _notify();
        },
      );
      _replaceWhere(
        contentId,
        (item) => EducationContent(
          id: item.id,
          type: item.type,
          status: receipt.status,
          title: item.title,
          body: item.body,
          caption: item.caption,
          mediaDurationMs: receipt.durationMs,
          rejectionCode: item.rejectionCode,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt,
          submittedAt: item.submittedAt,
          publishedAt: item.publishedAt,
        ),
      );
    }, successMessage: 'Video uploaded to your draft.');
    if (identical(_uploadCancelToken, cancelToken)) _uploadCancelToken = null;
    _uploadProgress = 0;
    _notify();
    return succeeded;
  }

  void cancelUpload() {
    _uploadCancelToken?.cancel('Upload cancelled by the professional.');
  }

  Future<bool> submit(EducationContent content) => _runMutation(() async {
    if (!content.canSubmit) {
      throw const AuthFailure(
        type: AuthFailureType.validation,
        message: 'Add the required text or upload a video before submitting.',
      );
    }
    await _repository.submit(contentId: content.id);
    _replaceWhere(
      content.id,
      (item) =>
          item.copyWith(status: 'PENDING_REVIEW', clearRejectionCode: true),
    );
  }, successMessage: 'Submitted for professional review.');

  Future<bool> archive(EducationContent content) => _runMutation(() async {
    await _repository.archive(contentId: content.id);
    _replaceWhere(content.id, (item) => item.copyWith(status: 'ARCHIVED'));
  }, successMessage: 'Post archived.');

  Future<bool> _runMutation(
    Future<void> Function() operation, {
    required String successMessage,
  }) async {
    if (_mutating || _disposed) return false;
    _mutating = true;
    _actionError = null;
    _notice = null;
    _notify();
    try {
      await operation();
      if (_disposed) return true;
      _notice = successMessage;
      await _reloadAfterMutation();
      return true;
    } on AuthFailure catch (failure) {
      if (!_disposed) _actionError = failure.message;
      if (!_disposed &&
          (failure.type == AuthFailureType.forbidden ||
              failure.type == AuthFailureType.unauthorized)) {
        _uncertainCreate = null;
        _reconciledCreateRequest = null;
        _reconciledCreateContent = null;
        _items.clear();
        _hasLoaded = false;
        _authoringUnavailable = true;
        _loadError = failure.message;
      }
      return false;
    } on DioException catch (failure) {
      if (!_disposed) {
        _actionError =
            failure.type == DioExceptionType.cancel
                ? 'Video upload cancelled. Your draft is still saved.'
                : 'The request could not be completed. Refresh your posts and try again.';
      }
      return false;
    } catch (_) {
      if (!_disposed) {
        _actionError = 'The request could not be completed. Please try again.';
      }
      return false;
    } finally {
      _mutating = false;
      if (!_disposed) _notify();
    }
  }

  Future<void> _reloadAfterMutation() async {
    _listCancelToken?.cancel('Reloading after a confirmed content change.');
    _listCancelToken = null;
    _loadOperation = null;
    _loading = false;
    await load();
  }

  Future<void> _startLoad() {
    final cancelToken = CancelToken();
    _listCancelToken = cancelToken;
    _loading = true;
    _loadError = null;
    _notify();
    final operation = _performLoad(cancelToken);
    _loadOperation = operation;
    return operation;
  }

  Future<void> _performLoad(CancelToken cancelToken) async {
    try {
      final loaded = await _repository.listMine(cancelToken: cancelToken);
      if (_disposed || cancelToken.isCancelled) return;
      _items
        ..clear()
        ..addAll(loaded);
      final uncertain = _uncertainCreate;
      if (uncertain != null) {
        for (final item in loaded) {
          if (uncertain.matches(item)) {
            _uncertainCreate = null;
            _reconciledCreateRequest = uncertain;
            _reconciledCreateContent = item;
            _actionError = null;
            _notice = 'A matching draft is already saved in your posts.';
            break;
          }
        }
      }
      _hasLoaded = true;
      _loadError = null;
      _authoringUnavailable = false;
    } on DioException catch (error) {
      if (_disposed || error.type == DioExceptionType.cancel) return;
      _loadError = 'Could not load your education posts. Please retry.';
    } on AuthFailure catch (failure) {
      if (_disposed) return;
      _loadError = failure.message;
      if (failure.type == AuthFailureType.forbidden ||
          failure.type == AuthFailureType.unauthorized) {
        _uncertainCreate = null;
        _reconciledCreateRequest = null;
        _reconciledCreateContent = null;
        _items.clear();
        _hasLoaded = false;
        _authoringUnavailable = true;
      }
    } catch (_) {
      if (_disposed) return;
      _loadError = 'Could not load your education posts. Please retry.';
    } finally {
      if (!_disposed && identical(_listCancelToken, cancelToken)) {
        _loading = false;
        _listCancelToken = null;
        _loadOperation = null;
        _notify();
      }
    }
  }

  void _upsert(EducationContent content) {
    final index = _items.indexWhere((item) => item.id == content.id);
    if (index < 0) {
      _items.insert(0, content);
    } else {
      _items[index] = content;
    }
  }

  EducationContent? _takeReconciledCreate(_EducationDraftRequest request) {
    if (_reconciledCreateRequest?.samePayload(request) != true) return null;
    final content = _reconciledCreateContent;
    _reconciledCreateRequest = null;
    _reconciledCreateContent = null;
    return content;
  }

  void _replaceWhere(
    String id,
    EducationContent Function(EducationContent) update,
  ) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) _items[index] = update(_items[index]);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _listCancelToken?.cancel('Education studio closed.');
    _uploadCancelToken?.cancel('Education studio closed.');
    super.dispose();
  }
}

class _EducationDraftRequest {
  const _EducationDraftRequest({
    required this.type,
    required this.title,
    required this.body,
    required this.caption,
  });

  final EducationContentType type;
  final String title;
  final String? body;
  final String? caption;

  bool matches(EducationContent item) =>
      item.type == type &&
      item.title == title &&
      item.body == body &&
      item.caption == caption;

  bool samePayload(_EducationDraftRequest other) =>
      type == other.type &&
      title == other.title &&
      body == other.body &&
      caption == other.caption;
}
