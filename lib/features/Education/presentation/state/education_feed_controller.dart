import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Education/data/repositories/education_public_content_repository.dart';
import 'package:app_t/features/Education/domain/entities/public_education_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class EducationFeedController extends ChangeNotifier {
  EducationFeedController(this._source);

  final EducationPublicContentSource _source;
  final List<PublicEducationContent> _items = <PublicEducationContent>[];
  String? _nextCursor;
  String? _error;
  String? _refreshError;
  String? _loadMoreError;
  bool _loading = false;
  bool _refreshing = false;
  bool _loadingMore = false;
  bool _disposed = false;
  int _generation = 0;
  CancelToken? _listCancelToken;
  CancelToken? _pageCancelToken;
  Future<void>? _listRequest;
  Future<void>? _pageRequest;

  List<PublicEducationContent> get items =>
      List<PublicEducationContent>.unmodifiable(_items);
  String? get error => _error;
  String? get refreshError => _refreshError;
  String? get loadMoreError => _loadMoreError;
  bool get loading => _loading;
  bool get refreshing => _refreshing;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _nextCursor != null;

  Future<void> load() {
    if (_disposed) return Future<void>.value();
    final current = _listRequest;
    if (current != null) return current;
    return _startListRequest(refresh: false);
  }

  Future<void> refresh() {
    if (_disposed) return Future<void>.value();
    final current = _listRequest;
    if (current != null) return current;
    _generation++;
    _listCancelToken?.cancel('Education feed refreshed.');
    _pageCancelToken?.cancel('Education feed refreshed.');
    _listRequest = null;
    _pageRequest = null;
    _loading = _items.isEmpty;
    _refreshing = _items.isNotEmpty;
    _loadingMore = false;
    _error = null;
    _refreshError = null;
    _loadMoreError = null;
    _notify();
    return _startListRequest(refresh: _items.isNotEmpty, alreadyStarted: true);
  }

  Future<void> loadMore() {
    if (_disposed || _nextCursor == null) return Future<void>.value();
    final current = _pageRequest;
    if (current != null) return current;
    final generation = _generation;
    final cursor = _nextCursor!;
    final cancelToken = CancelToken();
    _pageCancelToken = cancelToken;
    _loadingMore = true;
    _loadMoreError = null;
    _notify();
    final request = _loadNextPage(generation, cursor, cancelToken);
    _pageRequest = request;
    return request;
  }

  Future<void> _startListRequest({
    required bool refresh,
    bool alreadyStarted = false,
  }) {
    if (!alreadyStarted) {
      _loading = !refresh;
      _refreshing = refresh;
      _error = null;
      _refreshError = null;
      _notify();
    }
    final generation = _generation;
    final cancelToken = CancelToken();
    _listCancelToken = cancelToken;
    final request = _loadFirstPage(generation, cancelToken, refresh: refresh);
    _listRequest = request;
    return request;
  }

  Future<void> _loadFirstPage(
    int generation,
    CancelToken cancelToken, {
    required bool refresh,
  }) async {
    try {
      final page = await _source.listPublic(cancelToken: cancelToken);
      if (!_isCurrent(generation)) return;
      _items
        ..clear()
        ..addAll(_deduplicate(page.items));
      _nextCursor = page.nextCursor;
      _error = null;
      _refreshError = null;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) || !_isCurrent(generation)) return;
      _setListFailure(refresh);
    } on AuthFailure catch (_) {
      if (!_isCurrent(generation)) return;
      _setListFailure(refresh);
    } catch (_) {
      if (!_isCurrent(generation)) return;
      _setListFailure(refresh);
    } finally {
      if (_isCurrent(generation)) {
        _loading = false;
        _refreshing = false;
        _listCancelToken = null;
        _listRequest = null;
        _notify();
      }
    }
  }

  Future<void> _loadNextPage(
    int generation,
    String cursor,
    CancelToken cancelToken,
  ) async {
    try {
      final page = await _source.listPublic(
        cursor: cursor,
        cancelToken: cancelToken,
      );
      if (!_isCurrent(generation)) return;
      _items.addAll(_deduplicate(page.items));
      _nextCursor = page.nextCursor;
      _loadMoreError = null;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) || !_isCurrent(generation)) return;
      _loadMoreError = 'Could not load more posts. Please retry.';
    } on AuthFailure catch (_) {
      if (!_isCurrent(generation)) return;
      _loadMoreError = 'Could not load more posts. Please retry.';
    } catch (_) {
      if (!_isCurrent(generation)) return;
      _loadMoreError = 'Could not load more posts. Please retry.';
    } finally {
      if (_isCurrent(generation)) {
        _loadingMore = false;
        _pageCancelToken = null;
        _pageRequest = null;
        _notify();
      }
    }
  }

  void _setListFailure(bool wasRefresh) {
    const message = 'Education posts are unavailable right now. Please retry.';
    if (wasRefresh && _items.isNotEmpty) {
      _refreshError = message;
    } else {
      _error = message;
    }
  }

  List<PublicEducationContent> _deduplicate(
    List<PublicEducationContent> incoming,
  ) {
    final knownIds = _items.map((item) => item.id).toSet();
    final seen = <String>{...knownIds};
    return incoming.where((item) => seen.add(item.id)).toList(growable: false);
  }

  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _listCancelToken?.cancel('Education feed closed.');
    _pageCancelToken?.cancel('Education feed closed.');
    super.dispose();
  }
}

class EducationDetailController extends ChangeNotifier {
  EducationDetailController(this._source, this.contentId);

  final EducationPublicContentSource _source;
  final String contentId;
  PublicEducationContent? _content;
  String? _error;
  String? _reportError;
  bool _loading = false;
  bool _refreshing = false;
  bool _notFound = false;
  bool _reporting = false;
  bool _reported = false;
  bool _reportRequiresSignIn = false;
  bool _disposed = false;
  int _generation = 0;
  CancelToken? _cancelToken;
  Future<void>? _request;

  PublicEducationContent? get content => _content;
  String? get error => _error;
  String? get reportError => _reportError;
  bool get loading => _loading;
  bool get refreshing => _refreshing;
  bool get notFound => _notFound;
  bool get reporting => _reporting;
  bool get reported => _reported;
  bool get reportRequiresSignIn => _reportRequiresSignIn;

  Future<void> load() {
    if (_disposed) return Future<void>.value();
    final current = _request;
    if (current != null) return current;
    return _load(refresh: false);
  }

  Future<void> refresh() {
    if (_disposed) return Future<void>.value();
    final current = _request;
    if (current != null) return current;
    _generation++;
    _cancelToken?.cancel('Education post refreshed.');
    _request = null;
    _loading = _content == null;
    _refreshing = _content != null;
    _error = null;
    _notFound = false;
    _notify();
    return _load(refresh: _content != null, alreadyStarted: true);
  }

  Future<void> report(String reason) async {
    if (_disposed || _reporting || _reported || _content == null) return;
    _reporting = true;
    _reportError = null;
    _reportRequiresSignIn = false;
    _notify();
    try {
      await _source.report(contentId: contentId, reason: reason);
      if (_disposed) return;
      _reported = true;
    } on AuthFailure catch (error) {
      if (_disposed) return;
      _reportError = error.message;
      _reportRequiresSignIn =
          error.type == AuthFailureType.unauthorized || error.statusCode == 401;
    } catch (_) {
      if (_disposed) return;
      _reportError = 'Your report could not be sent. Please try again.';
    } finally {
      if (!_disposed) {
        _reporting = false;
        _notify();
      }
    }
  }

  Future<void> _load({required bool refresh, bool alreadyStarted = false}) {
    if (!alreadyStarted) {
      _loading = !refresh;
      _refreshing = refresh;
      _error = null;
      _notFound = false;
      _notify();
    }
    final generation = _generation;
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    final request = _loadContent(generation, cancelToken, refresh: refresh);
    _request = request;
    return request;
  }

  Future<void> _loadContent(
    int generation,
    CancelToken cancelToken, {
    required bool refresh,
  }) async {
    try {
      if (contentId.trim().isEmpty || contentId.length > 128) {
        _notFound = true;
        _content = null;
      } else {
        final content = await _source.getPublic(
          contentId: contentId,
          cancelToken: cancelToken,
        );
        if (!_isCurrent(generation)) return;
        _content = content;
        _error = null;
        _notFound = false;
      }
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) || !_isCurrent(generation)) return;
      _setContentFailure(error.response?.statusCode, refresh);
    } on AuthFailure catch (error) {
      if (!_isCurrent(generation)) return;
      _setContentFailure(error.statusCode, refresh);
    } catch (_) {
      if (!_isCurrent(generation)) return;
      _setContentFailure(null, refresh);
    } finally {
      if (_isCurrent(generation)) {
        _loading = false;
        _refreshing = false;
        _cancelToken = null;
        _request = null;
        _notify();
      }
    }
  }

  void _setContentFailure(int? status, bool wasRefresh) {
    if (status == 404) {
      _notFound = true;
      _content = null;
      _error = 'This post is no longer available.';
      return;
    }
    const message = 'This post is unavailable right now. Please retry.';
    if (wasRefresh && _content != null) {
      _error = message;
    } else {
      _error = message;
      _content = null;
    }
  }

  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _cancelToken?.cancel('Education post closed.');
    super.dispose();
  }
}
